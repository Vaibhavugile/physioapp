import 'package:flutter/material.dart';

class ReviewSubmitStep extends StatefulWidget {
  // ==============================================================
  // PERSONAL DETAILS
  // ==============================================================

  final String fullName;
  final String phone;
  final String email;
  final String? profileImageUrl;

  // ==============================================================
  // PROFESSIONAL DETAILS
  // ==============================================================

  final String professionalTitle;
  final String registrationNumber;
  final String primarySpecialization;
  final int yearsOfExperience;

  // ==============================================================
  // QUALIFICATIONS
  // ==============================================================

  final List<String> qualifications;

  // ==============================================================
  // SPECIALIZATIONS
  // ==============================================================

  final List<String> specializations;

  // ==============================================================
  // SERVICES
  // ==============================================================

  final List<String> services;

  // ==============================================================
  // LOCATION
  // ==============================================================

  final String clinicName;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String locality;
  final int homeVisitRadiusKm;
  final String pricingTierLabel;

  // ==============================================================
  // AVAILABILITY
  // ==============================================================

  final List<String> workingDays;

  final String startTime;
  final String endTime;
  final Map<String, dynamic> serviceSchedules;

  // ==============================================================
  // PRICING
  // ==============================================================

  final String currency;

  final double homeVisitFee;
  final double clinicVisitFee;
  final double onlineConsultationFee;
  final double followUpFee;

  final bool travelChargesEnabled;
  final double travelCharges;

  final bool discountAvailable;
  final double discountPercentage;

  // ==============================================================
  // VERIFICATION
  // ==============================================================

  final bool identityDocumentUploaded;
  final bool registrationDocumentUploaded;
  final bool qualificationDocumentUploaded;

  // ==============================================================
  // TERMS
  // ==============================================================

  final bool termsAccepted;

  final ValueChanged<bool> onTermsChanged;

  // ==============================================================
  // EDIT ACTIONS
  // ==============================================================

  final VoidCallback? onEditPersonal;
  final VoidCallback? onEditProfessional;
  final VoidCallback? onEditQualifications;
  final VoidCallback? onEditSpecializations;
  final VoidCallback? onEditLocation;
  final VoidCallback? onEditAvailability;
  final VoidCallback? onEditPricing;
  final VoidCallback? onEditVerification;

  const ReviewSubmitStep({
    super.key,

    required this.fullName,
    required this.phone,
    required this.email,
    this.profileImageUrl,

    required this.professionalTitle,
    required this.registrationNumber,
    required this.primarySpecialization,
    required this.yearsOfExperience,

    required this.qualifications,
    required this.specializations,
    required this.services,

    required this.clinicName,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.locality = '',
    this.homeVisitRadiusKm = 0,
    this.pricingTierLabel = '',

    required this.workingDays,
    required this.startTime,
    required this.endTime,
    this.serviceSchedules = const {},

    required this.currency,

    required this.homeVisitFee,
    required this.clinicVisitFee,
    required this.onlineConsultationFee,
    required this.followUpFee,

    required this.travelChargesEnabled,
    required this.travelCharges,

    required this.discountAvailable,
    required this.discountPercentage,

    required this.identityDocumentUploaded,
    required this.registrationDocumentUploaded,
    required this.qualificationDocumentUploaded,

    required this.termsAccepted,
    required this.onTermsChanged,

    this.onEditPersonal,
    this.onEditProfessional,
    this.onEditQualifications,
    this.onEditSpecializations,
    this.onEditLocation,
    this.onEditAvailability,
    this.onEditPricing,
    this.onEditVerification,
  });

  @override
  State<ReviewSubmitStep> createState() =>
      _ReviewSubmitStepState();
}

