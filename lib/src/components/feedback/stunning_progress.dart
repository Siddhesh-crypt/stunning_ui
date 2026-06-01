import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/stunning_theme.dart';

/// A theme-aware linear progress indicator.
///
/// Renders a rounded track with a brand-coloured active fill that animates its
/// width toward [value] using the theme's motion tokens. When [value] is
/// `null` it switches to an indeterminate mode that slides a shimmer segment
/// continuously across the track (or, under OS reduce-motion, shows a static
/// partial fill so nothing loops forever).
///
/// A brand glow is layered on the active fill whenever the active theme's
/// `glowIntensity` is greater than zero. The glow geometry is kept constant
/// (only its colour toggles to transparent when off) so an overshoot motion
/// curve can never extrapolate the blur radius negative.
class StunningProgressBar extends StatefulWidget {
  /// Progress in the inclusive range `0.0`–`1.0`. Pass `null` for an
  /// indeterminate (continuously animating) bar.
  final double? value;

  /// Thickness of the bar in logical pixels.
  final double height;

  /// Colour of the active fill. Defaults to the theme's `primaryBrand`.
  final Color? color;

  /// Colour of the inactive track. Defaults to the theme's `borderColor`.
  final Color? trackColor;

  /// Creates a linear progress bar. A `null` [value] is indeterminate.
  const StunningProgressBar({
    super.key,
    this.value,
    this.height = 6,
    this.color,
    this.trackColor,
  });

  @override
  State<StunningProgressBar> createState() => _StunningProgressBarState();
}

