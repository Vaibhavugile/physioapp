import 'package:flutter/material.dart';

// ================================================================
// PROFESSIONAL DETAILS DATA
// ================================================================

class ProfessionalDetailsData {
  final String professionalTitle;
  final String registrationNumber;
  final String registrationAuthority;
  final int yearsOfExperience;

  final String primarySpecialization;
  final List<String> specializations;

  final List<String> languages;

  final String professionalBio;

  final bool providesHomeVisit;
  final bool providesOnlineConsultation;
  final bool providesClinicVisit;

  const ProfessionalDetailsData({
    required this.professionalTitle,
    required this.registrationNumber,
    required this.registrationAuthority,
    required this.yearsOfExperience,
    required this.primarySpecialization,
    required this.specializations,
    required this.languages,
    required this.professionalBio,
    required this.providesHomeVisit,
    required this.providesOnlineConsultation,
    required this.providesClinicVisit,
  });

  ProfessionalDetailsData copyWith({
    String? professionalTitle,
    String? registrationNumber,
    String? registrationAuthority,
    int? yearsOfExperience,
    String? primarySpecialization,
    List<String>? specializations,
    List<String>? languages,
    String? professionalBio,
    bool? providesHomeVisit,
    bool? providesOnlineConsultation,
    bool? providesClinicVisit,
  }) {
    return ProfessionalDetailsData(
      professionalTitle:
          professionalTitle ?? this.professionalTitle,

      registrationNumber:
          registrationNumber ?? this.registrationNumber,

      registrationAuthority:
          registrationAuthority ?? this.registrationAuthority,

      yearsOfExperience:
          yearsOfExperience ?? this.yearsOfExperience,

      primarySpecialization:
          primarySpecialization ?? this.primarySpecialization,

      specializations:
          specializations ?? this.specializations,

      languages:
          languages ?? this.languages,

      professionalBio:
          professionalBio ?? this.professionalBio,

      providesHomeVisit:
          providesHomeVisit ?? this.providesHomeVisit,

      providesOnlineConsultation:
          providesOnlineConsultation ??
              this.providesOnlineConsultation,

      providesClinicVisit:
          providesClinicVisit ?? this.providesClinicVisit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'professionalTitle': professionalTitle,
      'registrationNumber': registrationNumber,
      'registrationAuthority': registrationAuthority,
      'yearsOfExperience': yearsOfExperience,
      'primarySpecialization': primarySpecialization,
      'specializations': specializations,
      'languages': languages,
      'professionalBio': professionalBio,
      'providesHomeVisit': providesHomeVisit,
      'providesOnlineConsultation':
          providesOnlineConsultation,
      'providesClinicVisit': providesClinicVisit,
    };
  }

  factory ProfessionalDetailsData.fromMap(
    Map<String, dynamic> map,
  ) {
    return ProfessionalDetailsData(
      professionalTitle:
          map['professionalTitle'] ?? '',

      registrationNumber:
          map['registrationNumber'] ?? '',

      registrationAuthority:
          map['registrationAuthority'] ?? '',

      yearsOfExperience:
          map['yearsOfExperience'] ?? 0,

      primarySpecialization:
          map['primarySpecialization'] ?? '',

      specializations:
          List<String>.from(
        map['specializations'] ?? [],
      ),

      languages:
          List<String>.from(
        map['languages'] ?? [],
      ),

      professionalBio:
          map['professionalBio'] ?? '',

      providesHomeVisit:
          map['providesHomeVisit'] ?? false,

      providesOnlineConsultation:
          map['providesOnlineConsultation'] ?? false,

      providesClinicVisit:
          map['providesClinicVisit'] ?? false,
    );
  }
}

// ================================================================
// PROFESSIONAL DETAILS STEP
// ================================================================

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

