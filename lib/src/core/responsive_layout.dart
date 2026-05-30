// lib/src/core/responsive_layout.dart
import 'package:flutter/material.dart';

class StunningResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxDesktopWidth;
  final double mobilePadding;

  const StunningResponsiveCenter({
    super.key,
    required this.child,
    this.maxDesktopWidth =
        600, // TextFields aur Cards ke liye ideal desktop width
    this.mobilePadding = 24.0, // Mobile edge padding
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxDesktopWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mobilePadding),
          child: child,
        ),
      ),
    );
  }
}
