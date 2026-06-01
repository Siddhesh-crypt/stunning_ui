import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/stunning_theme.dart';

/// A draggable value slider with a theme-aware, glowing thumb.
///
/// The user drags the thumb (or taps the track) to pick a value within
/// [min]..[max]. When [divisions] is set the value snaps to the nearest
/// step. The active portion of the track is painted with [activeColor]
/// (falling back to the theme's brand colour) and the thumb lights up with
/// the theme's [StunningTheme.glowingShadow] while active or pressed.
///
/// Accessibility is built in: the control exposes a `slider` [Semantics] role
/// with the current value, keeps a >=48dp tall hit area, and supports
/// arrow-key adjustment when focused. Passing `null` to [onChanged] disables
/// the slider (dimmed and non-interactive), mirroring Flutter's own controls.
class StunningSlider extends StatefulWidget {
  /// The current value. Clamped to [min]..[max].
  final double value;

  /// Called when the user changes the value by dragging, tapping the track,
  /// or pressing the arrow keys. Pass `null` to disable the slider.
  final ValueChanged<double>? onChanged;

  /// The lowest selectable value. Defaults to `0.0`.
  final double min;

  /// The highest selectable value. Defaults to `1.0`.
  final double max;

  /// If non-null, the number of discrete steps the value snaps to between
  /// [min] and [max]. `null` means continuous.
  final int? divisions;

  /// Colour of the active (filled) portion of the track and the thumb.
  /// Falls back to [StunningTheme.primaryBrand] when omitted.
  final Color? activeColor;

  /// Creates a draggable slider.
  const StunningSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.activeColor,
  });

  /// Whether the slider responds to input.
  bool get enabled => onChanged != null;

  @override
  State<StunningSlider> createState() => _StunningSliderState();
}

class _StunningSliderState extends State<StunningSlider> {
  static const double _trackHeight = 6.0;
  static const double _thumbRadius = 11.0;
  static const double _minTargetSize = 48.0;

  bool _dragging = false;

  /// Clamp + snap [raw] to a valid value within the configured range.
  double _normalize(double raw) {
    final lo = widget.min;
    final hi = widget.max;
    if (hi <= lo) return lo;
    double v = raw.clamp(lo, hi);
    final divisions = widget.divisions;
    if (divisions != null && divisions > 0) {
      final step = (hi - lo) / divisions;
      final snapped = lo + ((v - lo) / step).round() * step;
      v = snapped.clamp(lo, hi);
    }
    return v;
  }

  /// Fractional position (0..1) of the current value within the range.
  double get _fraction {
    final lo = widget.min;
    final hi = widget.max;
    if (hi <= lo) return 0.0;
    final v = _normalize(widget.value);
    return ((v - lo) / (hi - lo)).clamp(0.0, 1.0);
  }

  /// One discrete step, used for keyboard adjustment.
  double get _step {
    final divisions = widget.divisions;
    if (divisions != null && divisions > 0) {
      return (widget.max - widget.min) / divisions;
    }
    // Continuous: nudge by 10% of the range per key press.
    return (widget.max - widget.min) / 10.0;
  }

  void _emit(double value) {
    final v = _normalize(value);
    if (v != _normalize(widget.value)) {
      widget.onChanged!(v);
    }
  }

  void _updateFromDx(double localDx, double trackWidth) {
    if (trackWidth <= 0) return;
    final t = (localDx / trackWidth).clamp(0.0, 1.0);
    _emit(widget.min + t * (widget.max - widget.min));
  }

  void _adjust(double delta) {
    if (!widget.enabled) return;
    _emit(_normalize(widget.value) + delta);
  }

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final enabled = widget.enabled;
    final duration = st.motion(context);
    final curve = st.motionCurve;

    final active = widget.activeColor ?? st.primaryBrand;
    final inactive = st.borderColor;

    // Dim the whole control when disabled, like Flutter's own widgets.
    final opacity = enabled ? 1.0 : 0.38;

