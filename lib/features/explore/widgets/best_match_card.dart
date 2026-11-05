import 'package:flutter/material.dart';

import '../models/physio_match_model.dart';
import '../../core/config/pricing_config.dart';

class BestMatchCard extends StatefulWidget {
  final PhysioMatchModel match;

  final VoidCallback? onViewProfile;

  final VoidCallback? onBookSession;

  const BestMatchCard({
    super.key,
    required this.match,
    this.onViewProfile,
    this.onBookSession,
  });

  @override
  State<BestMatchCard> createState() =>
      _BestMatchCardState();
}

class _BestMatchCardState
    extends State<BestMatchCard> {
  bool _pressed = false;

  // ==============================================================
  // GETTERS
  // ==============================================================

  dynamic get _physio =>
      widget.match.physiotherapist;

  String get _name {
    final value =
        _physio.fullName.trim();

    if (value.isEmpty) {
      return 'Physiotherapist';
    }

    if (value.toLowerCase().startsWith('dr.')) {
      return value;
    }

    return 'Dr. $value';
  }

  String get _specialization {
    final specializations =
        _physio.specializations;

    if (specializations.isEmpty) {
      return _physio.professionalTitle
              .trim()
              .isNotEmpty
          ? _physio.professionalTitle
          : 'Physiotherapist';
    }

    return specializations.take(2).join(' • ');
  }

  String get _experience {
    final years =
        _physio.experienceYears;

    if (years <= 0) {
      return 'Experienced physiotherapist';
    }

    return '$years+ years experience';
  }

  String get _rating {
    final rating =
        _physio.rating;

    if (rating <= 0) {
      return 'New';
    }

    return rating.toStringAsFixed(1);
  }

  String get _reviews {
    final reviews =
        _physio.totalReviews;

    if (reviews <= 0) {
      return 'No reviews yet';
    }

    if (reviews == 1) {
      return '(1 review)';
    }

    return '($reviews reviews)';
  }

  String get _distance {
    final distance =
        widget.match.distanceKm;

    if (distance < 1) {
      final meters =
          (distance * 1000).round();

      return '$meters m away';
    }

    return '${distance.toStringAsFixed(1)} km away';
  }

  String get _matchPercentage {
    final score =
        widget.match.matchScore;

    // Supports score stored as:
    // 0.92 OR 92

    final percentage =
        score <= 1
            ? (score * 100).round()
            : score.round();

    return '$percentage% Match';
  }

  double get _matchScoreNormalized {
    final score =
        widget.match.matchScore;

    if (score > 1) {
      return score / 100;
    }

    return score;
  }

  // ==============================================================
  // ONBOARDING PRICING SNAPSHOT
  // ==============================================================

  String get _tierName {
    final saved = (_physio.pricingTierLabel ?? '').toString().trim();
    return saved.isNotEmpty ? saved : 'Pricing tier unavailable';
  }

  String get _tierDescription {
    final experience = _physio.experienceYears;
    final location = [
      (_physio.pricingLocality ?? '').toString().trim(),
      (_physio.pricingCity ?? '').toString().trim(),
    ].where((value) => value.isNotEmpty).join(', ');
    return '$experience years of experience${location.isEmpty ? '' : ' • $location'}';
  }

  String get _careMode {
    if (_physio.homeVisitEnabled && _physio.homeVisitPrice > 0) {
      return PricingConfig.home;
    }
    if (_physio.clinicVisitEnabled && _physio.clinicVisitPrice > 0) {
      return PricingConfig.clinic;
    }
    if (_physio.onlineConsultationEnabled && _physio.onlineConsultationPrice > 0) {
      return PricingConfig.online;
    }
    return PricingConfig.home;
  }

  String get _careModeName => PricingConfig.getCareModeName(_careMode);

  IconData get _careModeIcon {
    switch (_careMode) {
      case PricingConfig.clinic:
        return Icons.local_hospital_rounded;
      case PricingConfig.online:
        return Icons.videocam_rounded;
      case PricingConfig.home:
      default:
        return Icons.home_rounded;
    }
  }

  double get _sessionPrice {
    switch (_careMode) {
      case PricingConfig.clinic:
        return _physio.clinicVisitPrice;
      case PricingConfig.online:
        return _physio.onlineConsultationPrice;
      default:
        return _physio.homeVisitPrice;
    }
  }

  String get _currencySymbol {
    switch (_physio.currency.toString().toUpperCase()) {
      case 'INR': return '₹';
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      default: return '${_physio.currency} ';
    }
  }

  String get _priceText {
    if (_sessionPrice <= 0) return 'Price unavailable';
    return '$_currencySymbol${_sessionPrice.toStringAsFixed(0)}';
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        _physio.profileImageUrl;

    return Semantics(
      button: widget.onViewProfile != null || widget.onBookSession != null,
      label:
          'Best match, $_name, $_tierName, $_careModeName, '
          '$_priceText per session, $_matchPercentage',
      child: GestureDetector(
        onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },

      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },

      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });
      },

      onTap: widget.onViewProfile,

      child: AnimatedScale(
        scale: _pressed ? .985 : 1,

        duration:
            const Duration(milliseconds: 120),

        child: Container(
          width: double.infinity,

          padding:
              const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),

            borderRadius:
                BorderRadius.circular(26),

            border: Border.all(
              color:
                  const Color(0xFFE3E6F0),
            ),

            boxShadow: [
              BoxShadow(
                color: const Color(0xFF202B50)
                    .withOpacity(.075),

                blurRadius: 26,

                offset:
                    const Offset(0, 11),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,

                    decoration: BoxDecoration(
                      gradient:
                          const LinearGradient(
                        begin:
                            Alignment.topLeft,

                        end:
                            Alignment.bottomRight,

                        colors: [
                          Color(0xFFF0EDFF),
                          Color(0xFFE8F8F5),
                        ],
                      ),

                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    child: const Icon(
                      Icons.auto_awesome_rounded,

                      size: 18,

                      color:
                          Color(0xFF6548E8),
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Best match for you',

                          style: TextStyle(
                            fontSize: 15,

                            color:
                                Color(0xFF111A3D),

                            fontWeight:
                                FontWeight.w900,

                            letterSpacing: -.35,
                          ),
                        ),

                        SizedBox(height: 2),

                        Text(
                          'Based on location & preferences',

                          style: TextStyle(
                            fontSize: 8.5,

                            color:
                                Color(0xFF858DA4),

                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==============================================
                  // MATCH SCORE
                  // ==============================================

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(0xFFE7F9F4),
                          Color(0xFFF0FAF8),
                        ],
                      ),

                      borderRadius:
                          BorderRadius.circular(14),

                      border: Border.all(
                        color:
                            const Color(0xFFD7F0EA),
                      ),
                    ),

                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        const Icon(
                          Icons.check_circle_rounded,

                          size: 12,

                          color:
                              Color(0xFF079F87),
                        ),

                        const SizedBox(width: 4),

                        Text(
                          _matchPercentage,

                          style: const TextStyle(
                            fontSize: 9,

                            color:
                                Color(0xFF078B74),

                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // PHYSIO SECTION
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==============================================
                  // PROFILE IMAGE
                  // ==============================================

                  GestureDetector(
                    onTap:
                        widget.onViewProfile,

                    behavior:
                        HitTestBehavior.opaque,

                    child: Container(
                      width: 124,
                      height: 155,

                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(21),

                        color:
                            const Color(0xFFF0F3FA),

                        border: Border.all(
                          color:
                              const Color(0xFFE3E7F1),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF26345C)
                                    .withOpacity(.06),

                            blurRadius: 13,

                            offset:
                                const Offset(0, 5),
                          ),
                        ],
                      ),

                      clipBehavior:
                          Clip.antiAlias,

                      child: Stack(
                        fit: StackFit.expand,

                        children: [
                          // ======================================
                          // NETWORK IMAGE
                          // ======================================

                          if (imageUrl != null &&
                              imageUrl
                                  .trim()
                                  .isNotEmpty)
                            Image.network(
                              imageUrl,

                              fit: BoxFit.cover,

                              alignment:
                                  Alignment.topCenter,

                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return _buildImageFallback();
                              },
                            )
                          else
                            _buildImageFallback(),

                          // ======================================
                          // IMAGE GRADIENT
                          // ======================================

                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,

                            child: Container(
                              height: 48,

                              decoration: BoxDecoration(
                                gradient:
                                    LinearGradient(
                                  begin:
                                      Alignment.topCenter,

                                  end:
                                      Alignment.bottomCenter,

                                  colors: [
                                    Colors.transparent,

                                    Colors.black
                                        .withOpacity(.12),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ======================================
                          // VERIFIED BADGE
                          // ======================================

                          if (_physio.isVerified)
                            Positioned(
                              right: 8,
                              top: 8,

                              child: Container(
                                width: 27,
                                height: 27,

                                decoration: BoxDecoration(
                                  color:
                                      Colors.white
                                          .withOpacity(.96),

                                  shape:
                                      BoxShape.circle,

                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black
                                              .withOpacity(.08),

                                      blurRadius: 8,
                                    ),
                                  ],
                                ),

                                child: const Icon(
                                  Icons.verified_rounded,

                                  size: 16,

                                  color:
                                      Color(0xFF079F87),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ==============================================
                  // DETAILS
                  // ==============================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        // ========================================
                        // NAME
                        // ========================================

                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _name,

                                maxLines: 1,

                                overflow:
                                    TextOverflow.ellipsis,

                                style:
                                    const TextStyle(
                                  fontSize: 16,

                                  color:
                                      Color(0xFF111A3D),

                                  fontWeight:
                                      FontWeight.w900,

                                  letterSpacing: -.4,
                                ),
                              ),
                            ),

                            if (_physio.isVerified) ...[
                              const SizedBox(width: 5),

                              const Icon(
                                Icons.verified_rounded,

                                size: 17,

                                color:
                                    Color(0xFF079F87),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 6),

                        // ========================================
                        // SPECIALIZATION
                        // ========================================

                        Text(
                          _specialization,

                          maxLines: 2,

                          overflow:
                              TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 10,

                            height: 1.35,

                            color:
                                Color(0xFF626C87),

                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ========================================
                        // EXPERIENCE
                        // ========================================

                        Row(
                          children: [
                            Container(
                              width: 23,
                              height: 23,

                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFF2F0FF,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                  8,
                                ),
                              ),

                              child: const Icon(
                                Icons
                                    .workspace_premium_rounded,

                                size: 13,

                                color:
                                    Color(0xFF6148DF),
                              ),
                            ),

                            const SizedBox(width: 6),

                            Expanded(
                              child: Text(
                                _experience,

                                maxLines: 1,

                                overflow:
                                    TextOverflow.ellipsis,

                                style:
                                    const TextStyle(
                                  fontSize: 9.5,

                                  color:
                                      Color(0xFF59627E),

                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 9),

                        // ========================================
                        // UNIVERSAL EXPERIENCE TIER
                        // ========================================

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F0FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE4E1FF),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                size: 12,
                                color: Color(0xFF6148DF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _tierName,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  color: Color(0xFF5146D9),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ========================================
                        // RATING
                        // ========================================

                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,

                              size: 18,

                              color:
                                  Color(0xFFFFB21A),
                            ),

                            const SizedBox(width: 4),

                            Text(
                              _rating,

                              style:
                                  const TextStyle(
                                fontSize: 12,

                                color:
                                    Color(0xFF202744),

                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),

                            const SizedBox(width: 4),

                            Expanded(
                              child: Text(
                                _reviews,

                                maxLines: 1,

                                overflow:
                                    TextOverflow.ellipsis,

                                style:
                                    const TextStyle(
                                  fontSize: 8.5,

                                  color:
                                      Color(0xFF7C849A),

                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 9),

                        // ========================================
                        // DISTANCE
                        // ========================================

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,

                              size: 16,

                              color:
                                  Color(0xFF079F87),
                            ),

                            const SizedBox(width: 4),

                            Expanded(
                              child: Text(
                                _distance,

                                maxLines: 1,

                                overflow:
                                    TextOverflow.ellipsis,

                                style:
                                    const TextStyle(
                                  fontSize: 9.5,

                                  color:
                                      Color(0xFF59627E),

                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 11),

                        // ========================================
                        // BADGES
                        // ========================================

                        Wrap(
                          spacing: 5,
                          runSpacing: 5,

                          children: [
                            _MiniBadge(
                              icon: _careModeIcon,
                              label: _careModeName,
                            ),

                            if (_physio.isVerified)
                              const _MiniBadge(
                                icon: Icons.verified_outlined,
                                label: 'Verified',
                              ),

                            _MiniBadge(
                              icon: Icons.workspace_premium_outlined,
                              label: _tierName,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // MATCH EXPLANATION
              // ==================================================

              if (_matchScoreNormalized > 0)
                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFF7F8FC),

                    borderRadius:
                        BorderRadius.circular(12),
                  ),

                  child: Row(
                    children: [
                      const Icon(
                        Icons.insights_rounded,

                        size: 15,

                        color:
                            Color(0xFF6548E8),
                      ),

                      const SizedBox(width: 7),

                      Expanded(
                        child: Text(
                          'Matched based on location, specialization and rating',

                          style:
                              const TextStyle(
                            fontSize: 8.5,

                            color:
                                Color(0xFF68718B),

                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              // ==================================================
              // BOOKING AREA
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.fromLTRB(
                  13,
                  11,
                  10,
                  10,
                ),

                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(
                    begin:
                        Alignment.topLeft,

                    end:
                        Alignment.bottomRight,

                    colors: [
                      Color(0xFFF8F9FC),
                      Color(0xFFF5F6FB),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(18),

                  border: Border.all(
                    color:
                        const Color(0xFFE8EAF1),
                  ),
                ),

                child: Row(
                  children: [
                    // ============================================
                    // PRICE
                    // ============================================

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'SESSION FROM',

                            style: TextStyle(
                              fontSize: 8,

                              color:
                                  Color(0xFF9299AB),

                              fontWeight:
                                  FontWeight.w900,

                              letterSpacing: .6,
                            ),
                          ),

                          const SizedBox(height: 3),

                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _priceText,

                                  style:
                                      const TextStyle(
                                    fontSize: 19,

                                    color:
                                        Color(0xFF079F87),

                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),

                                const TextSpan(
                                  text:
                                      ' / session',

                                  style: TextStyle(
                                    fontSize: 8.5,

                                    color:
                                        Color(0xFF737C99),

                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            '$_tierName • $_careModeName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 7.5,
                              color: Color(0xFF737C99),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ============================================
                    // PROFILE
                    // ============================================

                    GestureDetector(
                      onTap:
                          widget.onViewProfile,

                      behavior:
                          HitTestBehavior.opaque,

                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),

                          border: Border.all(
                            color:
                                const Color(
                              0xFFE0E3EC,
                            ),
                          ),
                        ),

                        child: const Text(
                          'Profile',

                          style: TextStyle(
                            fontSize: 9,

                            color:
                                Color(0xFF5146D9),

                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 7),

                    // ============================================
                    // BOOK BUTTON
                    // ============================================

                    GestureDetector(
                      onTap:
                          widget.onBookSession,

                      behavior:
                          HitTestBehavior.opaque,

                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),

                        decoration: BoxDecoration(
                          gradient:
                              const LinearGradient(
                            begin:
                                Alignment.topLeft,

                            end:
                                Alignment.bottomRight,

                            colors: [
                              Color(0xFF6A4BE8),
                              Color(0xFF5146D9),
                            ],
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(
                                0xFF5146D9,
                              ).withOpacity(.22),

                              blurRadius: 11,

                              offset:
                                  const Offset(0, 5),
                            ),
                          ],
                        ),

                        child: const Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [
                            Text(
                              'Book',

                              style: TextStyle(
                                fontSize: 9,

                                color: Colors.white,

                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),

                            SizedBox(width: 5),

                            Icon(
                              Icons
                                  .arrow_forward_rounded,

                              size: 14,

                              color: Colors.white,
                            ),
                          ],
                        ),
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

  // ==============================================================
  // IMAGE FALLBACK
  // ==============================================================

  Widget _buildImageFallback() {
    return Container(
      color:
          const Color(0xFFF0F2FA),

      child: const Center(
        child: Icon(
          Icons.person_rounded,

          size: 58,

          color:
              Color(0xFF6570D8),
        ),
      ),
    );
  }
}

// =================================================================
// MINI BADGE
// =================================================================

class _MiniBadge extends StatelessWidget {
  final IconData icon;

  final String label;

  const _MiniBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color:
            const Color(0xFFF7F8FC),

        borderRadius:
            BorderRadius.circular(8),

        border: Border.all(
          color:
              const Color(0xFFE5E7EF),
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            icon,

            size: 10,

            color:
                const Color(0xFF079F87),
          ),

          const SizedBox(width: 3),

          Text(
            label,

            style:
                const TextStyle(
              fontSize: 8,

              color:
                  Color(0xFF5E6780),

              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}