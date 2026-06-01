import 'package:flutter/material.dart';
import '../../core/glass_surface.dart';
import '../../core/stunning_tappable.dart';
import '../../theme/stunning_theme.dart';

/// A generic, overlay-based dropdown/select that floats its menu in an
/// [OverlayPortal] instead of expanding inline.
///
/// Unlike the inline `StunningDropdown` (which is `String`-only and pushes
/// siblings down when it opens), [StunningSelect] is typed over [T] and anchors
/// a floating menu to its trigger, so it behaves correctly inside [Row]s and
/// other height-constrained layouts.
///
/// The trigger shows the selected item's label
/// (`itemLabel?.call(value) ?? value.toString()`) or [hint] when [value] is
/// `null`, plus a chevron that rotates while the menu is open. Tapping opens a
/// themed [GlassSurface] menu listing [items]; selecting a row calls
/// [onChanged] and closes the menu. A full-screen transparent barrier closes
/// the menu on an outside tap. The menu's height is capped at [maxMenuHeight]
/// with a scrollable list.
///
/// Passing `null` to [onChanged] disables the control (dimmed and
/// non-interactive). All chrome is derived from the active [StunningTheme] so
/// the widget works in both light and dark mode.
///
/// Accessibility is built in: the trigger is a [StunningTappable] button and
/// each menu row is a [StunningTappable] exposing its selected state, giving
/// keyboard focus, Enter/Space activation, a focus ring, and a >=48dp tap
/// target for free.
class StunningSelect<T> extends StatefulWidget {
  /// The selectable options shown in the floating menu.
  final List<T> items;

  /// The currently selected value, or `null` when nothing is selected (the
  /// [hint] is shown in that case).
  final T? value;

  /// Called with the chosen item when the user picks a row. Pass `null` to
  /// disable the control (it will not open and renders dimmed).
  final ValueChanged<T>? onChanged;

  /// Maps an item to its display string. Defaults to `item.toString()`.
  final String Function(T item)? itemLabel;

  /// Placeholder text shown on the trigger when [value] is `null`.
  final String? hint;

  /// Optional leading icon shown on the trigger.
  final IconData? icon;

  /// Maximum height of the floating menu before its list becomes scrollable.
  final double maxMenuHeight;

  /// Creates an overlay-based select.
  const StunningSelect({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.itemLabel,
    this.hint,
    this.icon,
    this.maxMenuHeight = 280,
  });

  /// Whether the control responds to input.
  bool get enabled => onChanged != null;

  @override
  State<StunningSelect<T>> createState() => _StunningSelectState<T>();
}

class _StunningSelectState<T> extends State<StunningSelect<T>> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();

  // Cache the trigger's size so the follower menu can match its width.
  Size _triggerSize = Size.zero;

  bool get _isOpen => _portal.isShowing;

  String _label(T item) => widget.itemLabel?.call(item) ?? item.toString();

  void _open() {
    if (!widget.enabled || _isOpen) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) _triggerSize = box.size;
    _portal.show();
    setState(() {}); // refresh chevron rotation + border highlight
  }

  void _close() {
    if (!_isOpen) return;
    _portal.hide();
    setState(() {});
  }

  void _toggle() => _isOpen ? _close() : _open();

  void _select(T item) {
    widget.onChanged?.call(item);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final enabled = widget.enabled;
    final duration = st.motion(context);
    final curve = st.motionCurve;

    final hasValue = widget.value != null;
    final triggerText =
        hasValue ? _label(widget.value as T) : (widget.hint ?? '');

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder:
            (overlayContext) => _buildOverlay(overlayContext, st),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.38,
          child: StunningTappable(
            onPressed: enabled ? _toggle : null,
            semanticLabel: hasValue ? triggerText : widget.hint,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: duration,
              curve: curve,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: st.surfaceGlass,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      _isOpen
                          ? st.primaryBrand.withValues(alpha: 0.5)
                          : st.borderColor,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (widget.icon != null) ...<Widget>[
                    Icon(
                      widget.icon,
                      size: 20,
                      color: hasValue ? st.primaryBrand : st.iconColor,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      triggerText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasValue ? st.textPrimary : st.hintColor,
                        fontSize: 16,
                        fontWeight:
                            hasValue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0.0,
                    duration: duration,
                    curve: curve,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: st.iconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, StunningTheme st) {
    return Stack(
      children: <Widget>[
        // Full-screen transparent barrier: tap outside closes the menu.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: const SizedBox.expand(),
          ),
        ),
        // The floating menu, anchored just below the trigger and matched to
        // its width.
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 8),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: _triggerSize.width > 0 ? _triggerSize.width : null,
              child: GlassSurface(
                borderRadius: 16,
                tintAmount: 0.06,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: widget.maxMenuHeight),
                  child: _MenuList<T>(
                    items: widget.items,
                    value: widget.value,
                    label: _label,
                    onSelect: _select,
                    theme: st,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The scrollable list of selectable rows inside the floating menu.
class _MenuList<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final String Function(T) label;
  final ValueChanged<T> onSelect;
  final StunningTheme theme;

  const _MenuList({
    required this.items,
    required this.value,
    required this.label,
    required this.onSelect,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final st = theme;
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 6),
      physics: const ClampingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = item == value;
        return StunningTappable(
          onPressed: () => onSelect(item),
          selected: isSelected,
          semanticLabel: label(item),
          minTargetSize: 0,
          borderRadius: BorderRadius.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? st.primaryBrand.withValues(alpha: 0.12)
                      : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isSelected ? st.primaryBrand : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    label(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? st.textPrimary : st.textSecondary,
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected) ...<Widget>[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: st.primaryBrand,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