class _ReviewSubmitStepState
    extends State<ReviewSubmitStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reviewAnimationController;

  @override
  void initState() {
    super.initState();
    _reviewAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _reviewAnimationController.dispose();
    super.dispose();
  }

  String get _currencySymbol {
    switch (widget.currency) {
      case 'USD':
        return '\$';

      case 'AED':
        return 'AED';

      case 'INR':
      default:
        return '₹';
    }
  }

  String _formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  String get _fullAddress {
    final parts = <String>[
      if (widget.address.trim().isNotEmpty)
        widget.address.trim(),

      if (widget.city.trim().isNotEmpty)
        widget.city.trim(),

      if (widget.state.trim().isNotEmpty)
        widget.state.trim(),

      if (widget.pincode.trim().isNotEmpty)
        widget.pincode.trim(),
    ];

    return parts.join(', ');
  }

  bool get _allDocumentsUploaded {
    return widget.identityDocumentUploaded &&
        widget.registrationDocumentUploaded &&
        widget.qualificationDocumentUploaded;
  }

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[];

    Widget animatedSection({
      required int index,
      required String title,
      required IconData icon,
      required VoidCallback? onEdit,
      required Widget child,
    }) {
      final begin = (index * .075).clamp(0.0, .72);
      final finish = (begin + .32).clamp(0.0, 1.0);
      return AnimatedBuilder(
        animation: _reviewAnimationController,
        builder: (context, _) {
          final value = Curves.easeOutCubic.transform(
            ((_reviewAnimationController.value - begin) /
                    (finish - begin))
                .clamp(0.0, 1.0),
          );
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - value)),
              child: _ReviewSection(
                title: title,
                icon: icon,
                onEdit: onEdit,
                child: child,
              ),
            ),
          );
        },
      );
    }

    sections.add(animatedSection(
      index: 0,
      title: 'Personal information',
      icon: Icons.person_outline_rounded,
      onEdit: widget.onEditPersonal,
      child: Column(
        children: [
          Row(
            children: [
              _ProfileAvatar(
                fullName: widget.fullName,
                profileImageUrl: widget.profileImageUrl,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fullName.isEmpty ? 'Not provided' : widget.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF17363A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.professionalTitle.isEmpty
                          ? 'Physiotherapist'
                          : widget.professionalTitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF71858A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: widget.phone.isEmpty ? 'Not provided' : widget.phone,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: widget.email.isEmpty ? 'Not provided' : widget.email,
          ),
        ],
      ),
    ));

    sections.add(animatedSection(
      index: 1,
      title: 'Professional details',
      icon: Icons.medical_information_outlined,
      onEdit: widget.onEditProfessional,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Professional title',
            value: widget.professionalTitle.isEmpty
                ? 'Not provided'
                : widget.professionalTitle,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.verified_user_outlined,
            label: 'Registration number',
            value: widget.registrationNumber.isEmpty
                ? 'Not provided'
                : widget.registrationNumber,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.workspace_premium_outlined,
            label: 'Primary specialization',
            value: widget.primarySpecialization.isEmpty
                ? 'Not provided'
                : widget.primarySpecialization,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.timeline_rounded,
            label: 'Experience',
            value: '${widget.yearsOfExperience} years',
          ),
        ],
      ),
    ));

    sections.add(animatedSection(
      index: 2,
      title: 'Qualifications',
      icon: Icons.school_outlined,
      onEdit: widget.onEditQualifications,
      child: _TagList(
        items: widget.qualifications,
        emptyText: 'No qualifications added yet',
      ),
    ));

    sections.add(animatedSection(
      index: 3,
      title: 'Specializations & services',
      icon: Icons.health_and_safety_outlined,
      onEdit: widget.onEditSpecializations,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MiniLabel('SPECIALIZATIONS'),
          const SizedBox(height: 9),
          _TagList(
            items: widget.specializations,
            emptyText: 'No specializations selected',
          ),
          const SizedBox(height: 17),
          const _MiniLabel('SERVICES OFFERED'),
          const SizedBox(height: 9),
          _TagList(
            items: widget.services,
            emptyText: 'No services selected',
          ),
        ],
      ),
    ));

    sections.add(animatedSection(
      index: 4,
      title: 'Practice location',
      icon: Icons.location_on_outlined,
      onEdit: widget.onEditLocation,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.business_outlined,
            label: 'Clinic / practice',
            value: widget.clinicName.isEmpty
                ? 'Home visit practice'
                : widget.clinicName,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: _fullAddress.isEmpty ? 'Not provided' : _fullAddress,
          ),
          if (widget.locality.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.location_city_outlined,
              label: 'Service locality',
              value: widget.locality,
            ),
          ],
          if (widget.homeVisitRadiusKm > 0) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.radar_rounded,
              label: 'Home-visit radius',
              value: '${widget.homeVisitRadiusKm} km',
            ),
          ],
        ],
      ),
    ));

    final activeScheduleKeys = ['home', 'clinic', 'online'].where((key) {
      final item = widget.serviceSchedules[key];
      if (item is Map) return item['enabled'] == true;
      return widget.services.any((service) =>
          (key == 'home' && service == 'Home Visit') ||
          (key == 'clinic' && service == 'Clinic Visit') ||
          (key == 'online' && service == 'Online Consultation'));
    }).toList();

    sections.add(animatedSection(
      index: 5,
      title: 'Availability',
      icon: Icons.calendar_month_outlined,
      onEdit: widget.onEditAvailability,
      child: activeScheduleKeys.isEmpty
          ? const Text(
              'No active service schedule provided.',
              style: TextStyle(color: Color(0xFF87999C), fontSize: 12),
            )
          : Column(
              children: activeScheduleKeys.map((key) {
                final raw = widget.serviceSchedules[key];
                final schedule = raw is Map
                    ? Map<String, dynamic>.from(raw)
                    : <String, dynamic>{};
                final days = List<String>.from(
                  schedule['days'] ?? widget.workingDays,
                );
                final flexible = schedule['flexible'] == true;
                final title = key == 'home'
                    ? 'Home visits'
                    : key == 'clinic'
                        ? 'Clinic visits'
                        : 'Online consultations';
                final hours = flexible
                    ? 'Flexible / anytime'
                    : '${schedule['startTime'] ?? widget.startTime} – ${schedule['endTime'] ?? widget.endTime}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _InfoRow(
                    icon: key == 'home'
                        ? Icons.home_work_outlined
                        : key == 'clinic'
                            ? Icons.local_hospital_outlined
                            : Icons.video_call_outlined,
                    label: title,
                    value: '$hours · ${days.join(', ')}',
                  ),
                );
              }).toList(),
            ),
    ));

    sections.add(animatedSection(
      index: 6,
      title: 'Assigned pricing',
      icon: Icons.currency_rupee_rounded,
      onEdit: widget.onEditPricing,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your rates are determined by your registered locality and experience tier. Pricing is managed by the platform.',
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: Color(0xFF77898D),
            ),
          ),
          if (widget.pricingTierLabel.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5F3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'ASSIGNED TIER  ·  ${widget.pricingTierLabel}',
                style: const TextStyle(
                  fontSize: 9.5,
                  letterSpacing: .45,
                  color: Color(0xFF087F78),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
          const SizedBox(height: 15),
          _PriceRow(
            title: 'Home visit',
            value: '$_currencySymbol ${_formatPrice(widget.homeVisitFee)}',
          ),
          const SizedBox(height: 12),
          _PriceRow(
            title: 'Clinic appointment',
            value: '$_currencySymbol ${_formatPrice(widget.clinicVisitFee)}',
          ),
          const SizedBox(height: 12),
          _PriceRow(
            title: 'Online consultation',
            value:
                '$_currencySymbol ${_formatPrice(widget.onlineConsultationFee)}',
          ),
          const SizedBox(height: 12),
          _PriceRow(
            title: 'Follow-up session',
            value: '$_currencySymbol ${_formatPrice(widget.followUpFee)}',
          ),
          if (widget.travelChargesEnabled) ...[
            const SizedBox(height: 12),
            _PriceRow(
              title: 'Travel charge',
              value: '$_currencySymbol ${_formatPrice(widget.travelCharges)}',
            ),
          ],
          if (widget.discountAvailable) ...[
            const SizedBox(height: 12),
            _PriceRow(
              title: 'Discount',
              value: '${widget.discountPercentage.toStringAsFixed(0)}%',
              valueColor: const Color(0xFF16875E),
            ),
          ],
        ],
      ),
    ));

    sections.add(animatedSection(
      index: 7,
      title: 'Verification documents',
      icon: Icons.verified_user_outlined,
      onEdit: widget.onEditVerification,
      child: Column(
        children: [
          _DocumentStatusRow(
            title: 'Identity document',
            uploaded: widget.identityDocumentUploaded,
          ),
          const SizedBox(height: 12),
          _DocumentStatusRow(
            title: 'Professional registration',
            uploaded: widget.registrationDocumentUploaded,
          ),
          const SizedBox(height: 12),
          _DocumentStatusRow(
            title: 'Qualification certificate',
            uploaded: widget.qualificationDocumentUploaded,
          ),
        ],
      ),
    ));

    final finalRequirements = [
      _allDocumentsUploaded,
      widget.termsAccepted,
    ].where((value) => value).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(19, 20, 19, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEAF6F4), Color(0xFFF7FAFA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFDCEBE8)),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -7,
                top: -14,
                child: Icon(
                  Icons.fact_check_rounded,
                  size: 100,
                  color: const Color(0xFF087F78).withOpacity(.065),
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
                        Icon(Icons.auto_awesome_rounded,
                            color: Color(0xFF087F78), size: 13),
                        SizedBox(width: 5),
                        Text(
                          'FINAL PROFILE CHECK',
                          style: TextStyle(
                            color: Color(0xFF087F78),
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
                    'Your profile,\none final look.',
                    style: TextStyle(
                      color: Color(0xFF17363A),
                      fontSize: 26,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Review every detail, make any final edits, and confirm your information before sending it for verification.',
                    style: TextStyle(
                      color: Color(0xFF71858A),
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _HeaderMetric(
                        value: '08',
                        label: 'PROFILE AREAS',
                      ),
                      const SizedBox(width: 9),
                      _HeaderMetric(
                        value: '$finalRequirements/2',
                        label: 'FINAL CHECKS',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ProfileCompletionCard(
          documentsCompleted: _allDocumentsUploaded,
          termsAccepted: widget.termsAccepted,
        ),
        const SizedBox(height: 20),
        const _ReviewGroupHeading(
          eyebrow: 'YOUR INFORMATION',
          title: 'Profile overview',
          subtitle: 'Check the details patients and our team will review.',
        ),
        const SizedBox(height: 13),
        ...sections,
        const SizedBox(height: 3),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF7F5),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFD8EAE6)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded,
                  color: Color(0xFF087F78), size: 19),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'After submission, your professional profile will be reviewed by our team. You may be asked to provide additional information before approval.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: Color(0xFF526F6B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.termsAccepted
                ? const Color(0xFFF0FAF5)
                : Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: widget.termsAccepted
                  ? const Color(0xFFBFE6D0)
                  : const Color(0xFFE3ECEB),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF17363A).withOpacity(.035),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => widget.onTermsChanged(!widget.termsAccepted),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: widget.termsAccepted,
                  activeColor: const Color(0xFF087F78),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onChanged: (value) =>
                      widget.onTermsChanged(value ?? false),
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'I confirm that the information provided is accurate and I agree to the platform terms, professional guidelines and verification process.',
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.5,
                        color: Color(0xFF526B6D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 13),
        if (!_allDocumentsUploaded)
          const _WarningCard(
            message:
                'Please upload all required verification documents before submitting your profile.',
          ),
        if (!widget.termsAccepted) ...[
          if (!_allDocumentsUploaded) const SizedBox(height: 10),
          const _WarningCard(
            message:
                'Please accept the terms and confirmation before submitting your profile.',
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}

// ================================================================
// PROFILE COMPLETION CARD
// ================================================================

class _ProfileCompletionCard extends StatelessWidget {
  final bool documentsCompleted;
  final bool termsAccepted;

  const _ProfileCompletionCard({
    required this.documentsCompleted,
    required this.termsAccepted,
  });

  @override
  Widget build(BuildContext context) {
    final completedItems = [documentsCompleted, termsAccepted]
        .where((item) => item)
        .length;
    final progress = completedItems / 2;
    final ready = completedItems == 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF087A73), Color(0xFF0D9A89)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF087F78).withOpacity(.17),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ready ? 'You are ready to submit' : 'Final steps remaining',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Complete both checks to finish your profile.',
                      style: TextStyle(
                        color: Color(0xFFD8F1EC),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(.25)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: Colors.white.withOpacity(.22),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              _ProgressCheck(
                label: 'Documents',
                complete: documentsCompleted,
              ),
              const SizedBox(width: 17),
              _ProgressCheck(
                label: 'Terms accepted',
                complete: termsAccepted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressCheck extends StatelessWidget {
  final String label;
  final bool complete;
  const _ProgressCheck({required this.label, required this.complete});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            complete ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 15,
            color: complete ? Colors.white : const Color(0xFFB9DCD6),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  final String value;
  final String label;
  const _HeaderMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.78),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFDCEBE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF17363A),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF71858A),
              fontSize: 8,
              letterSpacing: .65,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewGroupHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  const _ReviewGroupHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: Color(0xFF087F78),
              fontSize: 9,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF17363A),
              fontSize: 19,
              letterSpacing: -.45,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF7A8D90),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final String text;
  const _MiniLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF829397),
        fontSize: 9,
        letterSpacing: .9,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

