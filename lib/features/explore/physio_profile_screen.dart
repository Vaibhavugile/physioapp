import 'package:flutter/material.dart';

import '../core/config/pricing_config.dart';
import '../booking/booking_details_screen.dart';
import 'models/physio_match_model.dart';

class PhysioProfileScreen extends StatefulWidget {
  final PhysioMatchModel match;
  final String? initialCareMode;
  final int initialPackageVisits;

  const PhysioProfileScreen({
    super.key,
    required this.match,
    this.initialCareMode,
    this.initialPackageVisits = 1,
  });

  @override
  State<PhysioProfileScreen> createState() =>
      _PhysioProfileScreenState();
}

class _PhysioProfileScreenState
    extends State<PhysioProfileScreen> {
  // ================================================================
  // SELECTED CARE MODE
  // ================================================================

  String? mode;

  // ================================================================
  // INITIALIZE
  // ================================================================

  @override
  void initState() {
    super.initState();

    final p = widget.match.physiotherapist;

    final requested = widget.initialCareMode?.trim().toLowerCase();
    if (requested == PricingConfig.home && p.homeVisitEnabled && p.homeVisitPrice > 0) {
      mode = PricingConfig.home;
    } else if (requested == PricingConfig.clinic && p.clinicVisitEnabled && p.clinicVisitPrice > 0) {
      mode = PricingConfig.clinic;
    } else if (requested == PricingConfig.online && p.onlineConsultationEnabled && p.onlineConsultationPrice > 0) {
      mode = PricingConfig.online;
    } else {
      mode = p.homeVisitEnabled && p.homeVisitPrice > 0
          ? PricingConfig.home
          : p.clinicVisitEnabled && p.clinicVisitPrice > 0
              ? PricingConfig.clinic
              : p.onlineConsultationEnabled && p.onlineConsultationPrice > 0
                  ? PricingConfig.online
                  : null;
    }
  }

  // ================================================================
  // CURRENT TIER
  // ================================================================

  String get currentTier {
    final p = widget.match.physiotherapist;
    if (p.pricingTier.trim().isNotEmpty) return p.pricingTier.trim();
    return PricingConfig.getTierFromExperience(p.experienceYears);
  }

  // ================================================================
  // CURRENT TIER NAME — SAVED ONBOARDING SNAPSHOT
  // ================================================================

  String get currentTierName {
    final p = widget.match.physiotherapist;
    if (p.pricingTierLabel.trim().isNotEmpty) return p.pricingTierLabel.trim();
    return p.pricingTier.trim().isNotEmpty
        ? PricingConfig.getTierName(p.pricingTier)
        : 'Pricing tier unavailable';
  }

  // ================================================================
  // CURRENT PRICE — PROVIDER'S SAVED ONBOARDING RATE
  // ================================================================

  double get price => _priceForMode(mode);

  double _priceForMode(String? careMode) {
    final p = widget.match.physiotherapist;
    if (careMode == PricingConfig.home) return p.homeVisitPrice;
    if (careMode == PricingConfig.clinic) return p.clinicVisitPrice;
    if (careMode == PricingConfig.online) return p.onlineConsultationPrice;
    return 0;
  }

  String get currencySymbol {
    final currency = widget.match.physiotherapist.currency.toUpperCase();
    switch (currency) {
      case 'INR': return '₹';
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      default: return '$currency ';
    }
  }

  // ================================================================
  // MODE TITLE
  // ================================================================

  String get modeTitle {
    if (mode == PricingConfig.home) {
      return 'Home Visit';
    }

    if (mode == PricingConfig.clinic) {
      return 'Clinic Visit';
    }

    if (mode == PricingConfig.online) {
      return 'Online Consultation';
    }

    return 'Select care';
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final p = widget.match.physiotherapist;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FC),
      body: SafeArea(
        child: Stack(
          children: [
            // ======================================================
            // SCROLLABLE CONTENT
            // ======================================================

            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 132),
              physics:
                  const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  Row(
                    children: [
                      _icon(
                        Icons.arrow_back_rounded,
                        () {
                          Navigator.pop(context);
                        },
                      ),

                      const Expanded(
                        child: Center(
                          child: Text(
                            'Physiotherapist',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w900,
                              fontSize: 15,
                              color:
                                  Color(0xFF111A3D),
                            ),
                          ),
                        ),
                      ),

                      _icon(
                        Icons.favorite_border_rounded,
                        null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // PHYSIO HERO
                  // ==================================================

                  _hero(p),

                  const SizedBox(height: 20),

                  // ==================================================
                  // CARE MODE
                  // ==================================================

                  _title(
                    'Choose your care',
                    'Select how you want your session',
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      // =================================================
                      // HOME
                      // =================================================

                      if (p.homeVisitEnabled && p.homeVisitPrice > 0)
                        _mode(
                          PricingConfig.home,
                          Icons.home_rounded,
                          'Home Visit',
                          'At your doorstep',
                          _priceForMode(PricingConfig.home),
                        ),

                      // =================================================
                      // CLINIC
                      // =================================================

                      if (p.clinicVisitEnabled && p.clinicVisitPrice > 0)
                        _mode(
                          PricingConfig.clinic,
                          Icons.local_hospital_rounded,
                          'Clinic Visit',
                          'Visit the clinic',
                          _priceForMode(PricingConfig.clinic),
                        ),

                      // =================================================
                      // ONLINE
                      // =================================================

                      if (p.onlineConsultationEnabled && p.onlineConsultationPrice > 0)
                        _mode(
                          PricingConfig.online,
                          Icons.video_call_rounded,
                          'Online',
                          'Consult remotely',
                          _priceForMode(PricingConfig.online),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // HOME VISIT DETAILS
                  // ==================================================

                  if (mode == PricingConfig.home) ...[
                    _title(
                      'Home visit',
                      'Personalized care at your location',
                    ),

                    const SizedBox(height: 10),

                    _card(
                      Icons.home_rounded,
                      'Care at your doorstep',
                      widget.match
                              .withinHomeVisitRange
                          ? 'This physiotherapist is available within your home-visit range.'
                          : 'Home-visit availability will be confirmed before booking.',
                    ),

                    const SizedBox(height: 20),
                  ],

                  // ==================================================
                  // CLINIC DETAILS
                  // ==================================================

                  if (mode == PricingConfig.clinic) ...[
                    _title(
                      'Clinic details',
                      'Where your appointment will take place',
                    ),

                    const SizedBox(height: 10),

                    _card(
                      Icons.local_hospital_rounded,
                      p.clinicName.isEmpty
                          ? 'Clinic details'
                          : p.clinicName,
                      [
                        p.address,
                        p.city,
                        p.state,
                      ]
                          .where(
                            (x) =>
                                x.trim().isNotEmpty,
                          )
                          .join(', '),
                    ),

                    const SizedBox(height: 20),
                  ],

                  // ==================================================
                  // ONLINE DETAILS
                  // ==================================================

                  if (mode == PricingConfig.online) ...[
                    _title(
                      'Online consultation',
                      'Connect remotely with your physiotherapist',
                    ),

                    const SizedBox(height: 10),

                    _card(
                      Icons.video_call_rounded,
                      'Consult from anywhere',
                      'Online consultation details will be shared after booking confirmation.',
                    ),

                    const SizedBox(height: 20),
                  ],

                  // ==================================================
                  // ABOUT
                  // ==================================================

                  _title(
                    'About the physiotherapist',
                    'Experience you can trust',
                  ),

                  const SizedBox(height: 10),

                  _box(
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.professionalBio
                                  .trim()
                                  .isEmpty
                              ? '${p.professionalTitle} committed to helping patients recover and move better.'
                              : p.professionalBio,
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.55,
                            color:
                                Color(0xFF5F6985),
                          ),
                        ),

                        if (p.languages.isNotEmpty) ...[
                          const SizedBox(height: 12),

                          Text(
                            'Languages: ${p.languages.join(', ')}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  Color(0xFF5146D9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // SPECIALIZATIONS
                  // ==================================================

                  _title(
                    'Specializations',
                    'Conditions and areas of expertise',
                  ),

                  const SizedBox(height: 10),

                  _box(
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <String>[
                        if (p.primarySpecialization
                            .trim()
                            .isNotEmpty)
                          p.primarySpecialization,

                        ...p.specializations.where(
                          (x) =>
                              x.trim().isNotEmpty &&
                              x.trim() !=
                                  p.primarySpecialization
                                      .trim(),
                        ),
                      ].map(
                        (x) {
                          return Chip(
                            label: Text(
                              x,
                              style:
                                  const TextStyle(
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            backgroundColor:
                                const Color(
                              0xFFF0EEFF,
                            ),
                            side:
                                BorderSide.none,
                          );
                        },
                      ).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // AVAILABILITY
                  // ==================================================

                  _title(
                    'Availability',
                    'Working days and appointment hours',
                  ),

                  const SizedBox(height: 10),

                  _box(
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.workingDays.isEmpty
                              ? 'Schedule not specified'
                              : p.workingDays.join(', '),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '${p.startTime} – ${p.endTime}',
                          style: const TextStyle(
                            fontSize: 11,
                            color:
                                Color(0xFF69728D),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '${p.sessionDurationMinutes} minutes per session',
                          style: const TextStyle(
                            fontSize: 11,
                            color:
                                Color(0xFF69728D),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // PRICING CARD
                  // ==================================================

                  _card(
                    Icons.payments_rounded,
                    modeTitle,
                    '$currencySymbol${price.toStringAsFixed(0)} • '
                    '${p.sessionDurationMinutes} minute session',
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // TIER CARD
                  // ==================================================

                  _card(
                    Icons.workspace_premium_rounded,
                    '$currentTierName Tier',
                    '${p.experienceYears} years of professional experience • '
                    'Pricing is based on the platform tier.',
                  ),
                ],
              ),
            ),

            // ======================================================
            // BOTTOM BOOKING BAR
            // ======================================================

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  12,
                  18,
                  18,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    // =================================================
                    // PRICE
                    // =================================================

                    Expanded(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$currencySymbol${price.toStringAsFixed(0)}',
                            style:
                                const TextStyle(
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.w900,
                              color:
                                  Color(0xFF111A3D),
                            ),
                          ),

                          Text(
                            '$currentTierName • $modeTitle',
                            style:
                                const TextStyle(
                              fontSize: 9.5,
                              color:
                                  Color(0xFF7D859B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // BOOK BUTTON
                    // =================================================

                    GestureDetector(
                      onTap: () {
                        // =============================================
                        // CARE MODE VALIDATION
                        // =============================================

                        if (mode == null) {
                          _msg(
                            'Please select a care mode.',
                          );

                          return;
                        }

                        // =============================================
                        // OPEN BOOKING DETAILS
                        // =============================================

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingDetailsScreen(
                              // =======================================
                              // PHYSIOTHERAPIST ID
                              // =======================================

                              physiotherapistId:
                                  p.uid,

                              // =======================================
                              // PHYSIOTHERAPIST DETAILS
                              // =======================================

                              doctorName:
                                  p.fullName,

                              doctorImage:
                                  p.profileImageUrl ??
                                      '',

                              specialty:
                                  p.primarySpecialization,

                              rating:
                                  p.rating,

                              // =======================================
                              // UNIVERSAL TIER PRICE
                              // =======================================

                              experienceYears: p.experienceYears,

                              // =======================================
                              // PHYSIOTHERAPIST WORKING DAYS
                              // =======================================
                              //
                              // Pass the physiotherapist's onboarding
                              // availability into the booking flow so
                              // patients can only select working days.
                              //
                              workingDays: List<String>.from(
                                p.workingDays,
                              ),

                              // =======================================
                              // SELECTED CARE MODE
                              // =======================================

                              initialCareMode:
                                  mode!,
                              initialPackageVisits:
                                  widget.initialPackageVisits,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFF5146D9,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),
                        child: const Text(
                          'Book Appointment',
                          style:
                              TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // MESSAGE
  // ================================================================

  void _msg(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // ================================================================
  // ICON BUTTON
  // ================================================================

  Widget _icon(
    IconData icon,
    VoidCallback? tap,
  ) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color:
                const Color(0xFFE3E6EF),
          ),
        ),
        child: Icon(
          icon,
          color:
              const Color(0xFF151D3D),
        ),
      ),
    );
  }

  // ================================================================
  // HERO
  // ================================================================

  Widget _hero(dynamic p) {
    final url =
        (p.profileImageUrl ?? '').trim();

    final tierName = p.pricingTierLabel.trim().isNotEmpty
        ? p.pricingTierLabel.trim()
        : 'Pricing tier unavailable';

    return _box(
      Column(
        children: [
          SizedBox(
            height: 248,
            width: double.infinity,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(21),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: const Color(0xFFEEF0FF),
                  ),

                  url.isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          size: 95,
                          color:
                              Color(0xFF5B64D9),
                        )
                      : Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                            _,
                            __,
                            ___,
                          ) {
                            return const Icon(
                              Icons.person_rounded,
                              size: 95,
                              color:
                                  Color(0xFF5B64D9),
                            );
                          },
                        ),

                  Positioned(
                    left: 12,
                    top: 12,
                    child: _pill(
                      Icons.location_on_rounded,
                      widget.match.distanceLabel,
                    ),
                  ),

                  Positioned(
                    right: 12,
                    top: 12,
                    child: _pill(
                      Icons.workspace_premium_rounded,
                      '${widget.match.matchPercentage}% match',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Text(
                  p.fullName.isEmpty
                      ? 'Physiotherapist'
                      : p.fullName,
                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w900,
                    color:
                        Color(0xFF111A3D),
                  ),
                ),
              ),

              if (p.isVerified)
                const Icon(
                  Icons.verified_rounded,
                  color:
                      Color(0xFF079F87),
                ),
            ],
          ),

          const SizedBox(height: 5),

          Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              p.primarySpecialization
                      .isEmpty
                  ? p.professionalTitle
                  : p.primarySpecialization,
              style:
                  const TextStyle(
                fontSize: 11.5,
                color:
                    Color(0xFF69728D),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ==========================================================
          // TIER BADGE
          // ==========================================================

          Align(
            alignment:
                Alignment.centerLeft,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFFF0EEFF),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    size: 14,
                    color:
                        Color(0xFF5146D9),
                  ),

                  const SizedBox(width: 5),

                  Text(
                    '$tierName Tier',
                    style:
                        const TextStyle(
                      fontSize: 9.5,
                      fontWeight:
                          FontWeight.w900,
                      color:
                          Color(0xFF5146D9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _stat(
                  Icons.star_rounded,
                  p.rating
                      .toStringAsFixed(1),
                  '${p.totalReviews} reviews',
                  const Color(
                      0xFFFFB21A),
                ),
              ),

              Expanded(
                child: _stat(
                  Icons.workspace_premium_rounded,
                  '${p.experienceYears}+',
                  'Years experience',
                  const Color(
                      0xFF5146D9),
                ),
              ),

              Expanded(
                child: _stat(
                  Icons.location_on_rounded,
                  widget
                      .match
                      .distanceLabel
                      .replaceAll(
                    ' away',
                    '',
                  ),
                  widget.match.matchLabel,
                  const Color(
                      0xFF079F87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STAT
  // ================================================================

  Widget _stat(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 18,
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style:
              const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        Text(
          label,
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            fontSize: 9,
            color:
                Color(0xFF7D859B),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // PILL
  // ================================================================

  Widget _pill(
    IconData icon,
    String text,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(.94),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color:
                const Color(0xFF5146D9),
          ),

          const SizedBox(width: 4),

          Text(
            text,
            style:
                const TextStyle(
              fontSize: 9,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TITLE
  // ================================================================

  Widget _title(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color:
                Color(0xFF111A3D),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style:
              const TextStyle(
            fontSize: 11,
            color:
                Color(0xFF7D859B),
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // CARE MODE CARD
  // ================================================================

  Widget _mode(
    String key,
    IconData icon,
    String title,
    String subtitle,
    double amount,
  ) {
    final selected =
        mode == key;

    return SizedBox(
      width:
          (MediaQuery.of(context)
                      .size
                      .width -
                  46) /
              2,
      child:
          GestureDetector(
        onTap: () {
          setState(() {
            mode = key;
          });
        },
        child: Container(
          padding:
              const EdgeInsets.all(12),
          decoration:
              BoxDecoration(
            color: selected
                ? const Color(
                    0xFFF0EEFF)
                : Colors.white,
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            border:
                Border.all(
              color: selected
                  ? const Color(
                      0xFF8E82EF)
                  : const Color(
                      0xFFE3E6EF,
                    ),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Icon(
                icon,
                color:
                    const Color(
                        0xFF5146D9),
              ),

              const SizedBox(
                  height: 10),

              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(
                  height: 4),

              Text(
                subtitle,
                style:
                    const TextStyle(
                  fontSize: 9.5,
                  color:
                      Color(0xFF737C99),
                ),
              ),

              const SizedBox(
                  height: 8),

              Text(
                '$currencySymbol${amount.toStringAsFixed(0)} / session',
                style:
                    const TextStyle(
                  fontSize: 10,
                  color:
                      Color(0xFF079F87),
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // INFO CARD
  // ================================================================

  Widget _card(
    IconData icon,
    String title,
    String description,
  ) {
    return _box(
      Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Icon(
            icon,
            color:
                const Color(
                    0xFF5146D9),
          ),

          const SizedBox(
              width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                    height: 5),

                Text(
                  description
                          .isEmpty
                      ? 'Details will be confirmed before booking.'
                      : description,
                  style:
                      const TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color:
                        Color(0xFF69728D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // PREMIUM BOX
  // ================================================================

  Widget _box(
    Widget child,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(23),
        border:
            Border.all(
          color:
              const Color(0xFFE3E6EF),
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF26345C)
                    .withOpacity(.05),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}