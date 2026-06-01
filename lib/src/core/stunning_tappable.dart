import 'package:flutter/material.dart';
import '../theme/stunning_theme.dart';

/// Builds a child from the current interaction [states] (hovered / pressed /
/// disabled / selected). Lets a component drive its own visuals while
/// [StunningTappable] owns accessibility, keyboard and focus.
typedef StunningTappableBuilder = Widget Function(
    BuildContext context, Set<WidgetState> states);

/// The shared interaction primitive for every tappable Stunning component.
///
/// It gives — for free, with no work from the component — a proper [Semantics]
/// role (button / toggle / selected), screen-reader activation, full keyboard
/// support (Tab to focus, Enter/Space to activate), a focus-visible ring, and
/// a minimum 48x48 logical-pixel tap target. Pass [onPressed] `null` to
/// disable. Provide either a [child] or a state-driven [builder].
class StunningTappable extends StatefulWidget {
  /// Called on tap / Enter / Space. `null` disables the control.
  final VoidCallback? onPressed;

  /// Screen-reader label. Falls back to any text in [child].
  final String? semanticLabel;

  /// Expose a `button` role in semantics (default true). Ignored when
  /// [toggled] or [selected] is set (those imply their own role).
  final bool button;

  /// Switch/checkbox on-off state for semantics. `null` = not a toggle.
  final bool? toggled;

  /// Tab/segment selected state for semantics. `null` = not selectable.
  final bool? selected;

  /// Draw a focus ring when focused via keyboard.
  final bool showFocusRing;

  /// Minimum tap-target size (WCAG/Material recommend 48).
  final double minTargetSize;

  /// Shape of the focus ring; should match the child's corner radius.
  final BorderRadius borderRadius;

  final Widget? child;
  final StunningTappableBuilder? builder;

  const StunningTappable({
    super.key,
    required this.onPressed,
    this.semanticLabel,
    this.button = true,
    this.toggled,
    this.selected,
    this.showFocusRing = true,
    this.minTargetSize = 48.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.child,
    this.builder,
  }) : assert(child != null || builder != null,
            'Provide either a child or a builder');

  bool get enabled => onPressed != null;

  @override
  State<StunningTappable> createState() => _StunningTappableState();
}

class _StunningTappableState extends State<StunningTappable> {
  final Set<WidgetState> _states = <WidgetState>{};
  bool _focusVisible = false;

  void _set(WidgetState s, bool on) {
    if (on == _states.contains(s)) return;
    setState(() => on ? _states.add(s) : _states.remove(s));
  }

  void _activate() {
    if (!widget.enabled) return;
    Feedback.forTap(context);
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = StunningTheme.of(context);
    final enabled = widget.enabled;

    final states = <WidgetState>{
      ..._states,
      if (!enabled) WidgetState.disabled,
      if (widget.selected == true) WidgetState.selected,
    };

    Widget content =
        widget.builder != null ? widget.builder!(context, states) : widget.child!;

    if (widget.showFocusRing) {
      content = Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          content,
          if (_focusVisible && enabled)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    border: Border.all(color: theme.primaryBrand, width: 2),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    Widget result = FocusableActionDetector(
      enabled: enabled,
      mouseCursor:
          enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onShowFocusHighlight: (v) => setState(() => _focusVisible = v),
      onShowHoverHighlight: (v) => _set(WidgetState.hovered, v),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _activate();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(WidgetState.pressed, true) : null,
        onTapUp: enabled ? (_) => _set(WidgetState.pressed, false) : null,
        onTapCancel: enabled ? () => _set(WidgetState.pressed, false) : null,
        onTap: enabled ? _activate : null,
        child: content,
      ),
    );

    if (widget.minTargetSize > 0) {
      result = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.minTargetSize,
          minHeight: widget.minTargetSize,
        ),
        child: result,
      );
    }

    return MergeSemantics(
      child: Semantics(
        enabled: enabled,
        button: widget.button && widget.toggled == null && widget.selected == null,
        toggled: widget.toggled,
        selected: widget.selected,
        label: widget.semanticLabel,
        child: result,
      ),
    );
  }
}
