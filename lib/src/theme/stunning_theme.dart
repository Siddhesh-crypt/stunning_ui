import 'package:flutter/material.dart';
import 'app_colors.dart';

class StunningTheme extends ThemeExtension<StunningTheme> {
  final Color primaryBrand;
  final Color surfaceGlass;
  final LinearGradient premiumGradient;
  final BoxShadow glowingShadow;
  final TextStyle buttonText;
  final double borderRadius;

  const StunningTheme({
    required this.primaryBrand,
    required this.surfaceGlass,
    required this.premiumGradient,
    required this.glowingShadow,
    required this.buttonText,
    required this.borderRadius,
  });

  factory StunningTheme.light() {
    return StunningTheme(
      primaryBrand: AppColors.primaryLight,
      surfaceGlass: AppColors.surfaceGlassLight,
      premiumGradient: const LinearGradient(
        colors: [AppColors.primaryLight, AppColors.secondaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      glowingShadow: BoxShadow(
        color: AppColors.primaryLight.withValues(alpha:0.3),
        blurRadius: 16,
        spreadRadius: 2,
        offset: const Offset(0, 8),
      ),
      buttonText: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.white,
      ),
      borderRadius: 16.0,
    );
  }

  factory StunningTheme.dark() {
    return StunningTheme(
      primaryBrand: AppColors.primaryDark,
      surfaceGlass: AppColors.surfaceGlassDark,
      premiumGradient: const LinearGradient(
        colors: [AppColors.primaryDark, AppColors.secondaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      glowingShadow: BoxShadow(
        color: AppColors.primaryDark.withValues(alpha:0.4),
        blurRadius: 20,
        spreadRadius: 2,
        offset: const Offset(0, 8),
      ),
      buttonText: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.black,
      ),
      borderRadius: 16.0,
    );
  }

  @override
  ThemeExtension<StunningTheme> copyWith({
    Color? primaryBrand,
    Color? surfaceGlass,
    LinearGradient? premiumGradient,
    BoxShadow? glowingShadow,
  }) {
    return StunningTheme(
      primaryBrand: primaryBrand ?? this.primaryBrand,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      premiumGradient: premiumGradient ?? this.premiumGradient,
      glowingShadow: glowingShadow ?? this.glowingShadow,
      buttonText: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.white,
      ),
      borderRadius: 16.0,
    );
  }

  @override
  ThemeExtension<StunningTheme> lerp(
    ThemeExtension<StunningTheme>? other,
    double t,
  ) {
    if (other is! StunningTheme) return this;
    return StunningTheme(
      primaryBrand: Color.lerp(primaryBrand, other.primaryBrand, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      premiumGradient: LinearGradient.lerp(
        premiumGradient,
        other.premiumGradient,
        t,
      )!,
      glowingShadow: BoxShadow.lerp(glowingShadow, other.glowingShadow, t)!,
      buttonText: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.black,
      ),
      borderRadius: 16.0,
    );
  }
}
