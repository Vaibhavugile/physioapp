import 'package:flutter/material.dart';

import 'premium_theme.dart';

/// This step owns one field only: the public-facing professional title.
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 3 : 2;
        const spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final t in _titles)
                  SizedBox(
                    width: itemWidth,
                    child: PXChoiceCard(
                      label: t,
                      icon: _icons[t],
                      selected: _title == t,
                      caption: _title == t ? 'Shown on your profile' : null,
                      onTap: () => _select(t),
                    ),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: _title.isEmpty
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: PX.deep,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded,
                                color: PX.mint, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Patients will see',
                                      style: TextStyle(
                                          color: Color(0xFFA9C9C3),
                                          fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(_title,
                                      style: PX.display(17, color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
