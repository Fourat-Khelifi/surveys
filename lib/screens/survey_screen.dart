import 'package:flutter/material.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/core/constants/motion.dart';
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
  bool _isSubmitting = false;
  bool _loadFailed = false;

  /// +1 when moving forward, -1 when going back. Drives which way the question
  /// slides, so Back visibly reverses Next rather than repeating it.
  int _stepDirection = 1;

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
        if (QuestionTypeExtension.isText(q.type)) {
          final controller = TextEditingController();
          controller.addListener(() {
            if (mounted) setState(() {});
          });
          _controllers[q.id] = controller;
        } else if (q.type == QuestionType.slider) {
          _answers[q.id] = (q.min ?? 0).toDouble();
        }
      }
      setState(() {
        _survey = survey;
        _questions = survey.questions ?? [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching survey with questions: $e");

      if (!mounted) return;

      // Without this the spinner spins forever on any network failure.
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
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

  // ── Validation ──────────────────────────────────────────────────────────

  bool _validateCurrentStep() {
    final q = _questions[_currentStep];
    if (!q.isRequired) return true;

    switch (q.type) {
      case QuestionType.shortText:
      case QuestionType.longText:
      case QuestionType.number:
      case QuestionType.decimal:
      case QuestionType.email:
      case QuestionType.phone:
        final controller = _controllers[q.id];
        if (controller == null || controller.text.trim().isEmpty) return false;
      case QuestionType.singleChoice:
        if (_answers[q.id] == null) return false;
      case QuestionType.multiChoice:
        final selected = _answers[q.id];
        if (selected == null) return false;
        if (selected is Set && selected.isEmpty) return false;
      case QuestionType.slider:
        // Slider always has a value (default min).
        break;
    }
    return true;
  }

  // ── Navigation ───────────────────────────────────────────────────────────

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Leave survey?"),
        content: const Text(
          "Your progress will be lost. Are you sure you want to leave?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Stay"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("Leave"),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    _saveCurrentAnswer();

    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer this question before continuing.'),
        ),
      );
      return;
    }

    if (_currentStep < _totalQuestions - 1) {
      setState(() {
        _stepDirection = 1;
        _currentStep++;
      });
    } else {
      _submitSurvey();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _saveCurrentAnswer();
      setState(() {
        _stepDirection = -1;
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  // ── Submission ───────────────────────────────────────────────────────────

  Future<void> _submitSurvey() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final result = await _service.submitSurvey(
        surveyId: _survey!.id,
        questions: _questions,
        answers: _answers,
      );

      if (!mounted) return;

      // Replace rather than push: the survey is submitted, so Back must not
      // return to the last question of it.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SurveyOutroScreen(reward: result.reward),
        ),
      );
    } on SubmitSurveyFailure catch (failure) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          // The answers are still in _answers, so retrying costs the user
          // nothing — except where retrying cannot possibly work.
          action: failure.isTerminal
              ? null
              : SnackBarAction(label: 'Retry', onPressed: _submitSurvey),
        ),
      );
    } catch (e) {
      debugPrint("Submit error: $e");

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Couldn't submit your answers."),
          action: SnackBarAction(label: 'Retry', onPressed: _submitSurvey),
        ),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadFailed || _survey == null) {
      return _buildMessageScaffold(
        "Couldn't load this survey",
        "Check your connection and try again.",
      );
    }

    // A survey row can exist with no questions attached — the `length` column
    // is not always in step with the questions table. Guard rather than let
    // _questions[_currentStep] throw a RangeError.
    if (_questions.isEmpty) {
      return _buildMessageScaffold(
        "This survey isn't ready yet",
        "It has no questions attached. Please try another one.",
      );
    }

    final question = _questions[_currentStep];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmExit();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppMotion.of(context, AppMotion.base),
                    switchInCurve: AppMotion.enter,
                    switchOutCurve: AppMotion.standard,
                    // Default is a crossfade in place, which reads as a flicker
                    // when both children are text on the same background. A
                    // small horizontal slide gives the step a direction.
                    transitionBuilder: (child, animation) {
                      final entering = child.key == ValueKey<int>(_currentStep);
                      final offset = entering
                          ? _stepDirection * 0.12
                          : _stepDirection * -0.12;
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(offset, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    // Sizing the outgoing child out of the layout stops a tall
                    // question from stretching the scroll view while a short
                    // one fades in behind it.
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        ...previous.map(
                          (c) =>
                              Positioned.fill(child: IgnorePointer(child: c)),
                        ),
                        ?current,
                      ],
                    ),
                    child: SingleChildScrollView(
                      key: ValueKey<int>(_currentStep),
                      child: _buildQuestionContent(question),
                    ),
                  ),
                ),
                _buildNavigation(),
              ],
            ),
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
        if ((question.options ?? []).isEmpty) {
          return _buildBrokenQuestion(question);
        }
        return SingleChoiceQuestion(
          key: ValueKey(question.id),
          title: question.title,
          description: question.description,
          op: question.options,
          selectedValue: _answers[question.id],
          onChanged: (value) => setState(() => _answers[question.id] = value),
        );
      case QuestionType.multiChoice:
        if ((question.options ?? []).isEmpty) {
          return _buildBrokenQuestion(question);
        }
        return MultiChoiceQuestion(
          key: ValueKey(question.id),
          title: question.title,
          description: question.description,
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
    }
  }

  /// A choice question whose options were never authored. Rendering the empty
  /// list would just show the title over blank space, leaving the user to
  /// wonder what to tap.
  Widget _buildBrokenQuestion(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.title,
          style: Theme.of(context).textTheme.titleLarge,
          softWrap: true,
        ),
        const SizedBox(height: 12),
        Text(
          "This question has no answers to choose from yet. Skip it with Next.",
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSubtle),
        ),
      ],
    );
  }

  Widget _buildMessageScaffold(String title, String body) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSubtle),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: "Go back",
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: AppMotion.of(context, AppMotion.quick),
          child: Text(
            'Question ${_currentStep + 1}/$_totalQuestions'
            ' (${((_currentStep + 1) / _totalQuestions * 100).toStringAsFixed(0)}%)',
            key: ValueKey<int>(_currentStep),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        _buildProgressBar(),
      ],
    );
  }

  Widget _buildProgressBar() {
    final target = (_currentStep + 1) / _totalQuestions;

    return Column(
      children: [
        // Tweening the value rather than setting it makes the bar travel to the
        // new step instead of jumping, which is what sells the sense of
        // progress through a long survey.
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: target),
          duration: AppMotion.of(context, AppMotion.base),
          curve: AppMotion.standard,
          builder: (context, value, _) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.disabled,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNavigation() {
    final canProceed = !_isSubmitting && _validateCurrentStep();

    return Row(
      children: [
        AppIconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting ? null : _previousStep,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppButton(
            text: _isSubmitting
                ? 'Submitting...'
                : (_currentStep == _totalQuestions - 1 ? 'Finish' : 'Next'),
            onPressed: canProceed ? _nextStep : null,
            enabled: canProceed,
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
