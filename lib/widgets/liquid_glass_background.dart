import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme.dart';

class LiquidGlassBackground extends StatefulWidget {
  final Widget? child;
  final bool animate;
  final double speedMultiplier;

  const LiquidGlassBackground({super.key, this.child, this.animate = true, this.speedMultiplier = 1.0});

  @override
  State<LiquidGlassBackground> createState() => _LiquidGlassBackgroundState();
}

class _LiquidGlassBackgroundState extends State<LiquidGlassBackground> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _elapsed = 0.0; // seconds, continuously increasing
  double? _pendingElapsed;
  bool _frameScheduled = false;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker((elapsed) {
      // elapsed is a Duration since ticker start; use seconds as continuous time
      final secs = elapsed.inMilliseconds / 1000.0;
      // Schedule setState for the next frame to avoid calling setState during the build
      _pendingElapsed = secs;
      if (!_frameScheduled) {
        _frameScheduled = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _frameScheduled = false;
          if (!mounted) return;
          setState(() {
            _elapsed = _pendingElapsed ?? _elapsed;
          });
        });
      }
    });
    if (widget.animate) _ticker.start();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_ticker.isActive) {
      _ticker.start();
    } else if (!widget.animate && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Offset _drift(double baseX, double baseY, double radius, double phase, double speed) {
    // Use continuously increasing _elapsed so the motion never "resets"
    final t = _elapsed * speed * widget.speedMultiplier + phase;
    final dx = math.sin(2 * math.pi * t) * radius;
    final dy = math.cos(2 * math.pi * t * 0.7) * (radius * 0.6);
    return Offset(baseX + dx, baseY + dy);
  }

  @override
  Widget build(BuildContext context) {
    final blob1 = _drift(90, -60, 40, 0.0, 0.06);
    final blob2 = _drift(120, 200, 60, 0.5, 0.045);
    final blob3 = _drift(0, 100, 50, 0.25, 0.05);
    final blob4 = _drift(90, 150, 30, 0.75, 0.25);

    return Stack(
      children: [
        // base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.glassGradientStart, AppTheme.glassGradientEnd],
            ),
          ),
        ),

        // blob 1
        Positioned(
          left: blob1.dx,
          top: blob1.dy,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppTheme.glassAccent1.withOpacity(0.12), Colors.transparent],
                stops: const [0.0, 1.0],
                radius: 0.8,
              ),
            ),
          ),
        ),

        // blob 2
        Positioned(
          left: blob2.dx,
          top: blob2.dy,
          child: Container(
            width: 420,
            height: 420,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppTheme.glassAccent2.withOpacity(0.13), Colors.transparent],
                stops: const [0.0, 1.0],
                radius: 0.8,
              ),
            ),
          ),
        ),

        // blob 3
        Positioned(
          right: blob3.dx,
          top: blob3.dy,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppTheme.glassAccent3.withOpacity(0.14), Colors.transparent],
                stops: const [0.0, 1.0],
                radius: 0.8,
              ),
            ),
          ),
        ),

        // optional subtle highlight overlay
        Positioned(
          right: blob4.dx,
          bottom: blob4.dy,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white.withOpacity(0.15), Colors.transparent],
                stops: const [0.0, 1.0],
                radius: 0.8,
              ),
            ),
          ),
        ),

        // Global dark tint overlay to match the HeroSection look across all pages
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.20),
                  Colors.black.withOpacity(0.50),
                ],
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.02), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // child content
        if (widget.child != null) Positioned.fill(child: widget.child!),
      ],
    );
  }
}
