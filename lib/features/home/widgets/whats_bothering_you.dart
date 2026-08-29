import 'package:flutter/material.dart';

class WhatsBotheringYou extends StatefulWidget {
  final ValueChanged<String>? onAreaSelected;
  final VoidCallback? onAssessmentTap;

  const WhatsBotheringYou({
    super.key,
    this.onAreaSelected,
    this.onAssessmentTap,
  });

  @override
  State<WhatsBotheringYou> createState() =>
      _WhatsBotheringYouState();
}

class _WhatsBotheringYouState
    extends State<WhatsBotheringYou> {
  String? _selectedArea;

  // ============================================================
  // PAIN AREAS
  // ============================================================

  static const List<_PainArea> _areas = [
    _PainArea(
      id: 'neck',
      name: 'Neck',
      subtitle: 'Neck pain & stiffness',
      imagePath: 'assets/images/conditions/neck.png',
    ),
    _PainArea(
      id: 'shoulder',
      name: 'Shoulder',
      subtitle: 'Shoulder pain',
      imagePath: 'assets/images/conditions/shoulder.png',
    ),
    _PainArea(
      id: 'back',
      name: 'Back',
      subtitle: 'Upper & mid back',
      imagePath: 'assets/images/conditions/back.png',
    ),
    _PainArea(
      id: 'lower_back',
      name: 'Lower Back',
      subtitle: 'Lower back pain',
      imagePath: 'assets/images/conditions/lower_back.png',
    ),
    _PainArea(
      id: 'knee',
      name: 'Knee',
      subtitle: 'Knee pain',
      imagePath: 'assets/images/conditions/knee.png',
    ),
    _PainArea(
      id: 'hip',
      name: 'Hip',
      subtitle: 'Hip pain',
      imagePath: 'assets/images/conditions/hip.png',
    ),
    _PainArea(
      id: 'ankle',
      name: 'Ankle',
      subtitle: 'Ankle pain',
      imagePath: 'assets/images/conditions/ankle.png',
    ),
    _PainArea(
      id: 'other',
      name: 'Other',
      subtitle: 'Other areas',
      imagePath: 'assets/images/conditions/other.png',
    ),
  ];

  // ============================================================
  // SELECT AREA
  // ============================================================

  void _selectArea(String id) {
    setState(() {
      _selectedArea = id;
    });

    widget.onAreaSelected?.call(id);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE7EAF3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C2854)
                .withOpacity(0.055),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 18),

          // ======================================================
          // BODY + CONDITIONS
          // ======================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 37,
                child: _BodyIllustration(
                  selectedArea: _selectedArea,
                  onAreaSelected: _selectArea,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 63,
                child: _buildConditionGrid(),
              ),
            ],
          ),

          const SizedBox(height: 13),

          _AssessmentCard(
            onTap: widget.onAssessmentTap,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF5367EA),
                Color(0xFF7658E8),
              ],
            ),
            borderRadius:
                BorderRadius.circular(10),
          ),
        ),

        const SizedBox(width: 11),

        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "What's bothering you?",
                style: TextStyle(
                  fontSize: 18,
                  height: 1.1,
                  color: Color(0xFF111A3A),
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.55,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Select the area of pain to get started',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF6C7595),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF0F3FF),
                Color(0xFFF8F5FF),
              ],
            ),
            borderRadius:
                BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFE2E5F6),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 14,
                color: Color(0xFF5366E9),
              ),
              SizedBox(width: 4),
              Text(
                'Recovery',
                style: TextStyle(
                  fontSize: 8.5,
                  color: Color(0xFF3546B8),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONDITION GRID
  // ============================================================

  Widget _buildConditionGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: _areas.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 88,
      ),
      itemBuilder: (context, index) {
        final area = _areas[index];

        return _PainAreaCard(
          area: area,
          selected:
              _selectedArea == area.id,
          onTap: () => _selectArea(
            area.id,
          ),
        );
      },
    );
  }
}

// ================================================================
// PAIN AREA MODEL
// ================================================================

class _PainArea {
  final String id;
  final String name;
  final String subtitle;
  final String imagePath;

  const _PainArea({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imagePath,
  });
}

// ================================================================
// BODY ILLUSTRATION
// ================================================================

