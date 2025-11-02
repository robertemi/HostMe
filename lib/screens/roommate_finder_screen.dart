import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Roommate Finder screen UI based on `mockups/roommateScreen.html`.
///
/// NOTE:
/// - Navigation (home/filter) and swipe/action behaviors are TODOs.
/// - Data is mocked; later replace with real profiles and images from DB.
class RoommateFinderScreen extends StatelessWidget {
  const RoommateFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _TopBar(onHomeTap: () {
          // TODO: Navigate to Home
        }, onFilterTap: () {
          // TODO: Open filters
        }),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ProfileCard(
                      name: 'Sarah',
                      age: 21,
                      bio:
                          'Creative soul looking for a chill and respectful roommate.',
                      tags: const ['Art', 'Clean', 'Night Owl', 'Pet-Friendly'],
                      // Placeholder image from assets for now
                      imageAsset: 'assets/Final-housing-for-all-pillar.jpg',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _ActionBar(
              onNope: () {
                // TODO: Handle "Nope" action
              },
              onSuperLike: () {
                // TODO: Handle "Super Like" action
              },
              onLike: () {
                // TODO: Handle "Like" action
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onHomeTap, required this.onFilterTap});
  final VoidCallback onHomeTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? const Color(0xFFECF0F1)
        : const Color(0xFF34495E);

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onHomeTap,
            icon: Icon(Icons.home, color: textColor, size: 28),
            tooltip: 'Home',
          ),
          Expanded(
            child: Center(
              child: Text(
                'Roomie Finder',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onFilterTap,
            icon: Icon(Icons.tune, color: textColor, size: 24),
            tooltip: 'Filters',
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.age,
    required this.bio,
    required this.tags,
    required this.imageAsset,
  });

  final String name;
  final int age;
  final String bio;
  final List<String> tags;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.68,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle tilted background card
          Transform.rotate(
            angle: -4 * (math.pi / 180),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main profile card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
              image: DecorationImage(
                image: AssetImage(imageAsset),
                fit: BoxFit.cover,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0x99000000),
                    Color(0x00000000),
                  ],
                  stops: [0.0, 0.4],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      '$name, $age',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bio,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final t in tags)
                              _TagChip(
                                label: t,
                                isDarkBackground: true,
                              ),
                          ],
                        ),
                      ],
                    ),
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

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, this.isDarkBackground = false});
  final String label;
  final bool isDarkBackground;

  @override
  Widget build(BuildContext context) {
    final bg = isDarkBackground ? Colors.white.withOpacity(0.2) : Colors.black12;
    final fg = isDarkBackground ? Colors.white : Colors.black87;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.onNope,
    required this.onSuperLike,
    required this.onLike,
  });

  final VoidCallback onNope;
  final VoidCallback onSuperLike;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF334155) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionColumnButton(
            label: 'Nope',
            icon: Icons.close,
            iconSize: 28,
            color: Colors.red.shade600,
            surface: surface,
            padding: const EdgeInsets.all(16),
            onTap: onNope,
          ),
          _ActionColumnButton(
            label: 'Super Like',
            icon: Icons.star,
            iconSize: 24,
            color: const Color(0xFFF39C12),
            surface: surface,
            padding: const EdgeInsets.all(12),
            onTap: onSuperLike,
          ),
          _ActionColumnButton(
            label: 'Like',
            icon: Icons.favorite,
            iconSize: 28,
            color: theme.primaryColor,
            surface: surface,
            padding: const EdgeInsets.all(16),
            onTap: onLike,
          ),
        ],
      ),
    );
  }
}

class _ActionColumnButton extends StatelessWidget {
  const _ActionColumnButton({
    required this.label,
    required this.icon,
    required this.iconSize,
    required this.color,
    required this.surface,
    required this.padding,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final double iconSize;
  final Color color;
  final Color surface;
  final EdgeInsets padding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: surface,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: padding,
              child: Icon(icon, color: color, size: iconSize),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
