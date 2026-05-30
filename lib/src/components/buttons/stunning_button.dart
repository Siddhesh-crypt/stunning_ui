// lib/src/components/buttons/stunning_button.dart
import 'package:flutter/material.dart';
import 'package:stunning_ui/src/theme/stunning_theme.dart';
import 'dart:ui';

class StunningButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isGlass;
  final bool isLoading; // Naya addition

  const StunningButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isGlass = false,
    this.isLoading = false,
  });

  @override
  State<StunningButton> createState() => _StunningButtonState();
}

class _StunningButtonState extends State<StunningButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<StunningTheme>();

    return GestureDetector(
      // Loading state me taps disable kar do
      onTapDown: widget.isLoading
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isLoading
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: widget.isGlass ? null : theme?.premiumGradient,
            color: widget.isGlass ? theme?.surfaceGlass : null,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: (_isPressed || widget.isLoading)
                ? []
                : [if (theme != null) theme.glowingShadow],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: BackdropFilter(
              filter: widget.isGlass
                  ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                  : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          widget.text,
                          key: ValueKey(widget.text),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
