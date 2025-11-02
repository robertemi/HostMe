import 'package:flutter/material.dart';

/// HousesScreen replicates the mockup in `mockups/housesScreen.html`.
/// Images will later come from the database; for now we use a local asset.
class HousesScreen extends StatelessWidget {
  const HousesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;

    // Temporary mock image from assets folder
    const headerImage = 'assets/Final-housing-for-all-pillar.jpg';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card shadow layer (subtle offset)
            Stack(
              alignment: Alignment.center,
              children: [
                // Soft offset shadow card
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

                // Main card
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
                      // Header image with gradient and captions
                      SizedBox(
                        height: 560 * 0.6,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              headerImage,
                              fit: BoxFit.cover,
                            ),

                            // Top progress bars
                            Positioned(
                              left: 8,
                              right: 8,
                              top: 8,
                              child: Row(
                                children: [
                                  _ProgressBar(filled: 0.9),
                                  const SizedBox(width: 6),
                                  _ProgressBar(filled: 0.4, dimmed: true),
                                  const SizedBox(width: 6),
                                  _ProgressBar(filled: 0.2, dimmed: true),
                                ],
                              ),
                            ),

                            // Bottom gradient + titles
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color(0xCC000000),
                                      Color(0x00000000),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Modern Downtown Loft',
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
                                        Text(
                                          'Downtown, 10-min walk to campus',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: Colors.white70,
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

                      // Content section
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Stack(
                            children: [
                              // Price pill
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
                                  child: const Text(
                                    '\$850/mo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),

                              // Body content
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sunny room with a private bath and walk-in closet. Comes fully furnished with access to a shared kitchen and living area.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark ? Colors.white70 : Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Current Roommates',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: isDark ? Colors.white70 : Color(0xFF334155),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _AvatarStack(
                                        image: headerImage,
                                        isDark: isDark,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '+2 more',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isDark ? Colors.white60 : Color(0xFF64748B),
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
            ),

            const SizedBox(height: 16),

            // Action buttons row with trailing undo
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SizedBox(
                height: 72,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionButton(
                            color: isDark ? const Color(0xFF3F3F46) : Colors.white,
                            splash: Colors.red.withOpacity(0.15),
                            icon: Icons.close,
                            iconColor: Colors.red,
                            size: 56,
                            onTap: () {},
                          ),
                          const SizedBox(width: 16),
                          _ActionButton(
                            color: isDark ? const Color(0xFF3F3F46) : Colors.white,
                            splash: Colors.blue.withOpacity(0.15),
                            icon: Icons.star,
                            iconColor: Colors.blue,
                            size: 48,
                            onTap: () {},
                          ),
                          const SizedBox(width: 16),
                          _ActionButton(
                            color: isDark ? const Color(0xFF3F3F46) : Colors.white,
                            splash: Colors.green.withOpacity(0.15),
                            icon: Icons.favorite,
                            iconColor: Colors.green,
                            size: 56,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: _ActionButton(
                        color: isDark ? const Color(0xFF3F3F46) : Colors.white,
                        splash: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                        icon: Icons.undo,
                        iconColor: isDark ? Colors.white70 : Colors.grey,
                        size: 48,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.filled, this.dimmed = false});
  final double filled; // 0..1
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final base = dimmed ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.8);
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          minHeight: 4,
          value: filled,
          backgroundColor: base.withOpacity(0.35),
          valueColor: AlwaysStoppedAnimation<Color>(base),
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.image, required this.isDark});
  final String image;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const double size = 44;
    final ring = isDark ? const Color(0xFF18181B) : Colors.white;

    Widget buildAvatar([double dx = 0]) => Transform.translate(
          offset: Offset(dx, 0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ring, width: 2),
              image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
            ),
          ),
        );

    return SizedBox(
      width: size * 2.6,
      height: size,
      child: Stack(
        children: [
          Positioned(left: 0, child: buildAvatar()),
          Positioned(left: size * 0.7, child: buildAvatar()),
          Positioned(left: size * 1.4, child: buildAvatar()),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.color,
    required this.splash,
    required this.icon,
    required this.iconColor,
    required this.size,
    required this.onTap,
  });

  final Color color;
  final Color splash;
  final IconData icon;
  final Color iconColor;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        splashColor: splash,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: iconColor, size: size * 0.48),
        ),
      ),
    );
  }
}
