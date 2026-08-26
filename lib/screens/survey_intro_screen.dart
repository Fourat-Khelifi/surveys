import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/core/constants/enums.dart';
import 'package:surveys/core/models/survey.dart';
import 'package:surveys/screens/survey_screen.dart';
import 'package:surveys/services/survey_service.dart';
import 'package:surveys/shared/widgets/button.dart';
import 'package:surveys/shared/widgets/app_bar.dart';
import 'package:surveys/shared/widgets/slide_route.dart';

class SurveyIntroScreen extends StatefulWidget {
  const SurveyIntroScreen({super.key, required this.surveyId});

  final String surveyId;

  @override
  State<SurveyIntroScreen> createState() => _SurveyIntroScreenState();
}

class _SurveyIntroScreenState extends State<SurveyIntroScreen> {
  final client = Supabase.instance.client;
  late final SurveyService _service;
  Survey? survey;
  bool isLoading = true;
  bool _loadFailed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchSurvey();
  }

  Future<void> fetchSurvey() async {
    _service = SurveyService();

    if (mounted) {
      setState(() {
        isLoading = true;
        _loadFailed = false;
        _error = null;
      });
    }

    try {
      survey = await _service.fetchSurvey(widget.surveyId);
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching survey: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
        _loadFailed = true;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_loadFailed || survey == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Couldn't load this survey",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Check your connection and try again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textSubtle),
                  ),
                  // "Check your connection" is a guess, and often a wrong one —
                  // a schema mismatch or an RLS refusal looks identical to the
                  // user. Show what actually failed while developing.
                  if (kDebugMode && _error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSubtle,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(text: "Try again", onPressed: fetchSurvey),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: "Go back",
                      type: ButtonType.outlined,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              Text(
                survey!.title,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(survey!.description, style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 24),

              Row(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monetization_on_outlined),
                      const SizedBox(width: 4),
                      Text(
                        survey!.reward.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Row(
                    children: [
                      const Icon(Icons.timelapse),
                      const SizedBox(width: 4),
                      Text(
                        "${survey!.duration} min",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: "Start Survey",
                  onPressed: () {
                    Navigator.push(
                      context,
                      slideTo(SurveyScreen(surveyId: survey!.id)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
