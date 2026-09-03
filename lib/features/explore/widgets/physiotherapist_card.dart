import 'package:flutter/material.dart';

import '../../core/config/pricing_config.dart';

/// Premium physiotherapist card.
///
/// IMPORTANT:
/// The [price] argument is retained for backwards compatibility, but when
/// [experience] and [careMode] are available the displayed price is calculated
/// from the platform's universal PricingConfig.
///
/// Physiotherapists never control the customer-facing price from this card.
class PhysiotherapistCard extends StatelessWidget {
  final String name;
  final String specialization;
  final String imagePath;
  final double rating;
  final int experience;
  final double distance;

  /// Legacy price fallback.
  ///
  /// Prefer [careMode] so the card can calculate the universal platform price.
  final int price;

  /// Care mode used to calculate the universal session price.
  final String? careMode;

  /// Optional explicit availability for the selected care mode.
  final bool available;

  final VoidCallback? onTap;
  final VoidCallback? onBookTap;

  const PhysiotherapistCard({
    super.key,
    required this.name,
    required this.specialization,
    required this.imagePath,
    required this.rating,
    required this.experience,
    required this.distance,
    required this.price,
    this.careMode = PricingConfig.home,
    this.available = true,
    this.onTap,
    this.onBookTap,
  });

  // ---------------------------------------------------------------------------
  // UNIVERSAL PRICING
  // ---------------------------------------------------------------------------

  double get _sessionPrice {
    if (careMode == null || careMode!.trim().isEmpty) {
      return price.toDouble();
    }

    final calculated = PricingConfig.getSessionPrice(
      experienceYears: experience,
      careMode: careMode!,
    );

    // If the config does not recognize the mode, preserve the legacy fallback.
    return calculated > 0 ? calculated : price.toDouble();
  }

  String get _tier {
    return PricingConfig.getTierFromExperience(experience);
  }

  String get _tierName {
    return PricingConfig.getTierName(_tier);
  }

  String get _careModeName {
    if (careMode == null || careMode!.trim().isEmpty) {
      return 'Session';
    }

    return PricingConfig.getCareModeName(careMode!);
  }

  IconData get _careModeIcon {
    switch (careMode?.trim().toLowerCase()) {
      case PricingConfig.clinic:
        return Icons.local_hospital_rounded;
      case PricingConfig.online:
        return Icons.videocam_rounded;
      case PricingConfig.home:
      default:
        return Icons.home_rounded;
    }
  }

  String _money(double value) => '₹${value.round()}';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label:
          '$name, $specialization, $_tierName, '
          '${_money(_sessionPrice)} per session, '
          '${distance.toStringAsFixed(1)} kilometres away',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: const Color(0xFFE6E9F1),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF26345C).withOpacity(.055),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            children: [
              // ----------------------------------------------------------------
              // PROFILE AREA
              // ----------------------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileImage(
                    imagePath: imagePath,
                    available: available,
                  ),
                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NAME + VERIFIED
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF121A3A),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.25,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: Color(0xFF079F87),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          specialization,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF737C99),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 9),

                        // RATING + EXPERIENCE
                        Row(
                          children: [
                            _RatingPill(rating: rating),
                            const SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                '$experience yrs exp.',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF737C99),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // DISTANCE + CARE MODE
                        Wrap(
                          spacing: 9,
                          runSpacing: 5,
                          children: [
                            _MetaItem(
                              icon: Icons.location_on_outlined,
                              text: '${distance.toStringAsFixed(1)} km',
                            ),
                            _MetaItem(
                              icon: _careModeIcon,
                              text: _careModeName,
                              accent: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ----------------------------------------------------------------
              // UNIVERSAL TIER + PRICE AREA
              // ----------------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FC),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFEEF0F5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _tierName.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 7,
                                    color: Color(0xFF9299AB),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: .5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.workspace_premium_rounded,
                                size: 11,
                                color: Color(0xFF5146D9),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _money(_sessionPrice),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF121A3A),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -.3,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Text(
                                '/ session',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFF737C99),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // CARE MODE CHIP
                    Container(
                      margin: const EdgeInsets.only(right: 7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F1FF),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: const Color(0xFFE4E5FA),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _careModeIcon,
                            size: 11,
                            color: const Color(0xFF5146D9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _shortCareModeName,
                            style: const TextStyle(
                              fontSize: 7.5,
                              color: Color(0xFF5146D9),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // AVAILABILITY
                    if (available)
                      Container(
                        margin: const EdgeInsets.only(right: 7),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F8F3),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 5,
                              color: Color(0xFF08A789),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Available',
                              style: TextStyle(
                                fontSize: 8,
                                color: Color(0xFF078B74),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // BOOK
                    GestureDetector(
                      onTap: available ? onBookTap : null,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          gradient: available
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF5E68E8),
                                    Color(0xFF5146D9),
                                  ],
                                )
                              : null,
                          color: available
                              ? null
                              : const Color(0xFFD8DBE5),
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: available
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF5146D9)
                                        .withOpacity(.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              available ? 'Book' : 'Unavailable',
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (available) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
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
    );
  }

  String get _shortCareModeName {
    switch (careMode?.trim().toLowerCase()) {
      case PricingConfig.clinic:
        return 'Clinic';
      case PricingConfig.online:
        return 'Online';
      case PricingConfig.home:
      default:
        return 'Home';
    }
  }
}

// ============================================================================
// PROFILE IMAGE
// ============================================================================

class _ProfileImage extends StatelessWidget {
  final String imagePath;
  final bool available;

  const _ProfileImage({
    required this.imagePath,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: SizedBox(
            width: 82,
            height: 94,
            child: _image(),
          ),
        ),
        if (available)
          Positioned(
            right: 6,
            bottom: 6,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF08A789),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _image() {
    if (imagePath.trim().isEmpty) {
      return const _ImageFallback();
    }

    // Keep the existing asset behaviour, but also support Firebase/network
    // profile URLs without forcing callers to change immediately.
    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ImageFallback(),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F3FF),
      child: const Icon(
        Icons.person_rounded,
        size: 36,
        color: Color(0xFF6974D6),
      ),
    );
  }
}

// ============================================================================
// RATING
// ============================================================================

class _RatingPill extends StatelessWidget {
  final double rating;

  const _RatingPill({
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final safeRating = rating.clamp(0.0, 5.0);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E5),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 12,
            color: Color(0xFFF5A623),
          ),
          const SizedBox(width: 3),
          Text(
            safeRating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 8.5,
              color: Color(0xFF765800),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// META ITEM
// ============================================================================

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool accent;

  const _MetaItem({
    required this.icon,
    required this.text,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent
        ? const Color(0xFF079F87)
        : const Color(0xFF66718D);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: color,
        ),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 9,
            color: color,
            fontWeight: accent ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
