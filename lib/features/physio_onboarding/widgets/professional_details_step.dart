import 'package:flutter/material.dart';

/// This step owns one field only: the public-facing professional title.
/// Registration, experience, specializations, languages and service choices
/// each have a single dedicated step elsewhere in onboarding.
class ProfessionalDetailsData {
  final String professionalTitle;

  const ProfessionalDetailsData({required this.professionalTitle});
}

class ProfessionalDetailsStep extends StatefulWidget {
  final ProfessionalDetailsData? initialData;
  final ValueChanged<ProfessionalDetailsData> onChanged;

  const ProfessionalDetailsStep({
    super.key,
    this.initialData,
    required this.onChanged,
  });

  @override
  State<ProfessionalDetailsStep> createState() =>
      _ProfessionalDetailsStepState();
}

class _ProfessionalDetailsStepState extends State<ProfessionalDetailsStep> {
  static const _titles = [
    'Physiotherapist',
    'Senior Physiotherapist',
    'Consultant Physiotherapist',
    'Sports Physiotherapist',
    'Orthopedic Physiotherapist',
    'Neuro Physiotherapist',
    'Pediatric Physiotherapist',
    'Women’s Health Physiotherapist',
  ];

  static const _ink = Color(0xFF183D39);
  static const _green = Color(0xFF078F83);
  static const _muted = Color(0xFF7B918C);
  static const _border = Color(0xFFE4ECE9);

  static const Map<String, IconData> _icons = {
    'Physiotherapist': Icons.health_and_safety_rounded,
    'Senior Physiotherapist': Icons.workspace_premium_rounded,
    'Consultant Physiotherapist': Icons.medical_services_rounded,
    'Sports Physiotherapist': Icons.sports_gymnastics_rounded,
    'Orthopedic Physiotherapist': Icons.accessibility_new_rounded,
    'Neuro Physiotherapist': Icons.psychology_alt_rounded,
    'Pediatric Physiotherapist': Icons.child_care_rounded,
    'Women’s Health Physiotherapist': Icons.female_rounded,
  };

  late String _title;

  @override
  void initState() {
    super.initState();
    _title = widget.initialData?.professionalTitle ?? '';
  }

  void _select(String value) {
    if (_title == value) return;
    setState(() => _title = value);
    widget.onChanged(ProfessionalDetailsData(professionalTitle: value));
  }

  Widget _titleCard(String value, int index) {
    final selected = _title == value;
    final icon = _icons[value] ?? Icons.medical_information_rounded;

    return Semantics(
      button: true,
      selected: selected,
      label: value,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () => _select(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 190),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(12, 13, 11, 13),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFEDF8F5) : Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: selected ? _green : _border,
                width: selected ? 1.5 : 1,
              ),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x14078F83),
                        blurRadius: 13,
                        offset: Offset(0, 5),
                      ),
                    ]
                  : const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 190),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: selected ? _green : const Color(0xFFF1F6F4),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: selected ? Colors.white : const Color(0xFF78928B),
                      ),
                    ),
                    const Spacer(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 190),
                      width: 19,
                      height: 19,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? _green : Colors.transparent,
                        border: Border.all(
                          color: selected ? _green : const Color(0xFFC8D6D1),
                          width: 1.4,
                        ),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 13,
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Text(
                  value,
                  style: TextStyle(
                    color: selected ? _ink : const Color(0xFF405D57),
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    letterSpacing: -.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  selected ? 'Selected title' : 'Tap to choose',
                  style: TextStyle(
                    color: selected ? _green : const Color(0xFFA0B0AB),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 3 : 2;
        const spacing = 10.0;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F8F6),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFFE7EFEC)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0BA391), Color(0xFF08756D)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.badge_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How should patients know you?',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Choose the professional title displayed on your profile.',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 10,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 19),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'SELECT YOUR TITLE',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Text(
                  '${_title.isEmpty ? 0 : 1} OF 1 SELECTED',
                  style: const TextStyle(
                    color: _green,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .55,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(
                _titles.length,
                (index) => SizedBox(
                  width: itemWidth,
                  child: _titleCard(_titles[index], index),
                ),
              ),
            ),
            if (_title.isNotEmpty) ...[
              const SizedBox(height: 14),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6F2),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFFD9ECE5)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: _green,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Your profile title',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        _title,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
