import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:stunning_ui/src/theme/stunning_theme.dart';

/// Defines the visual layout of the data table.
enum StunningTableStyle {
  /// Rows float individually with space between them. Best for modern/gaming UIs.
  floating,

  /// Traditional compact grid inside a single container. Best for ERP/Dashboards.
  solid,
}

/// A revolutionary, highly customizable data table.
class StunningDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> data;

  /// Determines if the table is floating or a solid block.
  final StunningTableStyle style;

  /// Turn off if you just want plain text instead of glowing status pills.
  final bool enableSmartBadges;

  const StunningDataTable({
    super.key,
    required this.columns,
    required this.data,
    this.style = StunningTableStyle.floating,
    this.enableSmartBadges = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<StunningTheme>();
    final isFloating = style == StunningTableStyle.floating;

    // --- Header Builder ---
    Widget buildHeader() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: theme?.primaryBrand.withValues(alpha: isFloating ? 0.1 : 0.05),
          borderRadius: isFloating
              ? BorderRadius.circular(30)
              : BorderRadius.zero,
          border: isFloating
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
        ),
        child: Row(
          children: columns
              .map(
                (col) => Expanded(
                  child: Text(
                    col.toUpperCase(),
                    style: TextStyle(
                      color:
                          theme?.primaryBrand.withValues(alpha: 0.8) ??
                          Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }

    // --- Rows Builder ---
    List<Widget> buildRows() {
      return List.generate(data.length, (index) {
        final isLast = index == data.length - 1;

        final rowWidget = _StunningDataRow(
          rowData: data[index],
          isFloating: isFloating,
          isLast: isLast,
          enableSmartBadges: enableSmartBadges,
        );

        if (isFloating) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: rowWidget,
          );
        }
        return rowWidget;
      });
    }

    // --- Layout Logic ---
    if (isFloating) {
      // Floating Layout: Everything is separated
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [buildHeader(), const SizedBox(height: 16), ...buildRows()],
      );
    } else {
      // Solid Layout: Everything is wrapped in one glass container (ERP style)
      final blur = theme?.glassBlurSigma ?? 10.0;
      final surfaceColor =
          theme?.surfaceGlass ?? Colors.white.withValues(alpha: 0.05);

      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [buildHeader(), ...buildRows()],
            ),
          ),
        ),
      );
    }
  }
}

/// Internal widget to handle individual row physics and smart badges.
class _StunningDataRow extends StatefulWidget {
  final List<String> rowData;
  final bool isFloating;
  final bool isLast;
  final bool enableSmartBadges;

  const _StunningDataRow({
    required this.rowData,
    required this.isFloating,
    required this.isLast,
    required this.enableSmartBadges,
  });

  @override
  State<_StunningDataRow> createState() => _StunningDataRowState();
}

class _StunningDataRowState extends State<_StunningDataRow> {
  bool _isHovered = false;
  bool _isPressed = false;

  Widget _buildCell(String text, StunningTheme? theme) {
    if (widget.enableSmartBadges) {
      final lower = text.toLowerCase();
      if (lower == 'success' || lower == 'completed') {
        return _StatusBadge(
          text: text,
          color: Colors.greenAccent,
          theme: theme,
        );
      } else if (lower == 'pending' || lower == 'processing') {
        return _StatusBadge(
          text: text,
          color: Colors.orangeAccent,
          theme: theme,
        );
      } else if (lower == 'failed' || lower == 'error') {
        return _StatusBadge(text: text, color: Colors.redAccent, theme: theme);
      }
    }

    return Text(
      text,
      style: TextStyle(
        color: _isHovered ? Colors.white : Colors.white70,
        fontSize: 15,
        fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<StunningTheme>();
    final duration = theme?.motionDuration ?? const Duration(milliseconds: 200);
    final curve = theme?.motionCurve ?? Curves.easeOutBack;

    final blur = theme?.glassBlurSigma ?? 10.0;
    final surfaceColor =
        theme?.surfaceGlass ?? Colors.white.withValues(alpha: 0.05);

    final rowContent = AnimatedContainer(
      duration: duration,
      curve: curve,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      decoration: BoxDecoration(
        color: _isHovered
            ? theme?.primaryBrand.withValues(
                alpha: widget.isFloating ? 0.15 : 0.05,
              )
            : (widget.isFloating ? surfaceColor : Colors.transparent),
        borderRadius: widget.isFloating ? BorderRadius.circular(16) : null,
        border: widget.isFloating
            ? Border.all(
                color: _isHovered
                    ? (theme?.primaryBrand ?? Colors.white).withValues(
                        alpha: 0.5,
                      )
                    : Colors.white.withValues(alpha: 0.05),
                width: 1.5,
              )
            : Border(
                bottom: widget.isLast
                    ? BorderSide.none
                    : BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
        boxShadow: widget.isFloating && _isHovered && !_isPressed
            ? [
                theme?.glowingShadow ??
                    const BoxShadow(color: Colors.transparent),
              ]
            : [],
      ),
      child: Row(
        children: widget.rowData
            .map((cell) => Expanded(child: _buildCell(cell, theme)))
            .toList(),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),

        child: widget.isFloating
            ? AnimatedScale(
                scale: _isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0),
                duration: duration,
                curve: curve,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: rowContent,
                  ),
                ),
              )
            : rowContent, // No scale/blur for individual rows in solid mode
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final StunningTheme? theme;

  const _StatusBadge({required this.text, required this.color, this.theme});

  @override
  Widget build(BuildContext context) {
    final glow = theme?.glowIntensity ?? 0.5;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
          boxShadow: glow > 0
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3 * glow),
                    blurRadius: 10 * glow,
                    spreadRadius: 1 * glow,
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
