import 'package:flutter/material.dart';

import '../models/physio_match_model.dart';
import '../physio_profile_screen.dart';
import '../../core/config/pricing_config.dart';

class TopRatedPhysios extends StatelessWidget {
  final List<PhysioMatchModel> matches;

  final ValueChanged<PhysioMatchModel>? onPhysioTap;

  final VoidCallback? onSeeAll;

  final String careMode;

  const TopRatedPhysios({
    super.key,
    required this.matches,
    this.onPhysioTap,
    this.onSeeAll,
    this.careMode = PricingConfig.home,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =========================================================
        // HEADER
        // =========================================================

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top rated near you',
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.1,
                      color: Color(0xFF111A3D),
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.5,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Trusted physiotherapists around you',
                    style: TextStyle(
                      fontSize: 9,
                      height: 1.1,
                      color: Color(0xFF7B849C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // =====================================================
            // SEE ALL
            // =====================================================

            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF3F1FF),
                      Color(0xFFEEF8F7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE1E0F4),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF5146D9),
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    SizedBox(width: 4),

                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: Color(0xFF5146D9),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // =========================================================
        // REAL FIREBASE PHYSIOTHERAPISTS
        // =========================================================

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,

          itemCount: matches.length,

          gridDelegate:
    const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  crossAxisSpacing: 11,
  mainAxisSpacing: 13,
  mainAxisExtent: 310,
),

          itemBuilder: (context, index) {
            final match = matches[index];

            return _PhysioCard(
              match: match,
              careMode: careMode,

              onTap: () {
  if (onPhysioTap != null) {
    onPhysioTap!(match);
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PhysioProfileScreen(
        match: match,
      ),
    ),
  );
},
            );
          },
        ),
      ],
    );
  }

  // ===============================================================
  // DOCTOR NAME
  // ===============================================================

  static String _doctorName(
    String name,
  ) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return 'Physiotherapist';
    }

    if (trimmed.toLowerCase().startsWith('dr.')) {
      return trimmed;
    }

    return 'Dr. $trimmed';
  }

  // ===============================================================
  // PROFILE IMAGE
  // ===============================================================

  static String _profileImage(
    dynamic physio,
  ) {
    try {
      final value =
          physio.profileImageUrl?.toString().trim();

      if (value != null && value.isNotEmpty) {
        return value;
      }
    } catch (_) {}

    try {
      final value =
          physio.profilePhotoUrl?.toString().trim();

      if (value != null && value.isNotEmpty) {
        return value;
      }
    } catch (_) {}

    try {
      final value =
          physio.imageUrl?.toString().trim();

      if (value != null && value.isNotEmpty) {
        return value;
      }
    } catch (_) {}

    return '';
  }

  // ===============================================================
  // SPECIALTY
  // ===============================================================

  static String _specialty(
    dynamic physio,
  ) {
    try {
      final value = physio.specializations;

      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
    } catch (_) {}

    try {
      final value = physio.specialization;

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    } catch (_) {}

    return 'Physiotherapy';
  }

  // ===============================================================
  // RATING
  // ===============================================================

  static double _rating(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  // ===============================================================
  // REVIEWS
  // ===============================================================

  static int _reviews(
    dynamic physio,
  ) {
    try {
      final value = physio.reviewCount;

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(
            value?.toString() ?? '',
          ) ??
          0;
    } catch (_) {}

    try {
      final value = physio.reviews;

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(
            value?.toString() ?? '',
          ) ??
          0;
    } catch (_) {}

    return 0;
  }

  // ===============================================================
  // EXPERIENCE
  // ===============================================================

  static int _experience(
    dynamic physio,
  ) {
    try {
      final value = physio.experienceYears;

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(
            value?.toString() ?? '',
          ) ??
          0;
    } catch (_) {}

    try {
      final value = physio.experience;

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(
            value?.toString() ?? '',
          ) ??
          0;
    } catch (_) {}

    return 0;
  }

  // ===============================================================
  // DISTANCE
  // ===============================================================

  static String _distance(
    PhysioMatchModel match,
  ) {
    try {
      final value = match.distanceKm;

      if (value < 1) {
        return '${(value * 1000).round()} m away';
      }

      return '${value.toStringAsFixed(1)} km away';
    } catch (_) {
      return 'Nearby';
    }
  }
}

// ===================================================================
// UNIVERSAL PRICING CHIP
// ===================================================================

class _PricingChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isTier;

  const _PricingChip({required this.icon, required this.label, this.isTier = false});

  @override
  Widget build(BuildContext context) {
    final iconColor = isTier ? const Color(0xFF5146D9) : const Color(0xFF079F87);
    final background = isTier ? const Color(0xFFF3F1FF) : const Color(0xFFEAF8F5);
    final border = isTier ? const Color(0xFFE2DFFF) : const Color(0xFFD7EEE8);
    return Container(
      constraints: const BoxConstraints(maxWidth: 86),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(7), border: Border.all(color: border, width: .7)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 9, color: iconColor),
        const SizedBox(width: 3),
        Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 6.5, color: iconColor, fontWeight: FontWeight.w900))),
      ]),
    );
  }
}

