import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:surveys/core/constants/enums.dart';
import 'package:surveys/core/models/question.dart';
import 'package:surveys/core/models/survey.dart';
import 'package:surveys/core/models/survey_submission.dart';

class SurveyService {
  final SupabaseClient _client = Supabase.instance.client;

  SurveyService();

  /// Surveys the signed-in user has not yet completed.
  ///
  /// Asks for a real question count alongside each survey row.
  ///
  /// `surveys.length` is authored by hand and is not reliable — one survey
  /// claims six questions and has none. The count is aliased so it does not
  /// collide with the `questions` key [Survey.fromJson] parses, and it costs
  /// nothing: PostgREST computes it in the same round trip.
  static const _availableSelect = '*, question_count:questions(count)';

  Future<List<Survey>> fetchAvailableSurveys() async {
    try {
      final data = await _client
          .rpc('get_available_surveys')
          .select(_availableSelect);
      return _mapSurveys(data);
    } catch (e) {
      debugPrint("Error fetching available surveys: $e");
      rethrow;
    }
  }

  /// Drops surveys that have no questions before they can reach the UI.
  ///
  /// Opening one used to be a `RangeError`; it is now a dead end that says
  /// "not ready yet". Neither belongs in a list of things you can earn from.
  List<Survey> _mapSurveys(dynamic data) {
    return (data as List<dynamic>)
        .where((json) => _questionCount(json) != 0)
        .map((json) => Survey.fromJson(json))
        .toList();
  }

  /// `question_count` arrives as `[{"count": 6}]`. Returns null when the key is
  /// absent, so an unexpected shape lets the survey through rather than hiding
  /// every survey in the list.
  int? _questionCount(dynamic json) {
    final raw = json['question_count'];
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      return (raw.first['count'] as num?)?.toInt();
    }
    return null;
  }

  /// Surveys the signed-in user has already completed, newest first.
  ///
  /// The `user_id` filter is explicit on purpose. RLS should also enforce it,
  /// but it is not enabled on this project yet — without the filter this
  /// returns every user's responses.
  Future<List<Survey>> fetchCompletedSurveys() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await _client
          .from('survey_responses')
          .select('survey:surveys(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List<dynamic>)
          .where((json) => json['survey'] != null)
          .map((json) => Survey.fromJson(json['survey']))
          .toList();
    } catch (e) {
      debugPrint("Error fetching completed surveys: $e");
      rethrow;
    }
  }

  /// The signed-in user's points balance.
  ///
  /// Derived by summing the reward of every survey the user has completed
  /// rather than read from a stored counter. Nothing has to stay in sync, and
  /// there is no balance column for a client to tamper with — the completed
  /// responses *are* the ledger.
  ///
  /// [pointsFrom] does the same arithmetic on a list you already hold, which
  /// is what the home screen uses to avoid a second round trip.
  Future<int> fetchPointsBalance() async {
    return pointsFrom(await fetchCompletedSurveys());
  }

  static int pointsFrom(List<Survey> completed) =>
      completed.fold(0, (total, survey) => total + survey.reward);

  Future<Survey> fetchSurvey(String surveyId) async {
    try {
      final data = await _client
          .from('surveys')
          .select()
          .eq('id', surveyId)
          .single();
      return Survey.fromJson(data);
    } catch (e) {
      debugPrint("Error fetching survey: $e");
      rethrow;
    }
  }

  /// A survey with its questions and each question's options.
  ///
  /// Ordering matters: without it Postgres returns embedded rows in planner
  /// order, so questions and choice options shuffle between loads.
  Future<Survey> fetchSurveyWithQuestions(String surveyId) async {
    const select = '*, questions(*, options(*))';

    try {
      final data = await _client
          .from('surveys')
          .select(select)
          .eq('id', surveyId)
          .order('order_index', referencedTable: 'questions')
          .order('order_index', referencedTable: 'questions.options')
          .single();

      return Survey.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching survey with questions: $e');
      rethrow;
    }
  }

  /// Submits a completed survey via the `submit_survey` RPC.
  ///
  /// The RPC does the whole thing in one database transaction with
  /// server-side validation.
  Future<SurveySubmission> submitSurvey({
    required String surveyId,
    required List<Question> questions,
    required Map<String, dynamic> answers,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const SubmitSurveyFailure(
        SubmitSurveyError.notAuthenticated,
        "Your session expired. Please sign in again.",
      );
    }

    final payload = _buildAnswerPayload(questions, answers);

    try {
      final data = await _client.rpc(
        'submit_survey',
        params: {'p_survey_id': surveyId, 'p_answers': payload},
      );
      return SurveySubmission.fromJson(Map<String, dynamic>.from(data as Map));
    } on PostgrestException catch (e) {
      debugPrint("Error submitting survey: ${e.code} ${e.message}");
      throw SubmitSurveyFailure.fromPostgrest(e);
    }
  }

  /// Turns the screen's `{questionId: value}` map into the array
  /// `submit_survey` expects.
  ///
  /// The value column is chosen from the question's declared type, never from
  /// the runtime type of the value — that is what used to route single-choice
  /// option ids into `text_answer`, since an option id is a String just like a
  /// free-text answer is.
  List<Map<String, dynamic>> _buildAnswerPayload(
    List<Question> questions,
    Map<String, dynamic> answers,
  ) {
    final payload = <Map<String, dynamic>>[];

    for (final question in questions) {
      final value = answers[question.id];
      if (value == null) continue;

      final entry = <String, dynamic>{'question_id': question.id};

      switch (question.type) {
        case QuestionType.shortText:
        case QuestionType.longText:
        case QuestionType.email:
        case QuestionType.phone:
          final text = (value as String).trim();
          if (text.isEmpty) continue;
          entry['text_answer'] = text;

        case QuestionType.number:
        case QuestionType.decimal:
        case QuestionType.slider:
          if (value is! num) continue;
          entry['number_answer'] = value;

        case QuestionType.singleChoice:
          entry['option_id'] = value as String;

        case QuestionType.multiChoice:
          final ids = value is Set ? value.toList() : value as List;
          if (ids.isEmpty) continue;
          entry['option_ids'] = ids.map((id) => id.toString()).toList();
      }

      payload.add(entry);
    }

    return payload;
  }
}

