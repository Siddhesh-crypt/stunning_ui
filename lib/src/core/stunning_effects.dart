import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../theme/stunning_theme.dart';
import 'glass_surface.dart';

/// Fluent entry point for the Stunning motion engine:
///
/// ```dart
/// myCard.stunning().glow().tilt().springIn()
/// ```
///
/// Every effect pulls its physics from the active [StunningTheme] spring token
/// and honors the OS reduce-motion setting automatically.
extension StunningWidgetX on Widget {
  Stunning stunning() => Stunning(child: this);
}

/// Stagger a list of widgets into view with a spring entrance, e.g.
/// `Column(children: cards.stunningStagger())`.
extension StunningStaggerX on List<Widget> {
  List<Widget> stunningStagger({
    Duration interval = const Duration(milliseconds: 70),
    double fromScale = 0.9,
    Offset fromOffset = const Offset(0, 18),
  }) {
    return <Widget>[
      for (int i = 0; i < length; i++)
        this[i].stunning().springIn(
              delay: interval * i,
              fromScale: fromScale,
              fromOffset: fromOffset,
            ),
    ];
  }
}

/// Internal description of one effect in a [Stunning] chain.
abstract class _Effect {
  const _Effect();
  Widget wrap(Widget child);
}

/// A chainable bundle of motion effects around [child] (flutter_animate style).
/// Each method returns a new [Stunning] with the effect appended, so the calls
/// read top-to-bottom and the last one wraps outermost.
class Stunning extends StatelessWidget {
  final Widget child;
  final List<_Effect> _effects;

  const Stunning({super.key, required this.child})
      : _effects = const <_Effect>[];

  const Stunning._({super.key, required this.child, required List<_Effect> effects})
      : _effects = effects;

  Stunning _add(_Effect e) =>
      Stunning._(key: key, effects: <_Effect>[..._effects, e], child: child);

  /// Spring-physics entrance: fades + scales (+ optional slide) into place.
  Stunning springIn({
    double fromScale = 0.85,
    Offset fromOffset = Offset.zero,
    Duration delay = Duration.zero,
  }) =>
      _add(_SpringInEffect(fromScale: fromScale, fromOffset: fromOffset, delay: delay));

  /// Adds the theme's brand glow. Set [pulse] for a gentle breathing glow.
  Stunning glow({
    double blur = 26,
    double spread = 1,
    bool pulse = false,
    Color? color,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
  }) =>
      _add(_GlowEffect(
          blur: blur, spread: spread, pulse: pulse, color: color, borderRadius: borderRadius));

  /// Interactive 3D tilt that follows the pointer and springs back on exit.
  Stunning tilt({double max = 0.12}) => _add(_TiltEffect(maxTilt: max));

  /// Wraps the child in a [GlassSurface] — refraction on Impeller, blur
  /// elsewhere, solid under reduce-transparency.
  Stunning glass({
    double? blur,
    double radius = 20,
    bool refract = true,
    Color? tint,
    double tintAmount = 0.08,
    bool border = true,
  }) =>
      _add(_GlassEffect(
          blur: blur,
          radius: radius,
          refract: refract,
          tint: tint,
          tintAmount: tintAmount,
          border: border));

