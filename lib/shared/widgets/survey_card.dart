import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/shared/widgets/pressable.dart';

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
    // A larger surface needs a smaller scale change to travel the same distance
    // on screen, so this presses less far than a chip does.
    return AppPressable(
      onPressed: onTap,
      scale: 0.985,
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
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: Colors.black, height: 1.2),
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.black87),
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.black87),
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
      return AppColors.tealLight;
    } else if (duration <= 10) {
      return AppColors.teal;
    } else if (duration <= 15) {
      return AppColors.dark;
    } else if (duration <= 20) {
      return AppColors.accent;
    } else {
      return AppColors.accentDark;
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
        backgroundColor: AppColors.dark,
        onTap: () {},
      ),
      SizedBox(height: 16),
      AppSurveyCard(
        title: 'Customer Satisfaction Survey',
        duration: 150,
        reward: 2,
        backgroundColor: AppColors.teal,
        onTap: () {},
      ),
      SizedBox(height: 16),
      AppSurveyCard(
        title: 'Customer Satisfaction Survey',
        duration: 150,
        reward: 2,
        backgroundColor: AppColors.tealLight,
        onTap: () {},
      ),
      SizedBox(height: 16),
      AppSurveyCard(
        title: 'Customer Satisfaction Survey',
        duration: 150,
        reward: 2,
        backgroundColor: AppColors.accent,
        onTap: () {},
      ),
      SizedBox(height: 16),
      AppSurveyCard(
        title: 'Customer Satisfaction Survey',
        duration: 150,
        reward: 2,
        backgroundColor: AppColors.accentDark,
        onTap: () {},
      ),
    ],
  );
}
