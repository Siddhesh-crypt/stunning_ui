import 'package:flutter/material.dart';
import 'dart:ui';
import '../../theme/stunning_theme.dart';

/// A glassmorphic top app bar that integrates perfectly with the Stunning UI ecosystem.
class StunningAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The primary widget displayed in the app bar (usually a Text widget).
  final Widget? title;

  /// A widget to display before the title (e.g., a menu or back button).
  final Widget? leading;

  /// A list of widgets to display after the title.
  final List<Widget>? actions;

  /// Whether the title should be centered. Defaults to true.
  final bool centerTitle;

  /// The background color of the app bar. Defaults to theme's surfaceGlass.
  final Color? backgroundColor;

  const StunningAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final surfaceColor = backgroundColor ?? st.surfaceGlass;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: st.glassBlurSigma,
          sigmaY: st.glassBlurSigma,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(
              bottom: BorderSide(color: st.borderColor, width: 1.5),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: NavigationToolbar(
                leading: leading,
                middle: title,
                trailing:
                    actions != null
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions!,
                        )
                        : null,
                centerMiddle: centerTitle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
