import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/stunning_tappable.dart';
import '../../theme/stunning_theme.dart';

/// A segmented control where a glowing pill slides behind the active tab.
class StunningTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const StunningTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final duration = st.motion(context);
    final curve = st.motionCurve;

    final blur = st.glassBlurSigma;
    final brandColor = st.primaryBrand;
    final surfaceColor = st.surfaceGlass;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: st.borderColor),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / tabs.length;

              return Stack(
                children: [
                  // The Sliding Pill Background
                  AnimatedPositioned(
                    duration: duration,
                    curve: curve,
                    left: selectedIndex * tabWidth,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: brandColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: brandColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),

                  // The Tab Texts
                  Row(
                    children: List.generate(tabs.length, (index) {
                      final isActive = index == selectedIndex;
                      return SizedBox(
                        width: tabWidth,
                        child: StunningTappable(
                          onPressed: () => onChanged(index),
                          selected: isActive,
                          minTargetSize: 0,
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: duration,
                                style: TextStyle(
                                  color: isActive
                                      ? st.textPrimary
                                      : st.textSecondary,
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 14,
                                ),
                                child: Text(tabs[index]),
                              ),
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