// ===================================================================
// PHYSIO CARD
// ===================================================================

class _PhysioCard extends StatelessWidget {
  final PhysioMatchModel match;

  final String careMode;

  final VoidCallback? onTap;

  const _PhysioCard({
    required this.match,
    required this.careMode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final physio = match.physiotherapist;

    final name = _getDoctorName(
      physio.fullName,
    );

    final specialty = _getSpecialty(
      physio,
    );

    final rating = _getRating(
      physio.rating,
    );

    final reviews = _getReviews(
      physio,
    );

    final distance = _getDistance(
      match,
    );

    final resolvedCareMode = _getResolvedCareMode(physio);
    final price = _getPrice(physio, resolvedCareMode);
    final tierName = _getTierName(physio);
    final careModeLabel = PricingConfig.getCareModeName(resolvedCareMode);

    final imageUrl = _getImageUrl(
      physio,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),

        splashColor: const Color(
          0xFF5146D9,
        ).withOpacity(.06),

        highlightColor: const Color(
          0xFF5146D9,
        ).withOpacity(.025),

        child: Container(
          width: double.infinity,

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(22),

            border: Border.all(
              color: const Color(0xFFE3E6EF),
              width: .9,
            ),

            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF26345C,
                ).withOpacity(.075),

                blurRadius: 22,
                spreadRadius: -5,
                offset: const Offset(0, 9),
              ),
            ],
          ),

          clipBehavior: Clip.antiAlias,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // =====================================================
              // IMAGE
              // =====================================================

              SizedBox(
                width: double.infinity,
                height: 137,

                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration:
                          const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF0F2FF),
                            Color(0xFFE8F9F5),
                          ],
                        ),
                      ),
                    ),

                    _buildProfileImage(
                      imageUrl,
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 45,

                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black
                                  .withOpacity(.13),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // VERIFIED

                    Positioned(
                      left: 9,
                      bottom: 9,

                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(.97),

                          borderRadius:
                              BorderRadius.circular(9),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(.10),

                              blurRadius: 8,

                              offset: const Offset(
                                0,
                                3,
                              ),
                            ),
                          ],
                        ),

                        child: const Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 11,
                              color: Color(0xFF079F87),
                            ),

                            SizedBox(width: 3),

                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 7,
                                color: Color(0xFF087F75),
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // FAVORITE ICON

                    Positioned(
                      top: 9,
                      right: 9,

                      child: Container(
                        width: 32,
                        height: 32,

                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(.96),

                          shape: BoxShape.circle,

                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF26345C,
                              ).withOpacity(.13),

                              blurRadius: 9,

                              offset: const Offset(
                                0,
                                3,
                              ),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.favorite_border_rounded,
                          size: 17,
                          color: Color(0xFF26345C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =====================================================
              // DETAILS
              // =====================================================

              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    11,
                    11,
                    11,
                    10,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,

                              maxLines: 1,

                              overflow:
                                  TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 11.2,
                                height: 1.1,
                                color:
                                    Color(0xFF111A3D),
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: -.25,
                              ),
                            ),
                          ),

                          const SizedBox(width: 3),

                          const Icon(
                            Icons.verified_rounded,
                            size: 13,
                            color: Color(0xFF079F87),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        specialty,

                        maxLines: 2,

                        overflow:
                            TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 7.8,
                          height: 1.25,
                          color: Color(0xFF68728B),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // RATING

                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Color(0xFFFFB21A),
                          ),

                          const SizedBox(width: 3),

                          Text(
                            rating.toStringAsFixed(1),

                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF202744),
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),

                          const SizedBox(width: 3),

                          Flexible(
                            child: Text(
                              '($reviews)',

                              maxLines: 1,

                              overflow:
                                  TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 7,
                                color: Color(0xFF8A92A8),
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      // DISTANCE

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: Color(0xFF079F87),
                          ),

                          const SizedBox(width: 3),

                          Expanded(
                            child: Text(
                              distance,

                              maxLines: 1,

                              overflow:
                                  TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 7.5,
                                color: Color(0xFF69728D),
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          _PricingChip(
                            icon: Icons.workspace_premium_rounded,
                            label: tierName,
                            isTier: true,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: _PricingChip(
                              icon: _careModeIcon(resolvedCareMode),
                              label: _shortCareModeLabel(careModeLabel),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      const Spacer(),

                      Container(
                        width: double.infinity,
                        height: 1,
                        color:
                            const Color(0xFFEDEFF4),
                      ),

                      const SizedBox(height: 8),

                      // PRICE

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,

                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  'PLATFORM PRICE',

                                  style: TextStyle(
                                    fontSize: 6,
                                    color:
                                        Color(0xFF98A0B4),
                                    fontWeight:
                                        FontWeight.w900,
                                    letterSpacing: .4,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                Text(
                                  price,

                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1,
                                    color:
                                        Color(0xFF079F87),
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                const Text(
                                  'per session',

                                  style: TextStyle(
                                    fontSize: 6.5,
                                    color:
                                        Color(0xFF8A92A8),
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            width: 33,
                            height: 33,

                            decoration: BoxDecoration(
                              gradient:
                                  const LinearGradient(
                                begin: Alignment.topLeft,
                                end:
                                    Alignment.bottomRight,
                                colors: [
                                  Color(0xFF6C59EA),
                                  Color(0xFF5146D9),
                                ],
                              ),

                              borderRadius:
                                  BorderRadius.circular(11),

                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF5146D9,
                                  ).withOpacity(.20),

                                  blurRadius: 9,

                                  offset:
                                      const Offset(0, 4),
                                ),
                              ],
                            ),

                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // IMAGE WIDGET
  // ===============================================================

  Widget _buildProfileImage(
    String imageUrl,
  ) {
    if (imageUrl.trim().isEmpty) {
      return const Center(
        child: Icon(
          Icons.person_rounded,
          size: 52,
          color: Color(0xFF5B64D9),
        ),
      );
    }

    final isNetwork =
        imageUrl.startsWith('http://') ||
            imageUrl.startsWith('https://');

    if (isNetwork) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,

        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Center(
            child: Icon(
              Icons.person_rounded,
              size: 52,
              color: Color(0xFF5B64D9),
            ),
          );
        },
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,

      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return const Center(
          child: Icon(
            Icons.person_rounded,
            size: 52,
            color: Color(0xFF5B64D9),
          ),
        );
      },
    );
  }

  // ===============================================================
  // HELPERS
  // ===============================================================

  String _getDoctorName(
    String name,
  ) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return 'Physiotherapist';
    }

    if (trimmed.toLowerCase().startsWith('dr.')) {
      return trimmed;
    }

    return 'Dr. $trimmed';
  }

  String _getSpecialty(
    dynamic physio,
  ) {
    try {
      final value = physio.specializations;

      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
    } catch (_) {}

    try {
      final value = physio.specialization;

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    } catch (_) {}

    return 'Physiotherapy';
  }

  double _getRating(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  int _getReviews(
    dynamic physio,
  ) {
    try {
      final value = physio.reviewCount;

      if (value is num) {
        return value.toInt();
      }
    } catch (_) {}

    try {
      final value = physio.reviews;

      if (value is num) {
        return value.toInt();
      }
    } catch (_) {}

    return 0;
  }

  String _getDistance(
    PhysioMatchModel match,
  ) {
    try {
      final distance = match.distanceKm;

      if (distance < 1) {
        return '${(distance * 1000).round()} m away';
      }

      return '${distance.toStringAsFixed(1)} km away';
    } catch (_) {
      return 'Nearby';
    }
  }

  int _getExperience(dynamic physio) {
    try {
      final value = physio.experienceYears;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    } catch (_) {}
    try {
      final value = physio.experience;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    } catch (_) {}
    return 0;
  }

  String _getResolvedCareMode(dynamic physio) {
    final requested = careMode.trim().toLowerCase();
    bool enabled(String mode) {
      try {
        if (mode == PricingConfig.home) return physio.homeVisitEnabled == true;
        if (mode == PricingConfig.clinic) return physio.clinicVisitEnabled == true;
        if (mode == PricingConfig.online) return physio.onlineConsultationEnabled == true;
      } catch (_) {}
      return false;
    }
    if ((requested == PricingConfig.home || requested == PricingConfig.clinic || requested == PricingConfig.online) && enabled(requested)) return requested;
    if (enabled(PricingConfig.home)) return PricingConfig.home;
    if (enabled(PricingConfig.clinic)) return PricingConfig.clinic;
    if (enabled(PricingConfig.online)) return PricingConfig.online;
    return requested == PricingConfig.clinic ? PricingConfig.clinic : requested == PricingConfig.online ? PricingConfig.online : PricingConfig.home;
  }

  String _getTierName(dynamic physio) {
    return PricingConfig.getTierName(PricingConfig.getTierFromExperience(_getExperience(physio)));
  }

  String _getPrice(dynamic physio, String resolvedCareMode) {
    final price = PricingConfig.getSessionPrice(
      experienceYears: _getExperience(physio),
      careMode: resolvedCareMode,
    );
    return price > 0 ? '₹${price.toStringAsFixed(0)}' : '₹--';
  }

  IconData _careModeIcon(String mode) {
    switch (mode) {
      case PricingConfig.clinic: return Icons.local_hospital_rounded;
      case PricingConfig.online: return Icons.videocam_rounded;
      default: return Icons.home_rounded;
    }
  }

  String _shortCareModeLabel(String label) {
    switch (label) {
      case 'Clinic Visit': return 'Clinic';
      case 'Online Consultation': return 'Online';
      default: return 'Home';
    }
  }


  String _getImageUrl(
    dynamic physio,
  ) {
    try {
      final value =
          physio.profileImageUrl?.toString().trim();

      if (value != null && value.isNotEmpty) {
        return value;
      }
    } catch (_) {}

    try {
      final value =
          physio.profilePhotoUrl?.toString().trim();

      if (value != null && value.isNotEmpty) {
        return value;
      }
    } catch (_) {}

    try {
      final value =
          physio.imageUrl?.toString().trim();

      if (value != null && value.isNotEmpty) {
        return value;
      }
    } catch (_) {}

    return '';
  }
}