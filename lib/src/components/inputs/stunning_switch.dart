import 'package:flutter/material.dart';
import 'package:stunning_ui/src/theme/stunning_theme.dart';

/// A highly interactive, theme-aware toggle switch.
class StunningSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const StunningSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<StunningSwitch> createState() => _StunningSwitchState();
}

class _StunningSwitchState extends State<StunningSwitch> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<StunningTheme>();
    final duration = theme?.motionDuration ?? const Duration(milliseconds: 200);
    final curve = theme?.motionCurve ?? Curves.easeInOut;

    final brandColor = theme?.primaryBrand ?? Colors.blueAccent;
    final surfaceColor = theme?.surfaceGlass ?? Colors.white.withValues(alpha: 0.1);

    // --- THE MAGIC FIX ---
    final activeShadow = theme?.glowingShadow ?? const BoxShadow(color: Colors.transparent);
    // Inactive shadow with exact same geometry but transparent color
    final inactiveShadow = BoxShadow(
      color: Colors.transparent,
      blurRadius: activeShadow.blurRadius,
      spreadRadius: activeShadow.spreadRadius,
      offset: activeShadow.offset,
    );

    final trackColor = widget.value ? brandColor : surfaceColor;
    final thumbAlignment = widget.value ? Alignment.centerRight : Alignment.centerLeft;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onChanged(!widget.value);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        width: 56,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.value ? brandColor : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          // Always provide a shadow, just switch the colors
          boxShadow: [widget.value ? activeShadow : inactiveShadow],
        ),
        child: AnimatedAlign(
          duration: duration,
          curve: curve,
          alignment: thumbAlignment,
          child: AnimatedContainer(
            duration: duration,
            curve: curve,
            width: _isPressed ? 28 : 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}