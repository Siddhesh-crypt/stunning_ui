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

  /// Dynamically generates the shadow based on glowIntensity.
  /// This fixes the broken components instantly.
  BoxShadow get glowingShadow {
    if (glowIntensity <= 0) return const BoxShadow(color: Colors.transparent);
    return BoxShadow(
      color: primaryBrand.withValues(alpha: 0.5 * glowIntensity),
      blurRadius: 30 * glowIntensity,
      spreadRadius: 2 * glowIntensity,
    );
  }

  const StunningTheme({
    required this.primaryBrand,
    required this.surfaceGlass,
    required this.backgroundHint,
    required this.glassBlurSigma,
    required this.glowIntensity,
    required this.borderOpacity,
    required this.motionCurve,
    required this.motionDuration,
  });

  /// The Smart Generator: This is where the magic happens.
  /// Developer gives a seed color, brightness, and vibe. We calculate the rest.
  factory StunningTheme.generate({
    required Color seedColor,
    required Brightness brightness,
    StunningUIStyle style = StunningUIStyle.minimal,
  }) {
    final isDark = brightness == Brightness.dark;

    // --- Base Colors Setup ---
    // If it's enterprise, we want high contrast. If gaming, deeper tones.
    final Color surface;
    final Color bgHint;

    if (isDark) {
      bgHint = Colors.black;
      surface = style == StunningUIStyle.enterprise
          ? const Color(0xFF121212) // Solid dark grey for enterprise
          : seedColor.withValues(alpha: 0.15); // Tinted glass for others
    } else {
      bgHint = Colors.white;
      surface = style == StunningUIStyle.enterprise
          ? const Color(0xFFF5F5F5) // Solid light grey for enterprise
          : seedColor.withValues(alpha: 0.05); // Frosted white for others
    }

    // --- Material & Physics Engine Setup ---
    double blur = 0.0;
    double glow = 0.0;
    double borderOp = 0.0;
    Curve curve = Curves.easeInOut;
    Duration duration = const Duration(milliseconds: 200);

    switch (style) {
      case StunningUIStyle.enterprise:
        blur = 0.0; // No blur, save GPU
        glow = 0.0; // No distractions
        borderOp = isDark ? 0.2 : 0.1; // Simple solid borders
        curve = Curves.easeOut; // Fast, linear-like snappy motion
        duration = const Duration(milliseconds: 150);
        break;

      case StunningUIStyle.minimal:
        blur = 10.0; // Slight frosted effect
        glow = 0.1; // Very subtle ambient glow
        borderOp = 0.1; // Soft borders
        curve = Curves.easeInOutCubic; // Smooth Apple-like motion
        duration = const Duration(milliseconds: 250);
        break;

      case StunningUIStyle.gaming:
        blur = 20.0; // Heavy deep glass
        glow = 0.8; // High neon intensity
        borderOp = 0.4; // Prominent glowing borders
        curve = Curves.easeOutBack; // Bouncy, elastic feedback
        duration = const Duration(milliseconds: 400);
        break;
    }

    return StunningTheme(
      primaryBrand: seedColor,
      surfaceGlass: surface,
      backgroundHint: bgHint,
      glassBlurSigma: blur,
      glowIntensity: glow,
      borderOpacity: borderOp,
      motionCurve: curve,
      motionDuration: duration,
    );
  }

  // --- Standard ThemeExtension Boilerplate ---
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
      // Curves and Durations don't interpolate smoothly like colors, so we switch halfway
      motionCurve: t < 0.5 ? motionCurve : other.motionCurve,
      motionDuration: t < 0.5 ? motionDuration : other.motionDuration,
    );
  }
}

// Custom lerp helper for doubles
double? lerpDouble(num? a, num? b, double t) {
  if (a == null && b == null) return null;
  a ??= 0.0;
  b ??= 0.0;
  return a + (b - a) * t;
}
