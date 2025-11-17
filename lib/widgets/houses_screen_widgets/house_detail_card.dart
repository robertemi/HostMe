import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../common/progress_bar_segment.dart';
import '../common/overlapping_avatars.dart';

class HouseDetailCard extends StatelessWidget {
  const HouseDetailCard({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.location,
    required this.price,
    required this.description,
    required this.roommateImages,
  });

  final String imageAsset;
  final String title;
  final String location;
  final String price;
  final String description;
  final List<ImageProvider> roommateImages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, 8),
          child: Opacity(
            opacity: 0.75,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              height: 560,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF27272A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 420),
          height: 560,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF18181B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SizedBox(
                height: 560 * 0.6,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(imageAsset, fit: BoxFit.cover),
                    Positioned(
                      left: 8,
                      right: 8,
                      top: 8,
                      child: Row(
                        children: const [
                          ProgressBarSegment(filled: 0.9),
                          SizedBox(width: 6),
                          ProgressBarSegment(filled: 0.4, dimmed: true),
                          SizedBox(width: 6),
                          ProgressBarSegment(filled: 0.2, dimmed: true),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xCC000000), Color(0x00000000)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white70, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 8,
                        top: -28,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Text(
                            price,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Current Roommates',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isDark ? Colors.white70 : const Color(0xFF334155),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              OverlappingAvatars(images: roommateImages),
                              const SizedBox(width: 12),
                              Text(
                                '+${math.max(0, roommateImages.length - 3)} more',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
