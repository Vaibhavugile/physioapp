import 'package:flutter/material.dart';

import '../../core/config/pricing_config.dart';

/// Premium package card used throughout the booking flow.
///
/// Pricing is driven by [PackagePricing] from [PricingConfig].
/// The legacy constructor is intentionally kept so existing call-sites
/// do not break while the app is migrated to the universal pricing system.
class RecoveryPackageCard extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // LEGACY / DISPLAY INPUTS
  // ---------------------------------------------------------------------------

  final int visits;
  final String title;
  final String description;
  final int price;
  final int? savings;

  // ---------------------------------------------------------------------------
  // UNIVERSAL PRICING INPUT
  // ---------------------------------------------------------------------------

  /// When supplied, this is the source of truth for all displayed pricing.
  ///
  /// Do not calculate therapist-specific pricing inside this widget.
  final PackagePricing? pricing;

  // Optional contextual labels for a richer package card.
  final String? tierName;
  final String? careModeName;

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  final bool selected;
  final bool popular;
  final bool bestValue;
  final VoidCallback? onTap;

  const RecoveryPackageCard({
    super.key,
    required this.visits,
    required this.title,
    required this.description,
    required this.price,
    this.savings,
    this.pricing,
    this.tierName,
    this.careModeName,
    this.selected = false,
    this.popular = false,
    this.bestValue = false,
    this.onTap,
  });

  // ---------------------------------------------------------------------------
  // EFFECTIVE PRICING
  // ---------------------------------------------------------------------------

  double get _finalPrice {
    return pricing?.finalPrice ?? price.toDouble();
  }

  double get _originalPrice {
    return pricing?.originalPrice ?? price.toDouble();
  }

  double get _sessionPrice {
    return pricing?.sessionPrice ?? (price / (visits <= 0 ? 1 : visits));
  }

  double get _savings {
    return pricing?.savings ?? savings?.toDouble() ?? 0;
  }

  double get _discountPercent {
    return pricing?.discountPercent ?? 0;
  }

  int get _visitCount {
    return pricing?.visits ?? visits;
  }

  String get _effectiveTierName {
    return pricing?.tierName ?? tierName ?? '';
  }

  String get _effectiveCareModeName {
    return pricing?.careMode != null
        ? PricingConfig.getCareModeName(pricing!.careMode)
        : careModeName ?? '';
  }

  String _money(double value) {
    return '₹${value.round()}';
  }

  String get pricePerVisit {
    if (_visitCount <= 0) return '₹0 / visit';
    return '${_money(_finalPrice / _visitCount)} / visit';
  }

  bool get _hasDiscount {
    return _savings > 0 && _discountPercent > 0;
  }

  @override
  Widget build(BuildContext context) {
    final effectivePopular = popular;
    final effectiveBestValue = bestValue;

    return Semantics(
      button: onTap != null,
      selected: selected,
      label:
          '$title, $_visitCount ${_visitCount == 1 ? 'session' : 'sessions'}, '
          '${_money(_finalPrice)}${selected ? ', selected' : ''}',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF1EFFF),
                      Color(0xFFEAF9F6),
                    ],
                  )
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? const Color(0xFF6657E8)
                  : const Color(0xFFE2E6EF),
              width: selected ? 1.4 : .9,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? const Color(0xFF5146D9).withOpacity(.11)
                    : const Color(0xFF26345C).withOpacity(.045),
                blurRadius: selected ? 20 : 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------------------
              // TOP ROW
              // ----------------------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFEDEAFF),
                          Color(0xFFE7F9F5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _visitCount == 1
                          ? Icons.calendar_today_rounded
                          : Icons.auto_awesome_rounded,
                      size: 21,
                      color: selected
                          ? const Color(0xFF5146D9)
                          : const Color(0xFF5D64B7),
                    ),
                  ),
                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF111A3D),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -.25,
                                ),
                              ),
                            ),
                            if (effectivePopular) ...[
                              const SizedBox(width: 6),
                              const _Badge(text: 'POPULAR'),
                            ],
                            if (effectiveBestValue) ...[
                              const SizedBox(width: 6),
                              const _Badge(text: 'BEST VALUE'),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            height: 1.3,
                            color: Color(0xFF6E7791),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 23,
                    height: 23,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? const Color(0xFF079F87)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF079F87)
                            : const Color(0xFFD5D9E4),
                        width: selected ? 0 : 1.3,
                      ),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 15,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ----------------------------------------------------------------
              // UNIVERSAL PRICE
              // ----------------------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _money(_finalPrice),
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF111A3D),
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.6,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      'total',
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF7D859B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),

                  if (_hasDiscount) ...[
                    Text(
                      _money(_originalPrice),
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF9AA1B2),
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 7),
                  ],

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.82),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE0E3ED),
                      ),
                    ),
                    child: Text(
                      pricePerVisit,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF079F87),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              // Discount strip
              if (_hasDiscount) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF9F5),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_offer_rounded,
                        size: 14,
                        color: Color(0xFF079F87),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Save ${_money(_savings)} with this package',
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF087F75),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '${_discountPercent.round()}% OFF',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF079F87),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Pricing context
              if (_effectiveTierName.isNotEmpty ||
                  _effectiveCareModeName.isNotEmpty) ...[
                const SizedBox(height: 10),
                _PricingContext(
                  tierName: _effectiveTierName,
                  careModeName: _effectiveCareModeName,
                ),
              ],

              const SizedBox(height: 13),

              // ----------------------------------------------------------------
              // BENEFITS
              // ----------------------------------------------------------------
              _BenefitRow(
                icon: Icons.person_search_rounded,
                text: 'Choose any physiotherapist',
              ),
              const SizedBox(height: 7),
              _BenefitRow(
                icon: Icons.swap_horiz_rounded,
                text: 'Home or clinic for each visit',
              ),
              if (_visitCount > 1) ...[
                const SizedBox(height: 7),
                _BenefitRow(
                  icon: Icons.calendar_month_rounded,
                  text: 'Flexible appointment scheduling',
                ),
              ],

              const SizedBox(height: 14),

              // ----------------------------------------------------------------
              // VISIT COUNT
              // ----------------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(.65)
                      : const Color(0xFFF7F8FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.confirmation_number_outlined,
                      size: 15,
                      color: selected
                          ? const Color(0xFF5146D9)
                          : const Color(0xFF69728D),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _visitCount == 1
                            ? '1 physiotherapy session'
                            : '$_visitCount physiotherapy sessions',
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF59627E),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      selected ? 'Selected' : 'Select plan',
                      style: TextStyle(
                        fontSize: 9,
                        color: selected
                            ? const Color(0xFF079F87)
                            : const Color(0xFF5146D9),
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
    );
  }
}

// ============================================================================
// PRICING CONTEXT
// ============================================================================

class _PricingContext extends StatelessWidget {
  final String tierName;
  final String careModeName;

  const _PricingContext({
    required this.tierName,
    required this.careModeName,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 6,
      children: [
        if (tierName.isNotEmpty)
          _ContextChip(
            icon: Icons.workspace_premium_rounded,
            label: tierName,
          ),
        if (careModeName.isNotEmpty)
          _ContextChip(
            icon: Icons.medical_services_rounded,
            label: careModeName,
          ),
      ],
    );
  }
}

class _ContextChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContextChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3FF),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFE5E2FF),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: const Color(0xFF5146D9),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8.5,
              color: Color(0xFF5146D9),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BADGE
// ============================================================================

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6657E8),
            Color(0xFF5146D9),
          ],
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 6.5,
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: .25,
        ),
      ),
    );
  }
}

// ============================================================================
// BENEFIT ROW
// ============================================================================

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F1FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: const Color(0xFF5146D9),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 9.5,
              color: Color(0xFF626C86),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Icon(
          Icons.check_rounded,
          size: 15,
          color: Color(0xFF079F87),
        ),
      ],
    );
  }
}
