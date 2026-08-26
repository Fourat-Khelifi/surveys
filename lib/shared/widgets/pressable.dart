import 'package:flutter/material.dart';
import 'package:surveys/core/constants/motion.dart';

/// Wraps any tappable thing in a subtle scale-down while the finger is held.
///
/// Flutter's ink splash doesn't read well on this app's flat, bordered surfaces
/// — the ripple fights the hard edges. A short press-in reads as physical
/// instead, and works identically on a coloured button, an outlined chip and a
/// large card.
///
/// The gesture cancels correctly: dragging off the widget releases the scale
/// without firing [onPressed], which a bare `GestureDetector` + `setState`
/// pairing usually gets wrong.
class AppPressable extends StatefulWidget {
  const AppPressable({
    super.key,
    required this.child,
    this.onPressed,
    this.scale = 0.97,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onPressed;

  /// How far to shrink. Larger surfaces want less — a full-width card at 0.97
  /// moves further in pixels than a chip at 0.94 does.
  final double scale;

  final BorderRadius? borderRadius;

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _held = false;

  bool get _enabled => widget.onPressed != null;

  void _setHeld(bool value) {
    if (!_enabled || _held == value) return;
    setState(() => _held = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: _enabled,
      enabled: _enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setHeld(true),
        onTapUp: (_) => _setHeld(false),
        onTapCancel: () => _setHeld(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _held ? widget.scale : 1,
          duration: AppMotion.of(context, AppMotion.press),
          curve: AppMotion.standard,
          child: widget.child,
        ),
      ),
    );
  }
}
