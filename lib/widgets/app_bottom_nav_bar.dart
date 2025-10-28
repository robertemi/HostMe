import 'dart:ui';

import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final Color active = Theme.of(context).primaryColor;
    final Color inactive = Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.grey.shade600;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withValues(alpha: 0.9),
            border: Border(top: BorderSide(color: Colors.black12)),
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
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.search,
                  label: 'Discover',
                  selected: currentIndex == 1,
                  active: active,
                  inactive: inactive,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  icon: Icons.favorite,
                  label: 'Matches',
                  selected: currentIndex == 2,
                  active: active,
                  inactive: inactive,
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  selected: currentIndex == 3,
                  active: active,
                  inactive: inactive,
                  onTap: () => onTap(3),
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
