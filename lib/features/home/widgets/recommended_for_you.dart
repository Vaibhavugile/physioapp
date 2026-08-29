import 'package:flutter/material.dart';

class RecommendedForYou extends StatelessWidget {
  const RecommendedForYou({super.key});

  // ============================================================
  // TEMPORARY HARDCODED RECOMMENDATIONS
  // ============================================================

  static const List<_Recommendation> _items = [
    _Recommendation(
      title: 'Lower Back\nPain Relief',
      programs: '12 Programs',
      imagePath:
          'assets/images/recommendations/lower_back_relief.png',
    ),
    _Recommendation(
      title: 'Knee Care &\nStrengthening',
      programs: '9 Programs',
      imagePath:
          'assets/images/recommendations/knee_strengthening.png',
    ),
    _Recommendation(
      title: 'Posture\nCorrection',
      programs: '8 Programs',
      imagePath:
          'assets/images/recommendations/posture_correction.png',
    ),
    _Recommendation(
      title: 'Neck Pain\nRelief',
      programs: '7 Programs',
      imagePath:
          'assets/images/recommendations/neck_pain_relief.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================================
        // SECTION HEADER
        // ========================================================

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Recommended for you',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF111936),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(20),
                  onTap: () {
                    // TODO:
                    // Open all recommendations.
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View all',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF5146D9),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 19,
                          color: Color(0xFF5146D9),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ========================================================
        // LARGE PREMIUM HORIZONTAL CARDS
        // ========================================================

        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.only(
              right: 4,
            ),

            itemCount: _items.length,

            separatorBuilder: (_, __) {
              return const SizedBox(width: 12);
            },

            itemBuilder: (context, index) {
              final item = _items[index];

              return _RecommendationCard(
                item: item,
                onTap: () {
                  // TODO:
                  // Open recommendation details.
                },
              );
            },
          ),
        ),
      ],
    );
  }
}


// ================================================================
// MODEL
// ================================================================

class _Recommendation {
  final String title;
  final String programs;
  final String imagePath;

  const _Recommendation({
    required this.title,
    required this.programs,
    required this.imagePath,
  });
}


// ================================================================
// PREMIUM RECOMMENDATION CARD
// ================================================================

class _RecommendationCard extends StatelessWidget {
  final _Recommendation item;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 285,

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: onTap,

          borderRadius:
              BorderRadius.circular(24),

          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(24),

              border: Border.all(
                color: const Color(0xFFE7EAF3),
                width: 1,
              ),

              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF26345C)
                      .withOpacity(.065),

                  blurRadius: 22,

                  spreadRadius: 0,

                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: Row(
              children: [
                // ==================================================
                // LARGE IMAGE
                // ==================================================

                Padding(
                  padding: const EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(19),

                    child: SizedBox(
                      width: 112,
                      height: 136,

                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            item.imagePath,

                            fit: BoxFit.cover,

                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Container(
                                color:
                                    const Color(0xFFF0F3FF),

                                child: const Icon(
                                  Icons
                                      .medical_services_outlined,

                                  color:
                                      Color(0xFF6571D0),

                                  size: 34,
                                ),
                              );
                            },
                          ),

                          // ------------------------------------------------
                          // PREMIUM IMAGE OVERLAY
                          // ------------------------------------------------

                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 45,

                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient:
                                    LinearGradient(
                                  begin:
                                      Alignment.topCenter,

                                  end:
                                      Alignment.bottomCenter,

                                  colors: [
                                    Colors.transparent,

                                    Colors.black
                                        .withOpacity(.20),
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

                // ==================================================
                // CONTENT
                // ==================================================

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      7,
                      13,
                      12,
                      12,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        // ------------------------------------------------
                        // SMALL CATEGORY LABEL
                        // ------------------------------------------------

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),

                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFF1F0FF),

                            borderRadius:
                                BorderRadius.circular(8),
                          ),

                          child: const Text(
                            'PHYSIO PROGRAM',
                            style: TextStyle(
                              fontSize: 7,
                              color:
                                  Color(0xFF5B50D6),
                              fontWeight:
                                  FontWeight.w800,
                              letterSpacing: .45,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ------------------------------------------------
                        // TITLE
                        // ------------------------------------------------

                        Text(
                          item.title,

                          maxLines: 2,

                          overflow:
                              TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.18,

                            color:
                                Color(0xFF111936),

                            fontWeight:
                                FontWeight.w800,

                            letterSpacing: -.3,
                          ),
                        ),

                        const SizedBox(height: 7),

                        // ------------------------------------------------
                        // PROGRAM COUNT
                        // ------------------------------------------------

                        Row(
                          children: [
                            const Icon(
                              Icons.play_circle_outline_rounded,
                              size: 14,
                              color:
                                  Color(0xFF7A82A0),
                            ),

                            const SizedBox(width: 5),

                            Text(
                              item.programs,

                              style:
                                  const TextStyle(
                                fontSize: 10,
                                color:
                                    Color(0xFF737C99),
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // ------------------------------------------------
                        // ARROW
                        // ------------------------------------------------

                        Align(
                          alignment:
                              Alignment.bottomRight,

                          child: Container(
                            width: 34,
                            height: 34,

                            decoration:
                                BoxDecoration(
                              shape:
                                  BoxShape.circle,

                              gradient:
                                  const LinearGradient(
                                begin:
                                    Alignment.topLeft,

                                end:
                                    Alignment.bottomRight,

                                colors: [
                                  Color(0xFF6256E8),
                                  Color(0xFF4338CA),
                                ],
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(
                                    0xFF5146D9,
                                  ).withOpacity(.20),

                                  blurRadius: 10,

                                  offset:
                                      const Offset(
                                    0,
                                    4,
                                  ),
                                ),
                              ],
                            ),

                            child: const Icon(
                              Icons
                                  .arrow_forward_rounded,

                              size: 17,

                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}