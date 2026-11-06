import 'package:flutter/material.dart';

import '../home/doctor_home_screen.dart';
import '../requests/doctor_requests_screen.dart';

/// Root shell for the physiotherapist app. Keep this separate from the
/// customer application's PhysioHomeScreen and navigation.
class DoctorNavigationScreen extends StatefulWidget {
  const DoctorNavigationScreen({super.key});

  @override
  State<DoctorNavigationScreen> createState() => _DoctorNavigationScreenState();
}

class _DoctorNavigationScreenState extends State<DoctorNavigationScreen> {
  static const _purple = Color(0xFF5548D9);
  static const _ink = Color(0xFF171B3A);
  static const _muted = Color(0xFF8B91A6);
  static const _line = Color(0xFFE9EAF2);
  int _index = 0;

  final List<Widget> _pages = const [
    DoctorHomeScreen(),
    DoctorRequestsScreen(),
    _DoctorSectionPage(title: 'My schedule', subtitle: 'Your confirmed appointments will be organised here.', icon: Icons.calendar_month_rounded, tag: 'SCHEDULE'),
    _DoctorSectionPage(title: 'Earnings', subtitle: 'Track completed sessions, payouts and your earnings summary.', icon: Icons.account_balance_wallet_rounded, tag: 'YOUR PRACTICE'),
    _DoctorSectionPage(title: 'My profile', subtitle: 'Manage your professional details, services and verification documents.', icon: Icons.person_rounded, tag: 'PROFESSIONAL PROFILE'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F6FB),
    extendBody: true,
    body: IndexedStack(index: _index, children: _pages),
    bottomNavigationBar: SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(13, 0, 13, 10),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: _line),
          boxShadow: [BoxShadow(color: _ink.withOpacity(.10), blurRadius: 28, offset: const Offset(0, 9))],
        ),
        child: Row(children: [
          _navItem(0, Icons.grid_view_rounded, 'Home'),
          _navItem(1, Icons.inbox_rounded, 'Requests', showDot: true),
          _navItem(2, Icons.calendar_month_rounded, 'Schedule'),
          _navItem(3, Icons.account_balance_wallet_rounded, 'Earnings'),
          _navItem(4, Icons.person_rounded, 'Profile'),
        ]),
      ),
    ),
  );

  Widget _navItem(int index, IconData icon, String label, {bool showDot = false}) {
    final selected = _index == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () => setState(() => _index = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 230),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(color: selected ? const Color(0xFFEDEBFF) : Colors.transparent, borderRadius: BorderRadius.circular(16)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Stack(clipBehavior: Clip.none, children: [
                AnimatedScale(scale: selected ? 1.08 : 1, duration: const Duration(milliseconds: 220), child: Icon(icon, color: selected ? _purple : _muted, size: 20)),
                if (showDot) Positioned(right: -5, top: -3, child: Container(width: 7, height: 7, decoration: BoxDecoration(color: const Color(0xFFFF8A65), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.2)))),
              ]),
              const SizedBox(height: 5),
              AnimatedDefaultTextStyle(duration: const Duration(milliseconds: 180), style: TextStyle(color: selected ? _purple : _muted, fontSize: 8.5, fontWeight: selected ? FontWeight.w900 : FontWeight.w700), child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(height: 3),
              AnimatedContainer(duration: const Duration(milliseconds: 200), width: selected ? 13 : 0, height: 2.5, decoration: BoxDecoration(color: _purple, borderRadius: BorderRadius.circular(4))),
            ]),
          ),
        ),
      ),
    );
  }
}

class _DoctorSectionPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String tag;
  const _DoctorSectionPage({required this.title, required this.subtitle, required this.icon, required this.tag});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F6FB),
    body: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 100), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(tag, style: const TextStyle(color: Color(0xFF5548D9), fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text(title, style: const TextStyle(color: Color(0xFF171B3A), fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -.8)),
      const SizedBox(height: 7),
      Text(subtitle, style: const TextStyle(color: Color(0xFF8188A1), fontSize: 12, height: 1.5)),
      const SizedBox(height: 30),
      Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE8EAF2))), child: Column(children: [Container(width: 68, height: 68, decoration: const BoxDecoration(color: Color(0xFFEDEBFF), shape: BoxShape.circle), child: Icon(icon, color: Color(0xFF5548D9), size: 30)), const SizedBox(height: 15), Text('$title workspace', style: const TextStyle(color: Color(0xFF171B3A), fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 7), Text('This section is prepared in the doctor app navigation. We can connect its live Firestore data and actions next.', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF8188A1), fontSize: 11, height: 1.55))]))
    ]))),
  );
}
