/// Platform-owned physiotherapy pricing.
/// Initial rollout: one common rate card for Pune and every other city.
/// Keep pricing changes in this file / the admin pricing configuration only.
class PricingTier {
  final String key;
  final String title;
  final String experienceLabel;
  final int minExperience;
  final int? maxExperience;
  final double homeVisit;
  final double clinic;
  final double online;
  final double followUp;

  const PricingTier({
    required this.key,
    required this.title,
    required this.experienceLabel,
    required this.minExperience,
    required this.maxExperience,
    required this.homeVisit,
    required this.clinic,
    required this.online,
    required this.followUp,
  });

  Map<String, dynamic> toMap() => {
    'key': key,
    'title': title,
    'experienceLabel': experienceLabel,
    'homeVisit': homeVisit,
    'clinic': clinic,
    'online': online,
    'followUp': followUp,
  };
}

class PricingConfig {
  PricingConfig._();

  static const String version = '2026-10-pune-all-cities-v1';
  static const String currency = 'INR';
  static const String regionKey = 'india_default';

  static const List<PricingTier> tiers = [
    PricingTier(
      key: 'beginner', title: 'Beginner', experienceLabel: '1–3 years',
      minExperience: 1, maxExperience: 3,
      homeVisit: 599, clinic: 499, online: 399, followUp: 399,
    ),
    PricingTier(
      key: 'professional', title: 'Professional', experienceLabel: '4–7 years',
      minExperience: 4, maxExperience: 7,
      homeVisit: 699, clinic: 599, online: 499, followUp: 479,
    ),
    PricingTier(
      key: 'expert', title: 'Expert', experienceLabel: '8–12 years',
      minExperience: 8, maxExperience: 12,
      homeVisit: 899, clinic: 749, online: 599, followUp: 599,
    ),
    PricingTier(
      key: 'senior_specialist', title: 'Senior Specialist', experienceLabel: '13+ years',
      minExperience: 13, maxExperience: null,
      homeVisit: 1099, clinic: 899, online: 699, followUp: 699,
    ),
  ];

  /// New physiotherapists with 0 years are assigned the entry tier provisionally.
  static PricingTier tierForExperience(int years) {
    final safeYears = years < 1 ? 1 : years;
    return tiers.lastWhere(
      (tier) => safeYears >= tier.minExperience,
      orElse: () => tiers.first,
    );
  }

  /// No city override in the initial release: Pune and all cities use this card.
  static PricingTier forCity({required int experienceYears, String? city}) =>
      tierForExperience(experienceYears);

  static Map<String, dynamic> firestoreSnapshot({
    required int experienceYears,
    String? city,
  }) {
    final tier = forCity(experienceYears: experienceYears, city: city);
    return {
      'currency': currency,
      'pricingTier': tier.key,
      'pricingTierLabel': tier.title,
      'pricingExperienceBasis': experienceYears,
      'pricingRegionKey': regionKey,
      'pricingConfigVersion': version,
      'homeVisitPrice': tier.homeVisit,
      'clinicVisitPrice': tier.clinic,
      'onlineConsultationPrice': tier.online,
      'followUpPrice': tier.followUp,
      // Travel and discounts are platform controlled; disabled in initial rollout.
      'travelChargesEnabled': false,
      'travelCharges': 0.0,
      'discountAvailable': false,
      'discountPercentage': 0.0,
    };
  }
}
