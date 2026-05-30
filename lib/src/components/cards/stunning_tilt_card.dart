// lib/src/components/cards/stunning_tilt_card.dart
import 'package:flutter/material.dart';
import 'package:stunning_ui/src/theme/stunning_theme.dart';
import 'dart:ui';

class StunningTiltCard extends StatefulWidget {
  final double width;
  final double height;
  final Widget child;

  const StunningTiltCard({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  State<StunningTiltCard> createState() => _StunningTiltCardState();
}

class _StunningTiltCardState extends State<StunningTiltCard> {
  double _x = 0.0;
  double _y = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<StunningTheme>();

    return MouseRegion(
      onHover: (details) {
        setState(() {
          // Calculate relative mouse position (-1 to 1)
          _x = (details.localPosition.dx / widget.width) * 2 - 1;
          _y = (details.localPosition.dy / widget.height) * 2 - 1;
        });
      },
      onExit: (details) {
        setState(() {
          // Reset when mouse leaves
          _x = 0;
          _y = 0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        // 3D Transform Logic
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective
          ..rotateX(-_y * 0.2) // Tilt X
          ..rotateY(_x * 0.2), // Tilt Y
        transformAlignment: FractionalOffset.center,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: theme?.surfaceGlass ?? Colors.white.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: Colors.white.withValues(alpha:0.2)),
              boxShadow: [if (theme != null) theme.glowingShadow],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Stack(
                  children: [
                    // Actual Content
                    Center(child: widget.child),

                    // Glare Effect
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-_x, -_y),
                            end: Alignment(_x, _y),
                            colors: [
                              Colors.white.withValues(alpha:0.3),
                              Colors.transparent,
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.3, 1.0],
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
