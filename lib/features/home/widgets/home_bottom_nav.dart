import 'package:flutter/material.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onChanged;

  const HomeBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onChanged,
  });

  static const List<_NavItem> _items = [
    _NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavItem(
      label: 'Explore',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
    ),
    _NavItem(
      label: 'Bookings',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_month_rounded,
    ),
    _NavItem(
      label: 'Recovery',
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFE7EAF2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF202B50)
                .withOpacity(.09),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          _items.length,
          (index) {
            return Expanded(
              child: _NavButton(
                item: _items[index],
                active: currentIndex == index,
                onTap: () {
                  onChanged?.call(index);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [
                    Color(0xFFE9F8F5),
                    Color(0xFFF0F0FF),
                  ],
                )
              : null,
          borderRadius:
              BorderRadius.circular(17),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active
                  ? item.activeIcon
                  : item.icon,
              size: 21,
              color: active
                  ? const Color(0xFF079F87)
                  : const Color(0xFF7A829B),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 8,
                fontWeight: active
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: active
                    ? const Color(0xFF087F75)
                    : const Color(0xFF7A829B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}