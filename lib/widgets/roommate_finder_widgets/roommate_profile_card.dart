import 'package:flutter/material.dart';
import '../common/tag_chip.dart';

class RoommateProfileCard extends StatelessWidget {
  const RoommateProfileCard({
    super.key,
    required this.name,
    required this.age,
    required this.bio,
    required this.tags,
    this.imageAsset,
    this.imageUrl,
    required this.matchScore,
    this.rentPrice,
    this.houseAddress,
    this.hostAvatarUrl,
    this.searchMode = 'find_roommate',
  });

  final String name;
  final int age;
  final String bio;
  final List<String> tags;
  final String? imageAsset;
  final String? imageUrl;
  final int matchScore;
  final double? rentPrice;
  final String? houseAddress;
  final String? hostAvatarUrl;
  /// 'find_place' shows house with host bubble, 'find_roommate' shows person
  final String searchMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageProvider = (imageUrl != null && imageUrl!.isNotEmpty)
        ? NetworkImage(imageUrl!) as ImageProvider
        : AssetImage(imageAsset ?? 'assets/images/placeholder.jpg');

    return Container(
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
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xCC000000),
                  Color(0x00000000),
                ],
                stops: [0.0, 0.6],
              ),
            ),
          ),
          
          // Match Score Badge (Top Right)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$matchScore% Match',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Host Avatar Bubble (Top Left) - Only in find_place mode
          if (searchMode == 'find_place' && hostAvatarUrl != null)
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  // TODO: Show host profile details
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(hostAvatarUrl!),
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              ),
            ),

          // Content (Bottom)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                // Different display based on search mode
                if (searchMode == 'find_place') ...[
                  // FIND PLACE MODE: Show house info prominently
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (rentPrice != null)
                              Text(
                                '€${rentPrice!.toStringAsFixed(0)}/mo',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            if (houseAddress != null)
                              Text(
                                houseAddress!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Host info
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Hosted by $name, $age',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // FIND ROOMMATE MODE: Show person info prominently
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          '$name, $age',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in tags) TagChip(label: t, darkBackground: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
