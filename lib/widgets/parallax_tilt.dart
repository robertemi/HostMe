import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ParallaxTilt extends StatefulWidget {
  final Widget child;
  final double maxTilt; // Max tilt in degrees
  final double sensitivity;
  final bool enabled;

  const ParallaxTilt({
    super.key,
    required this.child,
    this.maxTilt = 10.0,
    this.sensitivity = 0.05,
    this.enabled = true,
  });

  @override
  State<ParallaxTilt> createState() => _ParallaxTiltState();
}

class _ParallaxTiltState extends State<ParallaxTilt> {
  double _tiltX = 0; // Rotation around Y axis (left/right tilt)
  double _tiltY = 0; // Rotation around X axis (up/down tilt)
  StreamSubscription<AccelerometerEvent>? _accelSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startListening();
    }
  }

  @override
  void didUpdateWidget(ParallaxTilt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _startListening();
      } else {
        _stopListening();
      }
    }
  }

  void _startListening() {
    _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (!mounted) return;

      // Mapping accelerometer to rotation angles
      // event.x (Left/Right tilt) -> Rotate around Y axis
      // event.y (Up/Down tilt)    -> Rotate around X axis
      
      // We target these values
      double targetTiltY = -event.x * widget.sensitivity; 
      double targetTiltX = event.y * widget.sensitivity;

      // Clamp values to max tilt
      // Convert maxTilt to radians for comparison if needed, but here we are dealing with small radians directly
      // Let's just clamp the result to keep it subtle
      // 1 radian is approx 57 degrees. 10 degrees is ~0.17 rad.
      
      setState(() {
        // Simple lerp for smoothness
        _tiltX = _lerp(_tiltX, targetTiltY, 0.1);
        _tiltY = _lerp(_tiltY, targetTiltX, 0.1);
      });
    });
  }

  void _stopListening() {
    _accelSubscription?.cancel();
    _accelSubscription = null;
    setState(() {
      _tiltX = 0;
      _tiltY = 0;
    });
  }

  double _lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Add perspective
        ..rotateX(_tiltY)
        ..rotateY(_tiltX),
      child: widget.child,
    );
  }
}
