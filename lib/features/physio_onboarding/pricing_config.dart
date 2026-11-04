import 'package:flutter/material.dart';

/// Pricing is controlled by the platform. Admin configuration is resolved in
/// this order: locality -> city default -> India default.
///
/// Firestore document contract:
/// physio_pricing/active {
///   version: '2026-11-v1', currency: 'INR',
///   default: { tiers: { beginner: { homeVisit: 599, ... }, ... } },
///   cities: {
///     Pune: {
///       default: { tiers: { ... } },
///       localities: { Baner: { tiers: { ... } } }
///     }
///   }
/// }
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

  factory PricingTier.fromMap(String key, Map<String, dynamic> map,
      {required PricingTier fallback}) {
    double read(String key, double old) {
      final value = map[key];
      return value is num ? value.toDouble() : old;
    }

    return PricingTier(
      key: key,
      title: (map['title'] ?? fallback.title).toString(),
      experienceLabel:
          (map['experienceLabel'] ?? fallback.experienceLabel).toString(),
      minExperience: (map['minExperience'] as num?)?.toInt() ?? fallback.minExperience,
      maxExperience: map.containsKey('maxExperience')
          ? (map['maxExperience'] as num?)?.toInt()
          : fallback.maxExperience,
      homeVisit: read('homeVisit', fallback.homeVisit),
      clinic: read('clinic', fallback.clinic),
      online: read('online', fallback.online),
      followUp: read('followUp', fallback.followUp),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'experienceLabel': experienceLabel,
        'minExperience': minExperience,
        'maxExperience': maxExperience,
        'homeVisit': homeVisit,
        'clinic': clinic,
        'online': online,
        'followUp': followUp,
      };
}

class PricingConfig {
  PricingConfig._();

  static String version = '2026-11-default-v1';
  static String currency = 'INR';

  static const List<PricingTier> _defaults = [
    PricingTier(key: 'beginner', title: 'Beginner', experienceLabel: '1–3 years', minExperience: 1, maxExperience: 3, homeVisit: 599, clinic: 499, online: 399, followUp: 399),
    PricingTier(key: 'professional', title: 'Professional', experienceLabel: '4–7 years', minExperience: 4, maxExperience: 7, homeVisit: 699, clinic: 599, online: 499, followUp: 479),
    PricingTier(key: 'expert', title: 'Expert', experienceLabel: '8–12 years', minExperience: 8, maxExperience: 12, homeVisit: 899, clinic: 749, online: 599, followUp: 599),
    PricingTier(key: 'senior_specialist', title: 'Senior Specialist', experienceLabel: '13+ years', minExperience: 13, maxExperience: null, homeVisit: 1099, clinic: 899, online: 699, followUp: 699),
  ];

  static Map<String, dynamic> _adminConfig = {};

  /// Call after reading physio_pricing/active from Firestore.
  static void configure(Map<String, dynamic>? data) {
    _adminConfig = data == null ? {} : Map<String, dynamic>.from(data);
    version = (_adminConfig['version'] ?? '2026-11-default-v1').toString();
    currency = (_adminConfig['currency'] ?? 'INR').toString();
  }

  static List<PricingTier> _parseTierSet(dynamic source, {List<PricingTier>? fallbackTiers}) {
    final sourceMap = source is Map ? Map<String, dynamic>.from(source) : <String, dynamic>{};
    final tiersMap = sourceMap['tiers'] is Map
        ? Map<String, dynamic>.from(sourceMap['tiers'])
        : sourceMap;
    return (fallbackTiers ?? _defaults).map((base) {
      final raw = tiersMap[base.key];
      return raw is Map
          ? PricingTier.fromMap(base.key, Map<String, dynamic>.from(raw), fallback: base)
          : base;
    }).toList(growable: false);
  }

  static List<PricingTier> tiersForLocation({String? city, String? locality}) {
    final platformTiers = _parseTierSet(_adminConfig['default']);
    final cities = _adminConfig['cities'] is Map
        ? Map<String, dynamic>.from(_adminConfig['cities'])
        : <String, dynamic>{};
    final cityEntry = _caseInsensitiveGet(cities, city);
    final cityMap = cityEntry is Map ? Map<String, dynamic>.from(cityEntry) : <String, dynamic>{};
    final citySource = cityMap['default'] is Map ? cityMap['default'] : cityMap;
    final cityTiers = _hasTierOverrides(citySource)
        ? _parseTierSet(citySource, fallbackTiers: platformTiers)
        : platformTiers;
    final localities = cityMap['localities'] is Map
        ? Map<String, dynamic>.from(cityMap['localities'])
        : <String, dynamic>{};
    final localityEntry = _caseInsensitiveGet(localities, locality);
    if (localityEntry is Map && _hasTierOverrides(localityEntry)) {
      return _parseTierSet(localityEntry, fallbackTiers: cityTiers);
    }
    return cityTiers;
  }

