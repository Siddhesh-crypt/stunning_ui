import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:stunning_ui/src/theme/stunning_theme.dart';

class StunningDropdown extends StatefulWidget {
  final String hintText;
  final List<String> items;
  final String? value;
  final ValueChanged<String> onChanged;
  final IconData? prefixIcon;

  const StunningDropdown({
    super.key,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.value,
    this.prefixIcon,
  });

  @override
  State<StunningDropdown> createState() => _StunningDropdownState();
}

class _StunningDropdownState extends State<StunningDropdown> {
  bool _isOpen = false;

  void _toggleDropdown() => setState(() => _isOpen = !_isOpen);

  void _selectItem(String item) {
    widget.onChanged(item);
    _toggleDropdown();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<StunningTheme>();
    final duration = theme?.motionDuration ?? const Duration(milliseconds: 200);
    final curve = theme?.motionCurve ?? Curves.easeInOut;

    final blur = theme?.glassBlurSigma ?? 10.0;
    final brandColor = theme?.primaryBrand ?? Colors.blueAccent;
    final activeShadow =
        theme?.glowingShadow ?? const BoxShadow(color: Colors.transparent);

    final inactiveShadow = BoxShadow(
      color: Colors.transparent,
      blurRadius: activeShadow.blurRadius,
      spreadRadius: activeShadow.spreadRadius,
    );

    return AnimatedContainer(
      duration: duration,
      curve: curve,
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.03,
        ), // No muddy colors, just clean glass
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isOpen
              ? brandColor.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
        boxShadow: [_isOpen ? activeShadow : inactiveShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Clean Header ---
              InkWell(
                onTap: _toggleDropdown,
                splashColor: brandColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      if (widget.prefixIcon != null) ...[
                        Icon(
                          widget.prefixIcon,
                          color: widget.value != null
                              ? brandColor
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          widget.value ?? widget.hintText,
                          style: TextStyle(
                            color: widget.value != null
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            fontSize: 16,
                            fontWeight: widget.value != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isOpen ? 0.5 : 0.0,
                        duration: duration,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- The Stealth List ---
              AnimatedSize(
                duration: duration,
                curve: curve,
                alignment: Alignment.topCenter,
                child: _isOpen
                    ? Column(
                        children: [
                          Divider(
                            color: Colors.white.withValues(alpha: 0.1),
                            height: 1,
                          ),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: widget.items.map((item) {
                                  final isSelected = widget.value == item;
                                  return InkWell(
                                    onTap: () => _selectItem(item),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        // A subtle left border highlight for the selected item
                                        border: isSelected
                                            ? Border(
                                                left: BorderSide(
                                                  color: brandColor,
                                                  width: 3,
                                                ),
                                              )
                                            : const Border(
                                                left: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 3,
                                                ),
                                              ),
                                        color: isSelected
                                            ? brandColor.withValues(alpha: 0.05)
                                            : Colors.transparent,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.white.withValues(
                                                        alpha: 0.6,
                                                      ),
                                                fontSize: 15,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: brandColor,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
