import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../home/widgets/home_bottom_nav.dart';
import '../explore/explore_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({
    super.key,
  });

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = const [
      HomeScreen(),
      ExploreScreen(),

      // Temporary screens.
      _ComingSoonScreen(
        title: 'Bookings',
        icon: Icons.calendar_month_rounded,
      ),

      _ComingSoonScreen(
        title: 'Recovery',
        icon: Icons.favorite_rounded,
      ),

      _ComingSoonScreen(
        title: 'Profile',
        icon: Icons.person_rounded,
      ),
    ];
  }

  void _changeTab(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FC),

      // ==========================================================
      // SCREEN
      // ==========================================================

      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // ==========================================================
      // ONE SHARED BOTTOM NAVIGATION
      // ==========================================================

      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onChanged: _changeTab,
      ),
    );
  }
}


// ===============================================================
// TEMPORARY SCREEN
// ===============================================================

class _ComingSoonScreen
    extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ComingSoonScreen({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FC),

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,

              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5E68E8),
                    Color(0xFF5146D9),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(0xFF5146D9)
                            .withOpacity(.15),
                    blurRadius: 18,
                    offset:
                        const Offset(0, 7),
                  ),
                ],
              ),

              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF121A3A),
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Coming soon',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF737C99),
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}