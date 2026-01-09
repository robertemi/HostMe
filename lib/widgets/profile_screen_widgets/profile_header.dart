import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget implements PreferredSizeWidget {
  const ProfileHeader({super.key, this.onEdit});

  final VoidCallback? onEdit;

  void onEditPressed() {
    if (onEdit != null) {
      onEdit!();
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'My Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: onEdit,
              child: Text(
                'Edit',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
