// lib/src/components/inputs/stunning_segmented_control.dart
import 'package:flutter/material.dart';
import '../../core/stunning_tappable.dart';
import '../../theme/stunning_theme.dart';
import 'dart:ui';

/// A modern, glassmorphic segmented control with a sliding background highlight.
class StunningSegmentedControl extends StatelessWidget {
  /// The list of string labels for each segment.
  final List<String> options;

  /// The index of the currently selected segment.
  final int selectedIndex;

  /// Callback triggered when a new segment is tapped.
  final ValueChanged<int> onValueChanged;

  const StunningSegmentedControl({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final primaryColor = st.primaryBrand;
    final duration = st.motion(context);

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: st.surfaceGlass,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: st.borderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: st.glassBlurSigma,
            sigmaY: st.glassBlurSigma,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / options.length;

              return Stack(
                children: [
                  // Sliding Highlight Background
                  AnimatedPositioned(
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    left: selectedIndex * itemWidth,
                    top: 0,
                    bottom: 0,
                    width: itemWidth,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Text Options Layer
                  Row(
                    children: List.generate(options.length, (index) {
                      final isSelected = selectedIndex == index;

                      return StunningTappable(
                        onPressed: () => onValueChanged(index),
                        selected: isSelected,
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: itemWidth,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: duration,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? st.onColor(primaryColor)
                                        : st.textSecondary,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                fontSize: 15,
                              ),
                              child: Text(options[index]),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
