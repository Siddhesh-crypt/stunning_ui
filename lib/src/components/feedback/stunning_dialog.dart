import 'package:flutter/material.dart';
import '../../theme/stunning_theme.dart';
import '../../core/glass_surface.dart';

/// The semantic intent behind a [StunningDialog], used only to resolve a
/// theme-derived default accent for the presets (so `error` can pick up the
/// theme error colour, which is only available at build time).
enum _DialogIntent { neutral, error }

/// A centred, glassmorphic dialog panel: an optional accent-tinted [icon], a
/// [title], an optional [message] (or arbitrary [content]), and an actions row.
///
/// Unlike the single-purpose `StunningModal`, the icon, accent colour, and
/// actions are all caller-controlled, and the named presets
/// ([StunningDialog.confirm], [StunningDialog.success], [StunningDialog.error])
/// pre-wire sensible icon + accent combinations.
///
/// Every colour comes from the active [StunningTheme] so the dialog reads
/// correctly in both light and dark mode. Use [showStunningDialog] to present
/// it with a scale + fade transition and a dismissible scrim.
class StunningDialog extends StatelessWidget {
  /// Leading badge icon. Tinted with [accentColor]. Omit for a text-only dialog.
  final IconData? icon;

  /// The dialog headline. Rendered in [StunningTheme.textPrimary].
  final String title;

  /// Supporting body text in [StunningTheme.textSecondary]. Ignored when
  /// [content] is provided.
  final String? message;

  /// Arbitrary body widget. Takes precedence over [message] when non-null.
  final Widget? content;

  /// The affirmative / leading action (e.g. a `StunningButton`). Optional.
  final Widget? primaryAction;

  /// The dismissive / trailing action (e.g. a cancel `StunningButton`).
  /// Rendered before [primaryAction] in the actions row. Optional.
  final Widget? secondaryAction;

  /// Tint for the [icon] badge. Falls back to a theme colour resolved from the
  /// dialog's intent ([StunningTheme.primaryBrand] for the default/confirm
  /// dialog, the theme error colour for [StunningDialog.error]).
  final Color? accentColor;

  /// Preset intent — drives only the theme-derived default accent. Internal.
  final _DialogIntent _intent;

  /// Creates a fully customisable glass dialog.
  const StunningDialog({
    super.key,
    this.icon,
    required this.title,
    this.message,
    this.content,
    this.primaryAction,
    this.secondaryAction,
    this.accentColor,
  }) : _intent = _DialogIntent.neutral;

  /// Internal constructor that also carries a preset [_DialogIntent].
  const StunningDialog._intentful({
    super.key,
    this.icon,
    required this.title,
    this.message,
    this.content,
    this.primaryAction,
    this.secondaryAction,
    this.accentColor,
    required _DialogIntent intent,
  }) : _intent = intent;

  /// A confirmation dialog, brand-accented with a help/question icon. Wire
  /// [primaryAction] to the confirm action and [secondaryAction] to cancel.
  factory StunningDialog.confirm({
    Key? key,
    required String title,
    String? message,
    Widget? content,
    Widget? primaryAction,
    Widget? secondaryAction,
    IconData icon = Icons.help_outline_rounded,
    Color? accentColor,
  }) {
    return StunningDialog(
      key: key,
      icon: icon,
      title: title,
      message: message,
      content: content,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction,
      // null accent resolves to the brand colour at build time.
      accentColor: accentColor,
    );
  }

  /// A success dialog: green accent with a check icon.
  factory StunningDialog.success({
    Key? key,
    required String title,
    String? message,
    Widget? content,
    Widget? primaryAction,
    Widget? secondaryAction,
    IconData icon = Icons.check_circle_outline_rounded,
    Color? accentColor,
  }) {
    return StunningDialog(
      key: key,
      icon: icon,
      title: title,
      message: message,
      content: content,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction,
      accentColor: accentColor ?? const Color(0xFF22C55E),
    );
  }

