import 'package:flutter/material.dart';
import '../../core/stunning_tappable.dart';
import '../../theme/stunning_theme.dart';

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
  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final duration = st.motion(context);
    final curve = st.motionCurve;

    final brandColor = st.primaryBrand;
    final surfaceColor = st.surfaceGlass;

    // --- THE MAGIC FIX ---
    final activeShadow = st.glowingShadow;
    // Inactive shadow with exact same geometry but transparent color
    final inactiveShadow = BoxShadow(
      color: Colors.transparent,
      blurRadius: activeShadow.blurRadius,
      spreadRadius: activeShadow.spreadRadius,
      offset: activeShadow.offset,
    );

    final trackColor = widget.value ? brandColor : surfaceColor;
    final thumbAlignment =
        widget.value ? Alignment.centerRight : Alignment.centerLeft;

    return StunningTappable(
      onPressed: () => widget.onChanged(!widget.value),
      toggled: widget.value,
      borderRadius: BorderRadius.circular(16),
      builder: (context, states) {
        final isPressed = states.contains(WidgetState.pressed);
        return AnimatedContainer(
          duration: duration,
          curve: curve,
          width: 56,
          height: 32,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.value ? brandColor : st.borderColor,
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
              width: isPressed ? 28 : 22,
              height: 22,
              decoration: BoxDecoration(
                color: st.onColor(trackColor),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
