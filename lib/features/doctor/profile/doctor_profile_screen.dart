import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/physiotherapist_model.dart';
import '../services/physiotherapist_service.dart';

/// Premium profile and account screen for the physiotherapist application.
///
/// Reads the signed-in physiotherapist's existing profile from
/// physiotherapists/{uid}. Profile edits are saved with merge semantics so
/// onboarding fields and verification data are preserved.
class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen>
    with SingleTickerProviderStateMixin {
  static const Color _purple = Color(0xFF5548D9);
  static const Color _ink = Color(0xFF171B3A);
  static const Color _muted = Color(0xFF858BA2);
  static const Color _line = Color(0xFFE9EAF2);
  static const Color _bg = Color(0xFFF5F6FB);
  static const Color _teal = Color(0xFF1CA58B);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PhysiotherapistService _service = PhysiotherapistService();

  late final AnimationController _introController;
  bool _signingOut = false;

  String get _uid => _auth.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) return const _SignedOutProfile();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<PhysiotherapistModel?>(
          stream: _service.streamPhysiotherapist(_uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _ProfileMessage(
                icon: Icons.cloud_off_rounded,
                title: 'Unable to load profile',
                message: 'Please check your connection and try again.',
                action: () => setState(() {}),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: _purple),
              );
            }

            final profile = snapshot.data;
            if (profile == null) {
              return _ProfileMessage(
                icon: Icons.person_search_rounded,
                title: 'Profile not found',
                message:
                    'We could not find a physiotherapist profile for this account.',
                action: () => setState(() {}),
              );
            }

            return RefreshIndicator(
              color: _purple,
              onRefresh: () async {
                await FirebaseFirestore.instance
                    .collection('physiotherapists')
                    .doc(_uid)
                    .get(const GetOptions(source: Source.server));
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 125),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _topBar(),
                        const SizedBox(height: 18),
                        _animated(0, _hero(profile)),
                        const SizedBox(height: 16),
                        _animated(1, _stats(profile)),
                        const SizedBox(height: 23),
                        _sectionTitle('Professional information',
                            'Your identity and clinical credentials'),
                        const SizedBox(height: 11),
                        _animated(2, _professionalCard(profile)),
                        const SizedBox(height: 22),
                        _sectionTitle(
                            'Services & consultation', 'What patients can book'),
                        const SizedBox(height: 11),
                        _animated(3, _servicesCard(profile)),
                        const SizedBox(height: 22),
                        _sectionTitle(
                            'Practice location', 'Where you provide care'),
                        const SizedBox(height: 11),
                        _animated(4, _locationCard(profile)),
                        const SizedBox(height: 22),
                        _sectionTitle(
                            'Availability & pricing', 'Your practice preferences'),
                        const SizedBox(height: 11),
                        _animated(5, _availabilityCard(profile)),
                        const SizedBox(height: 22),
                        _sectionTitle(
                            'Education & certificates', 'Your submitted documents'),
                        const SizedBox(height: 11),
                        _animated(6, _documentsCard(profile)),
                        const SizedBox(height: 22),
                        _sectionTitle('Account & support',
                            'Manage your account and get assistance'),
                        const SizedBox(height: 11),
                        _animated(7, _accountCard(profile)),
                        const SizedBox(height: 18),
                        Center(
                          child: Text(
                            'PHYSIOHOMEY  •  PHYSIOTHERAPIST',
                            style: TextStyle(
                              color: _muted.withOpacity(.75),
                              fontSize: 8,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _animated(int index, Widget child) {
    final start = (index * .075).clamp(0.0, .55);
    final animation = CurvedAnimation(
      parent: _introController,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - animation.value)),
          child: child,
        ),
      ),
    );
  }

  Widget _topBar() => Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR ACCOUNT',
                  style: TextStyle(
                    color: _purple,
                    fontSize: 9,
                    letterSpacing: 1.7,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'My profile',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.8,
                  ),
                ),
              ],
            ),
          ),
          _iconButton(
            Icons.help_outline_rounded,
            onTap: _showHelp,
          ),
          const SizedBox(width: 8),
          _iconButton(
            Icons.more_horiz_rounded,
            onTap: _showAccountActions,
          ),
        ],
      );

  Widget _hero(PhysiotherapistModel p) {
    final name = _value(p.fullName, 'Physiotherapist');
    final verified = p.isVerified ||
        p.verificationStatus.toLowerCase() == 'approved';
    final status = p.verificationStatus.toLowerCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF171B49),
            Color(0xFF39358E),
            Color(0xFF6255E7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(.22),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -23,
            top: -30,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(.08),
                  width: 24,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _avatar(p.profileImageUrl, size: 72),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            height: 1.12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _value(p.professionalTitle, 'Physiotherapist'),
                          style: const TextStyle(
                            color: Color(0xFFD9D8FF),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _verificationPill(verified, status),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit profile',
                    onPressed: () => _editProfile(p),
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(.13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 1,
                color: Colors.white.withOpacity(.14),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _heroMeta(
                      Icons.workspace_premium_outlined,
                      '${p.experienceYears} years experience',
                    ),
                  ),
                  Expanded(
                    child: _heroMeta(
                      Icons.location_on_outlined,
                      _value(p.city, 'Location not added'),
                    ),
                  ),
                ],
              ),
              if (p.rejectionReason?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 13),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE9E9).withOpacity(.14),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: Colors.white.withOpacity(.12)),
                  ),
                  child: Text(
                    'Verification note: ${p.rejectionReason}',
                    style: const TextStyle(
                      color: Color(0xFFFFE2E2),
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _verificationPill(bool verified, String status) {
    final label = verified
        ? 'VERIFIED'
        : status == 'pending'
            ? 'UNDER REVIEW'
            : status == 'rejected'
                ? 'ACTION REQUIRED'
                : status == 'draft'
                    ? 'PROFILE INCOMPLETE'
                    : status.isEmpty
                        ? 'NOT VERIFIED'
                        : status.toUpperCase();

    final color = verified
        ? const Color(0xFF72E2B9)
        : status == 'rejected'
            ? const Color(0xFFFFB4A8)
            : const Color(0xFFFFD58C);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified_rounded : Icons.info_outline_rounded,
            color: color,
            size: 11,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8,
              letterSpacing: .7,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroMeta(IconData icon, String value) => Row(
        children: [
          Icon(icon, color: const Color(0xFFC9C7FF), size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );

  Widget _stats(PhysiotherapistModel p) => Row(
        children: [
          Expanded(
            child: _statCard(
              Icons.star_rounded,
              p.rating.toStringAsFixed(1),
              '${p.totalReviews} reviews',
              const Color(0xFFFFF3DD),
              const Color(0xFFE6A23C),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _statCard(
              Icons.calendar_month_rounded,
              '${p.totalAppointments}',
              'Appointments',
              const Color(0xFFECEBFF),
              _purple,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _statCard(
              Icons.check_circle_rounded,
              '${p.completedAppointments}',
              'Completed',
              const Color(0xFFE4F7F0),
              _teal,
            ),
          ),
        ],
      );

  Widget _statCard(
    IconData icon,
    String value,
    String label,
    Color tint,
    Color accent,
  ) =>
      Container(
        padding: const EdgeInsets.fromLTRB(11, 13, 8, 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 17),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: _ink,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _muted,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  Widget _professionalCard(PhysiotherapistModel p) => _panel(
        child: Column(
          children: [
            _infoRow('Full name', p.fullName, Icons.person_outline_rounded),
            _infoRow('Phone number', p.phone, Icons.phone_outlined),
            _infoRow('Email address', p.email, Icons.mail_outline_rounded),
            _infoRow('Gender', p.gender, Icons.wc_rounded),
            _infoRow('Professional title', p.professionalTitle,
                Icons.medical_services_outlined),
            _infoRow('Primary specialization', p.primarySpecialization,
                Icons.health_and_safety_outlined),
            _infoRow('Registration number', p.registrationNumber,
                Icons.badge_outlined),
            _infoRow('Registration council', p.registrationCouncil,
                Icons.account_balance_outlined),
            _infoRow('Registration state', p.registrationState,
                Icons.map_outlined),
            _infoRow('Qualification', p.qualification,
                Icons.school_outlined),
            _infoRow('University', p.university, Icons.account_balance_rounded),
            _infoRow(
              'Graduation year',
              p.graduationYear > 0 ? '${p.graduationYear}' : '',
              Icons.event_available_outlined,
            ),
            _infoRow(
              'Experience',
              p.experienceYears > 0 ? '${p.experienceYears} years' : '',
              Icons.workspace_premium_outlined,
            ),
            _infoRow('Employment status', p.employmentStatus,
                Icons.work_outline_rounded),
            _infoRow('Current organization', p.currentOrganization,
                Icons.business_outlined),
            if (p.languages.isNotEmpty)
              _chipRow('Languages', p.languages),
            if (p.specializations.isNotEmpty)
              _chipRow('Specializations', p.specializations),
            if (p.professionalBio.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _subheading('ABOUT'),
              const SizedBox(height: 7),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  p.professionalBio,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    height: 1.55,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 13),
            _editButton(() => _editProfile(p), label: 'Edit profile details'),
          ],
        ),
      );

  Widget _servicesCard(PhysiotherapistModel p) {
    final items = <_ServiceItem>[
      _ServiceItem(
        'Home visits',
        'Treat patients at their location',
        Icons.home_rounded,
        p.homeVisitEnabled,
      ),
      _ServiceItem(
        'Clinic visits',
        'Appointments at your clinic',
        Icons.local_hospital_rounded,
        p.clinicVisitEnabled,
      ),
      _ServiceItem(
        'Online consultation',
        'Remote consultation sessions',
        Icons.video_call_rounded,
        p.onlineConsultationEnabled,
      ),
      _ServiceItem(
        'Emergency availability',
        'Available for urgent requests',
        Icons.emergency_rounded,
        p.emergencyAvailable,
      ),
    ];

    return _panel(
      child: Column(
        children: [
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Row(
                children: [
                  _smallIcon(item.icon, const Color(0xFFECEBFF), _purple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusTag(
                    item.enabled ? 'ENABLED' : 'DISABLED',
                    item.enabled,
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: _line, height: 20),
          _priceRow('Home visit', p.homeVisitPrice, p.currency),
          _priceRow('Clinic visit', p.clinicVisitPrice, p.currency),
          _priceRow('Online consultation', p.onlineConsultationPrice, p.currency),
          _priceRow('Follow-up session', p.followUpPrice, p.currency),
          _priceRow(
            'Travel charges',
            p.travelChargesEnabled ? p.travelCharges : 0,
            p.currency,
            suffix: p.travelChargesEnabled ? '' : 'Not enabled',
          ),
          if (p.discountAvailable)
            _plainInfo('Discount offered', '${p.discountPercentage}%'),
          const SizedBox(height: 8),
          _editButton(() => _showInfo(
                'Service settings',
                'Your service types and consultation fees are saved from your physiotherapist onboarding profile. Use the profile editing/onboarding flow to change these settings.',
              ), label: 'Service settings'),
        ],
      ),
    );
  }

  Widget _locationCard(PhysiotherapistModel p) => _panel(
        child: Column(
          children: [
            _infoRow('Clinic name', p.clinicName, Icons.local_hospital_outlined),
            _infoRow('Address', p.address, Icons.location_on_outlined),
            _infoRow('Locality', p.locality, Icons.place_outlined),
            _infoRow('City', p.city, Icons.location_city_rounded),
            _infoRow('State', p.state, Icons.map_outlined),
            _infoRow('Pincode', p.pincode, Icons.markunread_mailbox_outlined),
            _infoRow(
              'Home visit radius',
              p.homeVisitRadiusKm > 0 ? '${p.homeVisitRadiusKm} km' : '',
              Icons.radar_rounded,
            ),
            _editButton(
              () => _showInfo(
                'Location settings',
                'Your clinic and service-area details are stored in your physiotherapist profile. Edit them through the profile onboarding/edit flow.',
              ),
              label: 'Location settings',
            ),
          ],
        ),
      );

  Widget _availabilityCard(PhysiotherapistModel p) => _panel(
        child: Column(
          children: [
            _infoRow(
              'Working days',
              p.workingDays.isEmpty ? '' : p.workingDays.join(', '),
              Icons.date_range_rounded,
            ),
            _infoRow('Start time', p.startTime, Icons.wb_sunny_outlined),
            _infoRow('End time', p.endTime, Icons.nights_stay_outlined),
            _infoRow(
              'Session duration',
              '${p.sessionDurationMinutes} minutes',
              Icons.timer_outlined,
            ),
            _infoRow(
              'Maximum appointments/day',
              '${p.maxAppointmentsPerDay}',
              Icons.event_available_outlined,
            ),
            if (p.availability.isNotEmpty) ...[
              const SizedBox(height: 8),
              _subheading('WEEKLY AVAILABILITY'),
              const SizedBox(height: 7),
              ...p.availability.entries.map(
                (entry) => _plainInfo(
                  _titleCase(entry.key),
                  _readableValue(entry.value),
                ),
              ),
            ],
            _editButton(
              () => _showInfo(
                'Availability settings',
                'Your working days, timings, service schedules and appointment limits are saved in your physiotherapist profile. Edit them through the availability/onboarding flow.',
              ),
              label: 'Availability settings',
            ),
          ],
        ),
      );

  Widget _documentsCard(PhysiotherapistModel p) {
    final docs = <_DocumentItem>[
      _DocumentItem(
        'Registration certificate',
        p.registrationCertificateUploaded,
        p.registrationCertificateUrl,
        Icons.verified_user_outlined,
      ),
      _DocumentItem(
        'Degree certificate',
        p.degreeCertificateUploaded,
        p.degreeCertificateUrl,
        Icons.school_outlined,
      ),
      _DocumentItem(
        'Government identity document',
        p.identityDocumentUploaded,
        p.governmentIdUrl,
        Icons.badge_outlined,
      ),
      ...p.additionalCertificateUrls.asMap().entries.map(
            (entry) => _DocumentItem(
              'Additional certificate ${entry.key + 1}',
              entry.value.trim().isNotEmpty,
              entry.value,
              Icons.workspace_premium_outlined,
            ),
          ),
    ];

    return _panel(
      child: Column(
        children: [
          ...docs.map(
            (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  _smallIcon(doc.icon, const Color(0xFFE5F7F1), _teal),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          doc.url?.trim().isNotEmpty == true
                              ? 'Document uploaded'
                              : 'No document link saved',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusTag(
                    doc.uploaded && doc.url?.trim().isNotEmpty == true
                        ? 'UPLOADED'
                        : 'MISSING',
                    doc.uploaded && doc.url?.trim().isNotEmpty == true,
                  ),
                  if (doc.url?.trim().isNotEmpty == true)
                    IconButton(
                      tooltip: 'Copy document link',
                      onPressed: () => _copy(doc.url!, 'Document link copied'),
                      icon: const Icon(
                        Icons.copy_rounded,
                        color: _purple,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Divider(color: _line, height: 18),
          _plainInfo('Verification status', _titleCase(p.verificationStatus)),
          _plainInfo('Profile completed', p.isProfileCompleted ? 'Yes' : 'No'),
          _plainInfo('Onboarding step', '${p.onboardingStep}'),
        ],
      ),
    );
  }

  Widget _accountCard(PhysiotherapistModel p) => _panel(
        child: Column(
          children: [
            _actionRow(
              Icons.edit_note_rounded,
              'Edit profile',
              'Update your professional introduction',
              onTap: () => _editProfile(p),
            ),
            _actionRow(
              Icons.verified_user_outlined,
              'Verification status',
              'Review your profile verification',
              onTap: () => _showInfo(
                'Verification status',
                'Current status: ${_titleCase(p.verificationStatus)}\n\n'
                    '${p.isVerified ? 'Your profile is verified.' : 'Your profile is not yet verified.'}'
                    '${p.rejectionReason?.trim().isNotEmpty == true ? '\n\nReview note: ${p.rejectionReason}' : ''}',
              ),
            ),
            _actionRow(
              Icons.copy_rounded,
              'Copy account ID',
              'Copy your physiotherapist account identifier',
              onTap: () => _copy(p.uid, 'Account ID copied'),
            ),
            _actionRow(
              Icons.help_outline_rounded,
              'Help & support',
              'Get assistance with your doctor account',
              onTap: _showHelp,
            ),
            _actionRow(
              Icons.privacy_tip_outlined,
              'Privacy & account information',
              'Understand your saved account details',
              onTap: () => _showInfo(
                'Account information',
                'Your professional profile is stored in the physiotherapists collection under your authenticated account ID. Your profile includes identity, qualifications, services, availability, pricing, submitted document links and verification information.',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFFFDEDE)),
              ),
              child: TextButton.icon(
                onPressed: _signingOut ? null : _confirmLogout,
                icon: _signingOut
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFD94F5C),
                        ),
                      )
                    : const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFD94F5C),
                        size: 18,
                      ),
                label: Text(
                  _signingOut ? 'Signing out...' : 'Log out',
                  style: const TextStyle(
                    color: Color(0xFFD94F5C),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _panel({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: _line),
          boxShadow: [
            BoxShadow(
              color: _ink.withOpacity(.025),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: child,
      );

  Widget _sectionTitle(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: -.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: _muted,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );

  Widget _subheading(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: _purple,
            fontSize: 8,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w900,
          ),
        ),
      );

  Widget _infoRow(String label, String value, IconData icon) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _muted, size: 15),
          const SizedBox(width: 9),
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: _ink,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipRow(String label, List<String> values) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _subheading(label.toUpperCase()),
            const SizedBox(height: 7),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: values
                    .where((e) => e.trim().isNotEmpty)
                    .map(
                      (e) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEBFF),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          e,
                          style: const TextStyle(
                            color: _purple,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );

  Widget _smallIcon(IconData icon, Color tint, Color accent) => Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: accent, size: 17),
      );

  Widget _statusTag(String label, bool good) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: good ? const Color(0xFFE5F7F1) : const Color(0xFFFFF3E5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: good ? _teal : const Color(0xFFCE8A36),
            fontSize: 7,
            fontWeight: FontWeight.w900,
            letterSpacing: .4,
          ),
        ),
      );

  Widget _priceRow(String label, double amount, String currency,
      {String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            suffix.isNotEmpty
                ? suffix
                : '$currency ${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: _ink,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _plainInfo(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: _muted, fontSize: 9),
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _editButton(VoidCallback onTap, {required String label}) =>
      SizedBox(
        width: double.infinity,
        height: 43,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: _purple,
            side: const BorderSide(color: Color(0xFFDCD9FF)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );

  Widget _actionRow(
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            children: [
              _smallIcon(icon, const Color(0xFFECEBFF), _purple),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _muted,
                size: 19,
              ),
            ],
          ),
        ),
      );

  Widget _avatar(String? url, {double size = 58}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFECEBFF),
          borderRadius: BorderRadius.circular(size * .30),
          border: Border.all(color: Colors.white.withOpacity(.25), width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: url?.trim().isNotEmpty == true
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person_rounded,
                  color: _purple,
                  size: size * .48,
                ),
              )
            : Icon(
                Icons.person_rounded,
                color: _purple,
                size: size * .48,
              ),
      );

  Widget _iconButton(IconData icon, {required VoidCallback onTap}) =>
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _line),
            ),
            child: Icon(icon, color: _ink, size: 19),
          ),
        ),
      );

  Future<void> _editProfile(PhysiotherapistModel p) async {
    final name = TextEditingController(text: p.fullName);
    final organization = TextEditingController(text: p.currentOrganization);
    final bio = TextEditingController(text: p.professionalBio);
    final languages = TextEditingController(text: p.languages.join(', '));

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _EditProfileSheet(
          name: name,
          organization: organization,
          bio: bio,
          languages: languages,
        ),
      ),
    );

    if (result == true && mounted) {
      try {
        await _service.updateFields(
          uid: p.uid,
          data: {
            'fullName': name.text.trim(),
            'currentOrganization': organization.text.trim(),
            'professionalBio': bio.text.trim(),
            'bio': bio.text.trim(),
            'languages': languages.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
          },
        );
        _toast('Profile details updated successfully.');
      } catch (_) {
        _toast('Unable to save changes. Please try again.');
      }
    }

    name.dispose();
    organization.dispose();
    bio.dispose();
    languages.dispose();
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEEEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFD94F5C),
                  size: 25,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Log out of PhysioHomey?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You will need to sign in again to manage your practice and patient requests.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 21),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _ink,
                        side: const BorderSide(color: _line),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Text('Stay signed in'),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD94F5C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Text(
                        'Log out',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldLogout != true || !mounted) return;

    setState(() => _signingOut = true);
    try {
      await _auth.signOut();
      // The app's existing auth gate should react to FirebaseAuth state change.
    } catch (_) {
      if (mounted) {
        setState(() => _signingOut = false);
        _toast('Unable to log out. Please try again.');
      }
    }
  }

  void _showAccountActions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _actionRow(
                Icons.help_outline_rounded,
                'Help & support',
                'Get help with your account',
                onTap: () {
                  Navigator.pop(context);
                  _showHelp();
                },
              ),
              _actionRow(
                Icons.logout_rounded,
                'Log out',
                'Securely sign out of your account',
                onTap: () {
                  Navigator.pop(context);
                  _confirmLogout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelp() => _showInfo(
        'Help & support',
        'For assistance with your physiotherapist account, booking requests, profile verification or app access, please contact the PhysioHomey support team through your configured support channel.',
      );

  void _showInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
            height: 1.55,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                color: _purple,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));
    _toast(message);
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        margin: const EdgeInsets.all(14),
      ),
    );
  }

  String _value(String value, String fallback) =>
      value.trim().isEmpty ? fallback : value.trim();

  String _titleCase(String value) {
    if (value.trim().isEmpty) return 'Not provided';
    return value
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ');
  }

  String _readableValue(dynamic value) {
    if (value == null) return 'Not set';
    if (value is bool) return value ? 'Available' : 'Unavailable';
    if (value is Map) {
      return value.entries
          .map((e) => '${_titleCase(e.key.toString())}: ${e.value}')
          .join(' • ');
    }
    if (value is List) return value.join(', ');
    return value.toString();
  }
}

