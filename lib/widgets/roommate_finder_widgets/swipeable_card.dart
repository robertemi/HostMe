import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

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

  // Sensor state for 3D tilt effect
  double _tiltX = 0; // Rotation around Y axis (left/right tilt)
  double _tiltY = 0; // Rotation around X axis (up/down tilt)
  StreamSubscription<AccelerometerEvent>? _accelSubscription;

  late AnimationController _animationController;
  late Animation<double> _returnAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Subscribe to accelerometer events for the tilt effect
    // We use accelerometer instead of gyroscope for a stable "looking around" effect
    _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (!mounted) return;
      
      // Only apply tilt when not dragging to avoid fighting the user's finger
      if (!_isDragging) {
        setState(() {
          // Mapping accelerometer to rotation angles
          // event.x (Left/Right tilt) -> Rotate around Y axis
          // event.y (Up/Down tilt)    -> Rotate around X axis
          
          const double sensitivity = 0.05; // Increased sensitivity slightly
          
          // If phone tilts Left (positive x?), we want to rotate Y.
          // Experimentally:
          // event.x > 0 (Left tilt) -> We want to see the right side? -> Rotate Y positive?
          // Let's try direct mapping first.
          
          double targetRotateY = -event.x * sensitivity; 
          double targetRotateX = event.y * sensitivity;

          // Simple lerp for smoothness
          _tiltX = _lerp(_tiltX, targetRotateY, 0.1); // _tiltX is actually Rotation Y (left/right)
          _tiltY = _lerp(_tiltY, targetRotateX, 0.1); // _tiltY is actually Rotation X (up/down)
        });
      } else {
        // Reset tilt when dragging
        if (_tiltX != 0 || _tiltY != 0) {
          setState(() {
            _tiltX = 0;
            _tiltY = 0;
          });
        }
      }
    });
  }

  double _lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
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
          ..setEntry(3, 2, 0.001) // Add perspective for 3D effect
          ..translate(_dragX, _dragY)
          ..rotateZ(rotationAngle)
          ..rotateX(_tiltY) // Apply accelerometer tilt (up/down)
          ..rotateY(_tiltX), // Apply accelerometer tilt (left/right)
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
