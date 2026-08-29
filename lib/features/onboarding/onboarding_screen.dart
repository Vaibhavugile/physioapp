
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  late AnimationController _orbController;
  late AnimationController _contentController;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      eyebrow: 'CARE THAT COMES TO YOU',
      title: 'Better care.\nRight at home.',
      description:
          'Connect with trusted physiotherapists and get personalized rehabilitation care without leaving your home.',
      icon: Icons.home_rounded,
      number: '01',
    ),
    _OnboardingData(
      eyebrow: 'TRUSTED PROFESSIONALS',
      title: 'The right physio\nfor your recovery.',
      description:
          'Find verified physiotherapists matched to your condition, goals, location and preferred schedule.',
      icon: Icons.verified_rounded,
      number: '02',
    ),
    _OnboardingData(
      eyebrow: 'YOUR RECOVERY JOURNEY',
      title: 'Track every\nstep forward.',
      description:
          'Follow your treatment plan, complete exercises and see your recovery progress all in one place.',
      icon: Icons.monitor_heart_rounded,
      number: '03',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _orbController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'has_seen_onboarding',
      true,
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 550),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _finishOnboarding();
      return;
    }

    _contentController.reset();
    _contentController.forward();

    _pageController.nextPage(
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
    );
  }

  void _skip() {
    _finishOnboarding();
  }

  void _previous() {
    if (_currentPage == 0) return;

    _contentController.reset();
    _contentController.forward();

    _pageController.previousPage(
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Stack(
        children: [
          // ─────────────────────────────────────────────
          // PREMIUM BACKGROUND
          // ─────────────────────────────────────────────

          Positioned.fill(
            child: AnimatedBuilder(
              animation: _orbController,
              builder: (context, child) {
                final value = _orbController.value;

                return Stack(
                  children: [
                    Positioned(
                      top: -120 + (value * 30),
                      right: -100,
                      child: _GlowOrb(
                        size: 320,
                        color: const Color(0xFF5B6CFF),
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.28,
                      left: -160 + (value * 35),
                      child: _GlowOrb(
                        size: 280,
                        color: const Color(0xFF37C8B5),
                      ),
                    ),
                    Positioned(
                      bottom: -180,
                      right: -100,
                      child: _GlowOrb(
                        size: 360,
                        color: const Color(0xFF9D8CFF),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ─────────────────────────────────────────────
          // MAIN CONTENT
          // ─────────────────────────────────────────────

          SafeArea(
            child: Column(
              children: [
                // TOP BAR
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    18,
                    24,
                    0,
                  ),
                  child: Row(
                    children: [
                      // LOGO
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF4358F5),
                                  Color(0xFF24B9A7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4358F5)
                                      .withOpacity(.20),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.accessibility_new_rounded,
                              color: Colors.white,
                              size: 23,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Physio',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const Text(
                            'AtHome',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.5,
                              color: Color(0xFF687084),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // SKIP
                      GestureDetector(
                        onTap: _skip,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.65),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(.8),
                            ),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF596275),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PAGE CONTENT
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });

                      _contentController.reset();
                      _contentController.forward();
                    },
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        data: _pages[index],
                        animation: _contentController,
                        orbAnimation: _orbController,
                      );
                    },
                  ),
                ),

                // BOTTOM CONTROLS
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    0,
                    24,
                    24,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // PAGE NUMBER
                          Text(
                            '${(_currentPage + 1).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4358F5),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // PROGRESS
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                minHeight: 4,
                                value:
                                    (_currentPage + 1) /
                                    _pages.length,
                                backgroundColor:
                                    Colors.white.withOpacity(.75),
                                valueColor:
                                    const AlwaysStoppedAnimation(
                                  Color(0xFF4358F5),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Text(
                            _pages.length
                                .toString()
                                .padLeft(2, '0'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9AA1AF),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          // BACK BUTTON
                          AnimatedOpacity(
                            duration: const Duration(
                              milliseconds: 250,
                            ),
                            opacity:
                                _currentPage == 0 ? 0 : 1,
                            child: GestureDetector(
                              onTap: _currentPage == 0
                                  ? null
                                  : _previous,
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.8),
                                  borderRadius:
                                      BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ),
                          ),

                          if (_currentPage != 0)
                            const SizedBox(width: 12),

                          // PRIMARY CTA
                          Expanded(
                            child: GestureDetector(
                              onTap: _next,
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFF4358F5),
                                      Color(0xFF6375FF),
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4358F5)
                                          .withOpacity(.25),
                                      blurRadius: 24,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentPage ==
                                              _pages.length - 1
                                          ? 'Get started'
                                          : 'Continue',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withOpacity(.18),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons
                                            .arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ONBOARDING PAGE
// ─────────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final Animation<double> animation;
  final Animation<double> orbAnimation;

  const _OnboardingPage({
    required this.data,
    required this.animation,
    required this.orbAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final slide = 1 - animation.value;

        return Opacity(
          opacity: animation.value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, 25 * slide),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          24,
          12,
          24,
          10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 1),

            // HERO VISUAL
            Center(
              child: AnimatedBuilder(
                animation: orbAnimation,
                builder: (context, child) {
                  final movement =
                      (orbAnimation.value * 2 - 1) * 8;

                  return Transform.translate(
                    offset: Offset(0, movement),
                    child: child,
                  );
                },
                child: _HeroVisual(data: data),
              ),
            ),

            const Spacer(flex: 1),

            // EYEBROW
            Row(
              children: [
                Container(
                  width: 28,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4358F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  data.eyebrow,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: Color(0xFF4358F5),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // TITLE
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 38,
                height: 1.04,
                letterSpacing: -1.7,
                fontWeight: FontWeight.w800,
                color: Color(0xFF121827),
              ),
            ),

            const SizedBox(height: 16),

            // DESCRIPTION
            Text(
              data.description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.55,
                letterSpacing: -.1,
                color: Color(0xFF697386),
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// HERO VISUAL
// ─────────────────────────────────────────────────────────

class _HeroVisual extends StatelessWidget {
  final _OnboardingData data;

  const _HeroVisual({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // BACK CIRCLE
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE7EBFF),
                  Color(0xFFDDF7F3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4358F5)
                      .withOpacity(.08),
                  blurRadius: 50,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
          ),

          // GLASS PANEL
          Positioned(
            top: 30,
            right: 15,
            child: _GlassCard(
              width: 86,
              height: 74,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFEF6A83),
                    size: 21,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data.number == '03'
                        ? '92%'
                        : 'Care',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF263047),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // MAIN CARD
          Container(
            width: 175,
            height: 185,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.92),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27325B)
                      .withOpacity(.12),
                  blurRadius: 40,
                  offset: const Offset(0, 22),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 18,
                  left: 18,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF0FF),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      data.icon,
                      color: const Color(0xFF4358F5),
                      size: 21,
                    ),
                  ),
                ),

                Center(
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF4358F5),
                          Color(0xFF29B7A7),
                        ],
                      ),
                    ),
                    child: Icon(
                      data.icon,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),

                Positioned(
                  bottom: 18,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF35B86B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        'Trusted care',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // SMALL FLOATING CARD
          Positioned(
            bottom: 22,
            left: 4,
            child: _GlassCard(
              width: 108,
              height: 64,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8FAF6),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF16A89A),
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'On track',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF263047),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // DECORATIVE DOT
          Positioned(
            top: 105,
            left: 13,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF4358F5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// GLASS CARD
// ─────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const _GlassCard({
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.72),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(.9),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF25315C)
                    .withOpacity(.08),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────
// GLOW ORB
// ─────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: 65,
          sigmaY: 65,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────

class _OnboardingData {
  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final String number;

  const _OnboardingData({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.number,
  });
}

