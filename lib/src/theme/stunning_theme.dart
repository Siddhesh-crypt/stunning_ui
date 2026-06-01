import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// Defines the core DNA of how the UI behaves and looks.
enum StunningUIStyle {
  /// Flat, fast, high-contrast, zero distractions. Best for ERP, CRM, B2B.
  enterprise,

  /// Clean, subtle shadows, rounded corners. Best for Social Media, E-commerce.
  minimal,

  /// High glassmorphism, neon glows, elastic physics. Best for Gaming, Web3.
  gaming,
}

/// A motion "spring" token (duration + bounce) derived from the active style.
///
/// In the current release this is a data token consumed by physics-based
/// components; richer spring simulations are layered on top in a later release.
@immutable
class StunningSpring {
  /// How long the spring takes to settle.
  final int durationMs;

  /// Overshoot: 0 = no bounce (snappy), ~0.3 = lively, higher = bouncier.
  final double bounce;

  const StunningSpring({this.durationMs = 280, this.bounce = 0.1});

  /// Convenience [Duration] for the spring.
  Duration get duration => Duration(milliseconds: durationMs);

  /// Converts this token into a physics [SpringDescription] for use with
  /// [AnimationController.animateWith] / [SpringSimulation].
  SpringDescription toSpring() => SpringDescription.withDurationAndBounce(
    duration: duration,
    bounce: bounce,
  );

  static StunningSpring lerp(StunningSpring a, StunningSpring b, double t) {
    return StunningSpring(
      durationMs:
          (lerpDouble(a.durationMs, b.durationMs, t) ?? a.durationMs).round(),
      bounce: lerpDouble(a.bounce, b.bounce, t) ?? a.bounce,
    );
  }
}

/// The central design engine. One seed colour + brightness + style derives the
/// full colour scheme, glass/glow/border material, and motion tokens, so every
/// component can style itself with zero configuration from the caller.
class StunningTheme extends ThemeExtension<StunningTheme> {
  // 1. Color Tokens
  final Color primaryBrand;
  final Color surfaceGlass;
  final Color backgroundHint;

  // 2. Material Tokens (The Game Changer)
  final double glassBlurSigma;
  final double glowIntensity;
  final double borderOpacity;

  // 3. Physics Tokens (Animations)
  final Curve motionCurve;
  final Duration motionDuration;

  // 4. v2 tokens (added in 1.3.0 — all backward-compatible / optional).
  /// Full Material 3 colour scheme derived from the seed. Components prefer
  /// these roles (onSurface, outline, …) over hardcoded colours so the kit
  /// works in BOTH light and dark mode.
  final ColorScheme? colorScheme;

  /// Spring/motion token derived from [style].
  final StunningSpring spring;

  /// The style this theme was generated with.
  final StunningUIStyle style;

  /// Brightness this theme targets.
  final Brightness brightness;

  /// Dynamically generates the shadow based on glowIntensity.
  BoxShadow get glowingShadow {
    if (glowIntensity <= 0) return const BoxShadow(color: Colors.transparent);
    return BoxShadow(
      color: primaryBrand.withValues(alpha: 0.5 * glowIntensity),
      blurRadius: 30 * glowIntensity,
      spreadRadius: 2 * glowIntensity,
    );
  }

  // --- Theme-aware foreground helpers (the light-mode fix lives here) ---

  bool get isDark => brightness == Brightness.dark;

  /// Primary text colour — light in dark mode, dark in light mode.
  Color get textPrimary =>
      colorScheme?.onSurface ??
      (isDark ? Colors.white : const Color(0xFF12121A));

  /// Secondary / muted text colour.
  Color get textSecondary => textPrimary.withValues(alpha: 0.62);

  /// Hint / placeholder colour.
  Color get hintColor => textPrimary.withValues(alpha: 0.4);

  /// Default icon colour.
  Color get iconColor => textPrimary.withValues(alpha: 0.8);

  /// Default border colour, scaled by [borderOpacity].
  Color get borderColor => (colorScheme?.outline ?? textPrimary).withValues(
    alpha: borderOpacity > 0 ? borderOpacity : 0.12,
  );

  /// Returns a readable foreground (black/white) for any [background].
  Color onColor(Color background) =>
      background.computeLuminance() > 0.5
          ? const Color(0xFF101014)
          : Colors.white;

  // --- Accessibility resolvers (honor OS settings) ---

  /// True when the user requested reduced motion (OS "reduce motion" setting).
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  /// True when translucency should be avoided (maps to the platform
  /// "increase/high contrast" accessibility setting).
  static bool reduceTransparency(BuildContext context) =>
      MediaQuery.maybeOf(context)?.highContrast ?? false;

