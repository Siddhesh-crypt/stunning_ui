import 'package:flutter/material.dart';
import 'dart:ui';
import '../../theme/stunning_theme.dart';

class StunningModal extends StatelessWidget {
  final String title;
  final String message;
  final Widget? actionButton;
  final Widget? secondaryButton;

  const StunningModal({
    super.key,
    required this.title,
    required this.message,
    this.actionButton,
    this.secondaryButton,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    Widget? actionButton,
    Widget? secondaryButton,
  }) {
    final st = StunningTheme.of(context);
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'StunningModal',
      barrierColor: Colors.black.withValues(
        alpha: 0.7,
      ), // Deep focus background
      transitionDuration: st.motion(context),
      pageBuilder: (context, _, _) => StunningModal(
        title: title,
        message: message,
        actionButton: actionButton,
        secondaryButton: secondaryButton,
      ),
      transitionBuilder: (context, anim, secAnim, child) {
        final st = StunningTheme.of(context);
        final curve = st.motionCurve;
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: curve),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final blur = st.glassBlurSigma;
    final brandColor = st.primaryBrand;
    final activeShadow = st.glowingShadow;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // The Glass Plate
          Container(
            margin: const EdgeInsets.only(top: 30), // Space for floating icon
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
                  decoration: BoxDecoration(
                    color: st.surfaceGlass, // TRUE ultra-clear glass
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: st.borderColor,
                      width: 1,
                    ),
                    boxShadow: activeShadow.blurRadius > 0
                        ? [activeShadow]
                        : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: st.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: st.textSecondary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          if (secondaryButton != null) ...[
                            Expanded(child: secondaryButton!),
                            const SizedBox(width: 12),
                          ],
                          if (actionButton != null)
                            Expanded(child: actionButton!),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // The Floating Glowing Badge
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A24), // Dark solid core
                border: Border.all(color: brandColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: brandColor.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.cloud_sync_rounded,
                color: brandColor,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
