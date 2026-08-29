import 'package:flutter/material.dart';

class EducationQualification {
  final String id;
  final String qualification;
  final String specialization;
  final String institution;
  final int? completionYear;

  const EducationQualification({
    required this.id,
    required this.qualification,
    required this.specialization,
    required this.institution,
    required this.completionYear,
  });

  EducationQualification copyWith({
    String? id,
    String? qualification,
    String? specialization,
    String? institution,
    int? completionYear,
  }) {
    return EducationQualification(
      id: id ?? this.id,
      qualification: qualification ?? this.qualification,
      specialization: specialization ?? this.specialization,
      institution: institution ?? this.institution,
      completionYear: completionYear ?? this.completionYear,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'qualification': qualification,
      'specialization': specialization,
      'institution': institution,
      'completionYear': completionYear,
    };
  }

  factory EducationQualification.fromMap(
    Map<String, dynamic> map,
  ) {
    return EducationQualification(
      id: map['id']?.toString() ?? '',
      qualification:
          map['qualification']?.toString() ?? '',
      specialization:
          map['specialization']?.toString() ?? '',
      institution:
          map['institution']?.toString() ?? '',
      completionYear: map['completionYear'] is int
          ? map['completionYear'] as int
          : int.tryParse(
              map['completionYear']?.toString() ?? '',
            ),
    );
  }
}

class EducationQualificationStep extends StatelessWidget {
  final List<EducationQualification> qualifications;

  final ValueChanged<List<EducationQualification>>
      onChanged;

  const EducationQualificationStep({
    super.key,
    required this.qualifications,
    required this.onChanged,
  });

  static const List<String> _qualificationOptions = [
    'Bachelor of Physiotherapy (BPT)',
    'Master of Physiotherapy (MPT)',
    'Diploma in Physiotherapy',
    'Doctor of Physical Therapy (DPT)',
    'Certificate Course',
    'Advanced Certification',
    'Fellowship',
    'Other',
  ];

  // ============================================================
  // ADD QUALIFICATION
  // ============================================================

  Future<void> _addQualification(
    BuildContext context,
  ) async {
    final result =
        await showModalBottomSheet<EducationQualification>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _QualificationFormSheet(
          qualificationOptions: _qualificationOptions,
        );
      },
    );

    if (result == null) return;

    final updated =
        List<EducationQualification>.from(
      qualifications,
    );

    updated.add(result);

    onChanged(updated);
  }

  // ============================================================
  // EDIT QUALIFICATION
  // ============================================================

  Future<void> _editQualification(
    BuildContext context,
    int index,
  ) async {
    final result =
        await showModalBottomSheet<EducationQualification>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _QualificationFormSheet(
          qualificationOptions: _qualificationOptions,
          existingQualification: qualifications[index],
        );
      },
    );

    if (result == null) return;

    final updated =
        List<EducationQualification>.from(
      qualifications,
    );

    updated[index] = result;

    onChanged(updated);
  }

  // ============================================================
  // REMOVE QUALIFICATION
  // ============================================================

  void _removeQualification(int index) {
    final updated =
        List<EducationQualification>.from(
      qualifications,
    );

    updated.removeAt(index);

    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // ======================================================
        // HEADER
        // ======================================================

        const Text(
          'Education & qualifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111A3D),
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Add your professional education, degrees and relevant certifications.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF7B849C),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 22),

        // ======================================================
        // INFO
        // ======================================================

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
                Icons.school_outlined,
                size: 22,
                color: Color(0xFF246BFD),
              ),

              SizedBox(width: 11),

              Expanded(
                child: Text(
                  'Add your highest qualification and any additional professional certifications that help verify your expertise.',
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

        const SizedBox(height: 22),

        // ======================================================
        // EMPTY STATE
        // ======================================================

        if (qualifications.isEmpty)
          _EmptyQualifications(
            onAdd: () => _addQualification(context),
          ),

        // ======================================================
        // QUALIFICATIONS
        // ======================================================

        ...qualifications.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final qualification = entry.value;

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: _QualificationCard(
                qualification: qualification,
                index: index,
                onEdit: () =>
                    _editQualification(context, index),
                onDelete: () =>
                    _showDeleteConfirmation(
                  context,
                  index,
                ),
              ),
            );
          },
        ),

        // ======================================================
        // ADD MORE
        // ======================================================

        if (qualifications.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _addQualification(context),
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: const Text(
                'Add another qualification',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(0xFF246BFD),
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                side: const BorderSide(
                  color: Color(0xFF246BFD),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

        const SizedBox(height: 18),

        // ======================================================
        // REQUIREMENT MESSAGE
        // ======================================================

        if (qualifications.isEmpty)
          const Text(
            'Please add at least one professional qualification to continue.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFE5484D),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    int index,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),
          title: const Text(
            'Remove qualification?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF111A3D),
            ),
          ),
          content: const Text(
            'This qualification will be removed from your profile.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
                false,
              ),
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
                true,
              ),
              child: const Text(
                'Remove',
                style: TextStyle(
                  color: Color(0xFFE5484D),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _removeQualification(index);
    }
  }
}

// ================================================================
// EMPTY STATE
// ================================================================

class _EmptyQualifications extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyQualifications({
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3E8F1),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFF246BFD),
              size: 30,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No qualifications added yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF27314D),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Start by adding your primary physiotherapy qualification.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Color(0xFF7B849C),
            ),
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(
              Icons.add_rounded,
            ),
            label: const Text(
              'Add qualification',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF246BFD),
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// QUALIFICATION CARD
// ================================================================

