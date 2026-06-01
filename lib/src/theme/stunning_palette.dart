import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// How the secondary / tertiary colours are derived when the developer only
/// supplies a primary seed (or wants a specific colour relationship).
///
/// [auto] inspects the seed's chroma and picks the harmony that actually suits
/// it — vibrant seeds get [complementary] pop, calm seeds get a quiet
/// [analogous] family, and near-grey seeds stay [monochromatic]. This is why a
/// developer who passes a single colour still gets a *correct* palette with
/// zero choices to make.
enum StunningHarmony {
  /// Pick the best harmony from the seed's chroma (the real default).
  auto,

  /// Perceptual opposite — maximum brand pop. Best for vibrant / gaming seeds.
  complementary,

  /// A neighbour ~30° away — a quiet, single-family, sophisticated feel.
  analogous,

  /// Two accents 120° apart — playful, multi-accent dashboards.
  triadic,

  /// The complement, softened by ±30° — pop without the harshness.
  splitComplementary,

  /// Same hue, differentiated by tone/chroma — keeps a muted brand muted.
  monochromatic,
}

/// A colour role that owns a full Tailwind-style 50→950 tonal ramp.
enum StunningRole {
  primary,
  secondary,
  tertiary,
  neutral,
  neutralVariant,
  success,
  warning,
  error,
  info,
}

/// The eleven Tailwind ramp stops, in order.
const List<int> kStunningRampStops = <int>[
  50,
  100,
  200,
  300,
  400,
  500,
  600,
  700,
  800,
  900,
  950,
];

/// Perceptual tone (≈ L*) targets for each ramp stop. Because HCT tone maps
/// 1:1 to perceptual lightness, sampling a [TonalPalette] at these tones yields
/// a ramp whose steps are perceptually even by construction — no muddy
/// midtones, no manual HSL nudging.
const List<double> _kRampTones = <double>[
  98,
  95,
  90,
  80,
  68,
  56,
  46,
  38,
  30,
  23,
  15,
];

/// One brand-tuned semantic colour (success / warning / error / info) with an
/// AA-guaranteed foreground, a container fill, and its own 50→950 ramp.
@immutable
class StunningSemantic {
  /// The readable base colour (use on a surface).
  final Color color;

  /// A foreground that is guaranteed ≥ AA contrast on [color].
  final Color on;

  /// A soft fill for chips / banners.
  final Color container;

  /// A foreground guaranteed ≥ AA contrast on [container].
  final Color onContainer;

  /// The full Tailwind 50→950 ramp for this semantic hue.
  final List<Color> ramp;

  const StunningSemantic({
    required this.color,
    required this.on,
    required this.container,
    required this.onContainer,
    required this.ramp,
  });

  /// Element-wise interpolation (used by theme morphing).
  static StunningSemantic lerp(
    StunningSemantic a,
    StunningSemantic b,
    double t,
  ) {
    return StunningSemantic(
      color: Color.lerp(a.color, b.color, t)!,
      on: Color.lerp(a.on, b.on, t)!,
      container: Color.lerp(a.container, b.container, t)!,
      onContainer: Color.lerp(a.onContainer, b.onContainer, t)!,
      ramp: _lerpRamp(a.ramp, b.ramp, t),
    );
  }
}

/// The four brand-tuned semantic colours.
@immutable
class StunningSemantics {
  final StunningSemantic success;
  final StunningSemantic warning;
  final StunningSemantic error;
  final StunningSemantic info;

  const StunningSemantics({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });
}

/// Ready-to-use gradient stop lists derived from the harmony.
@immutable
class StunningGradients {
  /// A subtle "lit edge" of the primary (primary → hue-shifted primary).
  final List<Color> primary;

  /// primary → secondary.
  final List<Color> brand;

  /// A 3-stop mesh: primary → tertiary → secondary.
  final List<Color> mesh;

  const StunningGradients({
    required this.primary,
    required this.brand,
    required this.mesh,
  });
}

/// A complete, harmonious, WCAG-AA colour system derived from one (or two)
/// brand colours — entirely in HCT space via `material_color_utilities`.
///
/// ```dart
/// final p = StunningPalette.fromSeed(const Color(0xFF6C5CE7));
/// container.color = p.ramp(StunningRole.primary)[1];   // primary-100
/// chip.color      = p.semantics.success.color;          // brand-tuned green
/// text.color      = p.on(anyBackground);                // guaranteed AA
/// ```
///
/// Pure-Dart, synchronous, context-free — so [StunningTheme], `fromImage`,
/// `describe`, share-codes and token export can all reuse the same object.
@immutable
class StunningPalette {
  /// The exact brand colour the developer supplied.
  final Color primary;

