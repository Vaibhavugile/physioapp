import 'package:flutter/material.dart';

// ================================================================
// EDUCATION QUALIFICATION MODEL
// ================================================================

class EducationQualification {
  final String degree;
  final String specialization;
  final String institution;
  final String university;
  final int passingYear;

  const EducationQualification({
    required this.degree,
    required this.specialization,
    required this.institution,
    required this.university,
    required this.passingYear,
  });

  EducationQualification copyWith({
    String? degree,
    String? specialization,
    String? institution,
    String? university,
    int? passingYear,
  }) {
    return EducationQualification(
      degree: degree ?? this.degree,
      specialization:
          specialization ?? this.specialization,
      institution: institution ?? this.institution,
      university: university ?? this.university,
      passingYear:
          passingYear ?? this.passingYear,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'degree': degree,
      'specialization': specialization,
      'institution': institution,
      'university': university,
      'passingYear': passingYear,
    };
  }

  factory EducationQualification.fromMap(
    Map<String, dynamic> map,
  ) {
    return EducationQualification(
      degree: map['degree'] ?? '',
      specialization:
          map['specialization'] ?? '',
      institution:
          map['institution'] ?? '',
      university: map['university'] ?? '',
      passingYear:
          (map['passingYear'] ?? 0) as int,
    );
  }
}

// ================================================================
// PROFESSIONAL CERTIFICATION MODEL
// ================================================================

class ProfessionalCertification {
  final String certificateName;
  final String issuingOrganization;
  final int completionYear;

  const ProfessionalCertification({
    required this.certificateName,
    required this.issuingOrganization,
    required this.completionYear,
  });

  ProfessionalCertification copyWith({
    String? certificateName,
    String? issuingOrganization,
    int? completionYear,
  }) {
    return ProfessionalCertification(
      certificateName:
          certificateName ?? this.certificateName,
      issuingOrganization:
          issuingOrganization ??
              this.issuingOrganization,
      completionYear:
          completionYear ?? this.completionYear,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'certificateName': certificateName,
      'issuingOrganization':
          issuingOrganization,
      'completionYear': completionYear,
    };
  }

  factory ProfessionalCertification.fromMap(
    Map<String, dynamic> map,
  ) {
    return ProfessionalCertification(
      certificateName:
          map['certificateName'] ?? '',
      issuingOrganization:
          map['issuingOrganization'] ?? '',
      completionYear:
          (map['completionYear'] ?? 0) as int,
    );
  }
}

// ================================================================
// EDUCATION & QUALIFICATIONS DATA
// ================================================================

class EducationQualificationsData {
  final List<EducationQualification>
      qualifications;

  final List<ProfessionalCertification>
      certifications;

  const EducationQualificationsData({
    required this.qualifications,
    required this.certifications,
  });

  EducationQualificationsData copyWith({
    List<EducationQualification>?
        qualifications,
    List<ProfessionalCertification>?
        certifications,
  }) {
    return EducationQualificationsData(
      qualifications:
          qualifications ?? this.qualifications,

      certifications:
          certifications ?? this.certifications,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'qualifications': qualifications
          .map((item) => item.toMap())
          .toList(),

      'certifications': certifications
          .map((item) => item.toMap())
          .toList(),
    };
  }

  factory EducationQualificationsData.fromMap(
    Map<String, dynamic> map,
  ) {
    final qualificationsList =
        map['qualifications'] as List? ?? [];

    final certificationsList =
        map['certifications'] as List? ?? [];

    return EducationQualificationsData(
      qualifications:
          qualificationsList.map((item) {
        return EducationQualification.fromMap(
          Map<String, dynamic>.from(item),
        );
      }).toList(),

      certifications:
          certificationsList.map((item) {
        return ProfessionalCertification.fromMap(
          Map<String, dynamic>.from(item),
        );
      }).toList(),
    );
  }
}

// ================================================================
// EDUCATION & QUALIFICATIONS STEP
// ================================================================