class _EditProfileSheet extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController organization;
  final TextEditingController bio;
  final TextEditingController languages;

  const _EditProfileSheet({
    required this.name,
    required this.organization,
    required this.bio,
    required this.languages,
  });

  static const Color _purple = Color(0xFF5548D9);
  static const Color _ink = Color(0xFF171B3A);
  static const Color _muted = Color(0xFF858BA2);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * .88,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E6EE),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 19),
            const Text(
              'Edit profile details',
              style: TextStyle(
                color: _ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Update the information displayed on your professional profile.',
              style: TextStyle(
                color: _muted,
                fontSize: 10,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            _field('Full name', name, icon: Icons.person_outline_rounded),
            _field(
              'Current organization',
              organization,
              icon: Icons.business_outlined,
            ),
            _field(
              'Languages (comma separated)',
              languages,
              icon: Icons.translate_rounded,
            ),
            _field(
              'Professional bio',
              bio,
              icon: Icons.notes_rounded,
              maxLines: 5,
            ),
            const SizedBox(height: 9),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Save changes',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    required IconData icon,
    int maxLines = 1,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _ink,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            TextField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(
                color: _ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: _purple, size: 18),
                filled: true,
                fillColor: const Color(0xFFF7F7FC),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(
                    color: Color(0xFFE9EAF2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(
                    color: _purple,
                    width: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _ServiceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;

  const _ServiceItem(this.title, this.subtitle, this.icon, this.enabled);
}

class _DocumentItem {
  final String title;
  final bool uploaded;
  final String? url;
  final IconData icon;

  const _DocumentItem(this.title, this.uploaded, this.url, this.icon);
}

class _ProfileMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback action;

  const _ProfileMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF5548D9), size: 42),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF171B3A),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF858BA2),
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 17),
              ElevatedButton(
                onPressed: action,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5548D9),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
}

class _SignedOutProfile extends StatelessWidget {
  const _SignedOutProfile();

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Color(0xFFF5F6FB),
        body: Center(
          child: Text(
            'Please sign in to view your profile.',
            style: TextStyle(
              color: Color(0xFF171B3A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
