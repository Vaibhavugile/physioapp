import 'package:flutter/material.dart';

class ExperienceWorkStep extends StatefulWidget {
  final int? totalExperienceYears;
  final String employmentStatus;
  final String currentOrganization;
  final String professionalBio;
  final List<String> selectedLanguages;

  final ValueChanged<int?> onExperienceChanged;
  final ValueChanged<String> onEmploymentStatusChanged;
  final ValueChanged<String> onOrganizationChanged;
  final ValueChanged<String> onBioChanged;
  final ValueChanged<List<String>> onLanguagesChanged;

  const ExperienceWorkStep({
    super.key,
    required this.totalExperienceYears,
    required this.employmentStatus,
    required this.currentOrganization,
    required this.professionalBio,
    required this.selectedLanguages,
    required this.onExperienceChanged,
    required this.onEmploymentStatusChanged,
    required this.onOrganizationChanged,
    required this.onBioChanged,
    required this.onLanguagesChanged,
  });

  @override
  State<ExperienceWorkStep> createState() => _ExperienceWorkStepState();
}

class _ExperienceWorkStepState extends State<ExperienceWorkStep> {
  late final TextEditingController _organizationController;
  late final TextEditingController _bioController;

  static const Color _ink = Color(0xFF173E39);
  static const Color _muted = Color(0xFF7B8E89);
  static const Color _teal = Color(0xFF087F73);
  static const Color _line = Color(0xFFE5EEEA);
  static const Color _canvas = Color(0xFFF6FAF8);

  final List<int> _experienceOptions = List.generate(31, (index) => index);

  final List<String> _employmentOptions = const [
    'Self-employed',
    'Working at a clinic',
    'Working at a hospital',
    'Working at a physiotherapy center',
    'Freelance physiotherapist',
    'Currently not employed',
    'Other',
  ];

  final List<String> _languages = const [
    'English',
    'Hindi',
    'Marathi',
    'Gujarati',
    'Punjabi',
    'Bengali',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Urdu',
    'Other',
  ];

  static const Map<String, IconData> _employmentIcons = {
    'Self-employed': Icons.business_center_rounded,
    'Working at a clinic': Icons.medical_services_rounded,
    'Working at a hospital': Icons.local_hospital_rounded,
    'Working at a physiotherapy center': Icons.health_and_safety_rounded,
    'Freelance physiotherapist': Icons.laptop_mac_rounded,
    'Currently not employed': Icons.person_search_rounded,
    'Other': Icons.more_horiz_rounded,
  };

  @override
  void initState() {
    super.initState();
    _organizationController =
        TextEditingController(text: widget.currentOrganization);
    _bioController = TextEditingController(text: widget.professionalBio);
  }

