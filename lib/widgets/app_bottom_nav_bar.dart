import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.pageController,
  });

  final int currentIndex; // 0 = Home, 1 = Matches, 2 = Profile
  final ValueChanged<int> onTap;
  final PageController? pageController;

  @override
  Widget build(BuildContext context) {
    final Color active = Theme.of(context).primaryColor;
    final Color inactive = Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.grey.shade600;

    // Simple opaque Material nav bar with three buttons (Home, Matches, Profile)
    final theme = Theme.of(context);
    final navBg = theme.colorScheme.surface; // opaque surface color

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Material(
        color: navBg,
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(
            color: navBg,
            border: Border(top: BorderSide(color: theme.dividerColor)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home,
                  label: 'Home',
                  selected: currentIndex == 0,
                  active: active,
                  inactive: inactive,
                  onTap: () {
                    if (pageController != null) {
                      pageController!.jumpToPage(0);
                    } else {
                      onTap(0);
                    }
                  },
                ),
                _NavItem(
                  icon: Icons.favorite,
                  label: 'Matches',
                  selected: currentIndex == 1,
                  active: active,
                  inactive: inactive,
                  onTap: () {
                    if (pageController != null) {
                      pageController!.jumpToPage(1);
                    } else {
                      onTap(1);
                    }
                  },
                ),
                _NavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  selected: currentIndex == 2,
                  active: active,
                  inactive: inactive,
                  onTap: () {
                    if (pageController != null) {
                      pageController!.jumpToPage(2);
                    } else {
                      onTap(2);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.active,
    required this.inactive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color active;
  final Color inactive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? active : inactive;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
