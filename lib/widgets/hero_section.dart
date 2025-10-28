import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.backgroundImage,
    this.minHeight,
    this.child,
  });

  final String title;
  final String subtitle;
  final ImageProvider? backgroundImage;
  final double? minHeight;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final height = minHeight ?? MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(minHeight: height),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image (optional)
          if (backgroundImage != null)
            DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: backgroundImage!,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            // Fallback decorative gradient if no image provided
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF222222), Color(0xFF000000)],
                ),
              ),
            ),
          // Dark overlay gradient for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          // Foreground content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                    if (child != null) ...[
                      const SizedBox(height: 24),
                      child!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
