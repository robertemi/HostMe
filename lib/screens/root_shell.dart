import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'houses_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int idx) {
    setState(() => _currentIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          HomeScreen(),
          MatchesScreen(),
          ProfileScreen(),
        ],
        // allow natural swiping between pages; use default physics to respect platform behavior
        allowImplicitScrolling: true,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => _pageController.jumpToPage(i),
        pageController: _pageController,
      ),
    );
  }
}
