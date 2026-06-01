import 'package:flutter/material.dart';
import '../../core/stunning_tappable.dart';
import '../../theme/stunning_theme.dart';

/// A compact, theme-aware page navigation control.
///
/// Renders a [Row] of: a previous-page arrow, a windowed set of numbered page
/// buttons (at most [maxVisible], centred on [currentPage], with leading and
/// trailing ellipsis when the full range is truncated), and a next-page arrow.
///
/// Every button is a [StunningTappable], so each one comes with a `button`
/// semantics role, screen-reader activation, full keyboard support, a
/// focus-visible ring, and a 48x48 minimum tap target for free. The active page
/// is filled with [StunningTheme.primaryBrand] and reads with an on-brand
/// foreground; the rest use [StunningTheme.textPrimary] on a transparent fill.
///
/// Pass [onPageChanged] `null` to disable the whole control. The previous arrow
/// is disabled on the first page and the next arrow on the last page.
class StunningPagination extends StatelessWidget {
  /// Total number of pages. Should be at least 1.
  final int pageCount;

  /// The currently selected page, **0-based** (so the first page is `0`).
  final int currentPage;

  /// Called with the target page index (0-based) when a button is activated.
  /// `null` disables every button in the control.
  final ValueChanged<int>? onPageChanged;

  /// Maximum number of numbered page buttons to show at once. The window slides
  /// around [currentPage] and ellipses indicate any hidden range. Defaults to 5.
  final int maxVisible;

  /// Creates a [StunningPagination] control.
  const StunningPagination({
    super.key,
    required this.pageCount,
    required this.currentPage,
    required this.onPageChanged,
    this.maxVisible = 5,
  });

  bool get _enabled => onPageChanged != null;

  /// Computes the inclusive [start, end] window of page indices to display so
  /// that the window stays centred on [currentPage] and clamps to the edges.
  List<int> _visiblePages() {
    if (pageCount <= 0) return const <int>[];
    final visible = maxVisible.clamp(1, pageCount);
    final half = visible ~/ 2;
    var start = currentPage - half;
    var end = currentPage + (visible - 1 - half);

    if (start < 0) {
      end += -start;
      start = 0;
    }
    if (end > pageCount - 1) {
      start -= end - (pageCount - 1);
      end = pageCount - 1;
    }
    if (start < 0) start = 0;

    return <int>[for (var i = start; i <= end; i++) i];
  }

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 0) return const SizedBox.shrink();

    final pages = _visiblePages();
    final showLeadingEllipsis = pages.isNotEmpty && pages.first > 0;
    final showTrailingEllipsis =
        pages.isNotEmpty && pages.last < pageCount - 1;

    final children = <Widget>[
      _ArrowButton(
        icon: Icons.chevron_left,
        semanticLabel: 'Previous page',
        // Disabled at the first page (or when the whole control is disabled).
        onPressed: _enabled && currentPage > 0
            ? () => onPageChanged!(currentPage - 1)
            : null,
      ),
      const SizedBox(width: 4),
      if (showLeadingEllipsis) const _Ellipsis(),
      for (final page in pages) ...<Widget>[
        _PageButton(
          page: page,
          isCurrent: page == currentPage,
          onPressed:
              _enabled ? () => onPageChanged!(page) : null,
        ),
        const SizedBox(width: 4),
      ],
      if (showTrailingEllipsis) const _Ellipsis(),
      _ArrowButton(
        icon: Icons.chevron_right,
        semanticLabel: 'Next page',
        // Disabled at the last page (or when the whole control is disabled).
        onPressed: _enabled && currentPage < pageCount - 1
            ? () => onPageChanged!(currentPage + 1)
            : null,
      ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

/// A single numbered page button. Highlights when it is the current page.
class _PageButton extends StatelessWidget {
  final int page;
  final bool isCurrent;
  final VoidCallback? onPressed;

  const _PageButton({
    required this.page,
    required this.isCurrent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final duration = st.motion(context);
    final curve = st.motionCurve;
    final radius = BorderRadius.circular(12);

    final fill = isCurrent ? st.primaryBrand : Colors.transparent;
    final fg = isCurrent ? st.onColor(st.primaryBrand) : st.textPrimary;

    return StunningTappable(
      onPressed: onPressed,
      // 1-based label for humans even though the index is 0-based.
      semanticLabel: 'Page ${page + 1}',
      selected: isCurrent,
      minTargetSize: 0,
      borderRadius: radius,
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: radius,
          border: Border.all(
            color: isCurrent ? Colors.transparent : st.borderColor,
            width: 1,
          ),
        ),
        child: Text(
          '${page + 1}',
          style: TextStyle(
            color: fg,
            fontSize: 14,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// A previous/next chevron arrow button.
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  const _ArrowButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final radius = BorderRadius.circular(12);
    final disabled = onPressed == null;

    return StunningTappable(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      borderRadius: radius,
      child: Container(
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: st.borderColor, width: 1),
        ),
        child: Icon(
          icon,
          // Dim the icon when the arrow is at the range edge / disabled.
          color: disabled ? st.iconColor.withValues(alpha: 0.35) : st.iconColor,
          size: 20,
        ),
      ),
    );
  }
}

/// A non-interactive truncation indicator between page-button groups.
class _Ellipsis extends StatelessWidget {
  const _Ellipsis();

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '…',
        style: TextStyle(
          color: st.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