  static String sourceForLocation({String? city, String? locality}) {
    final cities = _adminConfig['cities'] is Map
        ? Map<String, dynamic>.from(_adminConfig['cities'])
        : <String, dynamic>{};
    final cityEntry = _caseInsensitiveGet(cities, city);
    final cityMap = cityEntry is Map
        ? Map<String, dynamic>.from(cityEntry)
        : <String, dynamic>{};
    final localities = cityMap['localities'] is Map
        ? Map<String, dynamic>.from(cityMap['localities'])
        : <String, dynamic>{};
    final localityEntry = _caseInsensitiveGet(localities, locality);
    if (localityEntry is Map && _hasTierOverrides(localityEntry)) {
      return 'Locality-specific rate card';
    }
    final citySource = cityMap['default'] is Map ? cityMap['default'] : cityMap;
    if (_hasTierOverrides(citySource)) return 'City default rate card';
    return 'Platform default rate card';
  }

  static bool _hasTierOverrides(dynamic source) {
    if (source is! Map) return false;
    final map = Map<String, dynamic>.from(source);
    final tiers = map['tiers'] is Map ? Map<String, dynamic>.from(map['tiers']) : map;
    return tiers.isNotEmpty;
  }

  static dynamic _caseInsensitiveGet(Map<String, dynamic> map, String? key) {
    if (key == null || key.trim().isEmpty) return null;
    for (final entry in map.entries) {
      if (entry.key.trim().toLowerCase() == key.trim().toLowerCase()) return entry.value;
    }
    return null;
  }

  static PricingTier tierForExperience(int years, {String? city, String? locality}) {
    final safeYears = years < 1 ? 1 : years;
    final available = tiersForLocation(city: city, locality: locality);
    for (final tier in available.reversed) {
      if (safeYears >= tier.minExperience) return tier;
    }
    return available.first;
  }

  static PricingTier forCity({required int experienceYears, String? city, String? locality}) =>
      tierForExperience(experienceYears, city: city, locality: locality);

  static Map<String, dynamic> firestoreSnapshot({
    required int experienceYears,
    String? city,
    String? locality,
  }) {
    final tier = forCity(experienceYears: experienceYears, city: city, locality: locality);
    return {
      'currency': currency,
      'pricingTier': tier.key,
      'pricingTierLabel': tier.title,
      'pricingExperienceBasis': experienceYears,
      'pricingCity': city ?? '',
      'pricingLocality': locality ?? '',
      'pricingConfigVersion': version,
      'homeVisitPrice': tier.homeVisit,
      'clinicVisitPrice': tier.clinic,
      'onlineConsultationPrice': tier.online,
      'followUpPrice': tier.followUp,
      'travelChargesEnabled': false,
      'travelCharges': 0.0,
      'discountAvailable': false,
      'discountPercentage': 0.0,
    };
  }
}

class PricingLocationSummary extends StatelessWidget {
  final String? city;
  final String? locality;
  final int experienceYears;
  const PricingLocationSummary({super.key, this.city, this.locality, required this.experienceYears});

  @override
  Widget build(BuildContext context) {
    final all = PricingConfig.tiersForLocation(city: city, locality: locality);
    final assigned = PricingConfig.tierForExperience(experienceYears, city: city, locality: locality);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Pricing for your service location', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      Text([locality, city].where((e) => e != null && e.trim().isNotEmpty).join(', ').isEmpty ? 'Default location rates' : [locality, city].where((e) => e != null && e.trim().isNotEmpty).join(', '), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey)),
      const SizedBox(height: 3),
      Text(PricingConfig.sourceForLocation(city: city, locality: locality), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF3478D4), fontWeight: FontWeight.w700)),
      const SizedBox(height: 14),
      Container(decoration: BoxDecoration(color: const Color(0xFF142B4A), borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.all(18), child: Row(children: [
        const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD88A), size: 30), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your assigned tier', style: TextStyle(color: Colors.white.withOpacity(.72), fontSize: 12)), Text('${assigned.title} · ${assigned.experienceLabel}', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))])),
        const Icon(Icons.verified_rounded, color: Color(0xFF8DE0B6)),
      ])),
      const SizedBox(height: 14),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF0F4F8)),
        columns: const [DataColumn(label: Text('Experience')), DataColumn(label: Text('Home')), DataColumn(label: Text('Clinic')), DataColumn(label: Text('Online')), DataColumn(label: Text('Follow-up'))],
        rows: all.map((tier) => DataRow(
          color: WidgetStateProperty.resolveWith((states) => tier.key == assigned.key ? const Color(0xFFE8F3FF) : null),
          cells: [DataCell(Text('${tier.title}\n${tier.experienceLabel}', style: TextStyle(fontWeight: tier.key == assigned.key ? FontWeight.w800 : FontWeight.w500))), DataCell(Text('₹${tier.homeVisit.toStringAsFixed(0)}')), DataCell(Text('₹${tier.clinic.toStringAsFixed(0)}')), DataCell(Text('₹${tier.online.toStringAsFixed(0)}')), DataCell(Text('₹${tier.followUp.toStringAsFixed(0)}'))],
        )).toList(),
      )),
      const SizedBox(height: 10),
      const Text('Rates are assigned by your registered service locality. If a locality has no custom rate card, city defaults apply; otherwise the platform default applies. Pricing is read-only for physiotherapists.', style: TextStyle(color: Colors.blueGrey, fontSize: 12, height: 1.5)),
    ]);
  }
}
