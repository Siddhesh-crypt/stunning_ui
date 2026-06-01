import 'package:flutter/material.dart';

import '../theme/stunning_theme.dart';

/// Recolours an entire subtree from a single colour, without rebuilding the
/// whole app's theme. Inherits the parent [StunningTheme]'s brightness and
/// style unless overridden, so a section / card / branded area can carry its
/// own accent in a multi-brand app.
///
/// ```dart
/// StunningAccent(
///   seedColor: const Color(0xFFFF7A00),
///   child: const PromoCard(),
/// );
/// ```
class StunningAccent extends StatelessWidget {
  /// The accent brand colour for this subtree.
  final Color seedColor;

  /// Optional second brand colour (auto-harmonised onto [seedColor]).
  final Color? secondaryColor;

  /// How the secondary/tertiary are derived. Defaults to [StunningHarmony.auto].
  final StunningHarmony harmony;

  /// Override the inherited style (otherwise the parent theme's style is kept).
  final StunningUIStyle? style;

  /// Override the inherited brightness.
  final Brightness? brightness;

  final Widget child;

  const StunningAccent({
    super.key,
    required this.seedColor,
    this.secondaryColor,
    this.harmony = StunningHarmony.auto,
    this.style,
    this.brightness,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final parent = StunningTheme.of(context);
    final accent = StunningTheme.generate(
      seedColor: seedColor,
      secondaryColor: secondaryColor,
      harmony: harmony,
      brightness: brightness ?? parent.brightness,
      style: style ?? parent.style,
    );
    return Theme(data: accent.toThemeData(), child: child);
  }
}

class _StunningThemeTween extends Tween<StunningTheme> {
  _StunningThemeTween({super.begin});

  @override
  StunningTheme lerp(double t) => begin!.lerp(end, t);
}

/// Animates smoothly between [StunningTheme]s whenever [theme] changes —
/// every token (colour scheme, glass blur, glow, border, motion, palette
/// gradients) interpolates via [StunningTheme.lerp].
///
/// This is how you "morph" the whole app's personality: wrap your app once and
/// just hand it a new theme (e.g. a different [StunningUIStyle] or seed) and it
/// animates there.
///
/// ```dart
/// StunningAnimatedTheme(
///   theme: _dark ? StunningTheme.dark() : StunningTheme.light(),
///   child: MaterialApp(/* ... */),
/// );
/// ```
class StunningAnimatedTheme extends ImplicitlyAnimatedWidget {
  final StunningTheme theme;
  final Widget child;

  const StunningAnimatedTheme({
    super.key,
    required this.theme,
    required this.child,
    super.duration = const Duration(milliseconds: 400),
    super.curve,
    super.onEnd,
  });

  @override
  AnimatedWidgetBaseState<StunningAnimatedTheme> createState() =>
      _StunningAnimatedThemeState();
}

class _StunningAnimatedThemeState
    extends AnimatedWidgetBaseState<StunningAnimatedTheme> {
  _StunningThemeTween? _tween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _tween =
        visitor(
              _tween,
              widget.theme,
              (dynamic value) => _StunningThemeTween(begin: value),
            )
            as _StunningThemeTween?;
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _tween!.evaluate(animation);
    return Theme(data: resolved.toThemeData(), child: widget.child);
  }
}
