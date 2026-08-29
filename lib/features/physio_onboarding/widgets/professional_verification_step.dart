import 'package:flutter/material.dart';

class ProfessionalVerificationStep extends StatefulWidget {
  final String registrationNumber;
  final String registrationCouncil;
  final String registrationState;

  final bool registrationCertificateUploaded;
  final bool degreeCertificateUploaded;
  final bool identityDocumentUploaded;

  final ValueChanged<String> onRegistrationNumberChanged;
  final ValueChanged<String> onRegistrationCouncilChanged;
  final ValueChanged<String> onRegistrationStateChanged;

  final ValueChanged<bool> onRegistrationCertificateChanged;
  final ValueChanged<bool> onDegreeCertificateChanged;
  final ValueChanged<bool> onIdentityDocumentChanged;

  const ProfessionalVerificationStep({
    super.key,
    required this.registrationNumber,
    required this.registrationCouncil,
    required this.registrationState,
    required this.registrationCertificateUploaded,
    required this.degreeCertificateUploaded,
    required this.identityDocumentUploaded,
    required this.onRegistrationNumberChanged,
    required this.onRegistrationCouncilChanged,
    required this.onRegistrationStateChanged,
    required this.onRegistrationCertificateChanged,
    required this.onDegreeCertificateChanged,
    required this.onIdentityDocumentChanged,
  });

  @override
  State<ProfessionalVerificationStep> createState() =>
      _ProfessionalVerificationStepState();
}

class _ProfessionalVerificationStepState
    extends State<ProfessionalVerificationStep> {
  late TextEditingController _registrationNumberController;
  late TextEditingController _councilController;
  late TextEditingController _stateController;

  @override
  void initState() {
    super.initState();

    _registrationNumberController = TextEditingController(
      text: widget.registrationNumber,
    );

    _councilController = TextEditingController(
      text: widget.registrationCouncil,
    );

    _stateController = TextEditingController(
      text: widget.registrationState,
    );
  }

  @override
  void didUpdateWidget(
    covariant ProfessionalVerificationStep oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.registrationNumber != widget.registrationNumber &&
        _registrationNumberController.text !=
            widget.registrationNumber) {
      _registrationNumberController.text =
          widget.registrationNumber;
    }

    if (oldWidget.registrationCouncil !=
            widget.registrationCouncil &&
        _councilController.text !=
            widget.registrationCouncil) {
      _councilController.text =
          widget.registrationCouncil;
    }

    if (oldWidget.registrationState != widget.registrationState &&
        _stateController.text != widget.registrationState) {
      _stateController.text =
          widget.registrationState;
    }
  }

  @override
  void dispose() {
    _registrationNumberController.dispose();
    _councilController.dispose();
    _stateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================================================
        // HEADER
        // ======================================================

        const Text(
          'Professional verification',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111A3D),
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Provide your professional registration details and required documents for verification.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF7B849C),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 22),

        // ======================================================
        // SECURITY INFO
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.shield_outlined,
                color: Color(0xFF246BFD),
                size: 22,
              ),

              SizedBox(width: 11),

              Expanded(
                child: Text(
                  'Your documents are used only for professional verification and are not publicly displayed on your patient profile.',
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

        const SizedBox(height: 26),

        // ======================================================
        // REGISTRATION DETAILS
        // ======================================================

        const _SectionTitle(
          title: 'Professional registration',
          subtitle:
              'Enter your official professional registration details.',
        ),

        const SizedBox(height: 18),

        const _FieldLabel(
          title: 'Registration number',
          requiredField: true,
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _registrationNumberController,
          textCapitalization: TextCapitalization.characters,
          onChanged: widget.onRegistrationNumberChanged,
          decoration: _inputDecoration(
            hintText: 'Enter registration number',
            icon: Icons.badge_outlined,
          ),
        ),

        const SizedBox(height: 18),

        const _FieldLabel(
          title: 'Registration council / authority',
          requiredField: true,
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _councilController,
          textCapitalization: TextCapitalization.words,
          onChanged: widget.onRegistrationCouncilChanged,
          decoration: _inputDecoration(
            hintText: 'Example: State Physiotherapy Council',
            icon: Icons.account_balance_outlined,
          ),
        ),

        const SizedBox(height: 18),

        const _FieldLabel(
          title: 'Registration state',
          requiredField: true,
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _stateController,
          textCapitalization: TextCapitalization.words,
          onChanged: widget.onRegistrationStateChanged,
          decoration: _inputDecoration(
            hintText: 'Example: Maharashtra',
            icon: Icons.location_on_outlined,
          ),
        ),

        const SizedBox(height: 30),

        // ======================================================
        // DOCUMENTS
        // ======================================================

        const _SectionTitle(
          title: 'Verification documents',
          subtitle:
              'Upload clear and valid copies of the following documents.',
        ),

        const SizedBox(height: 18),

        _DocumentUploadCard(
          title: 'Professional registration certificate',
          subtitle:
              'Certificate issued by your registration authority',
          icon: Icons.verified_outlined,
          isRequired: true,
          isUploaded: widget.registrationCertificateUploaded,
          onTap: () {
            widget.onRegistrationCertificateChanged(
              !widget.registrationCertificateUploaded,
            );
          },
        ),

        const SizedBox(height: 12),

        _DocumentUploadCard(
          title: 'Degree / qualification certificate',
          subtitle:
              'Your primary physiotherapy degree certificate',
          icon: Icons.school_outlined,
          isRequired: true,
          isUploaded: widget.degreeCertificateUploaded,
          onTap: () {
            widget.onDegreeCertificateChanged(
              !widget.degreeCertificateUploaded,
            );
          },
        ),

        const SizedBox(height: 12),

        _DocumentUploadCard(
          title: 'Government identity document',
          subtitle:
              'Used only for identity verification',
          icon: Icons.perm_identity_outlined,
          isRequired: true,
          isUploaded: widget.identityDocumentUploaded,
          onTap: () {
            widget.onIdentityDocumentChanged(
              !widget.identityDocumentUploaded,
            );
          },
        ),

        const SizedBox(height: 24),

        // ======================================================
        // DOCUMENT REQUIREMENTS
        // ======================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFFFE3AB),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFE59A00),
                    size: 21,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Document requirements',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF805B00),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              _RequirementItem(
                text: 'Document should be clear and readable',
              ),

              _RequirementItem(
                text: 'All information must be valid and accurate',
              ),

              _RequirementItem(
                text: 'Expired or invalid documents may be rejected',
              ),

              _RequirementItem(
                text:
                    'Your profile may remain pending until verification is completed',
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // CURRENT STATUS
        // ======================================================

        _VerificationStatus(
          registrationUploaded:
              widget.registrationCertificateUploaded,
          degreeUploaded:
              widget.degreeCertificateUploaded,
          identityUploaded:
              widget.identityDocumentUploaded,
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFF9AA3B5),
        fontWeight: FontWeight.w500,
      ),

      prefixIcon: Icon(
        icon,
        color: const Color(0xFF667085),
      ),

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE1E6EF),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE1E6EF),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF246BFD),
          width: 1.5,
        ),
      ),
    );
  }
}

