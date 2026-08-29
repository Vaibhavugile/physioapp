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

  // ==============================================================
  // AVAILABILITY
  // ==============================================================

  final List<String> workingDays;

  final String startTime;
  final String endTime;

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

    required this.workingDays,
    required this.startTime,
    required this.endTime,

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
    extends State<ReviewSubmitStep> {
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
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // ========================================================
        // HEADER
        // ========================================================

        const Text(
          'Review your profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111A3D),
            letterSpacing: -0.6,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Please review all your information before submitting your profile for verification.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF7B849C),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 24),

        // ========================================================
        // PROFILE COMPLETION
        // ========================================================

        _ProfileCompletionCard(
          documentsCompleted:
              _allDocumentsUploaded,
          termsAccepted:
              widget.termsAccepted,
        ),

        const SizedBox(height: 24),

        // ========================================================
        // PERSONAL INFORMATION
        // ========================================================

        _ReviewSection(
          title: 'Personal information',
          icon: Icons.person_outline_rounded,
          onEdit: widget.onEditPersonal,
          child: Column(
            children: [
              Row(
                children: [
                  _ProfileAvatar(
                    fullName: widget.fullName,
                    profileImageUrl:
                        widget.profileImageUrl,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.fullName.isEmpty
                              ? 'Not provided'
                              : widget.fullName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                Color(0xFF27314D),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          widget.professionalTitle
                                  .isEmpty
                              ? 'Physiotherapist'
                              : widget
                                  .professionalTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color:
                                Color(0xFF7B849C),
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: widget.phone.isEmpty
                    ? 'Not provided'
                    : widget.phone,
              ),

              const SizedBox(height: 12),

              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: widget.email.isEmpty
                    ? 'Not provided'
                    : widget.email,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ========================================================
        // PROFESSIONAL INFORMATION
        // ========================================================

        _ReviewSection(
          title: 'Professional details',
          icon:
              Icons.medical_information_outlined,
          onEdit: widget.onEditProfessional,
          child: Column(
            children: [
              _InfoRow(
                icon:
                    Icons.badge_outlined,
                label: 'Professional title',
                value:
                    widget.professionalTitle.isEmpty
                        ? 'Not provided'
                        : widget.professionalTitle,
              ),

              const SizedBox(height: 12),

              _InfoRow(
                icon:
                    Icons.verified_user_outlined,
                label: 'Registration number',
                value:
                    widget.registrationNumber.isEmpty
                        ? 'Not provided'
                        : widget.registrationNumber,
              ),

              const SizedBox(height: 12),

              _InfoRow(
                icon:
                    Icons.workspace_premium_outlined,
                label: 'Primary specialization',
                value: widget
                        .primarySpecialization
                        .isEmpty
                    ? 'Not provided'
                    : widget.primarySpecialization,
              ),

              const SizedBox(height: 12),

              _InfoRow(
                icon:
                    Icons.timeline_outlined,
                label: 'Experience',
                value:
                    '${widget.yearsOfExperience} years',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ========================================================
        // QUALIFICATIONS
        // ========================================================

        _ReviewSection(
          title: 'Qualifications',
          icon:
              Icons.school_outlined,
          onEdit: widget.onEditQualifications,
          child: _TagList(
            items: widget.qualifications,
            emptyText:
                'No qualifications added yet',
          ),
        ),

        const SizedBox(height: 16),

        // ========================================================
        // SPECIALIZATIONS
        // ========================================================

        _ReviewSection(
          title: 'Specializations & services',
          icon:
              Icons.health_and_safety_outlined,
          onEdit: widget.onEditSpecializations,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Specializations',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w800,
                  color: Color(0xFF59637A),
                ),
              ),

              const SizedBox(height: 10),

              _TagList(
                items: widget.specializations,
                emptyText:
                    'No specializations selected',
              ),

              const SizedBox(height: 18),

              const Text(
                'Services offered',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w800,
                  color: Color(0xFF59637A),
                ),
              ),

              const SizedBox(height: 10),

              _TagList(
                items: widget.services,
                emptyText:
                    'No services selected',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ========================================================
        // LOCATION
        // ========================================================

        _ReviewSection(
          title: 'Practice location',
          icon:
              Icons.location_on_outlined,
          onEdit: widget.onEditLocation,
          child: Column(
            children: [
              _InfoRow(
                icon:
                    Icons.business_outlined,
                label: 'Clinic / practice',
                value:
                    widget.clinicName.isEmpty
                        ? 'Home visit practice'
                        : widget.clinicName,
              ),

              const SizedBox(height: 12),

              _InfoRow(
                icon:
                    Icons.location_on_outlined,
                label: 'Address',
                value: _fullAddress.isEmpty
                    ? 'Not provided'
                    : _fullAddress,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ========================================================
        // AVAILABILITY
        // ========================================================

        _ReviewSection(
          title: 'Availability',
          icon:
              Icons.calendar_month_outlined,
          onEdit: widget.onEditAvailability,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _InfoRow(
                icon:
                    Icons.access_time_outlined,
                label: 'Working hours',
                value:
                    '${widget.startTime} - ${widget.endTime}',
              ),

              const SizedBox(height: 16),

              const Text(
                'Working days',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w800,
                  color: Color(0xFF59637A),
                ),
              ),

              const SizedBox(height: 10),

              _TagList(
                items: widget.workingDays,
                emptyText:
                    'No working days selected',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ========================================================
        // PRICING
        // ========================================================

        _ReviewSection(
          title: 'Fees & pricing',
          icon:
              Icons.currency_rupee_rounded,
          onEdit: widget.onEditPricing,
          child: Column(
            children: [
              _PriceRow(
                title: 'Home visit',
                value:
                    '$_currencySymbol ${_formatPrice(widget.homeVisitFee)}',
              ),

              const SizedBox(height: 12),

              _PriceRow(
                title: 'Clinic appointment',
                value:
                    '$_currencySymbol ${_formatPrice(widget.clinicVisitFee)}',
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
                value:
                    '$_currencySymbol ${_formatPrice(widget.followUpFee)}',
              ),

              if (widget.travelChargesEnabled) ...[
                const SizedBox(height: 12),

                _PriceRow(
                  title: 'Travel charge',
                  value:
                      '$_currencySymbol ${_formatPrice(widget.travelCharges)}',
                ),
              ],

              if (widget.discountAvailable) ...[
                const SizedBox(height: 12),

                _PriceRow(
                  title: 'Discount',
                  value:
                      '${widget.discountPercentage.toStringAsFixed(0)}%',
                  valueColor:
                      const Color(0xFF22A864),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ========================================================
        // DOCUMENT VERIFICATION
        // ========================================================

        _ReviewSection(
          title: 'Verification documents',
          icon:
              Icons.verified_user_outlined,
          onEdit: widget.onEditVerification,
          child: Column(
            children: [
              _DocumentStatusRow(
                title: 'Identity document',
                uploaded:
                    widget.identityDocumentUploaded,
              ),

              const SizedBox(height: 12),

              _DocumentStatusRow(
                title:
                    'Professional registration',
                uploaded:
                    widget.registrationDocumentUploaded,
              ),

              const SizedBox(height: 12),

              _DocumentStatusRow(
                title:
                    'Qualification certificate',
                uploaded:
                    widget
                        .qualificationDocumentUploaded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // ========================================================
        // IMPORTANT INFORMATION
        // ========================================================

        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color:
                const Color(0xFFEAF2FF),
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color:
                  const Color(0xFFD5E4FF),
            ),
          ),
          child: const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color:
                    Color(0xFF246BFD),
              ),

              SizedBox(width: 12),

              Expanded(
                child: Text(
                  'After submission, your professional profile will be reviewed by our team. You may be asked to provide additional information before approval.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color:
                        Color(0xFF4B5B78),
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // ========================================================
        // TERMS
        // ========================================================

        InkWell(
          borderRadius:
              BorderRadius.circular(16),
          onTap: () {
            widget.onTermsChanged(
              !widget.termsAccepted,
            );
          },
          child: Container(
            padding:
                const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.termsAccepted
                  ? const Color(0xFFF0FAF4)
                  : Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: widget.termsAccepted
                    ? const Color(0xFFB8E6C9)
                    : const Color(0xFFE1E6EF),
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value:
                      widget.termsAccepted,
                  activeColor:
                      const Color(0xFF246BFD),
                  onChanged: (value) {
                    widget.onTermsChanged(
                      value ?? false,
                    );
                  },
                ),

                const SizedBox(width: 5),

                const Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 11),
                    child: Text(
                      'I confirm that the information provided is accurate and I agree to the platform terms, professional guidelines and verification process.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color:
                            Color(0xFF59637A),
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // ========================================================
        // SUBMISSION STATUS
        // ========================================================

        if (!_allDocumentsUploaded)
          _WarningCard(
            message:
                'Please upload all required verification documents before submitting your profile.',
          ),

        if (!widget.termsAccepted) ...[
          if (!_allDocumentsUploaded)
            const SizedBox(height: 12),

          _WarningCard(
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

class _ProfileCompletionCard
    extends StatelessWidget {
  final bool documentsCompleted;
  final bool termsAccepted;

  const _ProfileCompletionCard({
    required this.documentsCompleted,
    required this.termsAccepted,
  });

  @override
  Widget build(BuildContext context) {
    final completedItems = [
      documentsCompleted,
      termsAccepted,
    ].where((item) => item).length;

    final progress = completedItems / 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF246BFD),
            Color(0xFF4B8DFF),
          ],
        ),
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Almost ready to submit',
            style: TextStyle(
              fontSize: 17,
              color: Colors.white,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Complete the remaining requirements to send your profile for verification.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.45,
              color: Color(0xFFE7F0FF),
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  Colors.white.withValues(
                alpha: 0.25,
              ),
              valueColor:
                  const AlwaysStoppedAnimation(
                Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '$completedItems of 2 final requirements completed',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
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
      padding:
          const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFE1E6EF),
        ),
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
                  color:
                      const Color(0xFFEAF2FF),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color:
                      const Color(0xFF246BFD),
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
                        Color(0xFF27314D),
                  ),
                ),
              ),

              if (onEdit != null)
                TextButton(
                  onPressed: onEdit,
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w800,
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
          const Color(0xFFEAF2FF),
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
                        Color(0xFF246BFD),
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
              const Color(0xFF7B849C),
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
                  fontSize: 10.5,
                  color:
                      Color(0xFF8B95A9),
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
                      Color(0xFF27314D),
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
          color: Color(0xFF9AA3B5),
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
            color: Color(0xFF59637A),
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
                    const Color(0xFF27314D),
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
                  Color(0xFF27314D),
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