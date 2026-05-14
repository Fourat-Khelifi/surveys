import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:surveys/core/models/survey.dart';

class SurveyService {
  final SupabaseClient _client = Supabase.instance.client;

  SurveyService();

  Future<List<Survey>> fetchAvailableSurveys(String userId) async {
    try {
      final data = await _client.rpc(
        'get_available_surveys',
        params: {'p_user_id': userId},
      );

      return (data as List<dynamic>)
          .map((json) => Survey.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint("Error fetching available surveys: $e");
      rethrow;
    }
  }

  Future<List<Survey>> fetchCompletedSurveys(String userId) async {
    try {
      final data = await _client
          .from('survey_responses')
          .select('*, survey:surveys(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List<dynamic>)
          .map((json) => Survey.fromJson(json['survey']))
          .toList();
    } catch (e) {
      debugPrint("Error fetching completed surveys: $e");
      rethrow;
    }
  }

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

  Future<Survey> fetchSurveyWithQuestions(String surveyId) async {
    try {
      final data = await _client
          .from('surveys')
          .select('*, questions(*, options(*))')
          .eq('id', surveyId)
          .single();

      final survey = Survey.fromJson(data);
      return survey;
    } catch (e) {
      debugPrint('Error fetching survey with questions: $e');
      rethrow;
    }
  }

  Future<void> submitSurvey(
    String surveyId,
    String userId,
    Map<String, dynamic> answers,
  ) async {
    try {
      final response = await _client
          .from('survey_responses')
          .insert({'survey_id': surveyId, 'user_id': userId})
          .select()
          .single();

      final responseId = response['id'];

      debugPrint("Created response: $responseId");

      final List<Map<String, dynamic>> answersToInsert = [];

      for (var entry in answers.entries) {
        final questionId = entry.key;
        final value = entry.value;

        debugPrint("Answer for $questionId: $value");

        final answerData = {
          'response_id': responseId,
          'question_id': questionId,
        };

        if (value is String) {
          answerData['text_answer'] = value;
        } else if (value is num) {
          answerData['number_answer'] = value;
        } else if (value is int) {
          answerData['option_id'] = value;
        } else if (value is Set) {
          answerData['option_ids'] = value.toList();
        } else if (value is List) {
          answerData['option_ids'] = value;
        }

        answersToInsert.add(answerData);
      }

      if (answersToInsert.isNotEmpty) {
        await _client.from('answers').insert(answersToInsert);
      }

      debugPrint("Survey submitted successfully");
    } catch (e) {
      debugPrint("Error submitting survey: $e");
      rethrow;
    }
  }
}
