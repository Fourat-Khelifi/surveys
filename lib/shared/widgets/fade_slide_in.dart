import 'package:flutter/material.dart';
import 'package:surveys/core/constants/motion.dart';

/// Fades and lifts a widget into place once, on first build.
///
/// Used to stagger the survey list so the cards arrive in sequence rather than
/// all at once. The delay is what does the work — without it a stagger is just
/// a slower fade.
///
/// Deliberately fire-and-forget: it animates on mount and never again, so
/// rebuilds from a refresh or a tab switch don't re-trigger it.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 16,
  });

  final Widget child;
  final Duration delay;

  /// How far below its resting position the child starts, in logical pixels.
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.base,
  );

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
      // The list can be rebuilt out from under a pending delay by a refresh.
      if (!mounted) return;
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    final curved = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.enter,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset(0, (1 - curved.value) * widget.offset),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
