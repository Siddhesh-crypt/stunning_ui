// lib/src/components/layout/stunning_carousel.dart
import 'package:flutter/material.dart';

/// A 3D depth-scaling carousel slider that highlights the center widget and shrinks side elements.
class StunningCarousel extends StatefulWidget {
  /// The list of widgets to display inside the carousel.
  final List<Widget> items;

  /// The total height of the carousel container.
  final double height;
  final double viewportFraction;

  const StunningCarousel({
    super.key,
    required this.items,
    this.height = 300,
    this.viewportFraction = 0.75, // Screen ka kitna hissa center card lega
  });

  @override
  State<StunningCarousel> createState() => _StunningCarouselState();
}

class _StunningCarouselState extends State<StunningCarousel> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: 0,
    );

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          // Math to calculate distance from center
          double difference = index - _currentPage;

          // Cards side me jate hi shrink honge (0.8 scale) aur fade honge (0.5 opacity)
          double scale = 1.0 - (difference.abs() * 0.2).clamp(0.0, 0.2);
          double opacity = 1.0 - (difference.abs() * 0.5).clamp(0.0, 0.5);

          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 16,
                ), // Box shadow clipping rokne ke liye
                child: widget.items[index],
              ),
            ),
          );
        },
      ),
    );
  }
}