  /// A harmonised accent (derived, or the supplied secondary blended onto
  /// [primary] so it never clashes).
  final Color secondary;

  /// A second accent, harmonically adjacent yet visually distinct.
  final Color tertiary;

  final Color onPrimary;
  final Color onSecondary;
  final Color onTertiary;

  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;

  /// Brand-tinted surface (greys carry a hint of the brand hue).
  final Color surface;

  /// Brand-tinted background, one step beyond [surface].
  final Color background;

  /// success / warning / error / info, each hue-tuned toward the brand.
  final StunningSemantics semantics;

  /// primary / brand / mesh gradient stop lists.
  final StunningGradients gradients;

  /// A brand-tinted translucent fill for glass surfaces (not dead grey).
  final Color glassTint;

  /// A brighter brand-tinted edge highlight for glass borders.
  final Color glassBorderTint;

  /// The most luminous version of the brand — reads as emitted light. Wired
  /// into [StunningTheme.glowingShadow].
  final Color glowColor;

  /// The harmony that was actually used (after [StunningHarmony.auto] resolved).
  final StunningHarmony resolvedHarmony;

  /// The brightness this palette targets.
  final Brightness brightness;

  final Map<StunningRole, List<Color>> _ramps;

  const StunningPalette._({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.onPrimary,
    required this.onSecondary,
    required this.onTertiary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.surface,
    required this.background,
    required this.semantics,
    required this.gradients,
    required this.glassTint,
    required this.glassBorderTint,
    required this.glowColor,
    required this.resolvedHarmony,
    required this.brightness,
    required Map<StunningRole, List<Color>> ramps,
  }) : _ramps = ramps;

  /// The 11-stop Tailwind ramp `[50, 100, … , 950]` for any [role].
  ///
  /// `palette.ramp(StunningRole.success)[6]` is success-700.
  List<Color> ramp(StunningRole role) => _ramps[role]!;

  /// A foreground colour for an *arbitrary* [background] that is guaranteed to
  /// meet [ratio] (4.5 = AA body, 3.0 = large text / UI, 7.0 = AAA). The result
  /// is brand-tinted rather than stark black/white, so it feels designed.
  ///
  /// Contrast is computed in HCT tone space, which is exact because tone is
  /// perceptual luminance — so the guarantee is mathematical, not a luminance
  /// coin-flip.
  Color on(Color background, {double ratio = 4.5}) {
    final bg = Hct.fromInt(background.toARGB32());
    final t = bg.tone;
    final lighter = Contrast.lighter(
      tone: t,
      ratio: ratio,
    ); // -1 if unreachable
    final darker = Contrast.darker(tone: t, ratio: ratio);

    double tone;
    if (lighter < 0 && darker < 0) {
      // Mid-tone background where neither direction reaches the ratio: pick the
      // extreme with the higher achieved contrast (never silently fail).
      tone =
          Contrast.ratioOfTones(100, t) >= Contrast.ratioOfTones(0, t)
              ? 100
              : 0;
    } else if (lighter < 0) {
      tone = darker;
    } else if (darker < 0) {
      tone = lighter;
    } else {
      // Both reachable — take the one with more headroom.
      tone =
          Contrast.ratioOfTones(lighter, t) >= Contrast.ratioOfTones(darker, t)
              ? lighter
              : darker;
    }
    final chroma = math.min(bg.chroma, 16.0);
    return Color(Hct.from(bg.hue, chroma, tone).toInt());
  }