  /// Motion duration that collapses to zero when reduce-motion is enabled, so
  /// every animated component honors the setting with no extra work.
  Duration motion(BuildContext context) =>
      reduceMotion(context) ? Duration.zero : motionDuration;

  /// Blur sigma that collapses to zero when transparency should be reduced.
  double blurFor(BuildContext context) =>
      reduceTransparency(context) ? 0.0 : glassBlurSigma;

  const StunningTheme({
    required this.primaryBrand,
    required this.surfaceGlass,
    required this.backgroundHint,
    required this.glassBlurSigma,
    required this.glowIntensity,
    required this.borderOpacity,
    required this.motionCurve,
    required this.motionDuration,
    this.colorScheme,
    this.spring = const StunningSpring(),
    this.style = StunningUIStyle.minimal,
    this.brightness = Brightness.dark,
  });

  /// Resolve the active [StunningTheme] for [context], falling back to a
  /// brightness-appropriate default so components never render unstyled (and
  /// never need null checks). This is why components stay theme-aware even if
  /// the developer forgot to register the extension.
  static StunningTheme of(BuildContext context) {
    final ext = Theme.of(context).extension<StunningTheme>();
    if (ext != null) return ext;
    return StunningTheme.generate(
      seedColor: const Color(0xFF6C5CE7),
      brightness: Theme.of(context).brightness,
    );
  }

  /// Optional (nullable) lookup when you specifically want to know whether a
  /// theme was registered.
  static StunningTheme? maybeOf(BuildContext context) =>
      Theme.of(context).extension<StunningTheme>();

  /// The Smart Generator: developer gives a seed colour, brightness, and vibe.
  /// We calculate the rest — including a full Material 3 [ColorScheme].
  factory StunningTheme.generate({
    required Color seedColor,
    required Brightness brightness,
    StunningUIStyle style = StunningUIStyle.minimal,
  }) {
    final isDark = brightness == Brightness.dark;

    // --- Base surface / background ---
    final Color surface;
    final Color bgHint;
    if (isDark) {
      bgHint = Colors.black;
      surface =
          style == StunningUIStyle.enterprise
              ? const Color(0xFF121212)
              : seedColor.withValues(alpha: 0.15);
    } else {
      bgHint = Colors.white;
      surface =
          style == StunningUIStyle.enterprise
              ? const Color(0xFFF5F5F5)
              : seedColor.withValues(alpha: 0.05);
    }

    // --- Material & physics engine per style ---
    double blur = 0.0;
    double glow = 0.0;
    double borderOp = 0.0;
    Curve curve = Curves.easeInOut;
    Duration duration = const Duration(milliseconds: 200);
    StunningSpring spring = const StunningSpring();

    switch (style) {
      case StunningUIStyle.enterprise:
        blur = 0.0;
        glow = 0.0;
        borderOp = isDark ? 0.2 : 0.12;
        curve = Curves.easeOut;
        duration = const Duration(milliseconds: 150);
        spring = const StunningSpring(durationMs: 150, bounce: 0.0);
        break;
      case StunningUIStyle.minimal:
        blur = 10.0;
        glow = 0.1;
        borderOp = isDark ? 0.12 : 0.1;
        curve = Curves.easeInOutCubic;
        duration = const Duration(milliseconds: 250);
        spring = const StunningSpring(durationMs: 280, bounce: 0.12);
        break;
      case StunningUIStyle.gaming:
        blur = 20.0;
        glow = 0.8;
        borderOp = 0.4;
        curve = Curves.easeOutBack;
        duration = const Duration(milliseconds: 400);
        spring = const StunningSpring(durationMs: 420, bounce: 0.35);
        break;
    }

    // Full M3 colour scheme from the same seed — the "replace Material" unlock.
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      dynamicSchemeVariant: switch (style) {
        StunningUIStyle.enterprise => DynamicSchemeVariant.neutral,
        StunningUIStyle.minimal => DynamicSchemeVariant.tonalSpot,
        StunningUIStyle.gaming => DynamicSchemeVariant.vibrant,
      },
    );