// ================================================================
// REVIEW SECTION
// ================================================================

class _ReviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback? onEdit;

  const _ReviewSection({
    required this.title,
    required this.icon,
    required this.child,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5ECEE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17363A).withOpacity(.04),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5F3),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color:
                      const Color(0xFF078F83),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF244743),
                  ),
                ),
              ),

              if (onEdit != null)
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 13),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF087F78),
                    backgroundColor: const Color(0xFFEAF5F3),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}

// ================================================================
// PROFILE AVATAR
// ================================================================

class _ProfileAvatar extends StatelessWidget {
  final String fullName;
  final String? profileImageUrl;

  const _ProfileAvatar({
    required this.fullName,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final initials = fullName
        .trim()
        .split(' ')
        .where(
          (item) => item.isNotEmpty,
        )
        .take(2)
        .map(
          (item) => item[0].toUpperCase(),
        )
        .join();

    return CircleAvatar(
      radius: 29,
      backgroundColor:
          const Color(0xFFE5F6F2),
      backgroundImage:
          profileImageUrl != null &&
                  profileImageUrl!.isNotEmpty
              ? NetworkImage(profileImageUrl!)
              : null,
      child:
          profileImageUrl == null ||
                  profileImageUrl!.isEmpty
              ? Text(
                  initials.isEmpty
                      ? 'PT'
                      : initials,
                  style: const TextStyle(
                    color:
                        Color(0xFF078F83),
                    fontWeight:
                        FontWeight.w900,
                  ),
                )
              : null,
    );
  }
}

// ================================================================
// INFO ROW
// ================================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color:
              const Color(0xFF718D89),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: Color(0xFF829397),
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  color:
                      Color(0xFF244743),
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================================================================
// TAG LIST
// ================================================================

class _TagList extends StatelessWidget {
  final List<String> items;
  final String emptyText;

