import 'package:flutter/material.dart';
import 'package:surveys/core/constants/colors.dart';

/// The app's name, set as type rather than shipped as an image.
///
/// Fraunces is a warm, slightly old-style serif — it sits well against the
/// tangerine accent and reads as a consumer product rather than a form. The
/// full stop is the only place colour appears in the wordmark; everything else
/// stays in ink so the accent keeps its meaning elsewhere on the screen.
class AppWordmark extends StatelessWidget {
  const AppWordmark({
    super.key,
    this.fontSize = 44,
    this.color = AppColors.textPrimary,
    this.accent = AppColors.accent,
  });

  final double fontSize;
  final Color color;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'Fraunces',
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1,
      letterSpacing: -fontSize * 0.02,
      color: color,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Surveys', style: style),
          TextSpan(
            text: '.',
            style: style.copyWith(color: accent),
          ),
        ],
      ),
      textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3),
    );
  }
}