class _QualificationCard extends StatelessWidget {
  final EducationQualification qualification;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QualificationCard({
    required this.qualification,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE1E6EF),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Color(0xFF246BFD),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      qualification.qualification,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF27314D),
                      ),
                    ),

                    if (qualification
                        .specialization.isNotEmpty) ...[
                      const SizedBox(height: 4),

                      Text(
                        qualification.specialization,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF246BFD),
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  }

                  if (value == 'delete') {
                    onDelete();
                  }
                },
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF7B849C),
                ),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Remove',
                      style: TextStyle(
                        color: Color(0xFFE5484D),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(
            color: Color(0xFFF0F2F6),
          ),

          const SizedBox(height: 12),

          _InfoRow(
            icon: Icons.account_balance_rounded,
            text: qualification.institution,
          ),

          if (qualification.completionYear != null) ...[
            const SizedBox(height: 10),

            _InfoRow(
              icon: Icons.calendar_today_outlined,
              text:
                  'Completed in ${qualification.completionYear}',
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: const Color(0xFF8A94A6),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF667085),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// ADD / EDIT QUALIFICATION FORM
// ================================================================

class _QualificationFormSheet extends StatefulWidget {
  final List<String> qualificationOptions;
  final EducationQualification?
      existingQualification;

  const _QualificationFormSheet({
    required this.qualificationOptions,
    this.existingQualification,
  });

  @override
  State<_QualificationFormSheet> createState() =>
      _QualificationFormSheetState();
}

class _QualificationFormSheetState
    extends State<_QualificationFormSheet> {
  late String? _qualification;
  late TextEditingController _specializationController;
  late TextEditingController _institutionController;

  int? _completionYear;

  @override
  void initState() {
    super.initState();

    final existing =
        widget.existingQualification;

    _qualification = existing?.qualification;

    _specializationController =
        TextEditingController(
      text: existing?.specialization ?? '',
    );

    _institutionController =
        TextEditingController(
      text: existing?.institution ?? '',
    );

    _completionYear =
        existing?.completionYear;
  }

  @override
  void dispose() {
    _specializationController.dispose();
    _institutionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        MediaQuery.of(context)
            .viewInsets
            .bottom;

    final currentYear =
        DateTime.now().year;

    final years = List.generate(
      60,
      (index) => currentYear - index,
    );

    return Padding(
      padding: EdgeInsets.only(
        top: 40,
        bottom: bottomPadding,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              22,
              18,
              22,
              28,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFD9DEE8),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  widget.existingQualification == null
                      ? 'Add qualification'
                      : 'Edit qualification',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111A3D),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Qualification *',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF27314D),
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _qualification,
                  isExpanded: true,
                  decoration: _decoration(
                    Icons.school_outlined,
                  ),
                  hint: const Text(
                    'Select qualification',
                  ),
                  items: widget.qualificationOptions
                      .map(
                        (item) =>
                            DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _qualification = value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                const Text(
                  'Specialization',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF27314D),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller:
                      _specializationController,
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: _decoration(
                    Icons.psychology_outlined,
                  ).copyWith(
                    hintText:
                        'Example: Orthopedic Physiotherapy',
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Institution / University *',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF27314D),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller:
                      _institutionController,
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: _decoration(
                    Icons.account_balance_outlined,
                  ).copyWith(
                    hintText:
                        'Enter institution name',
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Year of completion *',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF27314D),
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<int>(
                  value: _completionYear,
                  decoration: _decoration(
                    Icons.calendar_today_outlined,
                  ),
                  hint: const Text(
                    'Select year',
                  ),
                  items: years
                      .map(
                        (year) =>
                            DropdownMenuItem(
                          value: year,
                          child: Text('$year'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _completionYear = value;
                    });
                  },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF246BFD),
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
                            BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      widget.existingQualification ==
                              null
                          ? 'Add qualification'
                          : 'Save changes',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
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

  InputDecoration _decoration(
    IconData icon,
  ) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF667085),
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFC),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE1E6EF),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE1E6EF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFF246BFD),
          width: 1.5,
        ),
      ),
    );
  }

  void _save() {
    final qualification =
        _qualification?.trim() ?? '';

    final institution =
        _institutionController.text.trim();

    if (qualification.isEmpty) {
      _showError(
        'Please select your qualification.',
      );
      return;
    }

    if (institution.isEmpty) {
      _showError(
        'Please enter your institution name.',
      );
      return;
    }

    if (_completionYear == null) {
      _showError(
        'Please select the completion year.',
      );
      return;
    }

    final result = EducationQualification(
      id: widget.existingQualification?.id ??
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      qualification: qualification,
      specialization:
          _specializationController.text.trim(),
      institution: institution,
      completionYear: _completionYear,
    );

    Navigator.pop(context, result);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}