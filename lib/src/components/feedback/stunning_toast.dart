import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:stunning_ui/src/theme/stunning_theme.dart';

/// A premium, floating toast notification that slides up from the bottom.
class StunningToast {
  static void show({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? overrideColor,
    double bottomOffset = 120.0, // Default clearance for bottom nav bars
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    // Auto-remove logic
    bool isRemoved = false;
    void removeToast() {
      if (!isRemoved) {
        entry.remove();
        isRemoved = true;
      }
    }

    entry = OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context).extension<StunningTheme>();
        final brandColor =
            overrideColor ?? theme?.primaryBrand ?? Colors.blueAccent;
        final blur = theme?.glassBlurSigma ?? 10.0;
        final glow = theme?.glowIntensity ?? 0.5;

        return Positioned(
          bottom: bottomOffset, // Ab ye Top ki jagah Bottom se position hoga
          left: 20.0,
          right: 20.0,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                // Changed to 100.0 so it slides UP from the bottom
                tween: Tween(begin: 100.0, end: 0.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack, // Bouncy pop-up effect
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, value),
                    child: child,
                  );
                },
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: brandColor.withValues(alpha: 0.5),
                            width: 1,
                          ),
                          boxShadow: glow > 0
                              ? [
                                  BoxShadow(
                                    color: brandColor.withValues(
                                      alpha: 0.3 * glow,
                                    ),
                                    blurRadius: 20 * glow,
                                    spreadRadius: 2 * glow,
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (icon != null) ...[
                              Icon(icon, color: brandColor, size: 20),
                              const SizedBox(width: 12),
                            ],
                            Text(
                              message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    // Automatically hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), removeToast);
  }
}