    final glow = st.glowingShadow;
    final showGlow = enabled && (_dragging);
    // Same geometry, transparent colour, so the shadow can animate in/out
    // without a layout jump.
    final thumbShadow =
        showGlow
            ? glow
            : BoxShadow(
              color: Colors.transparent,
              blurRadius: glow.blurRadius,
              spreadRadius: glow.spreadRadius,
              offset: glow.offset,
            );

    final roundedValue = _normalize(widget.value);
    String fmtValue(double v) =>
        (widget.divisions != null)
            ? v.toStringAsFixed(0)
            : v.toStringAsFixed(2);
    final valueLabel = fmtValue(roundedValue);

    return Semantics(
      slider: true,
      enabled: enabled,
      value: valueLabel,
      // increasedValue/decreasedValue are required by the framework whenever
      // increase/decrease actions are present.
      increasedValue: fmtValue(_normalize(widget.value + _step)),
      decreasedValue: fmtValue(_normalize(widget.value - _step)),
      // Let assistive tech drive the value too.
      onIncrease: enabled ? () => _adjust(_step) : null,
      onDecrease: enabled ? () => _adjust(-_step) : null,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor:
            enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowRight): _AdjustIntent(
            forward: true,
          ),
          SingleActivator(LogicalKeyboardKey.arrowUp): _AdjustIntent(
            forward: true,
          ),
          SingleActivator(LogicalKeyboardKey.arrowLeft): _AdjustIntent(
            forward: false,
          ),
          SingleActivator(LogicalKeyboardKey.arrowDown): _AdjustIntent(
            forward: false,
          ),
        },
        actions: <Type, Action<Intent>>{
          _AdjustIntent: CallbackAction<_AdjustIntent>(
            onInvoke: (intent) {
              _adjust(intent.forward ? _step : -_step);
              return null;
            },
          ),
        },
        child: Opacity(
          opacity: opacity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width =
                  constraints.maxWidth.isFinite ? constraints.maxWidth : 200.0;
              // The thumb centre travels between these two x positions so it
              // never overflows the track edges.
              final usableWidth = (width - 2 * _thumbRadius).clamp(0.0, width);

              void handleDx(double localDx) {
                _updateFromDx(localDx - _thumbRadius, usableWidth);
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: enabled ? (d) => handleDx(d.localPosition.dx) : null,
                onHorizontalDragStart:
                    enabled
                        ? (d) {
                          setState(() => _dragging = true);
                          handleDx(d.localPosition.dx);
                        }
                        : null,
                onHorizontalDragUpdate:
                    enabled ? (d) => handleDx(d.localPosition.dx) : null,
                onHorizontalDragEnd:
                    enabled ? (_) => setState(() => _dragging = false) : null,
                onHorizontalDragCancel:
                    enabled ? () => setState(() => _dragging = false) : null,
                child: SizedBox(
                  height: _minTargetSize,
                  width: width,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      // Inactive track.
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: _trackHeight,
                          decoration: BoxDecoration(
                            color: inactive,
                            borderRadius: BorderRadius.circular(
                              _trackHeight / 2,
                            ),
                          ),
                        ),
                      ),
                      // Active fill.
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedContainer(
                          duration: duration,
                          curve: curve,
                          height: _trackHeight,
                          width: _thumbRadius + usableWidth * _fraction,
                          decoration: BoxDecoration(
                            color: active,
                            borderRadius: BorderRadius.circular(
                              _trackHeight / 2,
                            ),
                          ),
                        ),
                      ),
                      // Thumb.
                      AnimatedPositioned(
                        duration: duration,
                        curve: curve,
                        left: usableWidth * _fraction,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: AnimatedContainer(
                            duration: duration,
                            curve: curve,
                            width: _thumbRadius * 2,
                            height: _thumbRadius * 2,
                            decoration: BoxDecoration(
                              color: active,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: st
                                    .onColor(active)
                                    .withValues(alpha: 0.9),
                                width: 2,
                              ),
                              boxShadow: <BoxShadow>[thumbShadow],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Intent fired by arrow keys to nudge the slider value up or down.
class _AdjustIntent extends Intent {
  final bool forward;
  const _AdjustIntent({required this.forward});
}
