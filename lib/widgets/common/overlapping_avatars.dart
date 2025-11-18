import 'package:flutter/material.dart';

class OverlappingAvatars extends StatelessWidget {
  const OverlappingAvatars({
    super.key,
    required this.images,
    this.size = 44,
    this.ringColor,
    this.spacingFactor = 0.7,
  });

  final List<ImageProvider> images;
  final double size;
  final Color? ringColor;
  final double spacingFactor;

  @override
  Widget build(BuildContext context) {
    final ring = ringColor ??
        (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF18181B) : Colors.white);
    final width = size * (1 + (images.length - 1) * spacingFactor);

    List<Widget> stackChildren = [];
    for (var i = 0; i < images.length; i++) {
      stackChildren.add(Positioned(
        left: i * size * spacingFactor,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ring, width: 2),
            image: DecorationImage(image: images[i], fit: BoxFit.cover),
          ),
        ),
      ));
    }

    return SizedBox(
      width: width,
      height: size,
      child: Stack(children: stackChildren),
    );
  }
}