class _StunningProgressBarState extends State<StunningProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _indeterminate => widget.value == null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (_indeterminate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant StunningProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_indeterminate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!_indeterminate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final activeColor = widget.color ?? st.primaryBrand;
    final track = widget.trackColor ?? st.borderColor;
    final glow = st.glowIntensity;
    final radius = BorderRadius.circular(widget.height / 2);

    // Constant-geometry glow: same blur/spread/offset always, only the colour
    // toggles to transparent when glow is disabled (gotcha #1).
    final glowShadow = BoxShadow(
      color: glow > 0
          ? activeColor.withValues(alpha: 0.5 * glow)
          : Colors.transparent,
      blurRadius: 12 * (glow > 0 ? glow : 1),
      spreadRadius: 1 * (glow > 0 ? glow : 1),
    );

    final reduceMotion = StunningTheme.reduceMotion(context);
    final pct = _indeterminate
        ? null
        : (widget.value!.clamp(0.0, 1.0) * 100).round();

    return Semantics(
      label: 'progress',
      value: pct != null ? '$pct%' : null,
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final track0 = DecoratedBox(
                decoration: BoxDecoration(color: track, borderRadius: radius),
              );

              if (!_indeterminate) {
                return Stack(
                  children: [
                    Positioned.fill(child: track0),
                    AnimatedFractionallySizedBox(
                      duration: st.motion(context),
                      curve: st.motionCurve,
                      widthFactor: widget.value!.clamp(0.0, 1.0),
                      heightFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: radius,
                          boxShadow: [glowShadow],
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Indeterminate. Under reduce-motion, never loop: show a static
              // partial fill instead.
              if (reduceMotion) {
                return Stack(
                  children: [
                    Positioned.fill(child: track0),
                    FractionallySizedBox(
                      widthFactor: 0.35,
                      heightFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: radius,
                          boxShadow: [glowShadow],
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Continuous sliding shimmer segment.
              final segWidth = width * 0.4;
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final travel = width + segWidth;
                  final dx = _controller.value * travel - segWidth;
                  return Stack(
                    children: [
                      Positioned.fill(child: track0),
                      Positioned(
                        left: dx,
                        top: 0,
                        bottom: 0,
                        width: segWidth,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: activeColor,
                            borderRadius: radius,
                            boxShadow: [glowShadow],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A theme-aware circular progress indicator.
///
/// Paints a circular track plus a brand-coloured active arc. When [value] is
/// provided the arc sweeps to `value * 2π` and animates toward new values with
/// the theme's motion tokens. A `null` [value] is indeterminate: the arc
/// rotates continuously (or, under OS reduce-motion, holds a static partial
/// arc so nothing loops).
///
/// A brand glow is applied to the active arc whenever the active theme's
/// `glowIntensity` is greater than zero, using a constant-geometry blur so an
/// overshoot motion curve can never drive the blur radius negative.
class StunningProgressRing extends StatefulWidget {
  /// Progress in the inclusive range `0.0`–`1.0`. Pass `null` for an
  /// indeterminate (continuously rotating) ring.
  final double? value;

  /// Diameter of the ring in logical pixels.
  final double size;

  /// Thickness of the track and arc in logical pixels.
  final double strokeWidth;

  /// Colour of the active arc. Defaults to the theme's `primaryBrand`.
  final Color? color;

  /// Creates a circular progress ring. A `null` [value] is indeterminate.
  const StunningProgressRing({
    super.key,
    this.value,
    this.size = 40,
    this.strokeWidth = 4,
    this.color,
  });

  @override
  State<StunningProgressRing> createState() => _StunningProgressRingState();
}

class _StunningProgressRingState extends State<StunningProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _indeterminate => widget.value == null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (_indeterminate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant StunningProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_indeterminate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!_indeterminate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final activeColor = widget.color ?? st.primaryBrand;
    final track = st.borderColor;
    final glow = st.glowIntensity;
    final reduceMotion = StunningTheme.reduceMotion(context);

    final pct = _indeterminate
        ? null
        : (widget.value!.clamp(0.0, 1.0) * 100).round();

    Widget paint(double sweep, double rotation) => CustomPaint(
          painter: _RingPainter(
            sweep: sweep,
            rotation: rotation,
            strokeWidth: widget.strokeWidth,
            activeColor: activeColor,
            trackColor: track,
            glowIntensity: glow,
          ),
        );

    Widget body;
    if (!_indeterminate) {
      // Determinate: animate the sweep toward value * 2π.
      body = TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0,
          end: widget.value!.clamp(0.0, 1.0) * 2 * math.pi,
        ),
        duration: st.motion(context),
        curve: st.motionCurve,
        builder: (context, sweep, _) => paint(sweep, -math.pi / 2),
      );
    } else if (reduceMotion) {
      // Static partial arc — no loop under reduce-motion.
      body = paint(0.25 * 2 * math.pi, -math.pi / 2);
    } else {
      // Continuous rotation of a fixed-length arc.
      body = AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => paint(
          0.25 * 2 * math.pi,
          _controller.value * 2 * math.pi,
        ),
      );
    }

    return Semantics(
      label: 'progress',
      value: pct != null ? '$pct%' : null,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: body,
      ),
    );
  }
}

/// Paints the [StunningProgressRing] track and active arc.
class _RingPainter extends CustomPainter {
  /// Arc length in radians.
  final double sweep;

  /// Start angle of the arc in radians.
  final double rotation;
  final double strokeWidth;
  final Color activeColor;
  final Color trackColor;
  final double glowIntensity;

  _RingPainter({
    required this.sweep,
    required this.rotation,
    required this.strokeWidth,
    required this.activeColor,
    required this.trackColor,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    if (radius <= 0) return;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    if (sweep <= 0) return;

    // Constant-geometry glow: a soft underlay drawn only when glow is enabled.
    // Its blur sigma is fixed, never driven by an animated/overshoot value.
    if (glowIntensity > 0) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = activeColor.withValues(alpha: 0.5 * glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawArc(rect, rotation, sweep, false, glowPaint);
    }

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = activeColor;
    canvas.drawArc(rect, rotation, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.sweep != sweep ||
      old.rotation != rotation ||
      old.strokeWidth != strokeWidth ||
      old.activeColor != activeColor ||
      old.trackColor != trackColor ||
      old.glowIntensity != glowIntensity;
}
