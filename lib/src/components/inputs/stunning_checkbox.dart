import 'package:flutter/material.dart';
import '../../core/stunning_tappable.dart';
import '../../theme/stunning_theme.dart';

/// A physics-y, glowing checkbox built on [StunningTappable].
///
/// Renders a ~22px rounded square that, when [value] is true, fills with
/// ([activeColor] ?? `st.primaryBrand`), draws a glow, and animates a check
/// icon in (scale + opacity) using `st.motion(context)`. When unchecked it is
/// transparent with a `st.borderColor` border. Passing `null` to [onChanged]
/// disables the control (dimmed and non-interactive), mirroring Flutter's own
/// [Checkbox]. Toggle semantics, keyboard activation, a focus ring and a 48dp
/// minimum tap target all come from [StunningTappable].
class StunningCheckbox extends StatelessWidget {
  /// Whether the checkbox is currently checked.
  final bool value;

  /// Called with the new value when the checkbox is toggled. Pass `null` to
  /// disable the control.
  final ValueChanged<bool>? onChanged;

  /// Screen-reader label describing what this checkbox controls.
  final String? semanticLabel;

  /// Fill / glow colour when checked. Defaults to `st.primaryBrand`.
  final Color? activeColor;

  /// Creates a glowing, theme-aware checkbox.
  const StunningCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.activeColor,
  });

  /// The visual size of the box (the tap target is enforced at 48dp by
  /// [StunningTappable]).
  static const double _boxSize = 22.0;

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final duration = st.motion(context);
    final curve = st.motionCurve;

    final enabled = onChanged != null;
    final fillColor = activeColor ?? st.primaryBrand;

    // Glow only when checked; keep identical geometry when off so the shadow
    // animates by colour alone (matches the switch's "magic fix").
    final activeShadow = st.glowingShadow;
    final glowColor = fillColor.withValues(
      alpha: 0.5 * (st.glowIntensity <= 0 ? 0 : st.glowIntensity),
    );

    return StunningTappable(
      onPressed: enabled ? () => onChanged!(!value) : null,
      toggled: value,
      semanticLabel: semanticLabel,
      borderRadius: BorderRadius.circular(6),
      builder: (context, states) {
        final isPressed = states.contains(WidgetState.pressed);

        Widget box = AnimatedContainer(
          duration: duration,
          curve: curve,
          width: _boxSize,
          height: _boxSize,
          decoration: BoxDecoration(
            color: value ? fillColor : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: value ? fillColor : st.borderColor,
              width: 2,
            ),
            boxShadow: <BoxShadow>[
              if (value)
                BoxShadow(
                  color: glowColor,
                  blurRadius: activeShadow.blurRadius,
                  spreadRadius: activeShadow.spreadRadius,
                  offset: activeShadow.offset,
                )
              else
                BoxShadow(
                  color: Colors.transparent,
                  blurRadius: activeShadow.blurRadius,
                  spreadRadius: activeShadow.spreadRadius,
                  offset: activeShadow.offset,
                ),
            ],
          ),
          child: Center(
            // Animated check-in: scale + fade the tick using the motion token.
            child: AnimatedScale(
              duration: duration,
              curve: curve,
              scale: value ? (isPressed ? 0.85 : 1.0) : 0.0,
              child: AnimatedOpacity(
                duration: duration,
                curve: curve,
                opacity: value ? 1.0 : 0.0,
                child: Icon(
                  Icons.check_rounded,
                  size: _boxSize - 6,
                  color: st.onColor(fillColor),
                ),
              ),
            ),
          ),
        );

        // Dim the whole control when disabled, like Flutter's own checkbox.
        return AnimatedOpacity(
          duration: duration,
          curve: curve,
          opacity: enabled ? 1.0 : 0.38,
          child: box,
        );
      },
    );
  }
}