class _BodyIllustration
    extends StatelessWidget {
  final String? selectedArea;
  final ValueChanged<String>
      onAreaSelected;

  const _BodyIllustration({
    required this.selectedArea,
    required this.onAreaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 376,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF0F4FF),
            Color(0xFFF8FAFF),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFE9ECF6),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ------------------------------------------------------
          // SOFT BODY GLOW
          // ------------------------------------------------------

          Positioned(
            top: 35,
            child: Container(
              width: 150,
              height: 285,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(100),
                gradient:
                    RadialGradient(
                  colors: [
                    const Color(0xFF7B8DFF)
                        .withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------------
          // BODY IMAGE
          // ------------------------------------------------------

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 8,
            ),
            child: Image.asset(
              'assets/images/pain_body.png',
              fit: BoxFit.contain,
              height: 360,
              width: double.infinity,
              errorBuilder:
                  (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons
                      .accessibility_new_rounded,
                  size: 150,
                  color: Color(0xFF7D89D8),
                );
              },
            ),
          ),

          // ------------------------------------------------------
          // SMALL LABEL
          // ------------------------------------------------------

          Positioned(
            bottom: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(0.88),
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(
                    0xFFE3E7F5,
                  ),
                ),
              ),
              child: const Text(
                'Tap an area to begin',
                style: TextStyle(
                  fontSize: 8.5,
                  color: Color(0xFF667091),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// PAIN AREA CARD
// ================================================================

class _PainAreaCard
    extends StatelessWidget {
  final _PainArea area;
  final bool selected;
  final VoidCallback onTap;

  const _PainAreaCard({
    required this.area,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 0.975 : 1,
      duration:
          const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF8F8FF)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFF5365E9)
                : const Color(0xFFE6E9F2),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF5365E9)
                      .withOpacity(0.13)
                  : const Color(0xFF34436B)
                      .withOpacity(0.04),
              blurRadius:
                  selected ? 18 : 11,
              offset:
                  const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius:
                BorderRadius.circular(18),
            child: Stack(
              children: [
                // ==================================================
                // IMAGE
                // ==================================================

                Positioned(
                  left: 7,
                  right: 7,
                  top: 7,
                  height: 53,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(13),
                    child: Image.asset(
                      area.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          decoration:
                              BoxDecoration(
                            color: const Color(
                              0xFFF1F4FF,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              13,
                            ),
                          ),
                          child: const Icon(
                            Icons
                                .medical_services_outlined,
                            color: Color(
                              0xFF6472D8,
                            ),
                            size: 22,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ==================================================
                // NAME
                // ==================================================

                Positioned(
                  left: 7,
                  right: 7,
                  bottom: 7,
                  child: Text(
                    area.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: selected
                          ? const Color(
                              0xFF3447C8,
                            )
                          : const Color(
                              0xFF151D3B,
                            ),
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),

                // ==================================================
                // SELECTED CHECK
                // ==================================================

                if (selected)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 21,
                      height: 21,
                      decoration:
                          const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient:
                            LinearGradient(
                          colors: [
                            Color(0xFF5265EA),
                            Color(0xFF7657E9),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 13,
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

// ================================================================
// ASSESSMENT CARD
// ================================================================

class _AssessmentCard
    extends StatelessWidget {
  final VoidCallback? onTap;

  const _AssessmentCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(18),
        child: Ink(
          height: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFF0EEFF),
                Color(0xFFF7F4FF),
                Color(0xFFF0F7FF),
              ],
            ),
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE2DEFF),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),

              // --------------------------------------------------
              // ICON
              // --------------------------------------------------

              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF6354DD,
                      ).withOpacity(.10),
                      blurRadius: 12,
                      offset:
                          const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  color: Color(0xFF5E50D8),
                  size: 23,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Not sure? Take a quick assessment',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF151D3D),
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Answer a few questions and we’ll guide you',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF697394),
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // --------------------------------------------------
              // ARROW
              // --------------------------------------------------

              Container(
                width: 40,
                height: 40,
                margin:
                    const EdgeInsets.only(
                  right: 10,
                ),
                decoration:
                    const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF5365EA),
                      Color(0xFF7458E9),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}