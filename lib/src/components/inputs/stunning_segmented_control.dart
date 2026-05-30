// lib/src/components/inputs/stunning_segmented_control.dart
import 'package:flutter/material.dart';
import 'package:stunning_ui/src/theme/stunning_theme.dart';
import 'dart:ui';

class StunningSegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onValueChanged;

  const StunningSegmentedControl({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<StunningTheme>();
    final primaryColor = theme?.primaryBrand ?? Colors.purpleAccent;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: theme?.surfaceGlass ?? Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / options.length;

              return Stack(
                children: [
                  // Sliding Highlight Background
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    left: selectedIndex * itemWidth,
                    top: 0,
                    bottom: 0,
                    width: itemWidth,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.5),
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

                      return GestureDetector(
                        onTap: () => onValueChanged(index),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: itemWidth,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white54,
                                fontWeight: isSelected
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
