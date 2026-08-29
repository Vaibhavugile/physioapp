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
  State<ExperienceWorkStep> createState() =>
      _ExperienceWorkStepState();
}

class _ExperienceWorkStepState extends State<ExperienceWorkStep> {
  late TextEditingController _organizationController;
  late TextEditingController _bioController;

  final List<int> _experienceOptions =
      List.generate(31, (index) => index);

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

  @override
  void initState() {
    super.initState();

    _organizationController =
        TextEditingController(
      text: widget.currentOrganization,
    );

    _bioController = TextEditingController(
      text: widget.professionalBio,
    );
  }

  @override
  void didUpdateWidget(
    covariant ExperienceWorkStep oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentOrganization !=
        widget.currentOrganization) {
      if (_organizationController.text !=
          widget.currentOrganization) {
        _organizationController.text =
            widget.currentOrganization;
      }
    }

    if (oldWidget.professionalBio !=
        widget.professionalBio) {
      if (_bioController.text !=
          widget.professionalBio) {
        _bioController.text =
            widget.professionalBio;
      }
    }
  }

  @override
  void dispose() {
    _organizationController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // ========================================================
        // HEADER
        // ========================================================

        const Text(
          'Experience & work details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111A3D),
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Tell us about your professional experience and current work situation.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF7B849C),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 26),

        // ========================================================
        // EXPERIENCE
        // ========================================================

        const _SectionLabel(
          title: 'Total professional experience',
          requiredField: true,
        ),

        const SizedBox(height: 10),

        _ExperienceDropdown(
          value: widget.totalExperienceYears,
          options: _experienceOptions,
          onChanged: widget.onExperienceChanged,
        ),

        const SizedBox(height: 24),

        // ========================================================
        // EMPLOYMENT STATUS
        // ========================================================

        const _SectionLabel(
          title: 'Current employment status',
          requiredField: true,
        ),

        const SizedBox(height: 10),

        ..._employmentOptions.map(
          (option) {
            final isSelected =
                widget.employmentStatus == option;

            return Padding(
              padding:
                  const EdgeInsets.only(bottom: 10),
              child: _EmploymentOption(
                title: option,
                isSelected: isSelected,
                onTap: () {
                  widget
                      .onEmploymentStatusChanged(
                    option,
                  );
                },
              ),
            );
          },
        ),

        const SizedBox(height: 14),

        // ========================================================
        // ORGANIZATION
        // ========================================================

        const _SectionLabel(
          title: 'Current clinic / hospital / organization',
          requiredField: false,
        ),

        const SizedBox(height: 10),

        TextField(
          controller: _organizationController,
          onChanged:
              widget.onOrganizationChanged,
          textCapitalization:
              TextCapitalization.words,
          decoration: _inputDecoration(
            hint:
                'Example: Apollo Physiotherapy Center',
            icon:
                Icons.business_rounded,
          ),
        ),

        const SizedBox(height: 24),

        // ========================================================
        // PROFESSIONAL BIO
        // ========================================================

        const _SectionLabel(
          title: 'About you',
          requiredField: true,
        ),

        const SizedBox(height: 6),

        const Text(
          'Write a short professional introduction that patients can see on your profile.',
          style: TextStyle(
            fontSize: 12,
            height: 1.45,
            color: Color(0xFF7B849C),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: _bioController,
          onChanged: widget.onBioChanged,
          maxLines: 6,
          maxLength: 500,
          textCapitalization:
              TextCapitalization.sentences,
          decoration: _inputDecoration(
            hint:
                'Example: I am a qualified physiotherapist with experience in treating orthopedic injuries, chronic pain and post-surgery rehabilitation...',
            icon: Icons.description_outlined,
          ),
        ),

        const SizedBox(height: 22),

        // ========================================================
        // LANGUAGES
        // ========================================================

        const _SectionLabel(
          title: 'Languages you speak',
          requiredField: true,
        ),

        const SizedBox(height: 6),

        const Text(
          'Select all languages you can comfortably communicate with patients in.',
          style: TextStyle(
            fontSize: 12,
            height: 1.45,
            color: Color(0xFF7B849C),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 14),

        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: _languages.map(
            (language) {
              final isSelected =
                  widget.selectedLanguages
                      .contains(language);

              return _LanguageChip(
                language: language,
                isSelected: isSelected,
                onTap: () {
                  final updated =
                      List<String>.from(
                    widget.selectedLanguages,
                  );

                  if (isSelected) {
                    updated.remove(language);
                  } else {
                    updated.add(language);
                  }

                  widget.onLanguagesChanged(
                    updated,
                  );
                },
              );
            },
          ).toList(),
        ),

        const SizedBox(height: 24),

        // ========================================================
        // INFO BOX
        // ========================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD5E4FF),
            ),
          ),
          child: const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF246BFD),
                size: 21,
              ),

              SizedBox(width: 11),

              Expanded(
                child: Text(
                  'Your professional information may be reviewed during the verification process. Please provide accurate details.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF4B5B78),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFF9AA3B5),
        fontWeight: FontWeight.w500,
      ),

      prefixIcon: Padding(
        padding: const EdgeInsets.only(
          bottom: 0,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF667085),
          size: 21,
        ),
      ),

      filled: true,
      fillColor: Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE1E6EF),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE1E6EF),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF246BFD),
          width: 1.5,
        ),
      ),
    );
  }
}

