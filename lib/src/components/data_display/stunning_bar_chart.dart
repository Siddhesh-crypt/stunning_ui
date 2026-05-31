import 'package:flutter/material.dart';
import 'package:stunning_ui/src/theme/stunning_theme.dart';

/// A premium, animated bar chart designed for Enterprise and SaaS dashboards.
class StunningBarChart extends StatelessWidget {
  /// The data values for the bars.
  final List<double> data;

  /// The labels corresponding to each data point (X-axis).
  final List<String> labels;

  /// The maximum value to scale the bars correctly.
  final double maxValue;

  /// The overall height of the chart container.
  final double height;

  const StunningBarChart({
    super.key,
    required this.data,
    required this.labels,
    required this.maxValue,
    this.height = 280,
  });

  @override
  Widget build(BuildContext context) {
    // Basic validation to prevent crashes
    assert(
      data.length == labels.length,
      'Data and labels must have the same length',
    );

    final theme = Theme.of(context).extension<StunningTheme>();
    final brandColor = theme?.primaryBrand ?? const Color(0xFF3B82F6);

    // Enterprise Dark SaaS Colors fallback
    final cardColor = theme?.surfaceGlass ?? const Color(0xFF1E293B);
    final borderColor = const Color(0xFF334155);
    final textMuted = const Color(0xFF94A3B8);

    return Container(
      height: height,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (index) {
          // Calculate height percentage (0.0 to 1.0)
          final percentage = (data[index] / maxValue).clamp(0.0, 1.0);

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // The Value Popup (Optional: visible on top of bar)
              Text(
                data[index].toInt().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Animated Growing Bar
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: percentage),
                    duration: const Duration(
                      milliseconds: 1200,
                    ), // Smooth 1.2s growth
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return FractionallySizedBox(
                        heightFactor: value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 24, // Bar width
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            brandColor.withValues(
                              alpha: 0.2,
                            ), // Base is dark/transparent
                            brandColor, // Top is glowing solid
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: brandColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, -4), // Glow points upwards
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // X-Axis Label
              Text(
                labels[index],
                style: TextStyle(
                  color: textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
