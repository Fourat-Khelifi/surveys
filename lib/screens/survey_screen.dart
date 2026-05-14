import 'package:flutter/material.dart';
import 'package:surveys/core/constants/enums.dart';
import 'package:surveys/core/models/question.dart';
import 'package:surveys/core/models/survey.dart';
import 'package:surveys/screens/survey_outro_screen.dart';
import 'package:surveys/services/survey_service.dart';
import 'package:surveys/shared/questions/long_text_question.dart';
import 'package:surveys/shared/questions/multi_choice_question.dart';
import 'package:surveys/shared/questions/short_text_question.dart';
import 'package:surveys/shared/questions/single_choice_question.dart';
import 'package:surveys/shared/questions/slider_question.dart';
import 'package:surveys/shared/widgets/button.dart';
import 'package:flutter/widget_previews.dart';
import 'package:surveys/shared/widgets/app_bar.dart';
import 'package:surveys/shared/widgets/icon_button.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

bool isTextType(QuestionType type) {
  const textTypes = {
    QuestionType.shortText,
    QuestionType.longText,
    QuestionType.number,
    QuestionType.decimal,
    QuestionType.email,
    QuestionType.phone,
  };
  return textTypes.contains(type);
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key, required this.surveyId});

  final String surveyId;

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  // ── State ────────────────────────────────────────────────────────────────

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _answers = {};
  late final SurveyService _service;

  Survey? _survey;
  List<Question> _questions = [];
  int _currentStep = 0;
  bool _isLoading = true;

  int get _totalQuestions => _questions.length;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _service = SurveyService();
    _fetchSurveyWithQuestions();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // ── Data fetching ────────────────────────────────────────────────────────

  Future<void> _fetchSurveyWithQuestions() async {
    try {
      final survey = await _service.fetchSurveyWithQuestions(widget.surveyId);
      if (!mounted) return;

      for (final q in survey.questions ?? []) {
        if (isTextType(q.type)) {
          _controllers[q.id] = TextEditingController();
        }
      }
      setState(() {
        _survey = survey;
        _questions = survey.questions ?? [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching survey with questions: $e");
    }
  }

  // ── Answer management ────────────────────────────────────────────────────

  void _saveCurrentAnswer() {
    final q = _questions[_currentStep];

    final controller = _controllers[q.id];
    if (controller == null) return;

    final text = controller.text;
    if (text.isEmpty) {
      _answers.remove(q.id);
      return;
    }

    switch (q.type) {
      case QuestionType.number:
        _answers[q.id] = int.tryParse(text);
      case QuestionType.decimal:
        _answers[q.id] = double.tryParse(text);
      default:
        _answers[q.id] = text;
    }
  }

  void _restoreControllerForStep(int step) {
    final q = _questions[step];
    final controller = _controllers[q.id];
    if (controller == null) return;

    final stored = _answers[q.id]?.toString() ?? '';
    if (controller.text != stored) {
      controller.text = stored;
    }
  }

  // ── Navigation ───────────────────────────────────────────────────────────

  void _nextStep() {
    _saveCurrentAnswer();

    if (_currentStep < _totalQuestions - 1) {
      setState(() => _currentStep++);
    } else {
      _submitSurvey();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _saveCurrentAnswer();
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  // ── Submission ───────────────────────────────────────────────────────────

  Future<void> _submitSurvey() async {
    debugPrint('Collected answers: $_answers');

    try {
      await _service.submitSurvey(
        _survey!.id,
        "11111111-1111-1111-1111-111111111111",
        _answers,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SurveyOutroScreen(reward: _survey!.reward),
        ),
      );
    } catch (e) {
      debugPrint("Submit error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to submit survey")));
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _survey == null) {
      return const Scaffold(
        backgroundColor: Color(0xffe5e1de),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    _restoreControllerForStep(_currentStep);
    final question = _questions[_currentStep];

    return Scaffold(
      backgroundColor: const Color(0xffe5e1de),
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildQuestionContent(question),
                ),
              ),
              _buildNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Question widgets ─────────────────────────────────────────────────────

  Widget _buildQuestionContent(Question question) {
    final controller = _controllers[question.id];

    switch (question.type) {
      case QuestionType.shortText:
        return ShortTextQuestionWidget(
          key: ValueKey(question.id),
          question: question,
          controller: controller!,
        );
      case QuestionType.number:
        return ShortTextQuestionWidget(
          key: ValueKey(question.id),
          question: question,
          controller: controller!,
          inputType: ShortTextInputType.number,
        );
      case QuestionType.decimal:
        return ShortTextQuestionWidget(
          key: ValueKey(question.id),
          question: question,
          controller: controller!,
          inputType: ShortTextInputType.decimal,
        );
      case QuestionType.email:
        return ShortTextQuestionWidget(
          key: ValueKey(question.id),
          question: question,
          controller: controller!,
          inputType: ShortTextInputType.email,
        );
      case QuestionType.phone:
        return ShortTextQuestionWidget(
          key: ValueKey(question.id),
          question: question,
          controller: controller!,
          inputType: ShortTextInputType.phone,
        );
      case QuestionType.longText:
        return LongTextQuestionWidget(
          key: ValueKey(question.id),
          question: question,
          controller: controller!,
        );
      case QuestionType.singleChoice:
        return SingleChoiceQuestion(
          key: ValueKey(question.id),
          title: question.title,
          op: question.options,
          selectedValue: _answers[question.id],
          onChanged: (value) => setState(() => _answers[question.id] = value),
        );
      case QuestionType.multiChoice:
        return MultiChoiceQuestion(
          key: ValueKey(question.id),
          title: question.title,
          op: question.options,
          selectedValues: _answers[question.id] as Set<String>? ?? {},
          onChanged: (value) => setState(() => _answers[question.id] = value),
        );
      case QuestionType.slider:
        return SliderQuestionWidget(
          key: ValueKey(question.id),
          question: question,
          value:
              _answers[question.id] as double? ??
              (question.min ?? 0).toDouble(),
          onChanged: (value) => setState(() => _answers[question.id] = value),
        );
      default:
        return const Text('Unsupported question type');
    }
  }

  // ── Sub-widgets ──────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _survey!.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Question ${_currentStep + 1}/$_totalQuestions'
          ' (${((_currentStep + 1) / _totalQuestions * 100).toStringAsFixed(0)}%)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildProgressBar(),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentStep + 1) / _totalQuestions,
          minHeight: 4,
          backgroundColor: Colors.grey[400],
          color: Colors.black,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNavigation() {
    return Row(
      children: [
        AppIconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousStep,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppButton(
            text: _currentStep == _totalQuestions - 1 ? 'Finish' : 'Next',
            onPressed: _nextStep,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Preview
// ---------------------------------------------------------------------------

@Preview(name: 'Survey Page')
Widget surveyPagePreview() => const SurveyScreen(surveyId: 'sample-survey-id');