  @override
  void didUpdateWidget(covariant ExperienceWorkStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentOrganization != widget.currentOrganization &&
        _organizationController.text != widget.currentOrganization) {
      _organizationController.value = TextEditingValue(
        text: widget.currentOrganization,
        selection: TextSelection.collapsed(offset: widget.currentOrganization.length),
      );
    }
    if (oldWidget.professionalBio != widget.professionalBio &&
        _bioController.text != widget.professionalBio) {
      _bioController.value = TextEditingValue(
        text: widget.professionalBio,
        selection: TextSelection.collapsed(offset: widget.professionalBio.length),
      );
    }
  }

  @override
  void dispose() {
    _organizationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  String _experienceLabel(int? years) {
    if (years == null) return 'Not selected';
    if (years == 0) return 'Less than 1 year';
    if (years == 30) return '30+ years';
    return '$years ${years == 1 ? 'year' : 'years'}';
  }

  void _toggleLanguage(String language, bool selected) {
    final updated = List<String>.from(widget.selectedLanguages);
    if (selected) {
      updated.remove(language);
    } else {
      updated.add(language);
    }
    widget.onLanguagesChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final languageCount = widget.selectedLanguages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A compact profile-style heading rather than a large banner.
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0C9484), Color(0xFF14534C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _teal.withOpacity(.18),
                    blurRadius: 13,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.badge_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your professional story',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 21,
                      letterSpacing: -.55,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Experience, workplace and patient communication',
                    style: TextStyle(color: _muted, fontSize: 11.5, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Profile snapshot strip.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: _canvas,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              Expanded(
                child: _SnapshotMetric(
                  icon: Icons.timeline_rounded,
                  label: 'EXPERIENCE',
                  value: _experienceLabel(widget.totalExperienceYears),
                ),
              ),
              Container(width: 1, height: 34, color: _line),
              const SizedBox(width: 13),
              Expanded(
                child: _SnapshotMetric(
                  icon: Icons.translate_rounded,
                  label: 'LANGUAGES',
                  value: '$languageCount selected',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _SectionHeading(
          number: '01',
          title: 'Professional experience',
          subtitle: 'How long have you been practising?',
        ),
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.workspace_premium_outlined, color: _teal, size: 19),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Total years of experience',
                      style: TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (widget.totalExperienceYears != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6F1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _experienceLabel(widget.totalExperienceYears),
                        style: const TextStyle(color: _teal, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 13),
              DropdownButtonFormField<int>(
                value: widget.totalExperienceYears,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _teal),
                decoration: _fieldDecoration(
                  hint: 'Choose your experience',
                  prefix: Icons.calendar_month_rounded,
                ),
                items: _experienceOptions.map((years) {
                  return DropdownMenuItem<int>(
                    value: years,
                    child: Text(
                      _experienceLabel(years),
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: widget.onExperienceChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),

        _SectionHeading(
          number: '02',
          title: 'Current work setup',
          subtitle: 'Choose the option that best describes you.',
        ),
        const SizedBox(height: 13),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 520 ? 3 : 2;
            const gap = 9.0;
            final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: _employmentOptions.map((option) {
                final selected = widget.employmentStatus == option;
                return SizedBox(
                  width: width,
                  child: _EmploymentTile(
                    title: option,
                    icon: _employmentIcons[option] ?? Icons.work_outline_rounded,
                    selected: selected,
                    onTap: () => widget.onEmploymentStatusChanged(option),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 21),

        _SectionHeading(
          number: '03',
          title: 'Where you work',
          subtitle: 'Add your current clinic, hospital or organization.',
          optional: true,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _organizationController,
          onChanged: widget.onOrganizationChanged,
          textCapitalization: TextCapitalization.words,
          decoration: _fieldDecoration(
            hint: 'e.g. Apollo Physiotherapy Center',
            prefix: Icons.apartment_rounded,
          ),
        ),
        const SizedBox(height: 25),

        _SectionHeading(
          number: '04',
          title: 'Introduce yourself',
          subtitle: 'This introduction can be displayed on your patient profile.',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFDFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: _teal, size: 20),
                  const SizedBox(width: 7),
                  const Expanded(
                    child: Text(
                      'Professional bio',
                      style: TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '${_bioController.text.length}/500',
                    style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bioController,
                onChanged: (value) {
                  widget.onBioChanged(value);
                  setState(() {});
                },
                maxLines: 5,
                minLines: 4,
                maxLength: 500,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) => const SizedBox.shrink(),
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText:
                      'Tell patients about your clinical approach, experience and the kind of care you provide...',
                  hintStyle: TextStyle(color: Color(0xFFA1B1AC), fontSize: 12, height: 1.5),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const Divider(height: 1, color: _line),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFB58A37), size: 15),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tip: Mention your key treatments and patient-care approach.',
                      style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),

        _SectionHeading(
          number: '05',
          title: 'Languages you speak',
          subtitle: 'Help patients find a physiotherapist they can communicate with.',
        ),
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.forum_outlined, color: _teal, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Patient communication',
                      style: TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '$languageCount chosen',
                    style: const TextStyle(color: _teal, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 8,
                runSpacing: 9,
                children: _languages.map((language) {
                  final selected = widget.selectedLanguages.contains(language);
                  return _LanguagePill(
                    language: language,
                    selected: selected,
                    onTap: () => _toggleLanguage(language, selected),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAEF),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFF1E6CD)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_user_outlined, color: Color(0xFFB78936), size: 19),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Your professional information may be reviewed during verification. Please provide accurate details.',
                  style: TextStyle(
                    color: Color(0xFF80652F),
                    fontSize: 11,
                    height: 1.5,
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

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA1B1AC), fontSize: 12),
      prefixIcon: Icon(prefix, color: const Color(0xFF82958F), size: 19),
      filled: true,
      fillColor: const Color(0xFFFBFDFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _teal, width: 1.4),
      ),
    );
  }
}

class _SnapshotMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SnapshotMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF078879), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF91A19C),
                  fontSize: 8,
                  letterSpacing: .8,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF173E39),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool optional;

  const _SectionHeading({
    required this.number,
    required this.title,
    required this.subtitle,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 29,
          height: 29,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5F1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Color(0xFF087F73),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF173E39),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (optional) ...[
                    const SizedBox(width: 7),
                    const Text(
                      'OPTIONAL',
                      style: TextStyle(
                        color: Color(0xFF98A7A2),
                        fontSize: 8,
                        letterSpacing: .6,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF82928D), fontSize: 10.5, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmploymentTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _EmploymentTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 91,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF7F3) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? const Color(0xFF169889) : const Color(0xFFE5EEEA),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 19,
                    color: selected ? const Color(0xFF087F73) : const Color(0xFF82958F),
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF087F73) : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? const Color(0xFF087F73) : const Color(0xFFD5E0DC),
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded, size: 11, color: Colors.white)
                        : null,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? const Color(0xFF087F73) : const Color(0xFF435B55),
                  fontSize: 10.5,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  final String language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguagePill({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF087F73) : const Color(0xFFF7FAF8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? const Color(0xFF087F73) : const Color(0xFFE5EEEA),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check_rounded, color: Colors.white, size: 13),
                const SizedBox(width: 5),
              ],
              Text(
                language,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF637D76),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
