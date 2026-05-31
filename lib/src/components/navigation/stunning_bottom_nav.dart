import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:stunning_ui/src/theme/stunning_theme.dart';

/// Represents an individual item inside the [StunningBottomNav].
class StunningNavItem {
  /// The icon to be displayed for this navigation item.
  final IconData icon;
  const StunningNavItem({required this.icon});
}

/// A highly interactive, floating bottom navigation bar with elastic physics and neon glow.
class StunningBottomNav extends StatelessWidget {
  /// The index of the currently active navigation item.
  final int currentIndex;

  /// Callback triggered when a navigation item is tapped.
  final ValueChanged<int> onTap;

  /// The list of items to display in the navigation bar.
  final List<StunningNavItem> items;

  /// The width of the active neon indicator line.
  final double indicatorWidth;

  /// The outer margin of the floating navigation bar.
  final EdgeInsetsGeometry margin;

  final Color? backgroundColor;

  const StunningBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.indicatorWidth = 40.0, // Default width thodi bada di hai
    this.margin = const EdgeInsets.symmetric(
      horizontal: 24.0,
      vertical: 24.0,
    ), // Customizable margin
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<StunningTheme>();
    final accentColor = theme?.primaryBrand ?? Colors.purpleAccent;

    /// Custom color lega, nahi toh theme ka color, nahi toh default
    final surfaceColor =
        backgroundColor ??
        theme?.surfaceGlass ??
        const Color(0xFF1A1A2E).withValues(alpha: 0.6);

    return SafeArea(
      child: Padding(
        padding: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Animated Indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack, // Spring animation
                    top: 0,
                    bottom: 0,
                    left:
                        (MediaQuery.of(context).size.width -
                            margin.horizontal) /
                        items.length *
                        currentIndex,
                    width:
                        (MediaQuery.of(context).size.width -
                            margin.horizontal) /
                        items.length,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        height: 4,
                        width:
                            indicatorWidth, // Yahan dynamic width use ho rahi hai
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Icons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(items.length, (index) {
                      final isSelected = currentIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onTap(index),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                items[index].icon,
                                color: isSelected
                                    ? accentColor
                                    : Colors.white.withValues(alpha: 0.5),
                                size: isSelected ? 28 : 24,
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
    );
  }
}
