import 'package:flutter/material.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/core/models/survey.dart';
import 'package:surveys/core/models/user_profile.dart';
import 'package:surveys/screens/profile_screen.dart';
import 'package:surveys/screens/survey_intro_screen.dart';
import 'package:surveys/services/auth_service.dart';
import 'package:surveys/services/survey_service.dart';
import 'package:surveys/shared/widgets/app_bar.dart';
import 'package:surveys/shared/widgets/slide_route.dart';
import 'package:surveys/shared/widgets/fade_slide_in.dart';
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
  List<Survey> surveysAvailable = [];
  List<Survey> surveysCompleted = [];
  int? pointsBalance;
  UserProfile? profile;
  bool isLoading = true;
  bool loadFailed = false;

  /// Which tab has already played its entrance stagger, so switching between
  /// Available and Completed doesn't re-run the full list animation every time.
  final Set<bool> _staggeredFor = {};

  @override
  void initState() {
    super.initState();
    _surveyService = SurveyService();
    _authService = AuthService();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    final displayedSurveys = showAvailable
        ? surveysAvailable
        : surveysCompleted;

    return Scaffold(
      appBar: const CustomAppBar(showCloseButton: false),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < 0 && showAvailable) {
              // Swipe left → completed
              _setTab(false);
            } else if (velocity > 0 && !showAvailable) {
              // Swipe right → available
              _setTab(true);
            }
          },
          child: RefreshIndicator(
            onRefresh: refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildIncomeCard()),
                SliverToBoxAdapter(child: const SizedBox(height: 16)),
                SliverToBoxAdapter(child: _buildTabs()),
                _buildSurveyList(displayedSurveys),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Reloads everything the home screen shows.
  ///
  /// The two reads are independent and may fail independently, so one problem
  /// cannot blank the whole screen. The points balance is not a third request:
  /// it is the sum of the rewards of the completed surveys we just fetched, so
  /// the number on screen can never disagree with the list below it.
  Future<void> refresh() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    // Started together so they overlap, awaited separately so a failure in one
    // does not cancel the other.
    final availableRequest = _guard(
      _surveyService.fetchAvailableSurveys(),
      'available surveys',
    );
    final completedRequest = _guard(
      _surveyService.fetchCompletedSurveys(),
      'completed surveys',
    );
    // The greeting reads from `profiles`, not auth metadata — the table is the
    // source of truth, so a rename on the profile screen shows up here too.
    final profileRequest = _guard(_authService.fetchProfile(), 'profile');

    final available = await availableRequest;
    final completed = await completedRequest;
    final fetchedProfile = await profileRequest;

    if (!mounted) return;

    setState(() {
      profile = fetchedProfile ?? profile;
      surveysAvailable = available ?? surveysAvailable;
      surveysCompleted = completed ?? surveysCompleted;
      pointsBalance = completed == null
          ? pointsBalance
          : SurveyService.pointsFrom(completed);
      isLoading = false;
      loadFailed = available == null && completed == null;
    });
  }

  Future<T?> _guard<T>(Future<T> request, String label) async {
    try {
      return await request;
    } catch (e) {
      debugPrint("Home: $label failed — $e");
      return null;
    }
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _setTab(true),
            child: Text(
              'Available (${surveysAvailable.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: showAvailable ? Colors.black : Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _setTab(false),
            child: Text(
              'Completed (${surveysCompleted.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: !showAvailable ? Colors.black : Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setTab(bool showAvailable) {
    if (this.showAvailable == showAvailable) return;
    // Mark the tab we're leaving as already staggered, so coming back to it
    // later doesn't replay the whole list entrance.
    _staggeredFor.add(this.showAvailable);
    setState(() => this.showAvailable = showAvailable);
  }

  Widget _buildSurveyList(List<Survey> surveys) {
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (loadFailed) {
      return SliverToBoxAdapter(
        child: _buildNotice(
          "Couldn't load your surveys.",
          "Check your connection and pull down to try again.",
        ),
      );
    }

    if (surveys.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildNotice(
          showAvailable
              ? "Nothing available right now"
              : "No completed surveys yet",
          showAvailable
              ? "You've finished everything we have. Check back soon."
              : "Finish a survey and it'll show up here.",
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _staggeredFor.contains(showAvailable)
              // Already played this tab's entrance — drop the wrapper entirely
              // so a remount doesn't re-animate or waste a controller.
              ? _surveyItem(surveys, index)
              : Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: FadeSlideIn(
                    // Capped so a long list still finishes arriving quickly —
                    // past the first handful the stagger has already done it.
                    delay: Duration(
                      milliseconds: 60 * (index.clamp(0, 5)),
                    ),
                    child: _surveyItem(surveys, index),
                  ),
                ),
          childCount: surveys.length,
        ),
      ),
    );
  }

  Widget _surveyItem(List<Survey> surveys, int index) {
    final survey = surveys[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppSurveyCard(
        title: survey.title,
        duration: survey.duration,
        reward: survey.reward,
        onTap: showAvailable ? () => _openSurvey(survey) : null,
      ),
    );
  }

  Widget _buildNotice(String title, String body) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  /// Opens a survey and reloads on return, so a completed survey moves to the
  /// Completed tab and the balance reflects the reward that was just paid.
  Future<void> _openSurvey(Survey survey) async {
    await Navigator.push(
      context,
      slideTo(SurveyIntroScreen(surveyId: survey.id)),
    );
    if (!mounted) return;
    await refresh();
  }

  Widget _buildIncomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
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
                    profile == null
                        ? 'Welcome back!'
                        : 'Welcome back ${profile!.firstName}!',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, slideTo(const ProfileScreen()));
                    },
                    child: const Icon(
                      Icons.settings,
                      size: 28,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Text(
                'Answer surveys, collect points',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total points',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(height: 1.5),
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
                      pointsBalance?.toString() ?? '—',
                      style: Theme.of(
                        context,
                      ).textTheme.displayLarge?.copyWith(height: 1),
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
