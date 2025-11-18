import 'package:flutter/material.dart';

class ProfileAvatarSection extends StatelessWidget {
  const ProfileAvatarSection({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.bio,
    this.onEditAvatar,
  });

  final String imageUrl;
  final String name;
  final String bio;
  final VoidCallback? onEditAvatar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 56,
              backgroundImage: NetworkImage(imageUrl),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: onEditAvatar,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            bio,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
