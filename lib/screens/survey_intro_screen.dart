import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:surveys/core/models/survey.dart';
import 'package:surveys/screens/survey_screen.dart';
import 'package:surveys/services/survey_service.dart';
import 'package:surveys/shared/widgets/button.dart';
import 'package:surveys/shared/widgets/app_bar.dart';

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

  @override
  void initState() {
    super.initState();
    fetchSurvey();
  }

  Future<void> fetchSurvey() async {
    _service = SurveyService();

    try {
      survey = await _service.fetchSurvey(widget.surveyId);
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching survey: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || survey == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xffe5e1de),
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
                      MaterialPageRoute(
                        builder: (_) => SurveyScreen(surveyId: survey!.id),
                      ),
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