/// The failures `submit_survey` raises, mapped to something showable.
///
/// Mirrors [describeAuthError] in AuthService: the database is the single
/// source of truth for what went wrong, and the UI layer never has to parse
/// Postgres error strings itself.
enum SubmitSurveyError {
  notAuthenticated,
  surveyNotFound,
  alreadySubmitted,
  missingRequiredAnswers,
  invalidAnswer,
  unknown,
}

class SubmitSurveyFailure implements Exception {
  final SubmitSurveyError error;
  final String message;

  const SubmitSurveyFailure(this.error, this.message);

  /// True when retrying the same submission cannot possibly help.
  bool get isTerminal =>
      error == SubmitSurveyError.alreadySubmitted ||
      error == SubmitSurveyError.surveyNotFound;

  factory SubmitSurveyFailure.fromPostgrest(PostgrestException e) {
    final raw = e.message;

    if (raw.contains('not_authenticated')) {
      return const SubmitSurveyFailure(
        SubmitSurveyError.notAuthenticated,
        "Your session expired. Please sign in again.",
      );
    }
    if (raw.contains('already_submitted')) {
      return const SubmitSurveyFailure(
        SubmitSurveyError.alreadySubmitted,
        "You've already completed this survey.",
      );
    }
    if (raw.contains('survey_not_found')) {
      return const SubmitSurveyFailure(
        SubmitSurveyError.surveyNotFound,
        "This survey is no longer available.",
      );
    }
    if (raw.contains('missing_required_answers')) {
      return const SubmitSurveyFailure(
        SubmitSurveyError.missingRequiredAnswers,
        "Some required questions are still unanswered.",
      );
    }
    if (raw.contains('question_not_in_survey') ||
        raw.contains('invalid_option') ||
        raw.contains('malformed_payload')) {
      return const SubmitSurveyFailure(
        SubmitSurveyError.invalidAnswer,
        "We couldn't read your answers. Please try again.",
      );
    }

    return const SubmitSurveyFailure(
      SubmitSurveyError.unknown,
      "Couldn't submit your answers. Check your connection and try again.",
    );
  }

  @override
  String toString() => message;
}
