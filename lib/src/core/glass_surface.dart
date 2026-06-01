import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/stunning_theme.dart';

/// Rendering tier for glass effects.
///
/// * [full] — real refraction shader on Impeller, blur elsewhere.
/// * [reduced] — plain blur, no shader.
/// * [off] — solid opaque surface (no backdrop work). Used for
///   reduce-transparency and the flat `enterprise` style.
enum StunningEffectTier { full, reduced, off }

/// Package-level glass helpers.
class StunningUI {
  StunningUI._();

  static const String _glassShaderKey =
      'packages/stunning_ui/shaders/glass_refraction.frag';

  static Future<ui.FragmentProgram>? _future;

  /// The loaded refraction program, or null until [warmUp] resolves.
  static ui.FragmentProgram? glassProgram;

  /// Precompiles the glass refraction shader so the first glass surface never
  /// pops. Call once at startup (e.g. in your splash). No-op on backends that
  /// don't support shader image filters.
  static Future<void> warmUp() async {
    if (!ui.ImageFilter.isShaderFilterSupported) return;
    _future ??= ui.FragmentProgram.fromAsset(_glassShaderKey);
    glassProgram = await _future!;
  }
}

/// Coalesces every descendant [GlassSurface] into a single backdrop blur pass
/// (via [BackdropGroup]). Wrap a screen/list in it so N glass surfaces cost one
/// blur instead of N.
class StunningGlassScope extends StatelessWidget {
  final Widget child;
  const StunningGlassScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) => BackdropGroup(child: child);
}

/// The one true glass recipe for the kit: a clipped, theme-tinted surface that
/// refracts (Impeller) or blurs (everywhere else) the content behind it.
///
/// All values default from the active [StunningTheme]. Honors reduce-motion
/// (static) and reduce-transparency (solid opaque fallback) automatically, and
/// degrades to a plain blur on non-Impeller backends (Skia / web).
class GlassSurface extends StatefulWidget {
  final Widget? child;

  /// Blur sigma override. Defaults to the theme's `glassBlurSigma`.
  final double? blur;

  final double borderRadius;
  final EdgeInsetsGeometry padding;

  /// Use the real refraction shader when the backend supports it. Falls back to
  /// blur automatically when false or unsupported.
  final bool refract;

  /// Brand tint colour. Defaults to the theme's primary brand.
  final Color? tint;
  final double tintAmount;

  /// Draw a hairline border.
  final bool border;

  /// Force a specific tier; defaults to auto (full when supported).
  final StunningEffectTier? tier;

  const GlassSurface({
    super.key,
    this.child,
    this.blur,
    this.borderRadius = 20,
    this.padding = EdgeInsets.zero,
    this.refract = true,
    this.tint,
    this.tintAmount = 0.08,
    this.border = true,
    this.tier,
  });

  @override
  State<GlassSurface> createState() => _GlassSurfaceState();
}

class _GlassSurfaceState extends State<GlassSurface> {
  @override
  void initState() {
    super.initState();
    // Lazily warm the shader the first time a refracting surface mounts.
    if (widget.refract &&
        ui.ImageFilter.isShaderFilterSupported &&
        StunningUI.glassProgram == null) {
      StunningUI.warmUp().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  StunningEffectTier _resolveTier(BuildContext context) {
    if (widget.tier != null) return widget.tier!;
    if (StunningTheme.reduceTransparency(context)) {
      return StunningEffectTier.off;
    }
    return StunningEffectTier.full;
  }

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final tier = _resolveTier(context);
    final radius = BorderRadius.circular(widget.borderRadius);
    final tint = widget.tint ?? st.primaryBrand;
    final blur =
        tier == StunningEffectTier.off
            ? 0.0
            : (widget.blur ?? st.glassBlurSigma);

    final content = Padding(
      padding: widget.padding,
      child: widget.child ?? const SizedBox.shrink(),
    );

    final border = widget.border ? Border.all(color: st.borderColor) : null;

    // Solid fallback: reduce-transparency, `off` tier, or zero blur (enterprise).
    if (blur <= 0) {
      final solid = st.colorScheme?.surface ?? st.backgroundHint;
      return RepaintBoundary(
        child: ClipRRect(
          borderRadius: radius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: solid,
              borderRadius: radius,
              border: border,
            ),
            child: content,
          ),
        ),
      );
    }

    final useRefraction =
        widget.refract &&
        tier == StunningEffectTier.full &&
        ui.ImageFilter.isShaderFilterSupported &&
        StunningUI.glassProgram != null;

    final ui.ImageFilter filter;
    final Color fill;
    if (useRefraction) {
      final fs = StunningUI.glassProgram!.fragmentShader();
      // indices 0,1 (uSize) + the sampler are bound by the engine.
      fs.setFloat(2, widget.borderRadius);
      fs.setFloat(3, blur * 1.2); // refraction strength tracks blur
      fs.setFloat(4, st.glowIntensity);
      fs.setFloat(5, tint.r);
      fs.setFloat(6, tint.g);
      fs.setFloat(7, tint.b);
      fs.setFloat(8, widget.tintAmount);
      filter = ui.ImageFilter.shader(fs);
      fill = Colors.transparent; // the shader already tints
    } else {
      filter = ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur);
      fill = tint.withValues(alpha: widget.tintAmount);
    }

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter.grouped(
          filter: filter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: radius,
              border: border,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
