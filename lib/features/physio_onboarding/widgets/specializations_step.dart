import 'package:flutter/material.dart';

class SpecializationsStep extends StatelessWidget {
  final List<String> selectedSpecializations;
  final ValueChanged<List<String>> onChanged;

  const SpecializationsStep({
    super.key,
    required this.selectedSpecializations,
    required this.onChanged,
  });

  // ============================================================
  // AVAILABLE SPECIALIZATIONS
  // ============================================================

  static const List<_SpecializationItem> _specializations = [
    _SpecializationItem(
      id: 'orthopedic',
      title: 'Orthopedic Physiotherapy',
      subtitle: 'Bones, joints and musculoskeletal conditions',
      icon: Icons.accessibility_new_rounded,
    ),

    _SpecializationItem(
      id: 'sports',
      title: 'Sports Physiotherapy',
      subtitle: 'Sports injuries and performance recovery',
      icon: Icons.sports_soccer_rounded,
    ),

    _SpecializationItem(
      id: 'neurological',
      title: 'Neurological Physiotherapy',
      subtitle: 'Stroke, nerve and neurological rehabilitation',
      icon: Icons.psychology_rounded,
    ),

    _SpecializationItem(
      id: 'pediatric',
      title: 'Pediatric Physiotherapy',
      subtitle: 'Physiotherapy care for children',
      icon: Icons.child_care_rounded,
    ),

    _SpecializationItem(
      id: 'geriatric',
      title: 'Geriatric Physiotherapy',
      subtitle: 'Mobility and rehabilitation for elderly patients',
      icon: Icons.elderly_rounded,
    ),

    _SpecializationItem(
      id: 'post_surgery',
      title: 'Post-Surgery Rehabilitation',
      subtitle: 'Recovery and rehabilitation after surgery',
      icon: Icons.medical_services_rounded,
    ),

    _SpecializationItem(
      id: 'back_neck',
      title: 'Back & Neck Pain',
      subtitle: 'Spine, posture and chronic pain management',
      icon: Icons.airline_seat_flat_angled_rounded,
    ),

    _SpecializationItem(
      id: 'womens_health',
      title: "Women's Health Physiotherapy",
      subtitle: 'Pregnancy, postpartum and women-specific care',
      icon: Icons.pregnant_woman_rounded,
    ),

    _SpecializationItem(
      id: 'cardiorespiratory',
      title: 'Cardiorespiratory Physiotherapy',
      subtitle: 'Heart and respiratory rehabilitation',
      icon: Icons.favorite_rounded,
    ),

    _SpecializationItem(
      id: 'home_care',
      title: 'Home Care Physiotherapy',
      subtitle: 'Professional physiotherapy services at home',
      icon: Icons.home_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================================
        // TITLE
        // ========================================================

        const Text(
          'Your specializations',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111A3D),
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Select all the areas in which you have professional experience and expertise.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF7B849C),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 12),

        // ========================================================
        // SELECTION COUNTER
        // ========================================================

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 19,
                color: Color(0xFF246BFD),
              ),

              const SizedBox(width: 8),

              Text(
                selectedSpecializations.isEmpty
                    ? 'Select at least one specialization'
                    : '${selectedSpecializations.length} specialization${selectedSpecializations.length == 1 ? '' : 's'} selected',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF246BFD),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ========================================================
        // SPECIALIZATION CARDS
        // ========================================================

        ..._specializations.map(
          (item) {
            final isSelected =
                selectedSpecializations.contains(item.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SpecializationCard(
                item: item,
                isSelected: isSelected,
                onTap: () {
                  final updated =
                      List<String>.from(selectedSpecializations);

                  if (isSelected) {
                    updated.remove(item.id);
                  } else {
                    updated.add(item.id);
                  }

                  onChanged(updated);
                },
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // ========================================================
        // INFO
        // ========================================================

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFE2A8),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFE59A00),
                size: 20,
              ),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Only select areas where you have relevant education, training or professional experience.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: Color(0xFF8A6400),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================================================================
// SPECIALIZATION CARD
// ================================================================

class _SpecializationCard extends StatelessWidget {
  final _SpecializationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpecializationCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFEAF2FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF246BFD)
                  : const Color(0xFFE5E9F2),
              width: isSelected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  isSelected ? 0.04 : 0.025,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ==================================================
              // ICON
              // ==================================================

              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF246BFD)
                      : const Color(0xFFF3F6FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.icon,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF59637A),
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              // ==================================================
              // TEXT
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? const Color(0xFF111A3D)
                            : const Color(0xFF27314D),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: Color(0xFF7B849C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ==================================================
              // CHECKBOX
              // ==================================================

              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF246BFD)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF246BFD)
                        : const Color(0xFFC9D0DD),
                    width: 1.6,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 17,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// SPECIALIZATION DATA MODEL
// ================================================================

class _SpecializationItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const _SpecializationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}