class EducationQualificationsStep
    extends StatefulWidget {
  final EducationQualificationsData? initialData;

  final ValueChanged<EducationQualificationsData>
      onChanged;

  const EducationQualificationsStep({
    super.key,
    this.initialData,
    required this.onChanged,
  });

  @override
  State<EducationQualificationsStep>
      createState() =>
          _EducationQualificationsStepState();
}

class _EducationQualificationsStepState
    extends State<EducationQualificationsStep> {
  // ==============================================================
  // DATA
  // ==============================================================

  final List<EducationQualification>
      _qualifications = [];

  final List<ProfessionalCertification>
      _certifications = [];

  // ==============================================================
  // OPTIONS
  // ==============================================================

  static const List<String> _degreeOptions = [
    'Bachelor of Physiotherapy (BPT)',
    'Master of Physiotherapy (MPT)',
    'Diploma in Physiotherapy (DPT)',
    'Bachelor of Science in Physiotherapy',
    'Master of Science in Physiotherapy',
    'Doctor of Physical Therapy',
    'Other',
  ];

  static const List<String>
      _specializationOptions = [
    'Orthopedic Physiotherapy',
    'Sports Physiotherapy',
    'Neurological Physiotherapy',
    'Cardiopulmonary Physiotherapy',
    'Pediatric Physiotherapy',
    'Geriatric Physiotherapy',
    'Women’s Health Physiotherapy',
    'Musculoskeletal Physiotherapy',
    'General Physiotherapy',
    'Other',
  ];

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    final data = widget.initialData;

    if (data != null) {
      _qualifications.addAll(
        data.qualifications,
      );

      _certifications.addAll(
        data.certifications,
      );
    }
  }

  // ==============================================================
  // NOTIFY
  // ==============================================================

  void _notifyChanged() {
    widget.onChanged(
      EducationQualificationsData(
        qualifications:
            List<EducationQualification>.from(
          _qualifications,
        ),

        certifications:
            List<ProfessionalCertification>.from(
          _certifications,
        ),
      ),
    );
  }

  // ==============================================================
  // ADD QUALIFICATION
  // ==============================================================

  Future<void> _showQualificationSheet({
    EducationQualification? existing,
    int? editIndex,
  }) async {
    String degree =
        existing?.degree ?? '';

    String specialization =
        existing?.specialization ?? '';

    final institutionController =
        TextEditingController(
      text: existing?.institution ?? '',
    );

    final universityController =
        TextEditingController(
      text: existing?.university ?? '',
    );

    int passingYear =
        existing?.passingYear ??
            DateTime.now().year;

    await showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setModalState,
          ) {
            return Container(
              padding:
                  EdgeInsets.only(
                left: 22,
                right: 22,
                top: 22,

                bottom:
                    MediaQuery.of(context)
                        .viewInsets
                        .bottom +
                    24,
              ),

              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFD),

                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ============================================
                    // HANDLE
                    // ============================================

                    Center(
                      child: Container(
                        width: 42,
                        height: 4,

                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFD7DDEA),

                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      existing == null
                          ? 'Add qualification'
                          : 'Edit qualification',

                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.w900,
                        color:
                            Color(0xFF111A3D),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Add your educational qualification details.',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Color(0xFF7B849C),
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ============================================
                    // DEGREE
                    // ============================================

                    _buildSheetDropdown(
                      label: 'Degree',
                      value:
                          degree.isEmpty
                              ? null
                              : degree,

                      hint:
                          'Select degree',

                      items:
                          _degreeOptions,

                      onChanged:
                          (value) {
                        setModalState(() {
                          degree =
                              value ?? '';
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // ============================================
                    // SPECIALIZATION
                    // ============================================

                    _buildSheetDropdown(
                      label:
                          'Specialization',

                      value:
                          specialization.isEmpty
                              ? null
                              : specialization,

                      hint:
                          'Select specialization',

                      items:
                          _specializationOptions,

                      onChanged:
                          (value) {
                        setModalState(() {
                          specialization =
                              value ?? '';
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // ============================================
                    // INSTITUTION
                    // ============================================

                    _buildSheetTextField(
                      controller:
                          institutionController,

                      label:
                          'College / Institution',

                      hint:
                          'Enter college name',

                      icon:
                          Icons.school_outlined,
                    ),

                    const SizedBox(height: 16),

                    // ============================================
                    // UNIVERSITY
                    // ============================================

                    _buildSheetTextField(
                      controller:
                          universityController,

                      label:
                          'University',

                      hint:
                          'Enter university name',

                      icon:
                          Icons.account_balance_outlined,
                    ),

                    const SizedBox(height: 18),

                    // ============================================
                    // PASSING YEAR
                    // ============================================

                    const Text(
                      'Passing year',

                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF303955),
                      ),
                    ),

                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () async {
                        final selectedYear =
                            await _pickYear(
                          context,
                          passingYear,
                        );

                        if (selectedYear != null) {
                          setModalState(() {
                            passingYear =
                                selectedYear;
                          });
                        }
                      },

                      child: Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),

                          border: Border.all(
                            color:
                                const Color(
                              0xFFE2E7F0,
                            ),
                          ),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 20,
                              color:
                                  Color(0xFF2457F5),
                            ),

                            const SizedBox(width: 12),

                            Text(
                              passingYear.toString(),

                              style:
                                  const TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w700,
                                color:
                                    Color(0xFF111A3D),
                              ),
                            ),

                            const Spacer(),

                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color:
                                  Color(0xFF2457F5),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ============================================
                    // SAVE
                    // ============================================

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton(
                        onPressed: () {
                          if (degree.isEmpty ||
                              institutionController
                                  .text
                                  .trim()
                                  .isEmpty) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please complete the required details.',
                                ),
                              ),
                            );

                            return;
                          }

                          final qualification =
                              EducationQualification(
                            degree: degree,

                            specialization:
                                specialization,

                            institution:
                                institutionController
                                    .text
                                    .trim(),

                            university:
                                universityController
                                    .text
                                    .trim(),

                            passingYear:
                                passingYear,
                          );

                          setState(() {
                            if (editIndex != null) {
                              _qualifications[
                                  editIndex] =
                                  qualification;
                            } else {
                              _qualifications.add(
                                qualification,
                              );
                            }
                          });

                          _notifyChanged();

                          Navigator.pop(context);
                        },

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF2457F5,
                          ),

                          foregroundColor:
                              Colors.white,

                          elevation: 0,

                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 16,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),

                        child: Text(
                          existing == null
                              ? 'Add qualification'
                              : 'Save changes',

                          style:
                              const TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // IMPORTANT:
    // Do not dispose these controllers immediately after the modal closes.
    // Flutter may still rebuild the closing modal/TextFields during the route
    // transition, which can cause a disposed-controller assertion.
  }

  // ==============================================================
  // ADD CERTIFICATION
  // ==============================================================

  Future<void> _showCertificationSheet({
    ProfessionalCertification? existing,
    int? editIndex,
  }) async {
    final certificateController =
        TextEditingController(
      text:
          existing?.certificateName ?? '',
    );

    final organizationController =
        TextEditingController(
      text:
          existing?.issuingOrganization ?? '',
    );

    int completionYear =
        existing?.completionYear ??
            DateTime.now().year;

    await showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setModalState,
          ) {
            return Container(
              padding:
                  EdgeInsets.only(
                left: 22,
                right: 22,
                top: 22,

                bottom:
                    MediaQuery.of(context)
                        .viewInsets
                        .bottom +
                    24,
              ),

              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFD),

                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,

                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFD7DDEA),

                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      existing == null
                          ? 'Add certification'
                          : 'Edit certification',

                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.w900,
                        color:
                            Color(0xFF111A3D),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Add additional courses and professional certifications.',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Color(0xFF7B849C),
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 22),

                    _buildSheetTextField(
                      controller:
                          certificateController,

                      label:
                          'Certification name',

                      hint:
                          'Example: Sports Rehabilitation Certification',

                      icon:
                          Icons.workspace_premium_outlined,
                    ),

                    const SizedBox(height: 16),

                    _buildSheetTextField(
                      controller:
                          organizationController,

                      label:
                          'Issuing organization',

                      hint:
                          'Enter organization name',

                      icon:
                          Icons.business_outlined,
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Completion year',

                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF303955),
                      ),
                    ),

                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () async {
                        final selectedYear =
                            await _pickYear(
                          context,
                          completionYear,
                        );

                        if (selectedYear != null) {
                          setModalState(() {
                            completionYear =
                                selectedYear;
                          });
                        }
                      },

                      child: Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),

                          border: Border.all(
                            color:
                                const Color(
                              0xFFE2E7F0,
                            ),
                          ),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 20,
                              color:
                                  Color(0xFF2457F5),
                            ),

                            const SizedBox(width: 12),

                            Text(
                              completionYear.toString(),

                              style:
                                  const TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w700,
                                color:
                                    Color(0xFF111A3D),
                              ),
                            ),

                            const Spacer(),

                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color:
                                  Color(0xFF2457F5),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton(
                        onPressed: () {
                          if (certificateController
                              .text
                              .trim()
                              .isEmpty) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter the certification name.',
                                ),
                              ),
                            );

                            return;
                          }

                          final certification =
                              ProfessionalCertification(
                            certificateName:
                                certificateController
                                    .text
                                    .trim(),

                            issuingOrganization:
                                organizationController
                                    .text
                                    .trim(),

                            completionYear:
                                completionYear,
                          );

                          setState(() {
                            if (editIndex != null) {
                              _certifications[
                                  editIndex] =
                                  certification;
                            } else {
                              _certifications.add(
                                certification,
                              );
                            }
                          });

                          _notifyChanged();

                          Navigator.pop(context);
                        },

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF2457F5,
                          ),

                          foregroundColor:
                              Colors.white,

                          elevation: 0,

                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 16,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),

                        child: Text(
                          existing == null
                              ? 'Add certification'
                              : 'Save changes',

                          style:
                              const TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // IMPORTANT:
    // Do not dispose these controllers immediately after the modal closes.
    // Flutter may still rebuild the closing modal/TextFields during the route
    // transition, which can cause a disposed-controller assertion.
  }

  // ==============================================================
  // PICK YEAR
  // ==============================================================

  Future<int?> _pickYear(
    BuildContext context,
    int selectedYear,
  ) async {
    final currentYear =
        DateTime.now().year;

    return showDialog<int>(
      context: context,

      builder: (context) {
        int tempYear = selectedYear;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),

          title: const Text(
            'Select year',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),

          content: SizedBox(
            width: double.maxFinite,
            height: 330,

            child: ListView.builder(
              itemCount:
                  currentYear - 1980 + 1,

              itemBuilder:
                  (context, index) {
                final year =
                    currentYear - index;

                final selected =
                    tempYear == year;

                return ListTile(
                  title: Text(
                    year.toString(),
                    style: TextStyle(
                      fontWeight: selected
                          ? FontWeight.w800
                          : FontWeight.w500,

                      color: selected
                          ? const Color(
                              0xFF2457F5,
                            )
                          : const Color(
                              0xFF303955,
                            ),
                    ),
                  ),

                  trailing: selected
                      ? const Icon(
                          Icons.check_circle,
                          color:
                              Color(0xFF2457F5),
                        )
                      : null,

                  onTap: () {
                    Navigator.pop(
                      context,
                      year,
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
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

        const SizedBox(height: 24),

        // ========================================================
        // EDUCATION
        // ========================================================

        _buildSectionHeader(
          icon:
              Icons.school_outlined,

          title:
              'Education & qualifications',

          subtitle:
              'Add your physiotherapy degrees and academic background.',
        ),

        const SizedBox(height: 16),

        if (_qualifications.isEmpty)
          _buildEmptyEducationCard(),

        if (_qualifications.isNotEmpty)
          ...List.generate(
            _qualifications.length,
            (index) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 12,
                ),

                child:
                    _buildQualificationCard(
                  qualification:
                      _qualifications[index],

                  index: index,
                ),
              );
            },
          ),

        const SizedBox(height: 4),

        _buildAddButton(
          icon: Icons.add_circle_outline,
          label: 'Add qualification',

          onTap: () {
            _showQualificationSheet();
          },
        ),

        const SizedBox(height: 30),

        // ========================================================
        // CERTIFICATIONS
        // ========================================================

        _buildSectionHeader(
          icon:
              Icons.workspace_premium_outlined,

          title:
              'Professional certifications',

          subtitle:
              'Add courses, certifications and additional professional training.',
        ),

        const SizedBox(height: 16),

        if (_certifications.isEmpty)
          _buildEmptyCertificationCard(),

        if (_certifications.isNotEmpty)
          ...List.generate(
            _certifications.length,
            (index) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 12,
                ),

                child:
                    _buildCertificationCard(
                  certification:
                      _certifications[index],

                  index: index,
                ),
              );
            },
          ),

        const SizedBox(height: 4),

        _buildAddButton(
          icon:
              Icons.workspace_premium_outlined,

          label:
              'Add certification',

          onTap: () {
            _showCertificationSheet();
          },
        ),

        const SizedBox(height: 30),

        _buildInfoCard(),
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
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF2457F5),
            Color(0xFF5B82FF),
          ],

          begin:
              Alignment.topLeft,

          end:
              Alignment.bottomRight,
        ),

        borderRadius:
            BorderRadius.circular(22),
      ),

      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(.16),

              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: const Icon(
              Icons.school_rounded,
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
                  'Show your expertise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Your qualifications help us verify your professional profile and build patient confidence.',
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
  // SECTION HEADER
  // ==============================================================

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color:
                const Color(0xFFEAF0FF),

            borderRadius:
                BorderRadius.circular(14),
          ),

          child: Icon(
            icon,
            size: 21,
            color:
                const Color(0xFF2457F5),
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
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w900,
                  color:
                      Color(0xFF111A3D),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,

                style: const TextStyle(
                  fontSize: 10,
                  height: 1.45,
                  color:
                      Color(0xFF7B849C),
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // EMPTY EDUCATION
  // ==============================================================

  Widget _buildEmptyEducationCard() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              const Color(0xFFE2E7F0),
        ),
      ),

      child: const Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 32,
            color: Color(0xFF9BA4B8),
          ),

          SizedBox(height: 9),

          Text(
            'No qualifications added yet',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF303955),
            ),
          ),

          SizedBox(height: 4),

          Text(
            'Add at least your primary physiotherapy degree.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color:
                  Color(0xFF7B849C),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // EMPTY CERTIFICATION
  // ==============================================================

  Widget _buildEmptyCertificationCard() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              const Color(0xFFE2E7F0),
        ),
      ),

      child: const Column(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 32,
            color: Color(0xFF9BA4B8),
          ),

          SizedBox(height: 9),

          Text(
            'No additional certifications',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF303955),
            ),
          ),

          SizedBox(height: 4),

          Text(
            'You can add certifications now or later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color:
                  Color(0xFF7B849C),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // QUALIFICATION CARD
  // ==============================================================

  Widget _buildQualificationCard({
    required EducationQualification
        qualification,

    required int index,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              const Color(0xFFE0E6F0),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color:
                  const Color(0xFFEAF0FF),

              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.school_outlined,
              color:
                  Color(0xFF2457F5),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  qualification.degree,

                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF111A3D),
                  ),
                ),

                if (qualification
                    .specialization
                    .isNotEmpty) ...[
                  const SizedBox(height: 3),

                  Text(
                    qualification.specialization,

                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(0xFF2457F5),
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                Text(
                  qualification.institution,

                  style: const TextStyle(
                    fontSize: 10,
                    color:
                        Color(0xFF68738B),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                if (qualification
                    .university
                    .isNotEmpty) ...[
                  const SizedBox(height: 2),

                  Text(
                    qualification.university,

                    style: const TextStyle(
                      fontSize: 9.5,
                      color:
                          Color(0xFF9BA4B8),
                    ),
                  ),
                ],

                const SizedBox(height: 7),

                Text(
                  'Completed ${qualification.passingYear}',

                  style: const TextStyle(
                    fontSize: 9.5,
                    color:
                        Color(0xFF7B849C),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              size: 20,
              color: Color(0xFF7B849C),
            ),

            onSelected: (value) {
              if (value == 'edit') {
                _showQualificationSheet(
                  existing: qualification,
                  editIndex: index,
                );
              }

              if (value == 'delete') {
                setState(() {
                  _qualifications
                      .removeAt(index);
                });

                _notifyChanged();
              }
            },

            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),

              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // CERTIFICATION CARD
  // ==============================================================

  Widget _buildCertificationCard({
    required ProfessionalCertification
        certification,

    required int index,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              const Color(0xFFE0E6F0),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color:
                  const Color(0xFFFFF4E5),

              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.workspace_premium_outlined,
              color:
                  Color(0xFFFF9D28),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  certification.certificateName,

                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF111A3D),
                  ),
                ),

                if (certification
                    .issuingOrganization
                    .isNotEmpty) ...[
                  const SizedBox(height: 4),

                  Text(
                    certification
                        .issuingOrganization,

                    style: const TextStyle(
                      fontSize: 10,
                      color:
                          Color(0xFF68738B),
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                Text(
                  'Completed ${certification.completionYear}',

                  style: const TextStyle(
                    fontSize: 9.5,
                    color:
                        Color(0xFF7B849C),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              size: 20,
              color: Color(0xFF7B849C),
            ),

            onSelected: (value) {
              if (value == 'edit') {
                _showCertificationSheet(
                  existing: certification,
                  editIndex: index,
                );
              }

              if (value == 'delete') {
                setState(() {
                  _certifications
                      .removeAt(index);
                });

                _notifyChanged();
              }
            },

            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),

              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // ADD BUTTON
  // ==============================================================

  Widget _buildAddButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding:
            const EdgeInsets.symmetric(
          vertical: 14,
        ),

        decoration: BoxDecoration(
          color:
              const Color(0xFFEAF0FF),

          borderRadius:
              BorderRadius.circular(16),

          border: Border.all(
            color:
                const Color(0xFFBFD0FF),
          ),
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 19,
              color:
                  const Color(0xFF2457F5),
            ),

            const SizedBox(width: 8),

            Text(
              label,

              style: const TextStyle(
                fontSize: 11.5,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xFF2457F5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // INFO CARD
  // ==============================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color:
            const Color(0xFFFFF8EA),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color:
              const Color(0xFFFFE2A8),
        ),
      ),

      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFFE89A00),
            size: 20,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Your education and qualifications may be reviewed during profile verification. Please provide accurate information.',
              style: TextStyle(
                fontSize: 10,
                height: 1.5,
                color: Color(0xFF7A5B20),
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // SHEET TEXT FIELD
  // ==============================================================

  Widget _buildSheetTextField({
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
            fontWeight:
                FontWeight.w800,
            color:
                Color(0xFF303955),
          ),
        ),

        const SizedBox(height: 7),

        TextField(
          controller: controller,

          style: const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
            color:
                Color(0xFF111A3D),
          ),

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: const TextStyle(
              fontSize: 10.5,
              color:
                  Color(0xFF9BA4B8),
            ),

            prefixIcon: Icon(
              icon,
              size: 20,
              color:
                  const Color(0xFF2457F5),
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
                color:
                    Color(0xFFE2E7F0),
              ),
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),

              borderSide:
                  const BorderSide(
                color:
                    Color(0xFFE2E7F0),
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),

              borderSide:
                  const BorderSide(
                color:
                    Color(0xFF2457F5),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // SHEET DROPDOWN
  // ==============================================================

  Widget _buildSheetDropdown({
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
            fontWeight:
                FontWeight.w800,
            color:
                Color(0xFF303955),
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

          child:
              DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,

              isExpanded: true,

              hint: Text(
                hint,

                style: const TextStyle(
                  fontSize: 10.5,
                  color:
                      Color(0xFF9BA4B8),
                ),
              ),

              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color:
                    Color(0xFF2457F5),
              ),

              items:
                  items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,

                  child: Text(
                    item,

                    style:
                        const TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(0xFF111A3D),
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
}