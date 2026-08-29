import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _orbController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _logoSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(
        0.0,
        0.65,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.82,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(
          0.0,
          0.75,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(
          0.15,
          0.85,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // Floating background animation
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    // Very subtle logo pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _mainController.forward();

    Timer(
      const Duration(milliseconds: 3000),
      _goToOnboarding,
    );
  }

  void _goToOnboarding() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            const OnboardingScreen(),
        transitionDuration:
            const Duration(milliseconds: 700),
        transitionsBuilder:
            (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 1.025,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _orbController.dispose();
    _pulseController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          // ==================================================
          // BACKGROUND GLOW
          // ==================================================

          Positioned(
            top: -160,
            right: -130,
            child: AnimatedBuilder(
              animation: _orbController,
              builder: (_, child) {
                final movement =
                    _orbController.value * 35;

                return Transform.translate(
                  offset: Offset(
                    -movement,
                    movement,
                  ),
                  child: child,
                );
              },
              child: const _GlowOrb(
                size: 370,
                color: Color(0xFF6375FF),
              ),
            ),
          ),

          Positioned(
            bottom: -190,
            left: -130,
            child: AnimatedBuilder(
              animation: _orbController,
              builder: (_, child) {
                final movement =
                    _orbController.value * 30;

                return Transform.translate(
                  offset: Offset(
                    movement,
                    -movement,
                  ),
                  child: child,
                );
              },
              child: const _GlowOrb(
                size: 360,
                color: Color(0xFF2EC2B1),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.sizeOf(context).height * .38,
            right: -180,
            child: const _GlowOrb(
              size: 300,
              color: Color(0xFFA99BFF),
            ),
          ),

          // ==================================================
          // MAIN CONTENT
          // ==================================================

          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _logoSlideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ==================================================
                        // PREMIUM LOGO
                        // ==================================================

                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (_, child) {
                            final value =
                                _pulseController.value;

                            return Transform.scale(
                              scale:
                                  1.0 + (value * .025),
                              child: child,
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow
                              Container(
                                width: 150,
                                height: 150,
                                decoration:
                                    BoxDecoration(
                                  shape:
                                      BoxShape.circle,
                                  color:
                                      const Color(
                                    0xFF4358F5,
                                  ).withOpacity(.06),
                                ),
                              ),

                              // Soft ring
                              Container(
                                width: 122,
                                height: 122,
                                decoration:
                                    BoxDecoration(
                                  shape:
                                      BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        Colors.white
                                            .withOpacity(
                                      .9,
                                    ),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color(
                                        0xFF4358F5,
                                      ).withOpacity(.10),
                                      blurRadius: 35,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                              ),

                              // Main logo
                              Container(
                                width: 98,
                                height: 98,
                                decoration:
                                    BoxDecoration(
                                  gradient:
                                      const LinearGradient(
                                    begin:
                                        Alignment.topLeft,
                                    end: Alignment
                                        .bottomRight,
                                    colors: [
                                      Color(0xFF4358F5),
                                      Color(0xFF6174FF),
                                      Color(0xFF25B8A6),
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    32,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color(
                                        0xFF4358F5,
                                      ).withOpacity(.28),
                                      blurRadius: 35,
                                      offset:
                                          const Offset(
                                        0,
                                        16,
                                      ),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons
                                      .accessibility_new_rounded,
                                  color: Colors.white,
                                  size: 53,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 34),

                        // ==================================================
                        // BRAND
                        // ==================================================

                        const Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Text(
                              'Physio',
                              style: TextStyle(
                                fontSize: 30,
                                letterSpacing: -1.3,
                                fontWeight:
                                    FontWeight.w800,
                                color:
                                    Color(0xFF121827),
                              ),
                            ),
                            Text(
                              'AtHome',
                              style: TextStyle(
                                fontSize: 30,
                                letterSpacing: -1.3,
                                fontWeight:
                                    FontWeight.w500,
                                color:
                                    Color(0xFF70798B),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 11),

                        // ==================================================
                        // TAGLINE
                        // ==================================================

                        const Text(
                          'Expert care. At your doorstep.',
                          style: TextStyle(
                            fontSize: 13,
                            letterSpacing: .1,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                Color(0xFF7B8495),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ==================================================
                        // MINI TRUST BADGE
                        // ==================================================

                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 12,
                              sigmaY: 12,
                            ),
                            child: Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 15,
                                vertical: 9,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: Colors.white
                                    .withOpacity(.65),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  30,
                                ),
                                border: Border.all(
                                  color: Colors.white
                                      .withOpacity(.9),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons
                                        .verified_rounded,
                                    size: 15,
                                    color:
                                        Color(
                                      0xFF35B86B,
                                    ),
                                  ),
                                  SizedBox(width: 7),
                                  Text(
                                    'Personalized recovery care',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                      color:
                                          Color(
                                        0xFF697386,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ==================================================
          // BOTTOM LOADING / BRAND STATUS
          // ==================================================

          Positioned(
            left: 32,
            right: 32,
            bottom: 34,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Progress line
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(20),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: 1,
                      ),
                      duration:
                          const Duration(milliseconds: 2700),
                      curve: Curves.easeInOut,
                      builder:
                          (context, value, child) {
                        return LinearProgressIndicator(
                          minHeight: 3,
                          value: value,
                          backgroundColor:
                              Colors.white
                                  .withOpacity(.75),
                          valueColor:
                              const AlwaysStoppedAnimation(
                            Color(0xFF4358F5),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration:
                            const BoxDecoration(
                          color: Color(0xFF35B86B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        'Your health, your journey.',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight:
                              FontWeight.w600,
                          color: Color(0xFF9AA1AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// GLOW ORB
// ==========================================================

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
          sigmaX: 70,
          sigmaY: 70,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(.10),
          ),
        ),
      ),
    );
  }
}