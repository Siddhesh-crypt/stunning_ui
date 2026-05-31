import 'package:flutter/material.dart';
import 'package:stunning_ui/src/theme/stunning_theme.dart';
import 'dart:ui';

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

class _StunningButtonState extends State<StunningButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<StunningTheme>();

    // Core Logic: Use custom color if provided, otherwise use theme, fallback to purple.
    final baseColor =
        widget.color ?? theme?.primaryBrand ?? Colors.purpleAccent;
    final isDisabled = widget.onPressed == null;

    // Logic to determine colors based on variant
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    List<BoxShadow> shadows = [];

    switch (widget.variant) {
      case StunningButtonVariant.primary:
        backgroundColor = baseColor.withValues(alpha: isDisabled ? 0.3 : 1.0);
        borderColor = Colors.transparent;
        textColor = Colors.white;
        if (!isDisabled) {
          shadows = [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ];
        }
        break;
      case StunningButtonVariant.outline:
        backgroundColor = baseColor.withValues(alpha: 0.1);
        borderColor = baseColor.withValues(alpha: isDisabled ? 0.3 : 0.8);
        textColor = baseColor;
        break;
      case StunningButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        borderColor = Colors.transparent;
        textColor = baseColor.withValues(alpha: isDisabled ? 0.5 : 1.0);
        break;
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: shadows,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.variant == StunningButtonVariant.ghost ? 0 : 10,
                sigmaY: widget.variant == StunningButtonVariant.ghost ? 0 : 10,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: textColor,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        widget.text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
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