// ================================================================
// SECTION TITLE
// ================================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111A3D),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            height: 1.4,
            color: Color(0xFF7B849C),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// FIELD LABEL
// ================================================================

class _FieldLabel extends StatelessWidget {
  final String title;
  final bool requiredField;

  const _FieldLabel({
    required this.title,
    required this.requiredField,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF27314D),
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
// DOCUMENT UPLOAD CARD
// ================================================================

class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isRequired;
  final bool isUploaded;
  final VoidCallback onTap;

  const _DocumentUploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isRequired,
    required this.isUploaded,
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isUploaded
                ? const Color(0xFFF0FFF7)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUploaded
                  ? const Color(0xFF3CCB7F)
                  : const Color(0xFFE2E7EF),
              width: isUploaded ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isUploaded
                      ? const Color(0xFFDDF8EA)
                      : const Color(0xFFF3F6FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isUploaded
                      ? Icons.check_circle_rounded
                      : icon,
                  color: isUploaded
                      ? const Color(0xFF22A864)
                      : const Color(0xFF59637A),
                  size: 24,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF27314D),
                            ),
                          ),
                        ),

                        if (isRequired)
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Color(0xFFE5484D),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: Color(0xFF7B849C),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                children: [
                  Icon(
                    isUploaded
                        ? Icons.check_circle_rounded
                        : Icons.upload_file_rounded,
                    color: isUploaded
                        ? const Color(0xFF22A864)
                        : const Color(0xFF246BFD),
                    size: 23,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    isUploaded
                        ? 'Added'
                        : 'Upload',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isUploaded
                          ? const Color(0xFF22A864)
                          : const Color(0xFF246BFD),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// REQUIREMENT ITEM
// ================================================================

class _RequirementItem extends StatelessWidget {
  final String text;

  const _RequirementItem({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 15,
              color: Color(0xFFE59A00),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.4,
                color: Color(0xFF805B00),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// VERIFICATION STATUS
// ================================================================

class _VerificationStatus extends StatelessWidget {
  final bool registrationUploaded;
  final bool degreeUploaded;
  final bool identityUploaded;

  const _VerificationStatus({
    required this.registrationUploaded,
    required this.degreeUploaded,
    required this.identityUploaded,
  });

  @override
  Widget build(BuildContext context) {
    final completed = [
      registrationUploaded,
      degreeUploaded,
      identityUploaded,
    ].where((value) => value).length;

    final isComplete = completed == 3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isComplete
            ? const Color(0xFFF0FFF7)
            : const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isComplete
              ? const Color(0xFFB9EDCF)
              : const Color(0xFFE3E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isComplete
                  ? const Color(0xFFDDF8EA)
                  : const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isComplete
                  ? Icons.verified_rounded
                  : Icons.pending_actions_rounded,
              color: isComplete
                  ? const Color(0xFF22A864)
                  : const Color(0xFF246BFD),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  isComplete
                      ? 'Documents ready for verification'
                      : '$completed of 3 documents added',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF27314D),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  isComplete
                      ? 'Your documents will be reviewed after profile submission.'
                      : 'Add all required documents to complete verification.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: Color(0xFF7B849C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}