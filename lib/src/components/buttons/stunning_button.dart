import 'package:flutter/material.dart';
import '../../core/stunning_tappable.dart';
import '../../theme/stunning_theme.dart';

/// Defines the visual style of the [StunningButton].
enum StunningButtonVariant {
  /// Solid filled button.
  primary,

  /// Transparent with a coloured border.
  outline,

  /// Transparent, colour-on-hover.
  ghost,

  /// Soft tinted fill (Material "tonal").
  tonal,

  /// Solid filled using the theme error colour — for destructive actions.
  danger,
}

/// Size scale for [StunningButton].
enum StunningButtonSize { small, medium, large }

/// A highly interactive, physics-based button. Accessible by default: button
/// role for screen readers, keyboard focus + Enter/Space activation, a focus
/// ring, a 48dp tap target, and reduce-motion support.
///
/// Provide [text], an [icon], or a fully custom [child]. `text` + `icon`
/// renders an icon-label row.
class StunningButton extends StatelessWidget {
  /// The label text. Optional when [icon] or [child] is provided.
  final String? text;

  /// Leading icon. Combine with [text] for an icon button.
  final IconData? icon;

  /// Fully custom content (takes precedence over [text]/[icon]).
  final Widget? child;

  /// Tapped callback. If null, the button is disabled.
  final VoidCallback? onPressed;

  /// Loading state — shows a spinner and disables taps.
  final bool isLoading;

  /// Visual style variant. Defaults to [StunningButtonVariant.primary].
  final StunningButtonVariant variant;

  /// Size scale. Defaults to [StunningButtonSize.medium].
  final StunningButtonSize size;

  /// Custom base colour. Falls back to the theme brand (or error for danger).
  final Color? color;

  /// Screen-reader label for icon-only buttons (no visible text).
  final String? semanticLabel;

  const StunningButton({
    super.key,
    this.text,
    this.icon,
    this.child,
    this.onPressed,
    this.isLoading = false,
    this.variant = StunningButtonVariant.primary,
    this.size = StunningButtonSize.medium,
    this.color,
    this.semanticLabel,
  }) : assert(
         text != null || icon != null || child != null,
         'Provide text, icon, or child',
       );

  EdgeInsets get _padding => switch (size) {
    StunningButtonSize.small => const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    StunningButtonSize.medium => const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 16,
    ),
    StunningButtonSize.large => const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 20,
    ),
  };

  double get _fontSize => switch (size) {
    StunningButtonSize.small => 14,
    StunningButtonSize.medium => 16,
    StunningButtonSize.large => 18,
  };

  double get _iconSize => switch (size) {
    StunningButtonSize.small => 16,
    StunningButtonSize.medium => 18,
    StunningButtonSize.large => 22,
  };

  bool get _isFilled =>
      variant == StunningButtonVariant.primary ||
      variant == StunningButtonVariant.danger;

  Color _baseColor(StunningTheme st) {
    if (color != null) return color!;
    if (variant == StunningButtonVariant.danger) {
      return st.colorScheme?.error ?? const Color(0xFFEF4444);
    }
    return st.primaryBrand;
  }

  Color _backgroundColor(Color base, bool hovered) {
    switch (variant) {
      case StunningButtonVariant.primary:
      case StunningButtonVariant.danger:
        return base.withValues(alpha: hovered ? 0.85 : 1.0);
      case StunningButtonVariant.tonal:
        return base.withValues(alpha: hovered ? 0.26 : 0.16);
      case StunningButtonVariant.outline:
      case StunningButtonVariant.ghost:
        return hovered ? base.withValues(alpha: 0.1) : Colors.transparent;
    }
  }

  BoxBorder? _border(Color base) =>
      variant == StunningButtonVariant.outline
          ? Border.all(color: base, width: 2)
          : null;

  Color _foreground(StunningTheme st, Color base) =>
      _isFilled ? st.onColor(base) : base;

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final base = _baseColor(st);
    final fg = _foreground(st, base);
    final enabled = onPressed != null && !isLoading;
    final duration = st.motion(context);
    final curve = st.motionCurve;

    return StunningTappable(
      onPressed: enabled ? onPressed : null,
      // Visible text supplies the label; only set an explicit label for
      // icon-only buttons to avoid double announcements.
      semanticLabel: text == null && child == null ? semanticLabel : null,
      borderRadius: BorderRadius.circular(12),
      builder: (context, states) {
        final hovered = states.contains(WidgetState.hovered);
        final pressed = states.contains(WidgetState.pressed);
        return AnimatedScale(
          scale: pressed ? 0.95 : 1.0,
          duration: duration,
          curve: curve,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: AnimatedContainer(
              duration: duration,
              curve: curve,
              decoration: BoxDecoration(
                color: _backgroundColor(base, hovered),
                borderRadius: BorderRadius.circular(12),
                border: _border(base),
                boxShadow:
                    hovered && !pressed && enabled && _isFilled
                        ? <BoxShadow>[st.glowingShadow]
                        : const <BoxShadow>[],
              ),
              padding: _padding,
              child: Center(child: _content(fg)),
            ),
          ),
        );
      },
    );
  }

  Widget _content(Color fg) {
    if (isLoading) {
      return SizedBox(
        height: _fontSize + 4,
        width: _fontSize + 4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    }
    if (child != null) return child!;
    final label =
        text != null
            ? Text(
              text!,
              style: TextStyle(
                color: fg,
                fontSize: _fontSize,
                fontWeight: FontWeight.bold,
              ),
            )
            : null;
    final leading =
        icon != null ? Icon(icon, size: _iconSize, color: fg) : null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (leading != null) leading,
        if (leading != null && label != null) const SizedBox(width: 8),
        if (label != null) label,
      ],
    );
  }
}
