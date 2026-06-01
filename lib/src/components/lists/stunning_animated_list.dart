// lib/src/components/lists/stunning_animated_list.dart
import 'package:flutter/material.dart';

import '../../theme/stunning_theme.dart';

class StunningAnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;

  const StunningAnimatedListItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<StunningAnimatedListItem> createState() =>
      _StunningAnimatedListItemState();
}

class _StunningAnimatedListItemState extends State<StunningAnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Staggered delay logic (har item thoda late aayega)
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);

    // Reduce-motion: skip the staggered slide/fade entrance and render the
    // final, static state immediately so no motion plays.
    if (StunningTheme.reduceMotion(context)) {
      return widget.child;
    }

    // Keep the entrance animation in sync with the themed (reduce-motion
    // aware) motion duration.
    _controller.duration = st.motion(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
