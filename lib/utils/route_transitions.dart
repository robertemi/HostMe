import 'package:flutter/material.dart';

PageRouteBuilder<T> slideFadeRoute<T>({required Widget page, Duration duration = const Duration(milliseconds: 360)}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(begin: const Offset(0.15, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      final fadeAnimation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(position: offsetAnimation, child: child),
      );
    },
  );
}

PageRouteBuilder<T> fadeRoute<T>({required Widget page, Duration duration = const Duration(milliseconds: 300)}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      return FadeTransition(opacity: fade, child: child);
    },
  );
}
