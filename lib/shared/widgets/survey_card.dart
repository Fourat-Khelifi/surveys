import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:surveys/core/constants/colors.dart';

class AppSurveyCard extends StatelessWidget {
  final String title;
  final int duration;
  final int reward;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;

  const AppSurveyCard({
    super.key,
    required this.title,
    required this.duration,
    required this.reward,
    this.onTap,
    this.backgroundColor,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _pickCardColor(duration: duration),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 24,
                    color: Colors.black54,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on_outlined,
                        size: 24,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reward.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timelapse,
                        size: 24,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$duration min",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _pickCardColor({required int duration}) {
    if (duration <= 5) {
      return AppColors.lightcyan;
    } else if (duration <= 10) {
      return AppColors.pacificblue;
    } else if (duration <= 15) {
      return AppColors.evergreen;
    } else if (duration <= 20) {
      return AppColors.atomictangerine;
    } else {
      return AppColors.burnttangerine;
    }
  }
}

@Preview(name: 'Survey card')
Widget surveyCardPreview() {
  return Column(
    children: [
      AppSurveyCard(
        title: 'Customer Satisfaction Survey',
        duration: 150,
        reward: 2,
        backgroundColor: AppColors.evergreen,
        onTap: () {},
      ),
      SizedBox(height: 16),
      AppSurveyCard(
        title: 'Customer Satisfaction Survey',
        duration: 150,
        reward: 2,
        backgroundColor: AppColors.pacificblue,
        onTap: () {},
      ),
      SizedBox(height: 16),
      AppSurveyCard(
        title: 'Customer Satisfaction Survey',
        duration: 150,
        reward: 2,
        backgroundColor: AppColors.lightcyan,
        onTap: () {},
      ),
      SizedBox(height: 16),
      AppSurveyCard(
        title: 'Customer Satisfaction Survey',
        duration: 150,
        reward: 2,
        backgroundColor: AppColors.atomictangerine,
        onTap: () {},
      ),
      SizedBox(height: 16),
      AppSurveyCard(
        title: 'Customer Satisfaction Survey',
        duration: 150,
        reward: 2,
        backgroundColor: AppColors.burnttangerine,
        onTap: () {},
      ),
    ],
  );
}
