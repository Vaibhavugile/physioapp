import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/config/pricing_config.dart';
import '../booking/booking_details_screen.dart';
import 'models/physio_match_model.dart';

class PhysioProfileScreen extends StatefulWidget {
  final PhysioMatchModel match;

  const PhysioProfileScreen({
    super.key,
    required this.match,
  });

  @override
  State<PhysioProfileScreen> createState() => _PhysioProfileScreenState();
}

class _PhysioProfileScreenState extends State<PhysioProfileScreen> {
  static const Color _ink = Color(0xFF17213D);
  static const Color _muted = Color(0xFF77819A);
  static const Color _purple = Color(0xFF6257E8);
  static const Color _mint = Color(0xFF18A88B);
  static const Color _canvas = Color(0xFFF5F6FB);

  String? mode;

  @override
  void initState() {
    super.initState();
    final p = widget.match.physiotherapist;
    mode = p.homeVisitEnabled
        ? PricingConfig.home
        : p.clinicVisitEnabled
            ? PricingConfig.clinic
            : p.onlineConsultationEnabled
                ? PricingConfig.online
                : null;
  }

  dynamic get currentTier => PricingConfig.getTierFromExperience(
        widget.match.physiotherapist.experienceYears,
      );

  String get currentTierName => PricingConfig.getTierName(currentTier);

  double get price {
    if (mode == null) return 0;
    return PricingConfig.getSessionPrice(
      experienceYears: widget.match.physiotherapist.experienceYears,
      careMode: mode!,
    );
  }

