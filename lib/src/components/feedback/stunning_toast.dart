// lib/src/components/feedback/stunning_toast.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:stunning_ui/src/theme/stunning_theme.dart';

/// A utility class to display elastic, glassmorphic toast notifications from the top of the screen.
/// A utility class to display elastic, glassmorphic toast notifications.
/// A utility class to display elastic, glassmorphic toast notifications.
class StunningToast {
  /// Displays a temporary floating toast message on top of the current UI.
  static void show({
    required BuildContext context,
    required String message,
    required IconData icon,
    bool isError = false,
    double? topOffset,
    double? bottomOffset, // <-- Naya parameter add kiya
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        // Smart Positioning Logic
        double? finalTop = topOffset;
        double? finalBottom = bottomOffset;

        // Agar bottom offset diya hai, toh top ko null karna padega varna Toast stretch ho jayega
        if (finalBottom != null) {
          finalTop = null;
        } else {
          // Dart ka modern null-aware assignment operator
          finalTop ??= MediaQuery.of(context).padding.top + 16;
        }

        return Positioned(
          top: finalTop,
          bottom: finalBottom,
          left: 24,
          right: 24,
          child: Material(
            color: Colors.transparent,
            child: _ToastWidget(
              message: message,
              icon: icon,
              isError: isError,
              onDismiss: () {
                entry.remove();
              },
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final bool isError;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.icon,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut, // Spring physics
    );

    _controller.forward();

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<StunningTheme>();
    final accentColor = widget.isError
        ? Colors.redAccent
        : (theme?.primaryBrand ?? Colors.greenAccent);

    return Positioned(
      top: 60, // Screen ke top se margin
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FractionalTranslation(
              // Slide down from top (-1.0 to 0.0)
              translation: Offset(0, -1.0 + _slideAnimation.value),
              child: Opacity(
                opacity: _controller.value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color:
                    theme?.surfaceGlass ?? Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, color: accentColor, size: 24),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
