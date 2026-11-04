import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/physiotherapist_model.dart';

class PhysioPartnerHubScreen extends StatefulWidget {
  final PhysiotherapistModel physiotherapist;

  const PhysioPartnerHubScreen({
    super.key,
    required this.physiotherapist,
  });

  @override
  State<PhysioPartnerHubScreen> createState() =>
      _PhysioPartnerHubScreenState();
}

class _PhysioPartnerHubScreenState extends State<PhysioPartnerHubScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _floatController;

  static const Color _teal = Color(0xFF078F83);
  static const Color _deepTeal = Color(0xFF08766F);
  static const Color _mint = Color(0xFF57CDBB);
  static const Color _ink = Color(0xFF143D3B);
  static const Color _muted = Color(0xFF66817E);
  static const Color _background = Color(0xFFF4F8F7);
  static const Color _line = Color(0xFFE0EBE8);

  String get _name {
    final value = widget.physiotherapist.fullName.trim();
    return value.isEmpty ? 'Physiotherapist' : value;
  }

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      _discoverPage(),
      _howItWorksPage(),
      _earningsPage(),
      _profilePage(),
    ];

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: _line)),
          boxShadow: [
            BoxShadow(
              color: _ink.withOpacity(.045),
              blurRadius: 24,
              offset: const Offset(0, -7),
            ),
          ],
        ),
        child: NavigationBar(
          height: 70,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE5F5F1),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: _teal),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded, color: _teal),
              label: 'Discover',
            ),
            NavigationDestination(
              icon: Icon(Icons.route_outlined),
              selectedIcon: Icon(Icons.route_rounded, color: _teal),
              label: 'How it works',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon:
                  Icon(Icons.account_balance_wallet_rounded, color: _teal),
              label: 'Earnings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: _teal),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageShell({
    required Widget child,
    bool showHeader = true,
    String? title,
    String? subtitle,
  }) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (showHeader)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_teal, _deepTeal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _teal.withOpacity(.2),
                          blurRadius: 16,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.health_and_safety_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PhysioAtHome',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.5,
                          ),
                        ),
                        Text(
                          'PARTNER NETWORK',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _line),
                    ),
                    child: IconButton(
                      tooltip: 'Sign out',
                      onPressed: _signOut,
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 19,
                        color: _muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (title != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 27,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
        if (subtitle != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(child: child),
        const SliverToBoxAdapter(child: SizedBox(height: 26)),
      ],
    );
  }

  Widget _homePage() {
    return _pageShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -3 * _floatController.value),
                  child: child,
                );
              },
              child: _heroCard(),
            ),
            const SizedBox(height: 20),
            _applicationCard(),
            const SizedBox(height: 25),
            _sectionHeading('Your opportunity with PhysioAtHome',
                'A platform that helps patients find professional care.'),
            const SizedBox(height: 13),
            _benefitGrid(),
            const SizedBox(height: 25),
            _sectionHeading('How the platform works',
                'A simple journey from patient discovery to care.'),
            const SizedBox(height: 13),
            _journeyPreview(),
            const SizedBox(height: 22),
            _calloutCard(),
          ],
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF087F75), Color(0xFF07988A), Color(0xFF38B9A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _teal.withOpacity(.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -35,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(.13), width: 24),
              ),
            ),
          ),
          Positioned(
            right: 5,
            bottom: -50,
            child: Icon(
              Icons.health_and_safety_rounded,
              size: 145,
              color: Colors.white.withOpacity(.075),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.16),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.waving_hand_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'WELCOME TO THE PARTNER NETWORK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 19),
              Text(
                'Hello, ${_name.split(' ').first}.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Your expertise can bring quality physiotherapy care right to someone’s home.',
                style: TextStyle(
                  color: Color(0xFFE5FFFA),
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _heroPill(Icons.home_rounded, 'Care at home'),
                  const SizedBox(width: 8),
                  _heroPill(Icons.verified_user_rounded, 'Trusted network'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _applicationCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: _ink.withOpacity(.035),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5E6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.hourglass_top_rounded,
                    color: Color(0xFFE5A13A), size: 21),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your application',
                        style: TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        )),
                    SizedBox(height: 3),
                    Text('Your profile has been submitted',
                        style: TextStyle(color: _muted, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5E6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'UNDER REVIEW',
                  style: TextStyle(
                    color: Color(0xFFB8791B),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _statusDot(done: true),
              Expanded(child: Container(height: 2, color: _teal.withOpacity(.35))),
              _statusDot(done: false),
              Expanded(child: Container(height: 2, color: _line)),
              _statusDot(done: false),
            ],
          ),
          const SizedBox(height: 9),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Submitted', style: TextStyle(color: _teal, fontSize: 10, fontWeight: FontWeight.w800)),
              Text('Verification', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700)),
              Text('Approved', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Our team is reviewing your professional information. You can explore the partner experience while you wait.',
            style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _statusDot({required bool done}) {
    return Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        color: done ? _teal : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: done ? _teal : const Color(0xFFB8CAC6), width: 2),
      ),
      child: done
          ? const Icon(Icons.check, size: 8, color: Colors.white)
          : null,
    );
  }

  Widget _sectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -.45,
            )),
        const SizedBox(height: 5),
        Text(subtitle,
            style: const TextStyle(color: _muted, fontSize: 12, height: 1.45)),
      ],
    );
  }

  Widget _benefitGrid() {
    final items = [
      (Icons.people_alt_rounded, 'Patient reach', 'Help more people discover your expertise.'),
      (Icons.house_rounded, 'Home visits', 'Provide care in the comfort of patients’ homes.'),
      (Icons.calendar_month_rounded, 'Flexible schedule', 'Share availability that works for you.'),
      (Icons.trending_up_rounded, 'Practice growth', 'Build your practice through platform bookings.'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 11,
        mainAxisSpacing: 11,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.$1, color: _teal, size: 19),
              ),
              const Spacer(),
              Text(item.$2,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  )),
              const SizedBox(height: 4),
              Text(item.$3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 10, height: 1.35)),
            ],
          ),
        );
      },
    );
  }

  Widget _journeyPreview() {
    final steps = [
      ('01', Icons.search_rounded, 'Patients discover', 'People find physiotherapy care through PhysioAtHome.'),
      ('02', Icons.event_available_rounded, 'A booking is made', 'Patients choose a suitable service and appointment.'),
      ('03', Icons.medical_services_rounded, 'You provide care', 'You deliver professional treatment to the patient.'),
      ('04', Icons.account_balance_wallet_rounded, 'Commission & payout', 'The platform commission is applied under the partner payout policy.'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index == steps.length - 1 ? 0 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6F3),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(step.$2, color: _teal, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.$3,
                          style: const TextStyle(color: _ink, fontWeight: FontWeight.w900, fontSize: 12)),
                      const SizedBox(height: 3),
                      Text(step.$4,
                          style: const TextStyle(color: _muted, fontSize: 11, height: 1.4)),
                    ],
                  ),
                ),
                Text(step.$1,
                    style: const TextStyle(color: Color(0xFFB5CBC6), fontSize: 11, fontWeight: FontWeight.w900)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _calloutCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6F3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD6ECE6)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Get ready for your first opportunity',
                    style: TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w900)),
                SizedBox(height: 5),
                Text('Explore services, understand the patient journey and keep your profile information up to date.',
                    style: TextStyle(color: _muted, fontSize: 11, height: 1.45)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.rocket_launch_rounded, color: _teal, size: 23),
          ),
        ],
      ),
    );
  }

  Widget _discoverPage() {
    return _pageShell(
      title: 'Discover your opportunities',
      subtitle: 'Explore the ways patients can connect with you through PhysioAtHome.',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _serviceCard(
              icon: Icons.home_rounded,
              number: '01',
              title: 'Home physiotherapy',
              description: 'Provide personalized physiotherapy treatment at the patient’s home, helping them receive care in a familiar and comfortable environment.',
              tags: const ['Patient location', 'Home visit'],
            ),
            const SizedBox(height: 13),
            _serviceCard(
              icon: Icons.local_hospital_rounded,
              number: '02',
              title: 'Clinic consultations',
              description: 'Patients can discover your registered clinic location and book physiotherapy sessions based on your available schedule.',
              tags: const ['Clinic location', 'In-person care'],
            ),
            const SizedBox(height: 13),
            _serviceCard(
              icon: Icons.video_call_rounded,
              number: '03',
              title: 'Online consultations',
              description: 'Connect with patients remotely and provide guidance through online physiotherapy consultations.',
              tags: const ['Remote care', 'Online session'],
            ),
            const SizedBox(height: 18),
            _infoStrip(
              icon: Icons.info_outline_rounded,
              text: 'Service availability and booking opportunities depend on your approved profile, service setup and schedule.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard({
    required IconData icon,
    required String number,
    required String title,
    required String description,
    required List<String> tags,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFEAF7F3), Color(0xFFDDF2ED)]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: _teal, size: 23),
              ),
              const Spacer(),
              Text(number, style: const TextStyle(color: Color(0xFFB8CEC9), fontSize: 12, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(color: _muted, fontSize: 12, height: 1.5)),
          const SizedBox(height: 13),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFF0F7F5), borderRadius: BorderRadius.circular(30)),
              child: Text(tag, style: const TextStyle(color: _deepTeal, fontSize: 10, fontWeight: FontWeight.w700)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _howItWorksPage() {
    return _pageShell(
      title: 'How PhysioAtHome works',
      subtitle: 'A connected care journey that brings patients and physiotherapists together.',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_deepTeal, _teal, _mint],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Better care, closer to home.',
                            style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900, height: 1.15)),
                        SizedBox(height: 7),
                        Text('We help patients find the right physiotherapy support for their recovery journey.',
                            style: TextStyle(color: Color(0xFFE5FFFA), fontSize: 12, height: 1.45)),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 62),
                ],
              ),
            ),
            const SizedBox(height: 17),
            _detailStep('Patients find care', 'Patients explore physiotherapy services based on their needs, location and preferred schedule.', Icons.search_rounded),
            _detailStep('The right service is selected', 'They choose from available home, clinic or online consultation options.', Icons.tune_rounded),
            _detailStep('A booking connects the journey', 'A patient booking creates an opportunity for the physiotherapist to provide care.', Icons.calendar_month_rounded),
            _detailStep('Professional care is delivered', 'The physiotherapist provides the agreed service and manages the appointment through the platform.', Icons.volunteer_activism_rounded),
            _detailStep('The platform commission is applied', 'PhysioAtHome earns a commission for facilitating bookings, according to the partner terms.', Icons.account_balance_wallet_rounded),
            const SizedBox(height: 8),
            _infoStrip(
              icon: Icons.verified_user_outlined,
              text: 'Only approved and active physiotherapist accounts can access operational booking features.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailStep(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFFEAF6F3), borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: _teal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: _ink, fontWeight: FontWeight.w900, fontSize: 13)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: _muted, fontSize: 11, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _earningsPage() {
    return _pageShell(
      title: 'Understand your earnings',
      subtitle: 'A clear overview of how the PhysioAtHome partner commission model works.',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_deepTeal, _teal, Color(0xFF36B9A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 29),
                  SizedBox(height: 16),
                  Text('A partnership that works together',
                      style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900, height: 1.2)),
                  SizedBox(height: 7),
                  Text('PhysioAtHome connects patients with physiotherapists and earns through a commission on bookings.',
                      style: TextStyle(color: Color(0xFFE5FFFA), fontSize: 12, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _sectionHeading('How the commission model works',
                'The basic flow behind a platform booking.'),
            const SizedBox(height: 12),
            _moneyStep('01', 'Patient makes a booking', 'A patient books a physiotherapy service through PhysioAtHome.'),
            _moneyStep('02', 'Service is delivered', 'The physiotherapist completes the booked service.'),
            _moneyStep('03', 'Platform commission', 'PhysioAtHome retains the applicable commission under the agreed partner terms.'),
            _moneyStep('04', 'Partner payout', 'The eligible remaining amount is settled according to the payout process.'),
            const SizedBox(height: 15),
            _infoStrip(
              icon: Icons.lock_outline_rounded,
              text: 'Exact commission rates, payment collection method, settlement timing and deductions are governed by the partner agreement. No estimated figures are shown here.',
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _line),
              ),
              child: const Row(
                children: [
                  Icon(Icons.visibility_outlined, color: _teal, size: 22),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text('Once your account is approved, eligible booking and payout information can be made available in your partner dashboard.',
                        style: TextStyle(color: _muted, fontSize: 11, height: 1.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moneyStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: const Color(0xFFEAF6F3), borderRadius: BorderRadius.circular(11)),
            alignment: Alignment.center,
            child: Text(number, style: const TextStyle(color: _teal, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: _muted, fontSize: 11, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profilePage() {
    return _pageShell(
      title: 'Your partner profile',
      subtitle: 'Your submitted profile is being reviewed by the PhysioAtHome team.',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: _line),
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [_teal, _mint]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 38),
                  ),
                  const SizedBox(height: 12),
                  Text(_name, style: const TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  const Text('Physiotherapist partner applicant',
                      style: TextStyle(color: _muted, fontSize: 11)),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFFFF5E6), borderRadius: BorderRadius.circular(30)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_top_rounded, color: Color(0xFFB8791B), size: 14),
                        SizedBox(width: 6),
                        Text('Profile under review',
                            style: TextStyle(color: Color(0xFFB8791B), fontSize: 11, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _infoStrip(
              icon: Icons.edit_note_rounded,
              text: 'Your submitted professional details are currently with our review team. If changes are requested, you will be guided to update your profile.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _deepTeal,
                  side: const BorderSide(color: _line),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoStrip({required IconData icon, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6F3),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFD8ECE7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _teal, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: _deepTeal, fontSize: 11, height: 1.5, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