  String get modeTitle {
    if (mode == PricingConfig.home) return 'Home visit';
    if (mode == PricingConfig.clinic) return 'Clinic visit';
    if (mode == PricingConfig.online) return 'Online consultation';
    return 'Select care';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.match.physiotherapist;

    return Scaffold(
      backgroundColor: _canvas,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _profileHero(p)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient-first order: booking availability and the
                      // clinic's location are immediately visible after the hero.
                      _sectionHeading(
                        'Availability',
                        'See when each type of appointment can be arranged',
                      ),
                      const SizedBox(height: 12),
                      _availabilityPanel(p),
                      const SizedBox(height: 20),

                      if (p.clinicVisitEnabled) ...[
                        _sectionHeading(
                          'Clinic details',
                          'Know where you will meet your physiotherapist',
                        ),
                        const SizedBox(height: 12),
                        _clinicPanel(p),
                        const SizedBox(height: 24),
                      ],

                      _sectionHeading(
                        'Areas of expertise',
                        'Conditions and treatment areas this specialist focuses on',
                      ),
                      const SizedBox(height: 12),
                      _specializations(p),
                      const SizedBox(height: 24),

                      _sectionHeading(
                        'Experience & professional background',
                        'Understand the experience behind your care',
                      ),
                      const SizedBox(height: 12),
                      _workPanel(p),
                      const SizedBox(height: 24),

                      _sectionHeading(
                        'Session pricing',
                        'Review the consultation fee before choosing a session',
                      ),
                      const SizedBox(height: 12),
                      _pricingPanel(p),
                      const SizedBox(height: 28),

                      _sectionHeading(
                        'Choose how you want to receive care',
                        'Select the appointment type that works best for you',
                      ),
                      const SizedBox(height: 14),
                      if (p.homeVisitEnabled)
                        _careDetailCard(
                          eyebrow: 'HOME VISIT',
                          title: 'Care at your doorstep',
                          description: widget.match.withinHomeVisitRange
                              ? 'This physiotherapist is within your home-visit service range.'
                              : 'Home-visit availability is confirmed before the appointment.',
                          icon: Icons.home_work_rounded,
                          accent: const Color(0xFF20A88B),
                          amount: PricingConfig.getSessionPrice(
                            experienceYears: p.experienceYears,
                            careMode: PricingConfig.home,
                          ),
                          selected: mode == PricingConfig.home,
                          onTap: () => setState(() => mode = PricingConfig.home),
                        ),
                      if (p.clinicVisitEnabled)
                        _careDetailCard(
                          eyebrow: 'CLINIC VISIT',
                          title: p.clinicName.trim().isEmpty
                              ? 'Visit the clinic'
                              : p.clinicName,
                          description:
                              'Meet your physiotherapist at the practice location.',
                          icon: Icons.local_hospital_rounded,
                          accent: _purple,
                          amount: PricingConfig.getSessionPrice(
                            experienceYears: p.experienceYears,
                            careMode: PricingConfig.clinic,
                          ),
                          selected: mode == PricingConfig.clinic,
                          onTap: () => setState(() => mode = PricingConfig.clinic),
                        ),
                      if (p.onlineConsultationEnabled)
                        _careDetailCard(
                          eyebrow: 'ONLINE CONSULTATION',
                          title: 'Consult from wherever you are',
                          description:
                              'Connect remotely. Joining details are shared after booking confirmation.',
                          icon: Icons.video_camera_front_rounded,
                          accent: const Color(0xFF3986D9),
                          amount: PricingConfig.getSessionPrice(
                            experienceYears: p.experienceYears,
                            careMode: PricingConfig.online,
                          ),
                          selected: mode == PricingConfig.online,
                          onTap: () => setState(() => mode = PricingConfig.online),
                        ),
                      if (p.emergencyAvailable) ...[
                        const SizedBox(height: 12),
                        _serviceNotice(
                          icon: Icons.emergency_rounded,
                          title: 'Emergency availability',
                          subtitle:
                              'This physiotherapist has indicated emergency availability. Contact and confirmation are subject to their response.',
                          accent: const Color(0xFFE16C5B),
                        ),
                      ],
                      const SizedBox(height: 28),

                      if (p.homeVisitEnabled) ...[
                        _sectionHeading(
                          'Home visit coverage',
                          'Understand the area covered for home appointments',
                        ),
                        const SizedBox(height: 12),
                        _homeCoveragePanel(p),
                        const SizedBox(height: 24),
                      ],
                      if (p.onlineConsultationEnabled) ...[
                        _sectionHeading(
                          'Online appointments',
                          'What to expect from a remote session',
                        ),
                        const SizedBox(height: 12),
                        _onlinePanel(),
                        const SizedBox(height: 24),
                      ],

                      _sectionHeading(
                        'About the physiotherapist',
                        'A little more about their approach to patient care',
                      ),
                      const SizedBox(height: 12),
                      _aboutPanel(p),
                      const SizedBox(height: 24),

                      _sectionHeading(
                        'Education & qualifications',
                        'Academic background and professional certifications',
                      ),
                      const SizedBox(height: 12),
                      _qualificationsPanel(p),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _bottomBookingBar(p),
        ],
      ),
    );
  }

  Widget _profileHero(dynamic p) {
    final imageUrl = (p.profileImageUrl ?? '').trim();
    final name = p.fullName.trim().isEmpty ? 'Physiotherapist' : p.fullName.trim();
    final specialty = p.primarySpecialization.trim().isEmpty
        ? p.professionalTitle
        : p.primarySpecialization;

    return SizedBox(
      height: 430,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 355,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF171D49), Color(0xFF5148B8), Color(0xFF786CEB)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
            ),
          ),
          Positioned(
            top: -95,
            right: -55,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.055),
              ),
            ),
          ),
          Positioned(
            top: 115,
            left: -65,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(.08), width: 24),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  _topIcon(Icons.arrow_back_rounded, () => Navigator.pop(context)),
                  const Spacer(),
                  const Text(
                    'SPECIALIST PROFILE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      letterSpacing: 2.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  _topIcon(Icons.favorite_border_rounded, null),
                ],
              ),
            ),
          ),
          Positioned(
            top: 92,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  width: 174,
                  height: 174,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(.45), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.22),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: imageUrl.isEmpty
                        ? Container(
                            color: const Color(0xFFE8E9FF),
                            child: const Icon(Icons.person_rounded, size: 86, color: _purple),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFE8E9FF),
                              child: const Icon(Icons.person_rounded, size: 86, color: _purple),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 17),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.7,
                        ),
                      ),
                    ),
                    if (p.isVerified) ...[
                      const SizedBox(width: 7),
                      const Icon(Icons.verified_rounded, color: Color(0xFF7DE3C7), size: 21),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  specialty,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFDCD9FF), fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _heroPill(Icons.workspace_premium_rounded, '$currentTierName tier'),
                    _heroPill(Icons.near_me_rounded, widget.match.distanceLabel),
                    _heroPill(Icons.auto_awesome_rounded, '${widget.match.matchPercentage}% match'),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(23),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF28345F).withOpacity(.10), blurRadius: 28, offset: const Offset(0, 12)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _heroMetric(
                      Icons.star_rounded,
                      p.rating.toStringAsFixed(1),
                      '${p.totalReviews} reviews',
                      const Color(0xFFFFB547),
                    ),
                  ),
                  _metricDivider(),
                  Expanded(
                    child: _heroMetric(
                      Icons.workspace_premium_rounded,
                      '${p.experienceYears}+',
                      'Years experience',
                      _purple,
                    ),
                  ),
                  _metricDivider(),
                  Expanded(
                    child: _heroMetric(
                      Icons.place_rounded,
                      widget.match.distanceLabel.replaceAll(' away', ''),
                      widget.match.matchLabel,
                      _mint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topIcon(IconData icon, VoidCallback? onTap) {
    return Material(
      color: Colors.white.withOpacity(.13),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 43,
          height: 43,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _heroPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        border: Border.all(color: Colors.white.withOpacity(.16)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFFE4E1FF)),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _heroMetric(IconData icon, String value, String label, Color accent) {
    return Column(
      children: [
        Icon(icon, size: 19, color: accent),
        const SizedBox(height: 7),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _metricDivider() => Container(width: 1, height: 42, color: const Color(0xFFEEF0F6));

  Widget _sectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: _ink, fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -.45)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: _muted, fontSize: 11.5, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _clinicPanel(dynamic p) {
    final addressParts = <String>[
      if (p.address.trim().isNotEmpty) p.address.trim(),
      if (p.locality.trim().isNotEmpty) p.locality.trim(),
      if (p.city.trim().isNotEmpty) p.city.trim(),
      if (p.state.trim().isNotEmpty) p.state.trim(),
      if (p.pincode.trim().isNotEmpty) p.pincode.trim(),
    ];
    final address = addressParts.join(', ');
    final hasCoordinates = p.latitude != 0 && p.longitude != 0;

    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFFF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.apartment_rounded, color: _purple, size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.clinicName.trim().isEmpty ? 'Registered clinic' : p.clinicName.trim(),
                      style: const TextStyle(color: _ink, fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    const Text('Physiotherapy practice', style: TextStyle(color: _muted, fontSize: 10)),
                  ],
                ),
              ),
              if (hasCoordinates)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7F3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 12, color: _mint),
                      SizedBox(width: 3),
                      Text('PINNED', style: TextStyle(color: _mint, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .6)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, color: _purple, size: 19),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    address.isEmpty ? 'Clinic address has not been provided.' : address,
                    style: const TextStyle(color: _ink, fontSize: 11, height: 1.55, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          if (hasCoordinates) ...[
            const SizedBox(height: 9),
            Text(
              'Location coordinates  ${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}',
              style: const TextStyle(color: _muted, fontSize: 9),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 47,
            child: OutlinedButton.icon(
              onPressed: address.isEmpty && !hasCoordinates ? null : () => _openClinicDirections(p),
              icon: const Icon(Icons.directions_rounded, size: 18),
              label: const Text('Get directions to clinic', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _purple,
                side: const BorderSide(color: Color(0xFFDCD9FF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openClinicDirections(dynamic p) async {
    final hasCoordinates = p.latitude != 0 && p.longitude != 0;
    final destination = hasCoordinates
        ? '${p.latitude},${p.longitude}'
        : [
            p.address,
            p.locality,
            p.city,
            p.state,
            p.pincode,
          ].where((part) => part.toString().trim().isNotEmpty).join(', ');

    if (destination.trim().isEmpty) return;

    final uri = Uri.https(
      'www.google.com',
      '/maps/dir/',
      {'api': '1', 'destination': destination},
    );

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _msg('Unable to open directions on this device.');
      }
    } catch (_) {
      if (mounted) _msg('Unable to open directions right now.');
    }
  }

  Widget _homeCoveragePanel(dynamic p) {
    final radius = p.homeVisitRadiusKm;
    return _surface(
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7F3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.home_work_rounded, color: _mint, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Home visit service radius', style: TextStyle(color: _ink, fontSize: 11.5, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  radius > 0 ? 'Accepting home visits within $radius km of the registered practice area.' : 'Service coverage is confirmed with the physiotherapist before booking.',
                  style: const TextStyle(color: _muted, fontSize: 10.5, height: 1.45),
                ),
              ],
            ),
          ),
          if (radius > 0)
            Text('$radius km', style: const TextStyle(color: _mint, fontSize: 15, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _onlinePanel() {
    return _serviceNotice(
      icon: Icons.video_camera_front_rounded,
      title: 'Remote consultation',
      subtitle: 'Connect from your preferred location. The consultation link or joining instructions are shared after the booking is confirmed.',
      accent: const Color(0xFF3986D9),
    );
  }

  Widget _serviceNotice({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
  }) {
    return _surface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: accent.withOpacity(.11), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: accent, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(color: _muted, fontSize: 10.5, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qualificationsPanel(dynamic p) {
    final qualifications = List<Map<String, dynamic>>.from(p.qualifications ?? const []);
    final certifications = List<Map<String, dynamic>>.from(p.certifications ?? const []);

    final hasLegacyQualification = p.qualification.trim().isNotEmpty ||
        p.university.trim().isNotEmpty || p.graduationYear > 0;
    if (qualifications.isEmpty && hasLegacyQualification) {
      qualifications.add({
        'degree': p.qualification,
        'university': p.university,
        'passingYear': p.graduationYear,
      });
    }

    if (qualifications.isEmpty && certifications.isEmpty) {
      return _surface(
        child: const Text('Education and qualification details have not been added to this profile yet.', style: TextStyle(color: _muted, fontSize: 11, height: 1.5)),
      );
    }

    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (qualifications.isNotEmpty)
            ...qualifications.asMap().entries.map((entry) {
              final item = entry.value;
              final degree = _mapText(item, 'degree');
              final specialization = _mapText(item, 'specialization');
              final institution = _mapText(item, 'institution');
              final university = _mapText(item, 'university');
              final year = _mapText(item, 'passingYear');

              return Padding(
                padding: EdgeInsets.only(bottom: entry.key == qualifications.length - 1 && certifications.isEmpty ? 0 : 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 39,
                      height: 39,
                      decoration: BoxDecoration(color: const Color(0xFFF0EFFF), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.school_rounded, color: _purple, size: 19),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(degree.isEmpty ? 'Qualification' : degree, style: const TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w900)),
                          if (specialization.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(specialization, style: const TextStyle(color: _purple, fontSize: 10, fontWeight: FontWeight.w700)),
                          ],
                          if (institution.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(institution, style: const TextStyle(color: _ink, fontSize: 10.5, fontWeight: FontWeight.w700)),
                          ],
                          if (university.isNotEmpty)
                            Text(university, style: const TextStyle(color: _muted, fontSize: 10)),
                          if (year.isNotEmpty && year != '0')
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Completed $year', style: const TextStyle(color: _muted, fontSize: 9)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          if (certifications.isNotEmpty) ...[
            if (qualifications.isNotEmpty) const Divider(height: 22, color: Color(0xFFEEF0F6)),
            const Text('PROFESSIONAL CERTIFICATIONS', style: TextStyle(color: _muted, fontSize: 8.5, letterSpacing: 1.1, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            ...certifications.map((item) {
              final name = _mapText(item, 'certificateName');
              final issuer = _mapText(item, 'issuingOrganization');
              final year = _mapText(item, 'completionYear');
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: Color(0xFFB58B3D), size: 18),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name.isEmpty ? 'Professional certificate' : name, style: const TextStyle(color: _ink, fontSize: 11, fontWeight: FontWeight.w800)),
                          if (issuer.isNotEmpty) Text(issuer, style: const TextStyle(color: _muted, fontSize: 9.5)),
                          if (year.isNotEmpty && year != '0') Text('Completed $year', style: const TextStyle(color: _muted, fontSize: 9)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _mapText(Map<String, dynamic> map, String key) {
    return (map[key] ?? '').toString().trim();
  }

  Widget _credentialsPanel(dynamic p) {
    final hasRegistration = p.registrationNumber.trim().isNotEmpty ||
        p.registrationCouncil.trim().isNotEmpty ||
        p.registrationState.trim().isNotEmpty;
    final hasDocuments = p.registrationCertificateUploaded ||
        p.degreeCertificateUploaded ||
        p.identityDocumentUploaded ||
        p.additionalCertificateUrls.isNotEmpty;

    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasRegistration) ...[
            _dataLine('Registration number', p.registrationNumber),
            _dataLine('Registration council', p.registrationCouncil),
            _dataLine('Registration state', p.registrationState),
            const SizedBox(height: 10),
          ],
          if (hasDocuments) ...[
            const Divider(height: 20, color: Color(0xFFEEF0F6)),
            const Text('DOCUMENT CHECKLIST', style: TextStyle(color: _muted, fontSize: 8.5, letterSpacing: 1.1, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            _documentStatus('Registration certificate', p.registrationCertificateUploaded),
            _documentStatus('Degree certificate', p.degreeCertificateUploaded),
            _documentStatus('Identity document', p.identityDocumentUploaded),
            if (p.additionalCertificateUrls.isNotEmpty)
              _documentStatus('${p.additionalCertificateUrls.length} additional certificate(s)', true),
          ],
          if (!hasRegistration && !hasDocuments)
            const Text('Professional registration details are not available on this profile yet.', style: TextStyle(color: _muted, fontSize: 11, height: 1.5)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                p.isVerified ? Icons.verified_rounded : Icons.pending_rounded,
                color: p.isVerified ? _mint : const Color(0xFFB58B3D),
                size: 17,
              ),
              const SizedBox(width: 7),
              Text(
                p.isVerified ? 'Professional profile verified' : 'Verification ${p.verificationStatus}',
                style: TextStyle(color: p.isVerified ? _mint : const Color(0xFF9A7737), fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dataLine(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 118, child: Text(label, style: const TextStyle(color: _muted, fontSize: 9.5, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: const TextStyle(color: _ink, fontSize: 10.5, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }

  Widget _documentStatus(String label, bool uploaded) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(uploaded ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: uploaded ? _mint : const Color(0xFFB8BECC), size: 15),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: _ink, fontSize: 10, fontWeight: FontWeight.w600))),
          Text(uploaded ? 'Submitted' : 'Not submitted', style: TextStyle(color: uploaded ? _mint : _muted, fontSize: 9, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _workPanel(dynamic p) {
    return _surface(
      child: Column(
        children: [
          _workInfo(Icons.timeline_rounded, 'Professional experience', p.experienceYears > 0 ? '${p.experienceYears} years' : 'Not specified'),
          if (p.employmentStatus.trim().isNotEmpty) ...[
            const Divider(height: 20, color: Color(0xFFEEF0F6)),
            _workInfo(Icons.work_outline_rounded, 'Employment status', p.employmentStatus),
          ],
          if (p.currentOrganization.trim().isNotEmpty) ...[
            const Divider(height: 20, color: Color(0xFFEEF0F6)),
            _workInfo(Icons.business_center_rounded, 'Current organization', p.currentOrganization),
          ],
        ],
      ),
    );
  }

  Widget _workInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(color: const Color(0xFFF0EFFF), borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: _purple, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w600))),
        Text(value, style: const TextStyle(color: _ink, fontSize: 10.5, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _aboutPanel(dynamic p) {
    final bio = p.professionalBio.trim().isEmpty
        ? '${p.professionalTitle} committed to helping patients recover and move better.'
        : p.professionalBio;

    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: const Color(0xFFF0EFFF), borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.person_search_rounded, color: _purple, size: 20),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text('Professional introduction', style: TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(bio, style: const TextStyle(color: Color(0xFF626D86), fontSize: 12, height: 1.7, fontWeight: FontWeight.w500)),
          if (p.languages.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF0F1F6), height: 1),
            const SizedBox(height: 13),
            const Text('LANGUAGES', style: TextStyle(color: _muted, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: p.languages.map<Widget>((language) => _tag(language, const Color(0xFFEAF7F3), _mint)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _specializations(dynamic p) {
    final items = <String>[
      if (p.primarySpecialization.trim().isNotEmpty) p.primarySpecialization.trim(),
      ...p.specializations.where(
        (x) => x.trim().isNotEmpty && x.trim() != p.primarySpecialization.trim(),
      ),
    ];

    if (items.isEmpty) {
      return _surface(child: const Text('Specialization details are not available yet.', style: TextStyle(color: _muted, fontSize: 12)));
    }

    return _surface(
      child: Wrap(
        spacing: 8,
        runSpacing: 9,
        children: items.map((item) => _tag(item, const Color(0xFFF0EFFF), _purple)).toList(),
      ),
    );
  }

  Widget _tag(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(30)),
      child: Text(text, style: TextStyle(color: foreground, fontSize: 10.5, fontWeight: FontWeight.w800)),
    );
  }

  Widget _availabilityPanel(dynamic p) {
    final schedules = Map<String, dynamic>.from(p.serviceSchedules ?? const {});
    final services = <_ScheduleDisplay>[];

    void addSchedule(String key, bool enabled, String title, Color accent, IconData icon) {
      if (!enabled) return;
      final raw = schedules[key];
      final schedule = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      final days = List<String>.from(schedule['days'] ?? const []);
      final flexible = schedule['flexible'] == true;
      final start = (schedule['startTime'] ?? '').toString();
      final end = (schedule['endTime'] ?? '').toString();
      services.add(_ScheduleDisplay(
        title: title,
        days: days.isNotEmpty ? days : p.workingDays,
        hours: flexible
            ? 'Flexible timings'
            : (start.isNotEmpty && end.isNotEmpty ? '$start – $end' : '${p.startTime} – ${p.endTime}'),
        accent: accent,
        icon: icon,
      ));
    }

    addSchedule('home', p.homeVisitEnabled, 'Home visits', _mint, Icons.home_work_rounded);
    addSchedule('clinic', p.clinicVisitEnabled, 'Clinic appointments', _purple, Icons.local_hospital_rounded);
    addSchedule('online', p.onlineConsultationEnabled, 'Online consultations', const Color(0xFF3986D9), Icons.videocam_rounded);

    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...services.asMap().entries.map((entry) {
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: entry.key == services.length - 1 ? 0 : 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(color: item.accent.withOpacity(.11), borderRadius: BorderRadius.circular(11)),
                        child: Icon(item.icon, color: item.accent, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item.title, style: const TextStyle(color: _ink, fontSize: 11.5, fontWeight: FontWeight.w900))),
                      Text(item.hours, style: TextStyle(color: item.accent, fontSize: 9.5, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.days.isEmpty
                        ? [_tag('Days to be confirmed', const Color(0xFFF4F5F9), _muted)]
                        : item.days.map<Widget>((day) => _tag(day, item.accent.withOpacity(.09), item.accent)).toList(),
                  ),
                ],
              ),
            );
          }),
          if (services.isEmpty)
            const Text('Availability details have not been added yet.', style: TextStyle(color: _muted, fontSize: 11)),
          const Divider(height: 24, color: Color(0xFFEEF0F6)),
          Row(
            children: [
              const Icon(Icons.hourglass_bottom_rounded, color: _purple, size: 17),
              const SizedBox(width: 8),
              const Expanded(child: Text('Session duration', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w600))),
              Text('${p.sessionDurationMinutes} minutes', style: const TextStyle(color: _ink, fontSize: 10.5, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.event_available_rounded, color: _purple, size: 17),
              const SizedBox(width: 8),
              const Expanded(child: Text('Daily appointment capacity', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w600))),
              Text('${p.maxAppointmentsPerDay} appointments', style: const TextStyle(color: _ink, fontSize: 10.5, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pricingPanel(dynamic p) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF202653), Color(0xFF5148B8)],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [BoxShadow(color: const Color(0xFF393B91).withOpacity(.17), blurRadius: 22, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD58A), size: 19),
              const SizedBox(width: 8),
              const Expanded(child: Text('YOUR SESSION ESTIMATE', style: TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1.35, fontWeight: FontWeight.w900))),
              _heroPill(Icons.verified_user_rounded, 'Platform pricing'),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 34, height: 1, fontWeight: FontWeight.w900, letterSpacing: -1)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('/ ${p.sessionDurationMinutes} min session', style: const TextStyle(color: Color(0xFFDAD8FF), fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(height: 1, color: Colors.white.withOpacity(.15)),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFFFD58A), size: 17),
              const SizedBox(width: 7),
              Expanded(child: Text('$currentTierName tier · ${p.experienceYears} years of experience', style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Fees are calculated by the platform based on experience tier and selected care mode.', style: TextStyle(color: Color(0xFFDAD8FF), fontSize: 9.5, height: 1.45)),
        ],
      ),
    );
  }

  Widget _careDetailCard({
    required String eyebrow,
    required String title,
    required String description,
    required IconData icon,
    required Color accent,
    required double amount,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(21),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? accent.withOpacity(.055) : Colors.white,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: selected ? accent.withOpacity(.65) : const Color(0xFFEAECF3),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27345F).withOpacity(.035),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(.11),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: accent, size: 21),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eyebrow,
                            style: TextStyle(
                              color: accent,
                              fontSize: 8.5,
                              letterSpacing: 1.35,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'SELECTED',
                          style: TextStyle(color: accent, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .5),
                        ),
                      )
                    else
                      Icon(Icons.radio_button_unchecked_rounded, color: const Color(0xFFCAD0DE), size: 20),
                  ],
                ),
                const SizedBox(height: 13),
                Text(
                  description,
                  style: const TextStyle(color: _muted, fontSize: 11, height: 1.55),
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: const Color(0xFFF0F1F6)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '₹${amount.toStringAsFixed(0)}',
                      style: const TextStyle(color: _ink, fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -.5),
                    ),
                    const SizedBox(width: 5),
                    const Text('per session', style: TextStyle(color: _muted, fontSize: 9.5)),
                    const Spacer(),
                    Text(
                      selected ? 'Chosen for booking' : 'Tap to choose',
                      style: TextStyle(color: accent, fontSize: 9.5, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: accent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _surface({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFEAECF3)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF27345F).withOpacity(.035), blurRadius: 20, offset: const Offset(0, 7)),
        ],
      ),
      child: child,
    );
  }

  Widget _bottomBookingBar(dynamic p) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFEAECF3))),
          boxShadow: [BoxShadow(color: const Color(0xFF1D2850).withOpacity(.08), blurRadius: 24, offset: const Offset(0, -7))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SESSION PRICE', style: TextStyle(color: _muted, fontSize: 8.5, letterSpacing: 1.1, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(color: _ink, fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: -.6)),
                  Text('$currentTierName · $modeTitle', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 9.5, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6257E8), Color(0xFF8174F4)]),
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [BoxShadow(color: _purple.withOpacity(.25), blurRadius: 15, offset: const Offset(0, 7))],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _book(p),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Book appointment', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 17),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _book(dynamic p) {
    if (mode == null) {
      _msg('Please select a care mode.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingDetailsScreen(
          physiotherapistId: p.uid,
          doctorName: p.fullName,
          doctorImage: p.profileImageUrl ?? '',
          specialty: p.primarySpecialization,
          rating: p.rating,
          experienceYears: p.experienceYears,
          workingDays: List<String>.from(p.workingDays),
          initialCareMode: mode!,
        ),
      ),
    );
  }

  void _msg(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}

class _ScheduleDisplay {
  final String title;
  final List<String> days;
  final String hours;
  final Color accent;
  final IconData icon;

  const _ScheduleDisplay({
    required this.title,
    required this.days,
    required this.hours,
    required this.accent,
    required this.icon,
  });
}