  /// An error dialog: the theme error colour with a warning icon.
  factory StunningDialog.error({
    Key? key,
    required String title,
    String? message,
    Widget? content,
    Widget? primaryAction,
    Widget? secondaryAction,
    IconData icon = Icons.error_outline_rounded,
    Color? accentColor,
  }) {
    return StunningDialog._intentful(
      key: key,
      icon: icon,
      title: title,
      message: message,
      content: content,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction,
      // null accent resolves to the theme error colour at build time.
      accentColor: accentColor,
      intent: _DialogIntent.error,
    );
  }

  /// Resolves the accent: an explicit [accentColor] wins; otherwise the colour
  /// is derived from the [_intent] using theme tokens.
  Color _resolveAccent(StunningTheme st) {
    if (accentColor != null) return accentColor!;
    switch (_intent) {
      case _DialogIntent.error:
        return st.colorScheme?.error ?? const Color(0xFFEF4444);
      case _DialogIntent.neutral:
        return st.primaryBrand;
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final accent = _resolveAccent(st);

    final body = content ??
        (message != null
            ? Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: st.textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              )
            : null);

    final hasActions = primaryAction != null || secondaryAction != null;

    return Semantics(
      container: true,
      label: title,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GlassSurface(
              borderRadius: 28,
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    _IconBadge(icon: icon!, accent: accent),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: st.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (body != null) ...<Widget>[
                    const SizedBox(height: 12),
                    body,
                  ],
                  if (hasActions) ...<Widget>[
                    const SizedBox(height: 28),
                    Row(
                      children: <Widget>[
                        if (secondaryAction != null) ...<Widget>[
                          Expanded(child: secondaryAction!),
                          if (primaryAction != null) const SizedBox(width: 12),
                        ],
                        if (primaryAction != null)
                          Expanded(child: primaryAction!),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The floating, glowing icon badge at the top of a [StunningDialog].
///
/// Keeps its shadow GEOMETRY constant (only the colour changes with the glow
/// token) so it never animates a blur radius toward zero under an overshoot
/// curve.
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color accent;

  const _IconBadge({required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final glow = st.glowIntensity;
    // Tinted surface core that reads on both light and dark backgrounds.
    final core = (st.colorScheme?.surface ?? st.surfaceGlass);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: core,
        border: Border.all(color: accent, width: 2),
        boxShadow: glow > 0
            ? <BoxShadow>[
                BoxShadow(
                  color: accent.withValues(alpha: 0.4 * glow),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: Icon(icon, color: accent, size: 32),
    );
  }
}

/// Presents a [StunningDialog] with a scale + fade transition and a dismissible
/// scrim, using the theme's motion duration and curve. Returns the value passed
/// to [Navigator.pop] (e.g. the user's choice), or `null` if dismissed.
///
/// Mirrors the [StunningDialog] constructor fields. Provide [content] to render
/// an arbitrary body in place of [message].
Future<T?> showStunningDialog<T>({
  required BuildContext context,
  IconData? icon,
  required String title,
  String? message,
  Widget? content,
  Widget? primaryAction,
  Widget? secondaryAction,
  Color? accentColor,

  /// Whether tapping the scrim dismisses the dialog. Defaults to `true`.
  bool barrierDismissible = true,
}) {
  final st = StunningTheme.of(context);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierDismissible
        ? MaterialLocalizations.of(context).modalBarrierDismissLabel
        : null,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    transitionDuration: st.motion(context),
    pageBuilder: (context, _, _) => SafeArea(
      child: StunningDialog(
        icon: icon,
        title: title,
        message: message,
        content: content,
        primaryAction: primaryAction,
        secondaryAction: secondaryAction,
        accentColor: accentColor,
      ),
    ),
    transitionBuilder: (context, anim, secAnim, child) {
      final st = StunningTheme.of(context);
      final curved = CurvedAnimation(parent: anim, curve: st.motionCurve);
      return FadeTransition(
        // Plain fade (no overshoot) keeps opacity within [0, 1].
        opacity: anim,
        child: ScaleTransition(scale: curved, child: child),
      );
    },
  );
}