class _ProfessionalDetailsStepState
    extends State<ProfessionalDetailsStep> {
  // ==============================================================
  // CONTROLLERS
  // ==============================================================

  late final TextEditingController _registrationNumberController;

  late final TextEditingController _registrationAuthorityController;

  late final TextEditingController _bioController;

  // ==============================================================
  // VALUES
  // ==============================================================

  String _professionalTitle = '';

  int _yearsOfExperience = 0;

  String _primarySpecialization = '';

  final List<String> _selectedSpecializations = [];

  final List<String> _selectedLanguages = [];

  bool _providesHomeVisit = true;

  bool _providesOnlineConsultation = false;

  bool _providesClinicVisit = false;

  // ==============================================================
  // OPTIONS
  // ==============================================================

  static const List<String> _professionalTitles = [
    'Physiotherapist',
    'Senior Physiotherapist',
    'Consultant Physiotherapist',
    'Sports Physiotherapist',
    'Orthopedic Physiotherapist',
    'Neuro Physiotherapist',
    'Pediatric Physiotherapist',
    'Women’s Health Physiotherapist',
  ];

  static const List<String> _specializationOptions = [
    'Back & Neck Pain',
    'Sports Injury',
    'Post Surgery Rehabilitation',
    'Orthopedic Rehabilitation',
    'Neurological Rehabilitation',
    'Stroke Rehabilitation',
    'Pediatric Physiotherapy',
    'Geriatric Physiotherapy',
    'Women’s Health',
    'Pregnancy & Postpartum Care',
    'Joint Pain',
    'Arthritis Management',
    'Posture Correction',
    'Home Rehabilitation',
  ];

  static const List<String> _languageOptions = [
    'English',
    'Hindi',
    'Marathi',
    'Gujarati',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Bengali',
    'Punjabi',
    'Urdu',
  ];

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    final data = widget.initialData;

    _registrationNumberController =
        TextEditingController(
      text: data?.registrationNumber ?? '',
    );

    _registrationAuthorityController =
        TextEditingController(
      text: data?.registrationAuthority ?? '',
    );

    _bioController =
        TextEditingController(
      text: data?.professionalBio ?? '',
    );

    _professionalTitle =
        data?.professionalTitle ?? '';

    _yearsOfExperience =
        data?.yearsOfExperience ?? 0;

    _primarySpecialization =
        data?.primarySpecialization ?? '';

    if (data != null) {
      _selectedSpecializations.addAll(
        data.specializations,
      );

      _selectedLanguages.addAll(
        data.languages,
      );

      _providesHomeVisit =
          data.providesHomeVisit;

      _providesOnlineConsultation =
          data.providesOnlineConsultation;

      _providesClinicVisit =
          data.providesClinicVisit;
    }

    _registrationNumberController.addListener(
      _notifyChanged,
    );

    _registrationAuthorityController.addListener(
      _notifyChanged,
    );

    _bioController.addListener(
      _notifyChanged,
    );
  }

  // ==============================================================
  // NOTIFY PARENT
  // ==============================================================

  void _notifyChanged() {
    widget.onChanged(
      ProfessionalDetailsData(
        professionalTitle:
            _professionalTitle,

        registrationNumber:
            _registrationNumberController.text.trim(),

        registrationAuthority:
            _registrationAuthorityController.text.trim(),

        yearsOfExperience:
            _yearsOfExperience,

        primarySpecialization:
            _primarySpecialization,

        specializations:
            List<String>.from(
          _selectedSpecializations,
        ),

        languages:
            List<String>.from(
          _selectedLanguages,
        ),

        professionalBio:
            _bioController.text.trim(),

        providesHomeVisit:
            _providesHomeVisit,

        providesOnlineConsultation:
            _providesOnlineConsultation,

        providesClinicVisit:
            _providesClinicVisit,
      ),
    );
  }

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    _registrationNumberController.dispose();

    _registrationAuthorityController.dispose();

    _bioController.dispose();

    super.dispose();
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        _buildIntroCard(),

        const SizedBox(height: 22),

        // ========================================================
        // PROFESSIONAL TITLE
        // ========================================================

        _buildSectionTitle(
          'Professional identity',
          'Tell patients about your professional role.',
        ),

        const SizedBox(height: 12),

        _buildDropdownField(
          label: 'Professional title',
          value: _professionalTitle.isEmpty
              ? null
              : _professionalTitle,
          hint: 'Select your professional title',
          items: _professionalTitles,
          onChanged: (value) {
            setState(() {
              _professionalTitle = value ?? '';
            });

            _notifyChanged();
          },
        ),

        const SizedBox(height: 16),

        // ========================================================
        // REGISTRATION
        // ========================================================

        _buildTextField(
          controller:
              _registrationNumberController,
          label: 'Registration / License number',
          hint: 'Enter your registration number',
          icon:
              Icons.verified_user_outlined,
        ),

        const SizedBox(height: 14),

        _buildTextField(
          controller:
              _registrationAuthorityController,
          label: 'Registration authority',
          hint:
              'Example: State Physiotherapy Council',
          icon:
              Icons.account_balance_outlined,
        ),

        const SizedBox(height: 26),

        // ========================================================
        // EXPERIENCE
        // ========================================================

        _buildSectionTitle(
          'Experience',
          'How long have you been practicing professionally?',
        ),

        const SizedBox(height: 14),

        _buildExperienceSelector(),

        const SizedBox(height: 28),

        // ========================================================
        // PRIMARY SPECIALIZATION
        // ========================================================

        _buildSectionTitle(
          'Primary specialization',
          'Choose the area you are most experienced in.',
        ),

        const SizedBox(height: 12),

        _buildDropdownField(
          label: 'Primary specialization',
          value: _primarySpecialization.isEmpty
              ? null
              : _primarySpecialization,
          hint:
              'Select your primary specialization',
          items: _specializationOptions,
          onChanged: (value) {
            setState(() {
              _primarySpecialization =
                  value ?? '';
            });

            _notifyChanged();
          },
        ),

        const SizedBox(height: 28),

        // ========================================================
        // OTHER SPECIALIZATIONS
        // ========================================================

        _buildSectionTitle(
          'Other areas of expertise',
          'Select all the conditions and services you handle.',
        ),

        const SizedBox(height: 14),

        _buildSelectableChips(
          options: _specializationOptions,
          selected: _selectedSpecializations,
          onChanged: (value) {
            setState(() {
              if (_selectedSpecializations
                  .contains(value)) {
                _selectedSpecializations
                    .remove(value);
              } else {
                _selectedSpecializations
                    .add(value);
              }
            });

            _notifyChanged();
          },
        ),

        const SizedBox(height: 28),

        // ========================================================
        // LANGUAGES
        // ========================================================

        _buildSectionTitle(
          'Languages spoken',
          'Select the languages you can comfortably consult in.',
        ),

        const SizedBox(height: 14),

        _buildSelectableChips(
          options: _languageOptions,
          selected: _selectedLanguages,
          onChanged: (value) {
            setState(() {
              if (_selectedLanguages
                  .contains(value)) {
                _selectedLanguages
                    .remove(value);
              } else {
                _selectedLanguages.add(value);
              }
            });

            _notifyChanged();
          },
        ),

        const SizedBox(height: 28),

        // ========================================================
        // SERVICES
        // ========================================================

        _buildSectionTitle(
          'Services you provide',
          'Select the ways you are available for patient care.',
        ),

        const SizedBox(height: 14),

        _buildServiceTile(
          icon: Icons.home_outlined,
          title: 'Home visits',
          subtitle:
              'Provide physiotherapy sessions at the patient’s home.',
          value: _providesHomeVisit,
          onChanged: (value) {
            setState(() {
              _providesHomeVisit = value;
            });

            _notifyChanged();
          },
        ),

        const SizedBox(height: 10),

        _buildServiceTile(
          icon: Icons.videocam_outlined,
          title: 'Online consultation',
          subtitle:
              'Provide consultation through video sessions.',
          value:
              _providesOnlineConsultation,
          onChanged: (value) {
            setState(() {
              _providesOnlineConsultation =
                  value;
            });

            _notifyChanged();
          },
        ),

        const SizedBox(height: 10),

        _buildServiceTile(
          icon:
              Icons.local_hospital_outlined,
          title: 'Clinic consultation',
          subtitle:
              'See patients at your clinic or practice location.',
          value:
              _providesClinicVisit,
          onChanged: (value) {
            setState(() {
              _providesClinicVisit = value;
            });

            _notifyChanged();
          },
        ),

        const SizedBox(height: 28),

        // ========================================================
        // PROFESSIONAL BIO
        // ========================================================

        _buildSectionTitle(
          'Professional introduction',
          'Write a short introduction patients can see on your profile.',
        ),

        const SizedBox(height: 12),

        _buildBioField(),

        const SizedBox(height: 12),

        const Text(
          'Tip: Mention your experience, approach to treatment and areas of expertise.',
          style: TextStyle(
            fontSize: 10.5,
            height: 1.5,
            color: Color(0xFF7B849C),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ==============================================================
  // INTRO CARD
  // ==============================================================

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2457F5),
            Color(0xFF4B7BFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius:
            BorderRadius.circular(22),
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),

              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: const Icon(
              Icons.badge_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Build patient trust',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Professional details help patients understand your expertise and choose the right physiotherapist.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                    height: 1.45,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // SECTION TITLE
  // ==============================================================

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111A3D),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10.5,
            height: 1.45,
            color: Color(0xFF7B849C),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // TEXT FIELD
  // ==============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF303955),
          ),
        ),

        const SizedBox(height: 7),

        TextField(
          controller: controller,

          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111A3D),
          ),

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9BA4B8),
              fontWeight: FontWeight.w500,
            ),

            prefixIcon: Icon(
              icon,
              size: 20,
              color: const Color(0xFF2457F5),
            ),

            filled: true,

            fillColor: Colors.white,

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),

              borderSide:
                  const BorderSide(
                color: Color(0xFFE2E7F0),
              ),
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),

              borderSide:
                  const BorderSide(
                color: Color(0xFFE2E7F0),
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),

              borderSide:
                  const BorderSide(
                color: Color(0xFF2457F5),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // DROPDOWN
  // ==============================================================

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF303955),
          ),
        ),

        const SizedBox(height: 7),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
          ),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(16),

            border: Border.all(
              color:
                  const Color(0xFFE2E7F0),
            ),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,

              isExpanded: true,

              hint: Text(
                hint,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9BA4B8),
                  fontWeight:
                      FontWeight.w500,
                ),
              ),

              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF2457F5),
              ),

              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,

                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 12,
                      color:
                          Color(0xFF111A3D),
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),

              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // EXPERIENCE SELECTOR
  // ==============================================================

  Widget _buildExperienceSelector() {
    final options = [
      0,
      1,
      2,
      3,
      5,
      7,
      10,
      15,
      20,
    ];

    return Wrap(
      spacing: 9,
      runSpacing: 9,

      children: options.map((years) {
        final isSelected =
            _yearsOfExperience == years;

        final label = years == 20
            ? '20+'
            : years == 0
                ? 'Fresher'
                : '$years yrs';

        return GestureDetector(
          onTap: () {
            setState(() {
              _yearsOfExperience = years;
            });

            _notifyChanged();
          },

          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 180),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 11,
            ),

            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2457F5)
                  : Colors.white,

              borderRadius:
                  BorderRadius.circular(14),

              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2457F5)
                    : const Color(0xFFE0E6F0),
              ),
            ),

            child: Text(
              label,

              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,

                color: isSelected
                    ? Colors.white
                    : const Color(0xFF4B5570),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==============================================================
  // SELECTABLE CHIPS
  // ==============================================================

  Widget _buildSelectableChips({
    required List<String> options,
    required List<String> selected,
    required ValueChanged<String> onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,

      children: options.map((option) {
        final isSelected =
            selected.contains(option);

        return GestureDetector(
          onTap: () {
            onChanged(option);
          },

          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 180),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 10,
            ),

            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFEAF0FF)
                  : Colors.white,

              borderRadius:
                  BorderRadius.circular(14),

              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2457F5)
                    : const Color(0xFFE0E6F0),
              ),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 15,
                    color: Color(0xFF2457F5),
                  ),

                  const SizedBox(width: 5),
                ],

                Text(
                  option,

                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,

                    color: isSelected
                        ? const Color(0xFF2457F5)
                        : const Color(
                            0xFF4B5570,
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==============================================================
  // SERVICE TILE
  // ==============================================================

  Widget _buildServiceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),

        padding:
            const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: value
              ? const Color(0xFFF3F6FF)
              : Colors.white,

          borderRadius:
              BorderRadius.circular(18),

          border: Border.all(
            color: value
                ? const Color(0xFF2457F5)
                : const Color(0xFFE1E6EF),
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: value
                    ? const Color(0xFF2457F5)
                    : const Color(0xFFF1F4F9),

                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: Icon(
                icon,

                size: 21,

                color: value
                    ? Colors.white
                    : const Color(0xFF68738B),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          Color(0xFF111A3D),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,

                    style: const TextStyle(
                      fontSize: 9.5,
                      height: 1.4,
                      color:
                          Color(0xFF7B849C),
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Switch(
              value: value,

              activeColor:
                  const Color(0xFF2457F5),

              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // BIO FIELD
  // ==============================================================

  Widget _buildBioField() {
    return TextField(
      controller: _bioController,

      minLines: 5,
      maxLines: 7,

      maxLength: 500,

      style: const TextStyle(
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: Color(0xFF111A3D),
      ),

      decoration: InputDecoration(
        hintText:
            'Example: I am an experienced physiotherapist specializing in orthopedic and sports rehabilitation...',

        hintStyle: const TextStyle(
          fontSize: 11,
          height: 1.5,
          color: Color(0xFF9BA4B8),
        ),

        filled: true,

        fillColor: Colors.white,

        contentPadding:
            const EdgeInsets.all(16),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),

          borderSide:
              const BorderSide(
            color: Color(0xFFE2E7F0),
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),

          borderSide:
              const BorderSide(
            color: Color(0xFFE2E7F0),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),

          borderSide:
              const BorderSide(
            color: Color(0xFF2457F5),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}