  /// Bakes this palette into a Material 3 [ColorScheme] — drops straight into
  /// [ThemeData] / the [StunningTheme.colorScheme] slot. Starts from
  /// `ColorScheme.fromSeed` (so every M3 role is populated correctly) and
  /// injects the harmonised secondary/tertiary and brand-tuned error.
  ColorScheme toColorScheme({
    DynamicSchemeVariant variant = DynamicSchemeVariant.tonalSpot,
  }) {
    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      dynamicSchemeVariant: variant,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: semantics.error.color,
      onError: semantics.error.on,
    );
  }

  /// The achieved WCAG ratio for every foreground/background token pair —
  /// consumed by `dart run stunning_ui:doctor` to print an accessibility table.
  Map<String, double> contrastReport() {
    double r(Color fg, Color bg) => Contrast.ratioOfTones(
      Hct.fromInt(fg.toARGB32()).tone,
      Hct.fromInt(bg.toARGB32()).tone,
    );
    return <String, double>{
      'onPrimary / primary': r(onPrimary, primary),
      'onSecondary / secondary': r(onSecondary, secondary),
      'onTertiary / tertiary': r(onTertiary, tertiary),
      'success.on / success': r(semantics.success.on, semantics.success.color),
      'warning.on / warning': r(semantics.warning.on, semantics.warning.color),
      'error.on / error': r(semantics.error.on, semantics.error.color),
      'info.on / info': r(semantics.info.on, semantics.info.color),
    };
  }

  /// The engine entry point. One required colour in, a full harmonious +
  /// accessible system out.
  ///
  /// * [secondary] is optional. When `null` it is auto-derived via [harmony];
  ///   when given it is auto-harmonised onto [primary] so it never clashes.
  /// * [harmony] defaults to [StunningHarmony.auto], which chooses the right
  ///   relationship from the seed's chroma.
  factory StunningPalette.fromSeed(
    Color primary, {
    Color? secondary,
    StunningHarmony harmony = StunningHarmony.auto,
    Brightness brightness = Brightness.dark,
  }) {
    final isDark = brightness == Brightness.dark;
    final seed = Hct.fromInt(primary.toARGB32());
    final resolved = _resolveHarmony(harmony, seed.chroma);

    final Hct? provided =
        secondary == null
            ? null
            : Hct.fromInt(
              Blend.harmonize(secondary.toARGB32(), primary.toARGB32()),
            );

    final (Hct secHct, Hct terHct) = _deriveAccents(seed, resolved, provided);

    // Role colours at M3-appropriate brand tones (vivid but on-scheme).
    final double roleTone = isDark ? 80 : 40;
    final Color secondaryColor = Color(
      Hct.from(secHct.hue, secHct.chroma, roleTone).toInt(),
    );
    final Color tertiaryColor = Color(
      Hct.from(terHct.hue, terHct.chroma, roleTone).toInt(),
    );

    // --- Ramps (perceptually even, gamut-mapped automatically). ---
    final ramps = <StunningRole, List<Color>>{
      StunningRole.primary: _rampFor(seed.hue, seed.chroma),
      StunningRole.secondary: _rampFor(secHct.hue, secHct.chroma),
      StunningRole.tertiary: _rampFor(terHct.hue, terHct.chroma),
      // Brand-tinted neutrals: tiny chroma so greys feel warmed, not coloured.
      StunningRole.neutral: _rampFor(seed.hue, math.min(seed.chroma * 0.12, 6)),
      StunningRole.neutralVariant: _rampFor(
        seed.hue,
        math.min(seed.chroma * 0.20, 10),
      ),
    };

    final neutralPal = TonalPalette.of(
      seed.hue,
      math.min(seed.chroma * 0.12, 6),
    );
    final surface = Color(neutralPal.get(isDark ? 12 : 98));
    final background = Color(neutralPal.get(isDark ? 6 : 100));

    // Build a partial palette so on()/ramps are usable while deriving the rest.
    Color onOf(Color bg, {double ratio = 4.5}) => _onColor(bg, ratio: ratio);

    final primaryContainer = Color(
      TonalPalette.of(seed.hue, seed.chroma).get(isDark ? 30 : 90),
    );
    final secondaryContainer = Color(
      TonalPalette.of(secHct.hue, secHct.chroma).get(isDark ? 30 : 90),
    );
    final tertiaryContainer = Color(
      TonalPalette.of(terHct.hue, terHct.chroma).get(isDark ? 30 : 90),
    );

    // --- Semantic colours, hue-tuned toward the brand. ---
    final double seedHue = seed.hue;
    final double semChroma = seed.chroma.clamp(48.0, 84.0);
    StunningSemantic buildSemantic(
      double canonicalHue,
      double maxShift,
      double bandLo,
      double bandHi,
    ) {
      double hue = _rotateToward(
        canonicalHue,
        seedHue,
        maxShift,
      ).clamp(bandLo, bandHi);
      // Escape the dark yellow-green "bile" zone.
      final fixed = DislikeAnalyzer.fixIfDisliked(
        Hct.from(hue, semChroma, isDark ? 70 : 48),
      );
      hue = fixed.hue;
      final pal = TonalPalette.of(hue, semChroma);
      final ramp = [for (final tn in _kRampTones) Color(pal.get(tn.round()))];
      final color = Color(pal.get(isDark ? 70 : 48));
      final container = Color(pal.get(isDark ? 30 : 90));
      return StunningSemantic(
        color: color,
        on: onOf(color),
        container: container,
        onContainer: onOf(container),
        ramp: ramp,
      );
    }

    final semantics = StunningSemantics(
      // Error rotates the least — it must stay unmistakably red (safety).
      error: buildSemantic(25, 12, 5, 40),
      warning: buildSemantic(80, 18, 55, 95),
      success: buildSemantic(142, 22, 110, 165),
      info: buildSemantic(232, 22, 205, 255),
    );
    ramps[StunningRole.success] = semantics.success.ramp;
    ramps[StunningRole.warning] = semantics.warning.ramp;
    ramps[StunningRole.error] = semantics.error.ramp;
    ramps[StunningRole.info] = semantics.info.ramp;

    // --- Gradients. ---
    final litEdge = Color(
      Hct.from(
        (seed.hue + 18) % 360,
        seed.chroma,
        (seed.tone + (isDark ? 8 : -8)).clamp(30.0, 80.0),
      ).toInt(),
    );

    // --- Glass + glow. ---
    final glassPal = TonalPalette.of(seed.hue, math.min(seed.chroma * 0.3, 16));
    final glassTint = Color(
      glassPal.get(isDark ? 30 : 92),
    ).withValues(alpha: isDark ? 0.14 : 0.55);
    final glassBorderTint = Color(
      glassPal.get(isDark ? 55 : 80),
    ).withValues(alpha: isDark ? 0.30 : 0.50);
    final glowColor = Color(
      Hct.from(
        seed.hue,
        math.min(seed.chroma * 1.15, 100),
        isDark ? 72 : 64,
      ).toInt(),
    );

    return StunningPalette._(
      primary: primary,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      onPrimary: onOf(primary),
      onSecondary: onOf(secondaryColor),
      onTertiary: onOf(tertiaryColor),
      primaryContainer: primaryContainer,
      onPrimaryContainer: onOf(primaryContainer),
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onOf(secondaryContainer),
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onOf(tertiaryContainer),
      surface: surface,
      background: background,
      semantics: semantics,
      gradients: StunningGradients(
        primary: [primary, litEdge],
        brand: [primary, secondaryColor],
        mesh: [primary, tertiaryColor, secondaryColor],
      ),
      glassTint: glassTint,
      glassBorderTint: glassBorderTint,
      glowColor: glowColor,
      resolvedHarmony: resolved,
      brightness: brightness,
      ramps: ramps,
    );
  }

  /// Element-wise interpolation between two palettes (used by theme morphing
  /// when a smooth colour transition is wanted).
  static StunningPalette lerp(StunningPalette a, StunningPalette b, double t) {
    final ramps = <StunningRole, List<Color>>{
      for (final role in StunningRole.values)
        role: _lerpRamp(a._ramps[role]!, b._ramps[role]!, t),
    };
    return StunningPalette._(
      primary: Color.lerp(a.primary, b.primary, t)!,
      secondary: Color.lerp(a.secondary, b.secondary, t)!,
      tertiary: Color.lerp(a.tertiary, b.tertiary, t)!,
      onPrimary: Color.lerp(a.onPrimary, b.onPrimary, t)!,
      onSecondary: Color.lerp(a.onSecondary, b.onSecondary, t)!,
      onTertiary: Color.lerp(a.onTertiary, b.onTertiary, t)!,
      primaryContainer: Color.lerp(a.primaryContainer, b.primaryContainer, t)!,
      onPrimaryContainer:
          Color.lerp(a.onPrimaryContainer, b.onPrimaryContainer, t)!,
      secondaryContainer:
          Color.lerp(a.secondaryContainer, b.secondaryContainer, t)!,
      onSecondaryContainer:
          Color.lerp(a.onSecondaryContainer, b.onSecondaryContainer, t)!,
      tertiaryContainer:
          Color.lerp(a.tertiaryContainer, b.tertiaryContainer, t)!,
      onTertiaryContainer:
          Color.lerp(a.onTertiaryContainer, b.onTertiaryContainer, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      background: Color.lerp(a.background, b.background, t)!,
      semantics: StunningSemantics(
        success: StunningSemantic.lerp(
          a.semantics.success,
          b.semantics.success,
          t,
        ),
        warning: StunningSemantic.lerp(
          a.semantics.warning,
          b.semantics.warning,
          t,
        ),
        error: StunningSemantic.lerp(a.semantics.error, b.semantics.error, t),
        info: StunningSemantic.lerp(a.semantics.info, b.semantics.info, t),
      ),
      gradients: StunningGradients(
        primary: _lerpRamp(a.gradients.primary, b.gradients.primary, t),
        brand: _lerpRamp(a.gradients.brand, b.gradients.brand, t),
        mesh: _lerpRamp(a.gradients.mesh, b.gradients.mesh, t),
      ),
      glassTint: Color.lerp(a.glassTint, b.glassTint, t)!,
      glassBorderTint: Color.lerp(a.glassBorderTint, b.glassBorderTint, t)!,
      glowColor: Color.lerp(a.glowColor, b.glowColor, t)!,
      resolvedHarmony: t < 0.5 ? a.resolvedHarmony : b.resolvedHarmony,
      brightness: t < 0.5 ? a.brightness : b.brightness,
      ramps: ramps,
    );
  }

  // ---------------------------------------------------------------------------
  // Static derivation helpers.
  // ---------------------------------------------------------------------------

  static StunningHarmony _resolveHarmony(StunningHarmony h, double chroma) {
    if (h != StunningHarmony.auto) return h;
    if (chroma < 12) return StunningHarmony.monochromatic;
    if (chroma < 48) return StunningHarmony.analogous;
    return StunningHarmony.complementary;
  }

  static (Hct, Hct) _deriveAccents(Hct seed, StunningHarmony h, Hct? provided) {
    final hue = seed.hue, chroma = seed.chroma, tone = seed.tone;
    Hct sec;
    Hct ter;
    if (provided != null) {
      final dh = (((provided.hue - hue) + 540) % 360) - 180;
      if (dh.abs() < 12 && (provided.tone - tone).abs() < 10) {
        // Two near-identical colours would merge — force a visible neighbour.
        sec = Hct.from((hue + 30) % 360, provided.chroma, provided.tone);
      } else {
        sec = provided;
      }
      ter = Hct.from((sec.hue + 30) % 360, sec.chroma, sec.tone);
    } else {
      switch (h) {
        case StunningHarmony.analogous:
          sec = Hct.from((hue + 30) % 360, chroma, tone);
          ter = Hct.from((hue - 30 + 360) % 360, chroma, tone);
        case StunningHarmony.triadic:
          sec = Hct.from((hue + 120) % 360, chroma, tone);
          ter = Hct.from((hue + 240) % 360, chroma, tone);
        case StunningHarmony.splitComplementary:
          final comp = TemperatureCache(seed).complement.hue;
          sec = Hct.from((comp - 30 + 360) % 360, chroma, tone);
          ter = Hct.from((comp + 30) % 360, chroma, tone);
        case StunningHarmony.monochromatic:
          sec = Hct.from(hue, chroma * 0.6, tone);
          ter = Hct.from(hue, chroma * 0.35, (tone + 12).clamp(0.0, 100.0));
        case StunningHarmony.complementary:
        case StunningHarmony.auto:
          sec = TemperatureCache(seed).complement;
          ter = Hct.from((hue + 30) % 360, chroma, tone);
      }
    }
    return (
      DislikeAnalyzer.fixIfDisliked(sec),
      DislikeAnalyzer.fixIfDisliked(ter),
    );
  }

  static List<Color> _rampFor(double hue, double chroma) {
    final pal = TonalPalette.of(hue, chroma);
    return [for (final t in _kRampTones) Color(pal.get(t.round()))];
  }

  /// Shortest-arc rotation of [from] toward [to], capped at [maxShift] degrees.
  static double _rotateToward(double from, double to, double maxShift) {
    final diff = (((to - from) + 540) % 360) - 180;
    return (from + diff.clamp(-maxShift, maxShift)) % 360;
  }

  /// Standalone copy of [on] for use during construction (before `this` exists).
  static Color _onColor(Color background, {double ratio = 4.5}) {
    final bg = Hct.fromInt(background.toARGB32());
    final t = bg.tone;
    final lighter = Contrast.lighter(tone: t, ratio: ratio);
    final darker = Contrast.darker(tone: t, ratio: ratio);
    double tone;
    if (lighter < 0 && darker < 0) {
      tone =
          Contrast.ratioOfTones(100, t) >= Contrast.ratioOfTones(0, t)
              ? 100
              : 0;
    } else if (lighter < 0) {
      tone = darker;
    } else if (darker < 0) {
      tone = lighter;
    } else {
      tone =
          Contrast.ratioOfTones(lighter, t) >= Contrast.ratioOfTones(darker, t)
              ? lighter
              : darker;
    }
    final chroma = math.min(bg.chroma, 16.0);
    return Color(Hct.from(bg.hue, chroma, tone).toInt());
  }
}

List<Color> _lerpRamp(List<Color> a, List<Color> b, double t) {
  final n = math.min(a.length, b.length);
  return [for (var i = 0; i < n; i++) Color.lerp(a[i], b[i], t)!];
}
