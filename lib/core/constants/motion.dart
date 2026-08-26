import 'package:flutter/material.dart';

/// One place for every duration and curve in the app.
///
/// Motion here is meant to confirm rather than decorate: a press should feel
/// like it landed, a step should feel like it moved in a direction. Anything
/// longer than [slow] starts to feel like waiting.
class AppMotion {
  const AppMotion._();

  /// Press feedback. Short enough to feel physical rather than laggy.
  static const Duration press = Duration(milliseconds: 110);

  /// Selection changes — a chip filling in, a border thickening.
  static const Duration quick = Duration(milliseconds: 180);

  /// Step transitions and progress.
  static const Duration base = Duration(milliseconds: 280);

  /// Entrances and the reward count-up.
  static const Duration slow = Duration(milliseconds: 520);

  /// Deceleration for anything entering the screen.
  static const Curve enter = Curves.easeOutCubic;

  /// Symmetric, for things that change in place.
  static const Curve standard = Curves.easeInOutCubic;

  /// A little overshoot. Used sparingly — the reward card, and nothing else.
  static const Curve emphasised = Curves.easeOutBack;

  /// Honours the platform "reduce motion" accessibility setting.
  ///
  /// Every animated widget in the app routes its duration through this, so
  /// turning the setting on collapses the whole app to instant transitions
  /// rather than leaving a few stragglers moving.
  static Duration of(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }
}
