import 'package:flutter/material.dart';

class SpecializationsStep extends StatelessWidget {
  final List<String> selectedSpecializations;
  final ValueChanged<List<String>> onChanged;

  const SpecializationsStep({
    super.key,
    required this.selectedSpecializations,
    required this.onChanged,
  });

  static const Color _ink = Color(0xFF173F3A);
  static const Color _muted = Color(0xFF7A8E89);
  static const Color _teal = Color(0xFF078879);

  // Persisted IDs and labels are intentionally kept unchanged.
  static const List<_SpecializationItem> _specializations = [
    _SpecializationItem(
      id: 'orthopedic',
      title: 'Orthopedic',
      fullTitle: 'Orthopedic Physiotherapy',
      subtitle: 'Bones, joints & muscles',
      icon: Icons.accessibility_new_rounded,
      tint: Color(0xFFE8F3FF),
      accent: Color(0xFF3979B9),
    ),
    _SpecializationItem(
      id: 'sports',
      title: 'Sports',
      fullTitle: 'Sports Physiotherapy',
      subtitle: 'Injuries & performance',
      icon: Icons.sports_soccer_rounded,
      tint: Color(0xFFFFF1E5),
      accent: Color(0xFFD77B32),
    ),
    _SpecializationItem(
      id: 'neurological',
      title: 'Neurological',
      fullTitle: 'Neurological Physiotherapy',
      subtitle: 'Stroke & nerve recovery',
      icon: Icons.psychology_rounded,
      tint: Color(0xFFF0EAFE),
      accent: Color(0xFF8062C7),
    ),
    _SpecializationItem(
      id: 'pediatric',
      title: 'Pediatric',
      fullTitle: 'Pediatric Physiotherapy',
      subtitle: 'Care for children',
      icon: Icons.child_care_rounded,
      tint: Color(0xFFFFEAF1),
      accent: Color(0xFFD65D87),
    ),
    _SpecializationItem(
      id: 'geriatric',
      title: 'Geriatric',
      fullTitle: 'Geriatric Physiotherapy',
      subtitle: 'Healthy ageing & mobility',
      icon: Icons.elderly_rounded,
      tint: Color(0xFFFFF5D9),
      accent: Color(0xFFB58A27),
    ),
    _SpecializationItem(
      id: 'post_surgery',
      title: 'Post-surgery',
      fullTitle: 'Post-Surgery Rehabilitation',
      subtitle: 'Recovery after surgery',
      icon: Icons.medical_services_rounded,
      tint: Color(0xFFE5F6F2),
      accent: Color(0xFF168A79),
    ),
    _SpecializationItem(
      id: 'back_neck',
      title: 'Back & neck',
      fullTitle: 'Back & Neck Pain',
      subtitle: 'Spine, posture & pain',
      icon: Icons.airline_seat_flat_angled_rounded,
      tint: Color(0xFFFFEDE5),
      accent: Color(0xFFC76C48),
    ),
    _SpecializationItem(
      id: 'womens_health',
      title: "Women's health",
      fullTitle: "Women's Health Physiotherapy",
      subtitle: 'Pregnancy & postpartum',
      icon: Icons.pregnant_woman_rounded,
      tint: Color(0xFFFBE9F5),
      accent: Color(0xFFB85A9A),
    ),
    _SpecializationItem(
      id: 'cardiorespiratory',
      title: 'Cardiorespiratory',
      fullTitle: 'Cardiorespiratory Physiotherapy',
      subtitle: 'Heart & lung rehabilitation',
      icon: Icons.favorite_rounded,
      tint: Color(0xFFFFE9E9),
      accent: Color(0xFFD45D62),
    ),
    _SpecializationItem(
      id: 'home_care',
      title: 'Home care',
      fullTitle: 'Home Care Physiotherapy',
      subtitle: 'Treatment at home',
      icon: Icons.home_rounded,
      tint: Color(0xFFE9F2FF),
      accent: Color(0xFF527DB9),
    ),
  ];

  void _toggle(String id, bool selected) {
    final values = List<String>.from(selectedSpecializations);
    if (selected) {
      values.remove(id);
    } else {
      values.add(id);
    }
    onChanged(values);
  }

  @override
  Widget build(BuildContext context) {
    final count = selectedSpecializations.length;
    final selectedItems = _specializations
        .where((item) => selectedSpecializations.contains(item.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compact editorial header — no oversized hero panel.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F5F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.grid_view_rounded, color: _teal, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your clinical focus',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.55,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Choose the areas you are qualified to treat.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 19),

        // Selection meter.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5FAF8),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE4EFEB)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: _teal, size: 18),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  count == 0
                      ? 'Select your areas of expertise'
                      : '$count ${count == 1 ? 'specialization' : 'specializations'} selected',
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${((count / _specializations.length) * 100).round()}%',
                style: const TextStyle(
                  color: _teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // Two-column specialty selector. Each item is a compact tile,
        // rather than a full-width row card.
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 600 ? 3 : 2;
            const gap = 11.0;
            final tileWidth =
                (constraints.maxWidth - (gap * (columns - 1))) / columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: _specializations.map((item) {
                final isSelected = selectedSpecializations.contains(item.id);
                return SizedBox(
                  width: tileWidth,
                  child: _SpecialtyTile(
                    item: item,
                    selected: isSelected,
                    onTap: () => _toggle(item.id, isSelected),
                  ),
                );
              }).toList(),
            );
          },
        ),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: selectedItems.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  key: const ValueKey('selected-specialty-strip'),
                  margin: const EdgeInsets.only(top: 17),
                  padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBFA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5EFEB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'SELECTED SPECIALTIES',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 9,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onChanged(<String>[]),
                            child: const Text(
                              'Clear all',
                              style: TextStyle(
                                color: _teal,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: selectedItems.map((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.fullTitle,
                              style: const TextStyle(
                                color: Color(0xFF08796D),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAEF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF1E5C9)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFFC18A27), size: 18),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Select only areas supported by your education, training or professional experience.',
                  style: TextStyle(
                    color: Color(0xFF80652F),
                    fontSize: 11,
                    height: 1.45,
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

class _SpecialtyTile extends StatelessWidget {
  final _SpecializationItem item;
  final bool selected;
  final VoidCallback onTap;

  const _SpecialtyTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.fullTitle,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 210),
            curve: Curves.easeOutCubic,
            height: 142,
            padding: const EdgeInsets.fromLTRB(12, 12, 11, 11),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF0FAF6) : Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: selected ? item.accent.withOpacity(.75) : const Color(0xFFE7EEEB),
                width: selected ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF173F3A).withOpacity(selected ? .075 : .035),
                  blurRadius: selected ? 14 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 210),
                      width: 39,
                      height: 39,
                      decoration: BoxDecoration(
                        color: selected ? item.accent : item.tint,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        item.icon,
                        color: selected ? Colors.white : item.accent,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 21,
                      height: 21,
                      decoration: BoxDecoration(
                        color: selected ? item.accent : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? item.accent : const Color(0xFFD5E0DC),
                          width: 1.4,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                          : null,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? _SpecializationsStepColors.ink : const Color(0xFF294B46),
                    fontSize: 12.5,
                    height: 1.18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF82928E),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
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

class _SpecializationsStepColors {
  static const Color ink = Color(0xFF173F3A);
}

class _SpecializationItem {
  final String id;
  final String title;
  final String fullTitle;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final Color accent;

  const _SpecializationItem({
    required this.id,
    required this.title,
    required this.fullTitle,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.accent,
  });
}
