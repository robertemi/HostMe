import 'package:flutter/material.dart';
import '../widgets/houses_screen_widgets/house_detail_card.dart';
import '../widgets/houses_screen_widgets/house_action_bar.dart';

/// HousesScreen replicates the mockup in `mockups/housesScreen.html`.
/// Images will later come from the database; for now we use a local asset.
class HousesScreen extends StatelessWidget {
  const HousesScreen({super.key});

  @override
  Widget build(BuildContext context) {
  const headerImage = 'assets/Final-housing-for-all-pillar.jpg';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HouseDetailCard(
              imageAsset: headerImage,
              title: 'Modern Downtown Loft',
              location: 'Downtown, 10-min walk to campus',
              price: '\$850/mo',
              description:
                  'Sunny room with a private bath and walk-in closet. Comes fully furnished with access to a shared kitchen and living area.',
              roommateImages: [
                const AssetImage(headerImage),
                const AssetImage(headerImage),
                const AssetImage(headerImage),
                const AssetImage(headerImage),
              ],
            ),

            const SizedBox(height: 16),

            HouseActionBar(
              onNope: () {},
              onStar: () {},
              onLike: () {},
              onUndo: () {},
            ),
          ],
        ),
      ),
    );
  }
}
