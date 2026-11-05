import 'package:flutter/material.dart';

import '../../models/user_location_model.dart';
import '../home/home_screen.dart' hide HomeBottomNav;
import '../home/widgets/home_bottom_nav.dart';
import '../explore/explore_screen.dart';
import '../booking/my_bookings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  int _exploreRequestVersion = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onExploreRequested: _openExploreFromHome),
      const ExploreScreen(),
      const MyBookingsScreen(),
      const _ComingSoonScreen(
        title: 'Recovery',
        icon: Icons.favorite_rounded,
      ),
      const _ComingSoonScreen(
        title: 'Profile',
        icon: Icons.person_rounded,
      ),
    ];
  }

  /// Receives HomeScreen's Explore request and changes the active tab instead
  /// of pushing a route above the navigation Scaffold.
  void _openExploreFromHome(
    UserLocationModel? location,
    String? condition,
  ) {
    setState(() {
      _exploreRequestVersion++;
      _screens[1] = ExploreScreen(
        key: ValueKey<int>(_exploreRequestVersion),
        initialLocation: location,
        initialCondition: condition,
      );
      _currentIndex = 1;
    });
  }

  void _changeTab(int index) {
    if (index < 0 || index >= _screens.length || _currentIndex == index) {
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onChanged: _changeTab,
      ),
    );
  }
}

class _ComingSoonScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ComingSoonScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5E68E8), Color(0xFF5146D9)],
                ),
                borderRadius: BorderRadius.circular(21),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5146D9).withOpacity(.18),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF121A3A),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Coming soon',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF737C99),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
