import 'dart:math' as math;
import 'package:flutter/material.dart';

class SwipeableCard extends StatefulWidget {
  const SwipeableCard({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.swipeThreshold = 100.0,
    this.maxRotation = 45.0,
  });

  final Widget child;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final double swipeThreshold;
  final double maxRotation; // Max rotation in degrees

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  double _dragY = 0;
  bool _isDragging = false;

  late AnimationController _animationController;
  late Animation<double> _returnAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _animationController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;
      _dragY += details.delta.dy * 0.4; // Reduce vertical movement
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;

    if (_dragX.abs() > widget.swipeThreshold) {
      // Swipe detected - animate off screen
      _animateOffScreen(_dragX > 0);
    } else {
      // Return to center
      _animateReturn();
    }
  }

  void _animateOffScreen(bool swipeRight) {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = swipeRight ? screenWidth * 1.5 : -screenWidth * 1.5;
    final startX = _dragX;
    final startY = _dragY;

    _returnAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.reset();
    _animationController.forward();

    _returnAnimation.addListener(() {
      setState(() {
        _dragX = startX + (targetX - startX) * _returnAnimation.value;
        _dragY = startY * (1 - _returnAnimation.value * 0.5);
      });
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (swipeRight) {
          widget.onSwipeRight();
        } else {
          widget.onSwipeLeft();
        }
        // Reset position for next card
        setState(() {
          _dragX = 0;
          _dragY = 0;
        });
      }
    });
  }

  void _animateReturn() {
    final startX = _dragX;
    final startY = _dragY;

    _returnAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.reset();
    _animationController.forward();

    _returnAnimation.addListener(() {
      setState(() {
        _dragX = startX * (1 - _returnAnimation.value);
        _dragY = startY * (1 - _returnAnimation.value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate rotation based on horizontal drag
    // Max rotation at swipe threshold, capped at maxRotation degrees
    final rotationProgress = (_dragX / widget.swipeThreshold).clamp(-1.0, 1.0);
    final rotationAngle = rotationProgress * widget.maxRotation * (math.pi / 180);

    // Calculate opacity for like/nope overlays
    final likeOpacity = (_dragX / widget.swipeThreshold).clamp(0.0, 1.0);
    final nopeOpacity = (-_dragX / widget.swipeThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(_dragX, _dragY)
          ..rotateZ(rotationAngle),
        child: Stack(
          children: [
            widget.child,
            // LIKE overlay (green, right swipe)
            if (likeOpacity > 0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.green.withOpacity(likeOpacity * 0.3),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: likeOpacity,
                      child: Transform.rotate(
                        angle: -0.4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'LIKE',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // NOPE overlay (red, left swipe)
            if (nopeOpacity > 0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.red.withOpacity(nopeOpacity * 0.3),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: nopeOpacity,
                      child: Transform.rotate(
                        angle: 0.4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NOPE',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
