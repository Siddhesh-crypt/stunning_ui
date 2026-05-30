// lib/src/components/inputs/stunning_switch.dart
import 'package:flutter/material.dart';
import 'package:stunning_ui/src/theme/stunning_theme.dart';

class StunningSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const StunningSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<StunningTheme>();
    final primary = theme?.primaryBrand ?? Colors.purpleAccent;

    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 56,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value
              ? primary.withValues(alpha:0.3)
              : Colors.white.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value
                ? primary.withValues(alpha:0.5)
                : Colors.white.withValues(alpha:0.2),
            width: 1.5,
          ),
          boxShadow: value
              ? [BoxShadow(color: primary.withValues(alpha:0.4), blurRadius: 12)]
              : [],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? primary : Colors.white54,
              boxShadow: value
                  ? [BoxShadow(color: primary, blurRadius: 8, spreadRadius: 1)]
                  : [],
            ),
          ),
        ),
      ),
    );
  }
}
