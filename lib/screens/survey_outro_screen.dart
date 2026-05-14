import 'package:flutter/material.dart';
import 'package:surveys/core/constants/colors.dart';
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
      backgroundColor: const Color(0xffe5e1de),
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 32,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
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
                "Your earnings will be credited to your account within 24 hours.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[800],
                ),
              ),

              const SizedBox(height: 16),
              _incomeCard(),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      text: "Next Survey",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      text: "Close",
                      type: ButtonType.outlined,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
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

  Widget _incomeCard() {
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
                      Text(
                        '$reward',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'DT',
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
                    'Will be credited to your account within 24 hours',
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