// ================================================================
// SECTION LABEL
// ================================================================

class _SectionLabel extends StatelessWidget {
  final String title;
  final bool requiredField;

  const _SectionLabel({
    required this.title,
    required this.requiredField,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF27314D),
          fontWeight: FontWeight.w800,
        ),
        children: [
          TextSpan(text: title),

          if (requiredField)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Color(0xFFE5484D),
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================
// EXPERIENCE DROPDOWN
// ================================================================

class _ExperienceDropdown extends StatelessWidget {
  final int? value;
  final List<int> options;
  final ValueChanged<int?> onChanged;

  const _ExperienceDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: value,

      isExpanded: true,

      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.work_history_outlined,
          color: Color(0xFF667085),
        ),

        filled: true,
        fillColor: Colors.white,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE1E6EF),
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE1E6EF),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF246BFD),
            width: 1.5,
          ),
        ),
      ),

      hint: const Text(
        'Select experience',
        style: TextStyle(
          fontSize: 13,
          color: Color(0xFF9AA3B5),
          fontWeight: FontWeight.w500,
        ),
      ),

      items: options.map(
        (years) {
          String label;

          if (years == 0) {
            label = 'Less than 1 year';
          } else if (years == 30) {
            label = '30+ years';
          } else {
            label =
                '$years ${years == 1 ? 'year' : 'years'}';
          }

          return DropdownMenuItem<int>(
            value: years,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF27314D),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ).toList(),

      onChanged: onChanged,
    );
  }
}

// ================================================================
// EMPLOYMENT OPTION
// ================================================================

class _EmploymentOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmploymentOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(15),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFEAF2FF)
                : Colors.white,
            borderRadius:
                BorderRadius.circular(15),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF246BFD)
                  : const Color(0xFFE3E7EF),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration:
                    const Duration(milliseconds: 180),
                width: 21,
                height: 21,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF246BFD)
                        : const Color(0xFFC6CEDA),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration:
                              const BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                Color(0xFF246BFD),
                          ),
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? const Color(0xFF1D4ED8)
                        : const Color(0xFF374151),
                  ),
                ),
              ),

              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                size: 20,
                color: isSelected
                    ? const Color(0xFF246BFD)
                    : const Color(0xFFB4BCCB),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// LANGUAGE CHIP
// ================================================================

class _LanguageChip extends StatelessWidget {
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(30),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF246BFD)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF246BFD)
                : const Color(0xFFE0E5EE),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              ),

              const SizedBox(width: 5),
            ],

            Text(
              language,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF59637A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}