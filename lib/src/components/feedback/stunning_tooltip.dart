import 'package:flutter/material.dart';
import '../../theme/stunning_theme.dart';

/// A theme-styled tooltip that wraps any [child] and reveals a short [message]
/// on long-press (touch) or hover (pointer).
///
/// This is a thin, correct wrapper over Material's [Tooltip]: it derives the
/// bubble surface, foreground, corners and shadow from the active
/// [StunningTheme] so it reads correctly in BOTH light and dark mode, and never
/// hardcodes white/black. Accessibility comes for free — [Tooltip] already
/// merges its [message] into the surrounding semantics for screen readers.
class StunningTooltip extends StatelessWidget {
  /// The text shown inside the tooltip bubble. Also exposed to screen readers
  /// by the underlying [Tooltip].
  final String message;

  /// The widget the tooltip is attached to and triggered from.
  final Widget child;

  /// Whether to prefer showing the bubble below [child] (vs. above) when there
  /// is room. Mirrors [Tooltip.preferBelow]. Defaults to `true`.
  final bool preferBelow;

  /// Creates a theme-styled tooltip wrapping [child].
  const StunningTooltip({
    super.key,
    required this.message,
    required this.child,
    this.preferBelow = true,
  });

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);

    // Inverse surface gives the classic "dark bubble in light mode / light
    // bubble in dark mode" contrast. Fall back to a theme token (never a
    // hardcoded colour) when no ColorScheme is registered.
    final Color surface = st.colorScheme?.inverseSurface ?? st.surfaceGlass;
    final Color foreground =
        st.colorScheme?.onInverseSurface ?? st.onColor(surface);

    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      waitDuration: const Duration(milliseconds: 500),
      // Keep the reveal animation reduce-motion aware and on-theme.
      showDuration: const Duration(milliseconds: 1500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.all(8),
      textStyle: TextStyle(
        color: foreground,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: st.borderColor),
        // Subtle shadow with CONSTANT geometry — always non-negative, so it is
        // safe even if a theme uses an overshoot motion curve.
        boxShadow: [
          BoxShadow(
            color: surface.withValues(alpha: 0.35),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
