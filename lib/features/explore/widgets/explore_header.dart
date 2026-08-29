import 'package:flutter/material.dart';

class ExploreHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const ExploreHeader({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 255,

      clipBehavior: Clip.antiAlias,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8F7FF),
            Color(0xFFEFFAF8),
          ],
        ),

        border: Border.all(
          color: const Color(0xFFE3E6F0),
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF202B50)
                .withOpacity(.08),
            blurRadius: 30,
            offset: const Offset(0, 13),
          ),
        ],
      ),

      child: Stack(
        children: [

          // ======================================================
          // PURPLE GLOW
          // ======================================================

          Positioned(
            right: -70,
            top: -75,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7567EE)
                        .withOpacity(.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ======================================================
          // TEAL GLOW
          // ======================================================

          Positioned(
            right: -15,
            bottom: -90,
            child: Container(
              width: 260,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF079F87)
                        .withOpacity(.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ======================================================
          // SOFT DECORATIVE DOTS
          // ======================================================

          Positioned(
            right: 190,
            bottom: 58,
            child: _DotPattern(),
          ),

          // ======================================================
          // MEDICAL ORBS
          // ======================================================

          Positioned(
            right: 139,
            bottom: 52,
            child: _MedicalOrb(
              icon: Icons.accessibility_new_rounded,
            ),
          ),

          Positioned(
            right: 104,
            bottom: 83,
            child: _MedicalOrb(
              icon: Icons.favorite_rounded,
            ),
          ),

          Positioned(
            right: 57,
            bottom: 48,
            child: _MedicalOrb(
              icon: Icons.directions_run_rounded,
            ),
          ),

          // ======================================================
          // TOP RIGHT ACTIONS
          // ======================================================

          Positioned(
            top: 15,
            right: 14,

            child: Row(
              children: [

                // ------------------------------------------------
                // NOTIFICATION
                // ------------------------------------------------

                GestureDetector(
                  onTap: onNotificationTap,
                  behavior:
                      HitTestBehavior.opaque,

                  child: Container(
                    width: 46,
                    height: 46,

                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(.96),

                      shape: BoxShape.circle,

                      border: Border.all(
                        color:
                            const Color(0xFFE2E5EF),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(
                            0xFF202B50,
                          ).withOpacity(.10),

                          blurRadius: 14,

                          offset:
                              const Offset(0, 5),
                        ),
                      ],
                    ),

                    child: Stack(
                      alignment: Alignment.center,
                      children: [

                        const Icon(
                          Icons
                              .notifications_none_rounded,
                          size: 23,
                          color:
                              Color(0xFF111A3B),
                        ),

                        Positioned(
                          top: 9,
                          right: 9,

                          child: Container(
                            width: 8,
                            height: 8,

                            decoration:
                                const BoxDecoration(
                              color:
                                  Color(0xFF6348E8),
                              shape:
                                  BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 9),

                // ------------------------------------------------
                // PROFILE
                // ------------------------------------------------

                GestureDetector(
                  onTap: onProfileTap,
                  behavior:
                      HitTestBehavior.opaque,

                  child: Container(
                    width: 47,
                    height: 47,

                    padding:
                        const EdgeInsets.all(2),

                    decoration:
                        const BoxDecoration(
                      shape: BoxShape.circle,

                      gradient:
                          LinearGradient(
                        begin:
                            Alignment.topLeft,
                        end:
                            Alignment.bottomRight,
                        colors: [
                          Color(0xFF6348E8),
                          Color(0xFF9D94F5),
                        ],
                      ),
                    ),

                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/profile_avatar.png',

                        fit: BoxFit.cover,

                        errorBuilder:
                            (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Container(
                            color:
                                const Color(
                              0xFFF1F0FF,
                            ),

                            child: const Icon(
                              Icons.person_rounded,
                              size: 25,
                              color:
                                  Color(0xFF5146D9),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // MAIN HEADLINE
          // ======================================================

          Positioned(
            left: 22,
            top: 38,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // ------------------------------------------------
                // FIND YOUR
                // ------------------------------------------------

                const Text(
                  'Find your',

                  style: TextStyle(
                    fontSize: 31,
                    height: .98,
                    color:
                        Color(0xFF10183A),
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),

                const SizedBox(height: 3),

                // ------------------------------------------------
                // BEST PHYSIO
                // ------------------------------------------------

                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      begin:
                          Alignment.centerLeft,
                      end:
                          Alignment.centerRight,
                      colors: [
                        Color(0xFF6248E7),
                        Color(0xFF079F87),
                      ],
                    ).createShader(
                      Rect.fromLTWH(
                        0,
                        0,
                        bounds.width,
                        bounds.height,
                      ),
                    );
                  },

                  child: const Text(
                    'best physio',

                    style: TextStyle(
                      fontSize: 31,
                      height: .98,
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ------------------------------------------------
                // DESCRIPTION
                // ------------------------------------------------

                const Text(
                  'Personalized care,',

                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Color(0xFF59627E),
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'delivered at your home.',

                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Color(0xFF59627E),
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 15),

                // ------------------------------------------------
                // TRUST BADGE
                // ------------------------------------------------

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(.88),

                    borderRadius:
                        BorderRadius.circular(22),

                    border: Border.all(
                      color:
                          const Color(0xFFE1E5EE),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(
                          0xFF202B50,
                        ).withOpacity(.035),

                        blurRadius: 10,

                        offset:
                            const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: const Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [

                      Icon(
                        Icons.verified_rounded,
                        size: 12,
                        color:
                            Color(0xFF079F87),
                      ),

                      SizedBox(width: 5),

                      Text(
                        'Trusted home physiotherapy',

                        style: TextStyle(
                          fontSize: 7.5,
                          color:
                              Color(0xFF44506D),
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // LARGE PHYSIOTHERAPIST IMAGE
          // ======================================================

          Positioned(
            right: -17,
            bottom: -18,

            child: SizedBox(
              width: 225,
              height: 225,

              child: Image.asset(
                'assets/images/explore_physio.png',

                fit: BoxFit.contain,

                alignment:
                    Alignment.bottomCenter,

                errorBuilder:
                    (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const SizedBox();
                },
              ),
            ),
          ),

          // ======================================================
          // IMAGE LIGHT BLEND
          // ======================================================

          Positioned(
            right: 90,
            bottom: 0,

            child: IgnorePointer(
              child: Container(
                width: 95,
                height: 120,

                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.centerLeft,
                    end:
                        Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.white
                          .withOpacity(.24),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ======================================================
          // BOTTOM INDICATORS
          // ======================================================

          Positioned(
            left: 22,
            bottom: 14,

            child: Row(
              children: [

                Container(
                  width: 31,
                  height: 6,

                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xFF6348E8),
                        Color(0xFF079F87),
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(width: 5),

                ...List.generate(
                  2,
                  (index) {
                    return Container(
                      width: 7,
                      height: 6,

                      margin:
                          const EdgeInsets.only(
                        right: 4,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFD9DDE8,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ===============================================================
// DECORATIVE DOT PATTERN
// ===============================================================

class _DotPattern extends StatelessWidget {
  const _DotPattern();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      height: 32,

      child: Wrap(
        spacing: 5,
        runSpacing: 5,

        children: List.generate(
          18,
          (index) {
            return Container(
              width: 3,
              height: 3,

              decoration:
                  const BoxDecoration(
                color: Color(0xFFD8D4FF),
                shape: BoxShape.circle,
              ),
            );
          },
        ),
      ),
    );
  }
}


// ===============================================================
// MEDICAL ORB
// ===============================================================

class _MedicalOrb extends StatelessWidget {
  final IconData icon;

  const _MedicalOrb({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,

      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(.92),

        shape: BoxShape.circle,

        border: Border.all(
          color:
              const Color(0xFFE1E5EE),
        ),

        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF26345C)
                    .withOpacity(.07),

            blurRadius: 9,

            offset:
                const Offset(0, 3),
          ),
        ],
      ),

      child: Icon(
        icon,
        size: 14,
        color:
            const Color(0xFF5146D9),
      ),
    );
  }
}