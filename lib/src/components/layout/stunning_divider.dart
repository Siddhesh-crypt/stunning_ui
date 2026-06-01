import 'package:flutter/material.dart';
import '../../theme/stunning_theme.dart';

/// A thin, theme-aware divider line.
///
/// Pure display — it draws a single hairline rule using the active
/// [StunningTheme]'s `borderColor` (so it reads correctly in BOTH light and
/// dark mode) unless an explicit [color] is supplied. Lay it out along either
/// axis and inset its ends with [indent] / [endIndent].
///
/// Horizontal (the default) fills the available width and reserves
/// [thickness] of height; vertical fills the available height and reserves
/// [thickness] of width.
class StunningDivider extends StatelessWidget {
  /// Thickness of the line in logical pixels (the divider's cross-axis size).
  final double thickness;

  /// Empty space inset before the start of the line along its main axis
  /// (left for horizontal, top for vertical).
  final double indent;

  /// Empty space inset after the end of the line along its main axis
  /// (right for horizontal, bottom for vertical).
  final double endIndent;

  /// The axis the divider runs along. Horizontal draws a left-to-right rule;
  /// vertical draws a top-to-bottom rule.
  final Axis axis;

  /// Line colour. Defaults to the theme's `borderColor` when null, keeping it
  /// theme-aware across light and dark modes.
  final Color? color;

  /// Creates a thin, theme-aware divider.
  const StunningDivider({
    super.key,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.axis = Axis.horizontal,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final lineColor = color ?? st.borderColor;

    if (axis == Axis.horizontal) {
      return Semantics(
        child: Padding(
          padding: EdgeInsets.only(left: indent, right: endIndent),
          child: SizedBox(
            height: thickness,
            child: ColoredBox(color: lineColor),
          ),
        ),
      );
    }

    return Semantics(
      child: Padding(
        padding: EdgeInsets.only(top: indent, bottom: endIndent),
        child: SizedBox(width: thickness, child: ColoredBox(color: lineColor)),
      ),
    );
  }
}
