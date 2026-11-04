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
    extends State<ProfessionalVerificationStep>
    with SingleTickerProviderStateMixin {
  static const _ink = Color(0xFF142F35);
  static const _muted = Color(0xFF71858A);
  static const _teal = Color(0xFF087F78);
  static const _line = Color(0xFFE5ECEE);

  late final TextEditingController _registrationNumberController;
  late final TextEditingController _councilController;
  late final TextEditingController _stateController;
  late final AnimationController _introController;

  @override
  void initState() {
    super.initState();
    _registrationNumberController =
        TextEditingController(text: widget.registrationNumber);
    _councilController =
        TextEditingController(text: widget.registrationCouncil);
    _stateController = TextEditingController(text: widget.registrationState);
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant ProfessionalVerificationStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.registrationNumber != widget.registrationNumber &&
        _registrationNumberController.text != widget.registrationNumber) {
      _registrationNumberController.value = TextEditingValue(
        text: widget.registrationNumber,
        selection:
            TextSelection.collapsed(offset: widget.registrationNumber.length),
      );
    }
    if (oldWidget.registrationCouncil != widget.registrationCouncil &&
        _councilController.text != widget.registrationCouncil) {
      _councilController.value = TextEditingValue(
        text: widget.registrationCouncil,
        selection:
            TextSelection.collapsed(offset: widget.registrationCouncil.length),
      );
    }
    if (oldWidget.registrationState != widget.registrationState &&
        _stateController.text != widget.registrationState) {
      _stateController.value = TextEditingValue(
        text: widget.registrationState,
        selection:
            TextSelection.collapsed(offset: widget.registrationState.length),
      );
    }
  }

  @override
  void dispose() {
    _registrationNumberController.dispose();
    _councilController.dispose();
    _stateController.dispose();
    _introController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFFA2B1B4),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF73918F), size: 19),
      filled: true,
      fillColor: const Color(0xFFF8FAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _teal, width: 1.5),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Color(0xFFE05252),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            onChanged: onChanged,
            textCapitalization: label == 'Registration number'
                ? TextCapitalization.characters
                : TextCapitalization.words,
            style: const TextStyle(
              color: _ink,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: _inputDecoration(hintText: hint, icon: icon),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String number,
    required String title,
    required String subtitle,
    required Widget child,
    required double start,
  }) {
    final end = (start + .48).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _introController,
      builder: (context, _) {
        final progress = Curves.easeOutCubic.transform(
          ((_introController.value - start) / (end - start)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - progress)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: _line),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF183A3E).withOpacity(.045),
                    blurRadius: 24,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF5F3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          number,
                          style: const TextStyle(
                            color: _teal,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: _ink,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 11,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _documentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isUploaded,
    required VoidCallback onTap,
    required int index,
  }) {
    final accent = isUploaded ? const Color(0xFF16875E) : _teal;
    return TweenAnimationBuilder<double>(
      key: ValueKey('$title-$isUploaded'),
      tween: Tween(begin: .985, end: 1),
      duration: Duration(milliseconds: 260 + index * 70),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUploaded
                  ? const Color(0xFFF0FAF5)
                  : const Color(0xFFFCFDFD),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isUploaded
                    ? const Color(0xFFB8E5D0)
                    : const Color(0xFFE6ECEE),
                width: isUploaded ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  width: 47,
                  height: 47,
                  decoration: BoxDecoration(
                    color: isUploaded
                        ? const Color(0xFFDDF4E8)
                        : const Color(0xFFEAF3F3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isUploaded ? Icons.check_rounded : icon,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 12.5,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 10.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isUploaded ? const Color(0xFFDDF4E8) : Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: isUploaded
                          ? const Color(0xFFB8E5D0)
                          : const Color(0xFFDCE8E7),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUploaded
                            ? Icons.check_circle_rounded
                            : Icons.add_rounded,
                        color: accent,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isUploaded ? 'Added' : 'Add',
                        style: TextStyle(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _requirements() {
    const items = [
      'Make sure every document is clear and readable.',
      'All details must be valid and accurate.',
      'Expired or invalid documents may be rejected.',
      'Your profile may remain pending until verification is completed.',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9ED),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFF3E5C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  color: Color(0xFFB77C23), size: 19),
              SizedBox(width: 8),
              Text(
                'Before you submit',
                style: TextStyle(
                  color: Color(0xFF805B28),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_rounded,
                      color: Color(0xFFB77C23),
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF80633D),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusSummary() {
    final completed = [
      widget.registrationCertificateUploaded,
      widget.degreeCertificateUploaded,
      widget.identityDocumentUploaded,
    ].where((value) => value).length;
    final complete = completed == 3;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: complete
              ? const [Color(0xFFEBF9F1), Color(0xFFF5FCF8)]
              : const [Color(0xFFEDF7F6), Color(0xFFF8FBFB)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: complete
              ? const Color(0xFFBFE8D0)
              : const Color(0xFFDCEBE8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: complete
                      ? const Color(0xFFD7F1E2)
                      : const Color(0xFFDDF0ED),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  complete
                      ? Icons.verified_rounded
                      : Icons.pending_actions_rounded,
                  color: complete ? const Color(0xFF16875E) : _teal,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      complete
                          ? 'All documents added'
                          : '$completed of 3 documents added',
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      complete
                          ? 'Ready for review after profile submission'
                          : 'Complete the remaining items to continue',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(completed / 3 * 100).round()}%',
                style: TextStyle(
                  color: complete ? const Color(0xFF16875E) : _teal,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: completed / 3),
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: const Color(0xFFDCEAE6),
                valueColor: AlwaysStoppedAnimation<Color>(
                  complete ? const Color(0xFF20A36B) : _teal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(19, 20, 19, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEAF6F4), Color(0xFFF6FAFA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFDCECE9)),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -8,
                top: -15,
                child: Icon(
                  Icons.verified_user_rounded,
                  size: 105,
                  color: _teal.withOpacity(.065),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.85),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            color: _teal, size: 13),
                        SizedBox(width: 5),
                        Text(
                          'SECURE PROFESSIONAL CHECK',
                          style: TextStyle(
                            color: _teal,
                            fontSize: 9,
                            letterSpacing: .9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    'Verify your\nprofessional identity',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 25,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Share your registration details and supporting documents to build trust with patients.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.78),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFE1EFEB)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_moon_outlined,
                            color: _teal, size: 19),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Your documents are used only for professional verification and are not publicly displayed on your patient profile.',
                            style: TextStyle(
                              color: Color(0xFF58716D),
                              fontSize: 10.5,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        _section(
          number: '01',
          title: 'Registration credentials',
          subtitle: 'Enter the details exactly as shown on your registration',
          start: 0,
          child: Column(
            children: [
              _field(
                label: 'Registration number',
                controller: _registrationNumberController,
                hint: 'Enter your official registration number',
                icon: Icons.badge_outlined,
                onChanged: widget.onRegistrationNumberChanged,
              ),
              _field(
                label: 'Registration council / authority',
                controller: _councilController,
                hint: 'Example: State Physiotherapy Council',
                icon: Icons.account_balance_outlined,
                onChanged: widget.onRegistrationCouncilChanged,
              ),
              _field(
                label: 'Registration state',
                controller: _stateController,
                hint: 'Example: Maharashtra',
                icon: Icons.location_on_outlined,
                onChanged: widget.onRegistrationStateChanged,
              ),
            ],
          ),
        ),
        _section(
          number: '02',
          title: 'Required documents',
          subtitle: 'Add clear copies of all three verification documents',
          start: .15,
          child: Column(
            children: [
              _documentCard(
                title: 'Professional registration certificate',
                subtitle: 'Issued by your registration authority',
                icon: Icons.workspace_premium_outlined,
                isUploaded: widget.registrationCertificateUploaded,
                index: 0,
                onTap: () => widget.onRegistrationCertificateChanged(
                  !widget.registrationCertificateUploaded,
                ),
              ),
              const SizedBox(height: 10),
              _documentCard(
                title: 'Degree / qualification certificate',
                subtitle: 'Your primary physiotherapy degree certificate',
                icon: Icons.school_outlined,
                isUploaded: widget.degreeCertificateUploaded,
                index: 1,
                onTap: () => widget.onDegreeCertificateChanged(
                  !widget.degreeCertificateUploaded,
                ),
              ),
              const SizedBox(height: 10),
              _documentCard(
                title: 'Government identity document',
                subtitle: 'For identity verification only',
                icon: Icons.contact_page_outlined,
                isUploaded: widget.identityDocumentUploaded,
                index: 2,
                onTap: () => widget.onIdentityDocumentChanged(
                  !widget.identityDocumentUploaded,
                ),
              ),
            ],
          ),
        ),
        _section(
          number: '03',
          title: 'Verification checklist',
          subtitle: 'A few quick checks before submitting your profile',
          start: .3,
          child: _requirements(),
        ),
        const SizedBox(height: 2),
        _statusSummary(),
        const SizedBox(height: 12),
      ],
    );
  }
}
