import 'package:flutter/material.dart';
import '../../theme/stunning_theme.dart';

/// A circular avatar that renders, in order of precedence, an [image], then
/// text [initials], then an [icon], and finally a default person glyph.
///
/// All chrome colours are pulled from the active [StunningTheme] so it reads
/// correctly in both light and dark mode: the tinted background defaults to the
/// brand colour, the initials/icon are tinted with the brand colour, and a thin
/// border ring uses the theme's border colour.
class StunningAvatar extends StatelessWidget {
  /// Optional image to fill the avatar. Highest precedence — when non-null the
  /// [initials] and [icon] are ignored.
  final ImageProvider? image;

  /// Optional initials (e.g. "SL") shown when no [image] is provided.
  final String? initials;

  /// Optional icon shown when neither [image] nor [initials] is provided.
  /// Falls back to [Icons.person] when all three are null.
  final IconData? icon;

  /// The radius of the circular avatar in logical pixels.
  final double radius;

  /// Background fill colour. Defaults to the brand colour at low opacity so it
  /// works against both light and dark surfaces.
  final Color? backgroundColor;

  /// Screen-reader label. Falls back to [initials] when null.
  final String? semanticLabel;

  /// Creates a circular avatar with image / initials / icon fallback.
  const StunningAvatar({
    super.key,
    this.image,
    this.initials,
    this.icon,
    this.radius = 22,
    this.backgroundColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final bg = backgroundColor ?? st.primaryBrand.withValues(alpha: 0.18);
    final foreground = st.primaryBrand;
    final diameter = radius * 2;

    // Precedence: image > initials > icon > default person icon.
    Widget? child;
    if (image == null) {
      if (initials != null && initials!.isNotEmpty) {
        child = Center(
          child: Text(
            initials!,
            style: TextStyle(
              color: foreground,
              fontSize: radius * 0.8,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
          ),
        );
      } else {
        child = Icon(
          icon ?? Icons.person,
          color: foreground,
          size: radius * 1.1,
        );
      }
    }

    final decoration = BoxDecoration(
      color: image == null ? bg : null,
      shape: BoxShape.circle,
      image: image != null
          ? DecorationImage(image: image!, fit: BoxFit.cover)
          : null,
      // Thin theme-driven ring so the avatar reads on any surface.
      border: Border.all(color: st.borderColor, width: 1),
    );

    return Semantics(
      label: semanticLabel ?? initials,
      image: image != null,
      container: true,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: decoration,
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
