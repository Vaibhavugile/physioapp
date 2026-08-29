import 'package:flutter/material.dart';

class BestMatchCard extends StatefulWidget {
  final VoidCallback? onViewProfile;
  final VoidCallback? onBookSession;

  const BestMatchCard({
    super.key,
    this.onViewProfile,
    this.onBookSession,
  });

  @override
  State<BestMatchCard> createState() => _BestMatchCardState();
}

class _BestMatchCardState extends State<BestMatchCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });
      },
      child: AnimatedScale(
        scale: _pressed ? .985 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFE3E6F0),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF202B50).withOpacity(.075),
                blurRadius: 26,
                offset: const Offset(0, 11),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====================================================
              // TOP HEADER
              // ====================================================

              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF0EDFF),
                          Color(0xFFE8F8F5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: Color(0xFF6548E8),
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Best match for you',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF111A3D),
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.35,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Based on your preferences',
                          style: TextStyle(
                            fontSize: 8.5,
                            color: Color(0xFF858DA4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // MATCH SCORE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE7F9F4),
                          Color(0xFFF0FAF8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFD7F0EA),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: Color(0xFF079F87),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '92% Match',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF078B74),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ====================================================
              // DOCTOR SECTION
              // ====================================================

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // DOCTOR IMAGE
                  // ==================================================

                  GestureDetector(
                    onTap: widget.onViewProfile,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 124,
                      height: 155,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(21),
                        color: const Color(0xFFF0F3FA),
                        border: Border.all(
                          color: const Color(0xFFE3E7F1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF26345C)
                                .withOpacity(.06),
                            blurRadius: 13,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/doctor_1.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Container(
                                color: const Color(0xFFF0F2FA),
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 58,
                                  color: Color(0xFF6570D8),
                                ),
                              );
                            },
                          ),

                          // IMAGE GRADIENT
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(.12),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // VERIFIED BADGE
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 27,
                              height: 27,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.96),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.08),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: Color(0xFF079F87),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ==================================================
                  // DETAILS
                  // ==================================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // NAME
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Dr. Neha Sharma',
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF111A3D),
                                  fontWeight:
                                      FontWeight.w900,
                                  letterSpacing: -.4,
                                ),
                              ),
                            ),

                            const SizedBox(width: 5),

                            const Icon(
                              Icons.verified_rounded,
                              size: 17,
                              color: Color(0xFF079F87),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // SPECIALIZATION
                        const Text(
                          'Orthopedic & Sports Physiotherapist',
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.35,
                            color: Color(0xFF626C87),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // EXPERIENCE
                        Row(
                          children: [
                            Container(
                              width: 23,
                              height: 23,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFF2F0FF),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                size: 13,
                                color: Color(0xFF6148DF),
                              ),
                            ),

                            const SizedBox(width: 6),

                            const Text(
                              '8+ years experience',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: Color(0xFF59627E),
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // RATING
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Color(0xFFFFB21A),
                            ),

                            const SizedBox(width: 4),

                            const Text(
                              '4.9',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF202744),
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),

                            const SizedBox(width: 4),

                            const Text(
                              '(230 reviews)',
                              style: TextStyle(
                                fontSize: 8.5,
                                color: Color(0xFF7C849A),
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 9),

                        // DISTANCE
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: Color(0xFF079F87),
                            ),

                            const SizedBox(width: 4),

                            const Text(
                              '1.8 km away',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: Color(0xFF59627E),
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 11),

                        // BADGES
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: const [
                            _MiniBadge(
                              icon: Icons.home_outlined,
                              label: 'Home Visit',
                            ),
                            _MiniBadge(
                              icon: Icons.verified_outlined,
                              label: 'Verified',
                            ),
                            _MiniBadge(
                              icon:
                                  Icons.workspace_premium_outlined,
                              label: 'Experienced',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ====================================================
              // BOTTOM BOOKING AREA
              // ====================================================

              Container(
                padding: const EdgeInsets.fromLTRB(
                  13,
                  11,
                  10,
                  10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF8F9FC),
                      Color(0xFFF5F6FB),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE8EAF1),
                  ),
                ),
                child: Row(
                  children: [
                    // =================================================
                    // PRICE
                    // =================================================

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SESSION FROM',
                            style: TextStyle(
                              fontSize: 7,
                              color: Color(0xFF9299AB),
                              fontWeight: FontWeight.w900,
                              letterSpacing: .6,
                            ),
                          ),

                          const SizedBox(height: 3),

                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: '₹599',
                                  style: TextStyle(
                                    fontSize: 19,
                                    color: Color(0xFF079F87),
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / session',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    color: Color(0xFF737C99),
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // VIEW PROFILE
                    // =================================================

                    GestureDetector(
                      onTap: widget.onViewProfile,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE0E3EC),
                          ),
                        ),
                        child: const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF5146D9),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 7),

                    // =================================================
                    // BOOK BUTTON
                    // =================================================

                    GestureDetector(
                      onTap: widget.onBookSession,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF6A4BE8),
                              Color(0xFF5146D9),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF5146D9)
                                      .withOpacity(.22),
                              blurRadius: 11,
                              offset:
                                  const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Text(
                              'Book Session',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// =================================================================
// MINI BADGE
// =================================================================

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E7EF),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: const Color(0xFF079F87),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 7,
              color: Color(0xFF5E6780),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}