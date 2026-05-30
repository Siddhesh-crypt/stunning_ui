// lib/src/components/inputs/stunning_text_field.dart
import 'package:flutter/material.dart';
import 'package:stunning_ui/src/theme/stunning_theme.dart';

class StunningTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isPassword;

  const StunningTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.isPassword = false,
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: theme?.surfaceGlass ?? Colors.white.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: _isFocused
              ? (theme?.primaryBrand ?? Colors.blue)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: _isFocused && theme != null ? [theme.glowingShadow] : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha:0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
