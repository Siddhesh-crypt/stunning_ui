import 'package:flutter/material.dart';
import 'package:stunning_ui/src/theme/stunning_theme.dart';

/// Defines the visual style of the [StunningButton].
enum StunningButtonVariant { primary, outline, ghost }

/// A highly interactive, physics-based button with multiple variants and dynamic colors.
class StunningButton extends StatefulWidget {
  /// The text to display inside the button.
  final String text;

  /// The callback when the button is tapped. If null, the button is disabled.
  final VoidCallback? onPressed;

  /// Controls the loading state. Displays a spinner and disables taps if true.
  final bool isLoading;

  /// The visual style variant of the button. Defaults to primary.
  final StunningButtonVariant variant;

  /// Custom color for the button. If null, it falls back to the theme's primaryBrand.
  final Color? color;

  const StunningButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = StunningButtonVariant.primary,
    this.color,
  });

  @override
  State<StunningButton> createState() => _StunningButtonState();
}

class _StunningButtonState extends State<StunningButton> {
  // Naye state variables jo hover aur press track karenge
  bool _isHovered = false;
  bool _isPressed = false;

  // Helper method: Background color calculate karne ke liye
  Color _getBackgroundColor(Color baseColor) {
    switch (widget.variant) {
      case StunningButtonVariant.primary:
        return baseColor.withValues(alpha: _isHovered ? 0.8 : 1.0);
      case StunningButtonVariant.outline:
      case StunningButtonVariant.ghost:
        return _isHovered
            ? baseColor.withValues(alpha: 0.1)
            : Colors.transparent;
    }
  }

  // Helper method: Border calculate karne ke liye
  BoxBorder? _getBorder(Color baseColor) {
    if (widget.variant == StunningButtonVariant.outline) {
      return Border.all(color: baseColor, width: 2);
    }
    return null; // Primary aur Ghost me border nahi hota
  }

  // Helper method: Text color calculate karne ke liye
  Color _getTextColor(Color baseColor) {
    if (widget.variant == StunningButtonVariant.primary) {
      // Agar primary color light hai toh dark text, nahi toh white text
      return baseColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }
    return baseColor; // Outline aur Ghost me text color base color jaisa hota hai
  }

  @override
  Widget build(BuildContext context) {
    // 1. Theme engine se current style read karo
    final theme = Theme.of(context).extension<StunningTheme>();

    // 2. Physics tokens extract karo
    final duration = theme?.motionDuration ?? const Duration(milliseconds: 200);
    final curve = theme?.motionCurve ?? Curves.easeInOut;

    // 3. Base color set karo (widget.color fix yahan hai)
    final baseColor = widget.color ?? theme?.primaryBrand ?? Colors.blueAccent;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.isLoading ? null : widget.onPressed,

        // AnimatedScale naye physics engine (curve/duration) ke sath
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: duration,
          curve: curve,
          child: AnimatedContainer(
            duration: duration,
            curve: curve,
            decoration: BoxDecoration(
              color: _getBackgroundColor(baseColor),
              borderRadius: BorderRadius.circular(12),
              border: _getBorder(baseColor),
              boxShadow: _isHovered && !_isPressed
                  ? [
                      theme?.glowingShadow ??
                          const BoxShadow(color: Colors.transparent),
                    ]
                  : [],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.text,
                      style: TextStyle(
                        color: _getTextColor(baseColor),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
