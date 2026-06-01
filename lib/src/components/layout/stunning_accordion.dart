// lib/src/components/layout/stunning_accordion.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/stunning_tappable.dart';
import '../../theme/stunning_theme.dart';

/// A glassmorphic accordion widget that smoothly expands and collapses.
class StunningAccordion extends StatefulWidget {
  /// The title text displayed on the collapsed state.
  final String title;

  /// The widget to display when the accordion is expanded.
  final Widget content;

  const StunningAccordion({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<StunningAccordion> createState() => _StunningAccordionState();
}

class _StunningAccordionState extends State<StunningAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final animDuration = st.motion(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: st.surfaceGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: st.borderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: st.glassBlurSigma,
            sigmaY: st.glassBlurSigma,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StunningTappable(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                toggled: _isExpanded,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: st.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: animDuration,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: st.iconColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: animDuration,
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child:
                    _isExpanded
                        ? Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 16,
                          ),
                          child: widget.content,
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