  @override
  Widget build(BuildContext context) {
    var result = child;
    for (final e in _effects) {
      result = e.wrap(result); // effects[0] ends up innermost
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// springIn
// ---------------------------------------------------------------------------

class _SpringInEffect extends _Effect {
  final double fromScale;
  final Offset fromOffset;
  final Duration delay;
  const _SpringInEffect(
      {required this.fromScale, required this.fromOffset, required this.delay});
  @override
  Widget wrap(Widget child) => _SpringIn(
      fromScale: fromScale, fromOffset: fromOffset, delay: delay, child: child);
}

class _SpringIn extends StatefulWidget {
  final Widget child;
  final double fromScale;
  final Offset fromOffset;
  final Duration delay;
  const _SpringIn(
      {required this.child,
      required this.fromScale,
      required this.fromOffset,
      required this.delay});
  @override
  State<_SpringIn> createState() => _SpringInState();
}

class _SpringInState extends State<_SpringIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController.unbounded(vsync: this);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (StunningTheme.reduceMotion(context)) {
      _c.value = 1.0; // appear instantly
      return;
    }
    final sim = SpringSimulation(
        StunningTheme.of(context).spring.toSpring(), 0, 1, 0,
        snapToEnd: true);
    if (widget.delay == Duration.zero) {
      _c.animateWith(sim);
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _c.animateWith(sim);
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final v = _c.value; // 0 .. ~1 (may overshoot when bouncy)
        final opacity = v.clamp(0.0, 1.0);
        final scale = widget.fromScale + (1 - widget.fromScale) * v;
        final offset = Offset.lerp(widget.fromOffset, Offset.zero, opacity)!;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: offset,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// glow
// ---------------------------------------------------------------------------

class _GlowEffect extends _Effect {
  final double blur;
  final double spread;
  final bool pulse;
  final Color? color;
  final BorderRadius borderRadius;
  const _GlowEffect(
      {required this.blur,
      required this.spread,
      required this.pulse,
      required this.color,
      required this.borderRadius});
  @override
  Widget wrap(Widget child) => _Glow(
      blur: blur,
      spread: spread,
      pulse: pulse,
      color: color,
      borderRadius: borderRadius,
      child: child);
}

class _Glow extends StatefulWidget {
  final Widget child;
  final double blur;
  final double spread;
  final bool pulse;
  final Color? color;
  final BorderRadius borderRadius;
  const _Glow(
      {required this.child,
      required this.blur,
      required this.spread,
      required this.pulse,
      required this.color,
      required this.borderRadius});
  @override
  State<_Glow> createState() => _GlowState();
}

class _GlowState extends State<_Glow> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shouldPulse = widget.pulse && !StunningTheme.reduceMotion(context);
    if (shouldPulse && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!shouldPulse && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final base = widget.color ?? st.primaryBrand;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = widget.pulse ? _c.value : 1.0;
        final alpha = 0.3 + 0.35 * t;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: base.withValues(alpha: alpha),
                blurRadius: widget.blur,
                spreadRadius: widget.spread,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// tilt
// ---------------------------------------------------------------------------

class _TiltEffect extends _Effect {
  final double maxTilt;
  const _TiltEffect({required this.maxTilt});
  @override
  Widget wrap(Widget child) => _Tilt(maxTilt: maxTilt, child: child);
}

class _GlassEffect extends _Effect {
  final double? blur;
  final double radius;
  final bool refract;
  final Color? tint;
  final double tintAmount;
  final bool border;
  const _GlassEffect({
    required this.blur,
    required this.radius,
    required this.refract,
    required this.tint,
    required this.tintAmount,
    required this.border,
  });
  @override
  Widget wrap(Widget child) => GlassSurface(
        blur: blur,
        borderRadius: radius,
        refract: refract,
        tint: tint,
        tintAmount: tintAmount,
        border: border,
        child: child,
      );
}

class _Tilt extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  const _Tilt({required this.child, required this.maxTilt});
  @override
  State<_Tilt> createState() => _TiltState();
}

class _TiltState extends State<_Tilt> with SingleTickerProviderStateMixin {
  late final AnimationController _return;

  // (rotateX, rotateY) in radians.
  Offset _rotation = Offset.zero;
  Offset _from = Offset.zero;

  @override
  void initState() {
    super.initState();
    // Created eagerly (not lazily) so dispose never has to construct a ticker
    // while the widget tree is being finalized.
    _return = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        setState(() {
          _rotation =
              Offset.lerp(_from, Offset.zero, _return.value.clamp(0.0, 1.0))!;
        });
      });
  }

  void _onHover(Offset local, Size size) {
    if (StunningTheme.reduceMotion(context) || size.isEmpty) return;
    _return.stop();
    final dx = (local.dx / size.width) - 0.5; // -0.5 .. 0.5
    final dy = (local.dy / size.height) - 0.5;
    setState(() {
      _rotation = Offset(-dy * widget.maxTilt, dx * widget.maxTilt);
    });
  }

  void _springBack() {
    if (StunningTheme.reduceMotion(context)) {
      setState(() => _rotation = Offset.zero);
      return;
    }
    _from = _rotation;
    _return
      ..value = 0
      ..animateWith(SpringSimulation(
          StunningTheme.of(context).spring.toSpring(), 0, 1, 0,
          snapToEnd: true));
  }

  @override
  void dispose() {
    _return.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return MouseRegion(
          onHover: (e) => _onHover(e.localPosition, size),
          onExit: (_) => _springBack(),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015) // perspective
              ..rotateX(_rotation.dx)
              ..rotateY(_rotation.dy),
            child: widget.child,
          ),
        );
      },
    );
  }
}
