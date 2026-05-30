// lib/src/components/modals/stunning_modal.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:stunning_ui/src/theme/stunning_theme.dart';

Future<T?> showStunningModal<T>({
  required BuildContext context,
  required Widget title,
  required Widget content,
  List<Widget>? actions,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.3), // Background dimming
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final theme = Theme.of(context).extension<StunningTheme>();

      return BackdropFilter(
        // Dynamic blur based on animation value
        filter: ImageFilter.blur(
          sigmaX: 8 * animation.value,
          sigmaY: 8 * animation.value,
        ),
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack, // Spring effect
          ),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor:
                  theme?.surfaceGlass ?? Colors.white.withOpacity(0.1),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              shadowColor: theme?.glowingShadow.color,
              title: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                child: title,
              ),
              content: DefaultTextStyle(
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                child: content,
              ),
              actions: actions,
            ),
          ),
        ),
      );
    },
  );
}
