import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:surveys/core/constants/colors.dart';

class AppSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final bool showLabels;

  const AppSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.divisions = 10,
    this.label,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    const double thumbWidth = 12;

    final labels = List.generate(
      (divisions ?? 1) + 1,
      (i) => (min + (i * (max - min) / (divisions ?? 1))).round().toString(),
    );

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackShape: const RectangularSliderTrackShape(),
              padding: const EdgeInsets.symmetric(horizontal: thumbWidth / 2),
              activeTrackColor: AppColors.atomictangerine,
              inactiveTrackColor: AppColors.disabled,
              trackHeight: 6,
              thumbColor: AppColors.atomictangerine,
              thumbShape: const RectangularSliderThumbShape(
                width: thumbWidth,
                height: 24,
                radius: 4,
              ),
              overlayColor: Colors.transparent,
              overlayShape: null,
              activeTickMarkColor: Colors.black,
              inactiveTickMarkColor: Colors.black,
              valueIndicatorShape: const DropSliderValueIndicatorShape(),
              valueIndicatorColor: AppColors.atomictangerine,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: min,
              max: max,
              divisions: divisions,
              label: label,
            ),
          ),
        ),
        if (showLabels)
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 0, right: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: labels
                    .map(
                      (v) => Text(
                        v,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }
}

class RectangularSliderThumbShape extends SliderComponentShape {
  final double width;
  final double height;
  final double radius;

  const RectangularSliderThumbShape({
    this.width = 20,
    this.height = 20,
    this.radius = 4,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final paint = Paint()..color = sliderTheme.thumbColor ?? Colors.black;

    final rect = Rect.fromCenter(center: center, width: width, height: height);

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rrect, paint);
  }
}

@Preview(name: 'App Slider')
Widget sliderPreview() {
  return AppSlider(
    value: 50,
    onChanged: (newValue) {},
    min: 0,
    max: 100,
    divisions: 5,
    label: '50',
  );
}
