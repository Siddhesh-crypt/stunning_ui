import 'package:flutter/material.dart';
import '../../theme/stunning_theme.dart';

/// A small count / status pill, optionally anchored to a [child].
///
/// Use it standalone as an inline status chip, or pass a [child] (such as an
/// icon or avatar) to anchor the badge at the top-right corner — a tiny dot
/// when [label] is null, or a rounded count pill when a [label] is set
/// (e.g. `"9+"`). Toggling [show] animates the anchored badge in and out with a
/// reduce-motion-aware scale.
///
/// All chrome colours derive from the active [StunningTheme] so the badge works
/// in both light and dark mode with zero configuration.
class StunningBadge extends StatelessWidget {
  /// Text shown inside the pill (e.g. `"9+"`, `"NEW"`). When null and anchored
  /// to a [child], the badge renders as a small dot instead of a pill.
  final String? label;

  /// Fill colour of the badge. Defaults to the theme's `primaryBrand`. The
  /// label text colour is derived automatically for contrast via
  /// `StunningTheme.onColor`.
  final Color? color;

  /// Optional widget to anchor the badge onto. When provided (and
  /// [standalone] is false) the badge floats at the top-right of this child.
  /// When null, only the pill itself is rendered.
  final Widget? child;

  /// Whether the badge is visible. When anchored to a [child] this is animated
  /// (scale in/out, reduce-motion aware). Defaults to true.
  final bool show;

  /// Forces the badge to render as a lone pill even when a [child] is given,
  /// instead of anchoring it. Defaults to false.
  final bool standalone;

  /// Creates a count / status badge.
  const StunningBadge({
    super.key,
    this.label,
    this.color,
    this.child,
    this.show = true,
    this.standalone = false,
  });

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final fill = color ?? st.primaryBrand;

    // No anchor (or explicitly standalone): render just the pill.
    if (child == null || standalone) {
      return Semantics(
        label: 'badge ${label ?? ''}'.trim(),
        container: true,
        child: _Pill(label: label, fill: fill, st: st),
      );
    }

    // Anchored: stack the child with the badge floating at the top-right.
    final dot = label == null;
    final badge = dot
        ? _Dot(fill: fill, st: st)
        : _Pill(label: label, fill: fill, st: st);

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child!,
        Positioned(
          top: -4,
          right: -4,
          child: Semantics(
            label: 'badge ${label ?? ''}'.trim(),
            container: true,
            child: TweenAnimationBuilder<double>(
              // Scale in when shown, out when hidden. Geometry only — no shadow
              // tween toward zero, so an overshoot motionCurve can't drive a
              // negative blur radius.
              tween: Tween<double>(begin: show ? 1.0 : 0.0, end: show ? 1.0 : 0.0),
              duration: st.motion(context),
              curve: st.motionCurve,
              builder: (context, value, animChild) {
                return Transform.scale(
                  scale: value,
                  alignment: Alignment.center,
                  child: animChild,
                );
              },
              child: badge,
            ),
          ),
        ),
      ],
    );
  }
}

/// A small filled dot used when an anchored badge has no [label].
class _Dot extends StatelessWidget {
  final Color fill;
  final StunningTheme st;

  const _Dot({required this.fill, required this.st});

  @override
  Widget build(BuildContext context) {
    // Constant shadow geometry: transparent when glow is off, but the radii are
    // never animated, so an overshoot curve cannot push blur negative.
    final glow = st.glowIntensity;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: st.backgroundHint, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: glow > 0 ? fill.withValues(alpha: 0.5 * glow) : Colors.transparent,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// A rounded count / status pill with theme-aware contrast text.
class _Pill extends StatelessWidget {
  final String? label;
  final Color fill;
  final StunningTheme st;

  const _Pill({required this.label, required this.fill, required this.st});

  @override
  Widget build(BuildContext context) {
    final text = label ?? '';
    final glow = st.glowIntensity;
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: st.borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: glow > 0 ? fill.withValues(alpha: 0.5 * glow) : Colors.transparent,
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: st.onColor(fill),
          fontSize: 11,
          height: 1.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
