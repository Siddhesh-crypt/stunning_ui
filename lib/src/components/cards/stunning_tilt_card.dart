import 'package:flutter/material.dart';
import '../../core/glass_surface.dart';
import '../../theme/stunning_theme.dart';

/// A 3D interactive glass card that tilts toward the pointer on web/desktop
/// (hover) AND toward the finger on mobile (pan), springing back to flat on
/// release. The glass body uses [GlassSurface] (refraction on Impeller, blur
/// elsewhere) and the whole effect collapses to flat under reduce-motion.
class StunningTiltCard extends StatefulWidget {
  /// The exact width of the tilt card.
  final double width;

  /// The exact height of the tilt card.
  final double height;

  /// The content displayed inside the card.
  final Widget child;

  /// Maximum tilt in radians at the card edges.
  final double maxTilt;

  /// Corner radius of the glass body.
  final double borderRadius;

  const StunningTiltCard({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.maxTilt = 0.2,
    this.borderRadius = 24,
  });

  @override
  State<StunningTiltCard> createState() => _StunningTiltCardState();
}

class _StunningTiltCardState extends State<StunningTiltCard> {
  // Relative pointer position, -1..1 on each axis.
  double _x = 0.0;
  double _y = 0.0;

  void _updateFrom(Offset local) {
    setState(() {
      _x = ((local.dx / widget.width) * 2 - 1).clamp(-1.0, 1.0);
      _y = ((local.dy / widget.height) * 2 - 1).clamp(-1.0, 1.0);
    });
  }

  void _reset() => setState(() {
        _x = 0;
        _y = 0;
      });

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final reduceMotion = StunningTheme.reduceMotion(context);
    final rotateX = reduceMotion ? 0.0 : -_y * widget.maxTilt;
    final rotateY = reduceMotion ? 0.0 : _x * widget.maxTilt;
    final radius = BorderRadius.circular(widget.borderRadius);

    return MouseRegion(
      onHover: (d) => _updateFrom(d.localPosition),
      onExit: (_) => _reset(),
      child: GestureDetector(
        onPanStart: (d) => _updateFrom(d.localPosition),
        onPanUpdate: (d) => _updateFrom(d.localPosition),
        onPanEnd: (_) => _reset(),
        onPanCancel: _reset,
        child: AnimatedContainer(
          duration: st.motion(context),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateX(rotateX)
            ..rotateY(rotateY),
          transformAlignment: FractionalOffset.center,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            // Outer brand glow (static geometry — not animated, so no overshoot
            // can drive the blur radius negative).
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                boxShadow: <BoxShadow>[st.glowingShadow],
              ),
              child: GlassSurface(
                borderRadius: widget.borderRadius,
                tintAmount: 0.06,
                child: Stack(
                  children: <Widget>[
                    Center(child: widget.child),
                    // Specular glare that follows the tilt.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedContainer(
                          duration: st.motion(context),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(-_x, -_y),
                              end: Alignment(_x, _y),
                              colors: <Color>[
                                Colors.white.withValues(alpha: 0.25),
                                Colors.transparent,
                                Colors.transparent,
                              ],
                              stops: const <double>[0.0, 0.3, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
