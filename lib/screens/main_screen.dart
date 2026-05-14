import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:surveys/core/models/survey.dart';
import 'package:surveys/screens/survey_intro_screen.dart';
import 'package:surveys/services/auth_service.dart';
import 'package:surveys/services/survey_service.dart';
import 'package:surveys/shared/widgets/app_bar.dart';
import 'package:surveys/shared/widgets/survey_card.dart';
import 'package:flutter/widget_previews.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool showAvailable = true;
  late final SurveyService _surveyService;
  late final AuthService _authService;
  late final User? _user = _authService.currentUser;
  List<Survey> surveysAvailable = [];
  List<Survey> surveysCompleted = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _surveyService = SurveyService();
    _authService = AuthService();
    fetchAvailableSurveys();
    fetchCompletedSurveys();
  }

  @override
  Widget build(BuildContext context) {
    final displayedSurveys = showAvailable
        ? surveysAvailable
        : surveysCompleted;

    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: const Color(0xffe5e1de),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Center(
              child: Column(
                children: [
                  _buildIncomeCard(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showAvailable = true;
                                  });
                                },
                                child: Text(
                                  'Available (${surveysAvailable.length})',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: showAvailable
                                        ? Colors.black
                                        : Colors.grey[500],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showAvailable = false;
                                  });
                                },
                                child: Text(
                                  'Completed (${surveysCompleted.length})',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: !showAvailable
                                        ? Colors.black
                                        : Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (var survey in displayedSurveys)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: AppSurveyCard(
                                  title: survey.title,
                                  duration: survey.duration,
                                  reward: survey.reward,
                                  onTap: showAvailable
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => SurveyIntroScreen(
                                                surveyId: survey.id,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                ),
                              ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchAvailableSurveys() async {
    try {
      final surveys = await _surveyService.fetchAvailableSurveys(_user!.id);

      if (!mounted) return;

      setState(() {
        surveysAvailable = surveys;
        isLoading = false;
      });

      debugPrint("Available surveys fetched: ${surveysAvailable.length}");
    } catch (e) {
      debugPrint("UI Error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCompletedSurveys() async {
    try {
      final surveys = await _surveyService.fetchCompletedSurveys(_user!.id);

      if (!mounted) return;

      setState(() {
        surveysCompleted = surveys;
        isLoading = false;
      });

      debugPrint("Completed surveys fetched: ${surveysCompleted.length}");
    } catch (e) {
      debugPrint("UI Error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildIncomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xffd5cfcc),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome back ${_user != null ? (_user.userMetadata?['display_name'] ?? 'User') : 'Guest'}!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Icon(Icons.settings, size: 28, color: Colors.black),
                ],
              ),
              SizedBox(height: 2),
              Text(
                'Start earning with surveys',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total earnings',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: Offset(-8, 0),
                    child: Icon(
                      Icons.monetization_on_outlined,
                      size: 72,
                      color: Colors.black,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(-8, 0),
                    child: Text(
                      '120',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Main Screen')
Widget mainScreenPreview() {
  return MainScreen();
}
