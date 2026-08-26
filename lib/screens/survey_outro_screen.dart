import 'package:flutter/material.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/core/constants/motion.dart';
import 'package:surveys/core/constants/enums.dart';
import 'package:surveys/screens/main_screen.dart';
import 'package:surveys/shared/widgets/button.dart';
import 'package:surveys/shared/widgets/app_bar.dart';

class SurveyOutroScreen extends StatelessWidget {
  const SurveyOutroScreen({super.key, required this.reward});
  final int reward;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 32,
                    ),
                    onPressed: () => _goToMain(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Survey Completed!",
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Your points have been added to your balance.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[800],
                ),
              ),

              const SizedBox(height: 16),
              _incomeCard(context),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      text: "Next Survey",
                      onPressed: () => _goToMain(context),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      text: "Close",
                      type: ButtonType.outlined,
                      onPressed: () => _goToMain(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToMain(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  Widget _incomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.atomictangerine,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'You earned',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      // Counting up to the reward instead of printing it is the
                      // one flourish in the app. It earns its place here: this
                      // is the moment the user is being paid, and a number
                      // that lands rather than appears is what makes it feel
                      // like a reward rather than a receipt.
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: reward.toDouble()),
                        duration: AppMotion.of(context, AppMotion.slow),
                        curve: AppMotion.enter,
                        builder: (context, value, _) => Text(
                          value.round().toString(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1,
                            // Digits change width as they count; tabular
                            // figures stop the label jittering as it climbs.
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'points',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Added to your balance',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w400,
                      height: 1.5,
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
