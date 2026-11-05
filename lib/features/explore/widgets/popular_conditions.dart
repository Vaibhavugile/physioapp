import 'package:flutter/material.dart';

class PopularConditions extends StatelessWidget {
  final ValueChanged<String>? onSelected;
  final VoidCallback? onSeeAll;

  const PopularConditions({
    super.key,
    this.onSelected,
    this.onSeeAll,
  });

  // ===============================================================
  // CONDITIONS
  // ===============================================================

  static const List<_Condition> _conditions = [
    _Condition(
      id: 'knee',
      title: 'Knee Pain',
      image: 'assets/images/knee_pain.png',
      icon: Icons.accessibility_new_rounded,
    ),

    _Condition(
      id: 'back',
      title: 'Back Pain',
      image: 'assets/images/back_pain.png',
      icon: Icons.accessibility_new_rounded,
    ),

    _Condition(
      id: 'neck',
      title: 'Neck Pain',
      image: 'assets/images/neck_pain.png',
      icon: Icons.accessibility_new_rounded,
    ),

    _Condition(
      id: 'shoulder',
      title: 'Shoulder Pain',
      image: 'assets/images/shoulder_pain.png',
      icon: Icons.accessibility_new_rounded,
    ),

    _Condition(
      id: 'sports',
      title: 'Sports Injury',
      image: 'assets/images/sports_injury.png',
      icon: Icons.directions_run_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =========================================================
        // SECTION HEADER
        // =========================================================

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'Popular conditions',
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF111A3D),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.45,
                ),
              ),
            ),

            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF5146D9),
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(width: 2),

                    Icon(
                      Icons.chevron_right_rounded,
                      size: 17,
                      color: Color(0xFF5146D9),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),

        // =========================================================
        // HORIZONTAL CONDITION CARDS
        // =========================================================

        SizedBox(
          height: 184,

          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            physics:
                const BouncingScrollPhysics(),

            padding: const EdgeInsets.symmetric(
              horizontal: 1,
            ),

            itemCount: _conditions.length,

            separatorBuilder: (_, __) {
              return const SizedBox(width: 10);
            },

            itemBuilder: (context, index) {
              final condition =
                  _conditions[index];

              return _ConditionCard(
                condition: condition,

                onTap: () {
                  onSelected?.call(
                    condition.id,
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // =========================================================
        // PREMIUM SCROLL INDICATOR
        // =========================================================

        const Center(
          child: _ScrollIndicator(),
        ),
      ],
    );
  }
}


// =================================================================
// CONDITION CARD
// =================================================================

class _ConditionCard extends StatefulWidget {
  final _Condition condition;
  final VoidCallback? onTap;

  const _ConditionCard({
    required this.condition,
    this.onTap,
  });

  @override
  State<_ConditionCard> createState() =>
      _ConditionCardState();
}

class _ConditionCardState
    extends State<_ConditionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,

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

      behavior: HitTestBehavior.opaque,

      child: AnimatedScale(
        scale: _pressed ? .97 : 1,

        duration:
            const Duration(milliseconds: 120),

        child: Container(
          width: 132,

          padding: const EdgeInsets.fromLTRB(
            6,
            6,
            6,
            9,
          ),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(23),

            border: Border.all(
              color:
                  const Color(0xFFE3E6F0),
            ),

            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFF202B50)
                        .withOpacity(.065),

                blurRadius: 22,

                offset:
                    const Offset(0, 7),
              ),
            ],
          ),

          child: Column(
            children: [
              // ===================================================
              // IMAGE CONTAINER
              // ===================================================

              Expanded(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(17),

                  child: Stack(
                    fit: StackFit.expand,

                    children: [
                      // -------------------------------------------
                      // MEDICAL IMAGE
                      // -------------------------------------------

                      Image.asset(
                        widget.condition.image,

                        fit: BoxFit.cover,

                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const _ImageFallback();
                        },
                      ),

                      // -------------------------------------------
                      // SOFT WHITE GRADIENT
                      // -------------------------------------------

                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,

                        child: Container(
                          height: 35,

                          decoration:
                              const BoxDecoration(
                            gradient:
                                LinearGradient(
                              begin:
                                  Alignment.topCenter,
                              end:
                                  Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0x550FFFFFF),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // -------------------------------------------
                      // MEDICAL ICON
                      // -------------------------------------------

                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 8,

                        child: Center(
                          child: Container(
                            width: 39,
                            height: 39,

                            decoration:
                                BoxDecoration(
                              color: Colors.white
                                  .withOpacity(.94),

                              shape:
                                  BoxShape.circle,

                              border:
                                  Border.all(
                                color:
                                    const Color(
                                  0xFFDCD9FF,
                                ),
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(
                                    0xFF5146D9,
                                  ).withOpacity(.12),

                                  blurRadius: 10,

                                  offset:
                                      const Offset(
                                    0,
                                    4,
                                  ),
                                ),
                              ],
                            ),

                            child: Icon(
                              widget.condition.icon,

                              size: 20,

                              color:
                                  const Color(
                                0xFF5A4DE0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ===================================================
              // TITLE
              // ===================================================

              Text(
                widget.condition.title,

                maxLines: 1,

                overflow:
                    TextOverflow.ellipsis,

                textAlign:
                    TextAlign.center,

                style: const TextStyle(
                  fontSize: 9.5,

                  color:
                      Color(0xFF151D3D),

                  fontWeight:
                      FontWeight.w900,

                  letterSpacing: -.15,
                ),
              ),

              const SizedBox(height: 5),

              // ===================================================
              // ARROW
              // ===================================================

              Container(
                width: 23,
                height: 23,

                decoration: BoxDecoration(
                  color:
                      const Color(0xFFF2F1FF),

                  shape:
                      BoxShape.circle,
                ),

                child: const Icon(
                  Icons
                      .arrow_forward_rounded,

                  size: 13,

                  color:
                      Color(0xFF5146D9),
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
// IMAGE FALLBACK
// =================================================================

class _ImageFallback
    extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          const BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFFF0F1FF),
            Color(0xFFEAF8F5),
          ],
        ),
      ),

      child: const Center(
        child: Icon(
          Icons
              .medical_services_outlined,

          color:
              Color(0xFF5A4DE0),

          size: 28,
        ),
      ),
    );
  }
}


// =================================================================
// MODEL
// =================================================================

class _Condition {
  final String id;
  final String title;
  final String image;
  final IconData icon;

  const _Condition({
    required this.id,
    required this.title,
    required this.image,
    required this.icon,
  });
}


// =================================================================
// SCROLL INDICATOR
// =================================================================

class _ScrollIndicator
    extends StatelessWidget {
  const _ScrollIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,

      children: [
        // ACTIVE
        Container(
          width: 22,
          height: 5,

          decoration:
              BoxDecoration(
            gradient:
                const LinearGradient(
              colors: [
                Color(0xFF6348E8),
                Color(0xFF5146D9),
              ],
            ),

            borderRadius:
                BorderRadius.circular(10),
          ),
        ),

        const SizedBox(width: 5),

        // INACTIVE DOTS
        ...List.generate(
          3,
          (index) {
            return Container(
              width: 6,
              height: 5,

              margin:
                  const EdgeInsets.only(
                right: 4,
              ),

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFE0E2EC,
                ),

                borderRadius:
                    BorderRadius.circular(10),
              ),
            );
          },
        ),
      ],
    );
  }
}