  const _TagList({
    required this.items,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        emptyText,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF9BB0AC),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color:
                const Color(0xFFF3F6FB),
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Text(
            item,
            style: const TextStyle(
              fontSize: 11.5,
              color:
                  Color(0xFF4B5B78),
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ================================================================
// PRICE ROW
// ================================================================

class _PriceRow extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _PriceRow({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF637D78),
            fontWeight:
                FontWeight.w600,
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color:
                valueColor ??
                    const Color(0xFF244743),
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// DOCUMENT STATUS
// ================================================================

class _DocumentStatusRow
    extends StatelessWidget {
  final String title;
  final bool uploaded;

  const _DocumentStatusRow({
    required this.title,
    required this.uploaded,
  });

  @override
  Widget build(BuildContext context) {
    final color = uploaded
        ? const Color(0xFF22A864)
        : const Color(0xFFE39B22);

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color:
                color.withValues(alpha: 0.10),
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Icon(
            uploaded
                ? Icons.check_circle_rounded
                : Icons.pending_outlined,
            color: color,
            size: 20,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              color:
                  Color(0xFF244743),
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),

        Text(
          uploaded
              ? 'Uploaded'
              : 'Required',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// WARNING CARD
// ================================================================

class _WarningCard extends StatelessWidget {
  final String message;

  const _WarningCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            const Color(0xFFFFF7E8),
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color:
              const Color(0xFFF5D99D),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color:
                Color(0xFFE39B22),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.45,
                color:
                    Color(0xFF80601E),
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}