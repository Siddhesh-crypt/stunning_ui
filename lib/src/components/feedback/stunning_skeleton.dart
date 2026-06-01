import 'package:flutter/material.dart';
import '../../theme/stunning_theme.dart';

/// A premium skeleton loader with a continuous glass shimmer effect.
class StunningSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const StunningSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 16.0,
  });

  @override
  State<StunningSkeleton> createState() => _StunningSkeletonState();
}

class _StunningSkeletonState extends State<StunningSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final surfaceColor = st.surfaceGlass;

    // Honor the OS "reduce motion" setting: stop the looping shimmer and render
    // a static placeholder instead of the continuous animation.
    if (StunningTheme.reduceMotion(context)) {
      if (_controller.isAnimating) _controller.stop();
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: surfaceColor,
          border: Border.all(color: st.borderColor, width: 1),
        ),
      );
    }

    // Resume the loop if it was previously stopped (e.g. reduce-motion toggled).
    if (!_controller.isAnimating) _controller.repeat();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: const Alignment(-2.0, -0.5),
              end: const Alignment(2.0, 0.5),
              stops: const [0.0, 0.5, 1.0],
              colors: [
                surfaceColor,
                st.textPrimary.withValues(alpha: 0.15), // The shimmering light
                surfaceColor,
              ],
              transform: _SlidingGradientTransform(_controller.value),
            ),
            border: Border.all(color: st.borderColor, width: 1),
          ),
        );
      },
    );
  }
}

/// Helper class to move the gradient across the skeleton.
class _SlidingGradientTransform extends GradientTransform {
  final double percent;
  const _SlidingGradientTransform(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final w = bounds.width;
    // Moves from left to right
    return Matrix4.translationValues((percent * 3.0 - 1.5) * w, 0.0, 0.0);
  }
}
