import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:stunning_ui/src/theme/stunning_theme.dart';

/// A highly interactive, theme-aware text field with focus animations.
class StunningTextField extends StatefulWidget {
  final String hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;

  const StunningTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<StunningTextField> createState() => _StunningTextFieldState();
}

class _StunningTextFieldState extends State<StunningTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<StunningTheme>();
    final duration = theme?.motionDuration ?? const Duration(milliseconds: 200);
    final curve = theme?.motionCurve ?? Curves.easeInOut;

    final blur = theme?.glassBlurSigma ?? 10.0;
    final surfaceColor =
        theme?.surfaceGlass ?? Colors.white.withValues(alpha: 0.05);
    final brandColor = theme?.primaryBrand ?? Colors.blueAccent;

    // --- The Magic Fix ---
    // Hum dono states ke liye geometry exactly same rakhenge, bas color hatayenge
    final activeShadow =
        theme?.glowingShadow ?? const BoxShadow(color: Colors.transparent);
    final inactiveShadow = BoxShadow(
      color: Colors.transparent, // Color transparent kiya
      blurRadius: activeShadow.blurRadius, // Sizes exact wahi rakhe
      spreadRadius: activeShadow.spreadRadius,
      offset: activeShadow.offset,
    );

    return AnimatedContainer(
      duration: duration,
      curve: curve,
      decoration: BoxDecoration(
        color: _isFocused ? brandColor.withValues(alpha: 0.05) : surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? brandColor : Colors.white.withValues(alpha: 0.1),
          width: _isFocused ? 2.0 : 1.0,
        ),
        // Yahan ab Flutter sizes minus nahi karega, sirf color lerp karega
        boxShadow: [_isFocused ? activeShadow : inactiveShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            cursorColor: brandColor,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 15,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? brandColor
                          : Colors.white.withValues(alpha: 0.4),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
