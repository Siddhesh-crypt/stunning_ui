// lib/src/components/navigation/stunning_bottom_nav.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:stunning_ui/src/theme/stunning_theme.dart';

class StunningNavItem {
  final IconData icon;
  const StunningNavItem({required this.icon});
}

class StunningBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<StunningNavItem> items;

  const StunningBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<StunningTheme>();
    final primaryColor = theme?.primaryBrand ?? Colors.purpleAccent;

    // Har icon item ki width fix kar rahe hain taaki slide animation precise rahe
    const double itemWidth = 70.0;

    return SafeArea(
      // ... SafeArea ke andar ka Align widget ...
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          height: 75,
          // YAHAN SE 'width' PROPERTY HATA DI GAYI HAI.
          // Ab ye apne baccho (children) ke hisaab se shrink-wrap hoga.
          decoration: BoxDecoration(
            color: theme?.surfaceGlass ?? Colors.black.withValues(alpha:0.55),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withValues(alpha:0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 1. THE SLIDING NEON INDICATOR & GLOW
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      left: itemWidth * currentIndex,
                      top: 0,
                      bottom: 0,
                      width: itemWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 4,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  primaryColor.withValues(alpha:0.3),
                                  Colors.transparent,
                                ],
                                stops: const [0.2, 1.0],
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    // 2. THE ICONS LAYER
                    Row(
                      // YAHAN MAIN AXIS SIZE MIN ADD KIYA HAI
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(items.length, (index) {
                        final isSelected = currentIndex == index;

                        return GestureDetector(
                          onTap: () => onTap(index),
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: itemWidth,
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutBack,
                                transform: Matrix4.translationValues(
                                  0,
                                  isSelected ? -6.0 : 0.0,
                                  0,
                                ),
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 300),
                                  scale: isSelected ? 1.2 : 1.0,
                                  child: Icon(
                                    items[index].icon,
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.white54,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
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
