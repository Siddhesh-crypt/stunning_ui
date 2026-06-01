import 'package:flutter/material.dart';
import '../../core/stunning_tappable.dart';
import '../../theme/stunning_theme.dart';

/// A generic, theme-aware single-choice radio button — the Stunning analogue of
/// Material's `Radio<T>`.
///
/// The control is *selected* when [value] equals [groupValue]. It paints an
/// outer ring with an animated inner dot that scales in when selected. All
/// chrome colours come from the active [StunningTheme] so it works in both light
/// and dark mode, the motion honours the OS reduce-motion setting via
/// `st.motion(context)`, and accessibility (48dp tap target, focus ring,
/// keyboard activation, mutually-exclusive semantics) is provided by
/// [StunningTappable].
///
/// Pass `null` to [onChanged] to render the radio disabled (dimmed and
/// non-interactive), mirroring Flutter's own controls.
class StunningRadio<T> extends StatelessWidget {
  /// The value this radio represents within its group.
  final T value;

  /// The currently-selected value for the group. This radio is selected when
  /// [value] equals [groupValue].
  final T? groupValue;

  /// Called with [value] when the user selects this radio. Pass `null` to
  /// disable the control (dimmed, non-interactive).
  final ValueChanged<T?>? onChanged;

  /// Optional screen-reader label describing this choice.
  final String? semanticLabel;

  /// Overrides the brand colour used for the ring/dot when selected. Defaults
  /// to `st.primaryBrand` when omitted.
  final Color? activeColor;

  /// Creates a single-choice radio button.
  const StunningRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.semanticLabel,
    this.activeColor,
  });

  /// Whether this radio is currently the selected choice in its group.
  bool get _selected => value == groupValue;

  /// Whether the control is interactive.
  bool get _enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final duration = st.motion(context);
    final curve = st.motionCurve;

    final selectedColor = activeColor ?? st.primaryBrand;
    final ringColor = _selected ? selectedColor : st.borderColor;

    // Dim the whole control when disabled, like Flutter's own controls.
    final double opacity = _enabled ? 1.0 : 0.38;

    return StunningTappable(
      onPressed: _enabled ? () => onChanged!(value) : null,
      selected: _selected,
      semanticLabel: semanticLabel,
      borderRadius: BorderRadius.circular(999),
      builder: (context, states) {
        return Semantics(
          inMutuallyExclusiveGroup: true,
          child: AnimatedOpacity(
            duration: duration,
            curve: curve,
            opacity: opacity,
            child: AnimatedContainer(
              duration: duration,
              curve: curve,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 2),
                // Constant-geometry shadow (transparent when off) so the
                // decoration tween only animates colour — an overshoot curve
                // must never extrapolate blurRadius below zero.
                boxShadow: <BoxShadow>[
                  _selected && st.glowIntensity > 0
                      ? st.glowingShadow
                      : BoxShadow(
                        color: Colors.transparent,
                        blurRadius: st.glowingShadow.blurRadius,
                        spreadRadius: st.glowingShadow.spreadRadius,
                        offset: st.glowingShadow.offset,
                      ),
                ],
              ),
              alignment: Alignment.center,
              child: AnimatedScale(
                duration: duration,
                curve: curve,
                scale: _selected ? 1.0 : 0.0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
