// lib/src/components/feedback/stunning_shimmer.dart
import 'package:flutter/material.dart';

import '../../theme/stunning_theme.dart';

/// A GPU-accelerated skeleton loading wrapper that applies a sliding highlight effect.
class StunningShimmer extends StatefulWidget {
  /// The actual widget to display when loading is complete, or the layout to mask over.
  final Widget child;

  /// Controls whether the shimmer animation is currently active.
  final bool isLoading;

  const StunningShimmer({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<StunningShimmer> createState() => _StunningShimmerState();
}

class _StunningShimmerState extends State<StunningShimmer>
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
    if (!widget.isLoading) return widget.child;

    final st = StunningTheme.of(context);

    // Reduce-motion: the shimmer is a continuous/looping animation, so render
    // the static (non-animated) child instead of the sliding highlight.
    if (StunningTheme.reduceMotion(context)) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                st.textPrimary.withValues(alpha: 0.05),
                st.textPrimary.withValues(alpha: 0.2),
                st.textPrimary.withValues(alpha: 0.05),
              ],
              stops: const [0.1, 0.5, 0.9],
              // Sliding effect logic
              begin: Alignment(-2.0 + (_controller.value * 4), -0.5),
              end: Alignment(0.0 + (_controller.value * 4), 0.5),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
