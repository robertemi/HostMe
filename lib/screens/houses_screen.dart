import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';
import '../widgets/houses_screen_widgets/house_detail_card.dart';
import '../widgets/houses_screen_widgets/house_action_bar.dart';

/// HousesScreen replicates the mockup in `mockups/housesScreen.html`.
/// Images will later come from the database; for now we use a local asset.
class HousesScreen extends StatefulWidget {
  const HousesScreen({super.key});

  @override
  State<HousesScreen> createState() => _HousesScreenState();
}

class _HousesScreenState extends State<HousesScreen> {
  int navIndex = 1; // Discover

  @override
  Widget build(BuildContext context) {
  const headerImage = 'assets/Final-housing-for-all-pillar.jpg';

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navIndex,
        onTap: (i) {
          if (i == navIndex) return;
          Widget target;
          switch (i) {
            case 0:
              target = const HomeScreen();
              break;
            case 1:
              target = const HousesScreen();
              break;
            case 2:
              target = const MatchesScreen();
              break;
            case 3:
            default:
              target = const ProfileScreen();
          }
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => target),
          );
        },
      ),
      body: Center(
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
      ),
    );
  }
}