    return StunningTheme(
      primaryBrand: seedColor,
      surfaceGlass: surface,
      backgroundHint: bgHint,
      glassBlurSigma: blur,
      glowIntensity: glow,
      borderOpacity: borderOp,
      motionCurve: curve,
      motionDuration: duration,
      colorScheme: scheme,
      spring: spring,
      style: style,
      brightness: brightness,
    );
  }

  // --- Ready-made presets (zero-arg onboarding) ---

  /// Neon, glassy, springy. Defaults to dark.
  factory StunningTheme.gaming({
    Color seedColor = const Color(0xFF22D3EE),
    Brightness brightness = Brightness.dark,
  }) => StunningTheme.generate(
    seedColor: seedColor,
    brightness: brightness,
    style: StunningUIStyle.gaming,
  );

  /// Flat, fast, high-contrast SaaS. Defaults to dark.
  factory StunningTheme.enterprise({
    Color seedColor = const Color(0xFF3B82F6),
    Brightness brightness = Brightness.dark,
  }) => StunningTheme.generate(
    seedColor: seedColor,
    brightness: brightness,
    style: StunningUIStyle.enterprise,
  );

  /// Soft frost, subtle motion. Defaults to light.
  factory StunningTheme.minimal({
    Color seedColor = const Color(0xFF8B5CF6),
    Brightness brightness = Brightness.light,
  }) => StunningTheme.generate(
    seedColor: seedColor,
    brightness: brightness,
    style: StunningUIStyle.minimal,
  );

  /// A sensible light theme in one line.
  factory StunningTheme.light({
    Color seedColor = const Color(0xFF6C5CE7),
    StunningUIStyle style = StunningUIStyle.minimal,
  }) => StunningTheme.generate(
    seedColor: seedColor,
    brightness: Brightness.light,
    style: style,
  );

  /// A sensible dark theme in one line.
  factory StunningTheme.dark({
    Color seedColor = const Color(0xFF22D3EE),
    StunningUIStyle style = StunningUIStyle.gaming,
  }) => StunningTheme.generate(
    seedColor: seedColor,
    brightness: Brightness.dark,
    style: style,
  );

  /// Build a Material [ThemeData] with this engine wired in — the one-line
  /// setup: `MaterialApp(theme: StunningTheme.dark().toThemeData())`.
  ThemeData toThemeData() {
    final scheme =
        colorScheme ??
        ColorScheme.fromSeed(seedColor: primaryBrand, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: backgroundHint,
      extensions: <ThemeExtension<dynamic>>[this],
    );
  }

  @override
  StunningTheme copyWith({
    Color? primaryBrand,
    Color? surfaceGlass,
    Color? backgroundHint,
    double? glassBlurSigma,
    double? glowIntensity,
    double? borderOpacity,
    Curve? motionCurve,
    Duration? motionDuration,
    ColorScheme? colorScheme,
    StunningSpring? spring,
    StunningUIStyle? style,
    Brightness? brightness,
  }) {
    return StunningTheme(
      primaryBrand: primaryBrand ?? this.primaryBrand,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      backgroundHint: backgroundHint ?? this.backgroundHint,
      glassBlurSigma: glassBlurSigma ?? this.glassBlurSigma,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      borderOpacity: borderOpacity ?? this.borderOpacity,
      motionCurve: motionCurve ?? this.motionCurve,
      motionDuration: motionDuration ?? this.motionDuration,
      colorScheme: colorScheme ?? this.colorScheme,
      spring: spring ?? this.spring,
      style: style ?? this.style,
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  StunningTheme lerp(ThemeExtension<StunningTheme>? other, double t) {
    if (other is! StunningTheme) return this;
    return StunningTheme(
      primaryBrand: Color.lerp(primaryBrand, other.primaryBrand, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      backgroundHint: Color.lerp(backgroundHint, other.backgroundHint, t)!,
      glassBlurSigma:
          lerpDouble(glassBlurSigma, other.glassBlurSigma, t) ?? glassBlurSigma,
      glowIntensity:
          lerpDouble(glowIntensity, other.glowIntensity, t) ?? glowIntensity,
      borderOpacity:
          lerpDouble(borderOpacity, other.borderOpacity, t) ?? borderOpacity,
      // Duration interpolates smoothly even though Curve cannot.
      motionDuration: Duration(
        milliseconds:
            (lerpDouble(
                      motionDuration.inMilliseconds,
                      other.motionDuration.inMilliseconds,
                      t,
                    ) ??
                    motionDuration.inMilliseconds)
                .round(),
      ),
      motionCurve: t < 0.5 ? motionCurve : other.motionCurve,
      colorScheme: ColorScheme.lerp(
        colorScheme ?? other.colorScheme ?? const ColorScheme.dark(),
        other.colorScheme ?? colorScheme ?? const ColorScheme.dark(),
        t,
      ),
      spring: StunningSpring.lerp(spring, other.spring, t),
      style: t < 0.5 ? style : other.style,
      brightness: t < 0.5 ? brightness : other.brightness,
    );
  }
}
