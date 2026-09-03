// ============================================================================
// PRICING CONFIG
// ============================================================================
//
// CENTRAL UNIVERSAL PRICING SYSTEM
//
// This file controls pricing for the entire platform.
//
// Pricing depends on:
//
// 1. Physiotherapist experience
// 2. Automatically assigned tier
// 3. Selected care mode
// 4. Selected package
//
// IMPORTANT:
//
// Physiotherapists DO NOT set their own prices.
//
// Every physiotherapist in the same experience tier gets the same
// platform price.
//
// ============================================================================

class PricingConfig {
  PricingConfig._();

  // ==========================================================================
  // EXPERIENCE TIERS
  // ==========================================================================

  static const String beginner = 'beginner';
  static const String professional = 'professional';
  static const String expert = 'expert';
  static const String senior = 'senior';

  // ==========================================================================
  // CARE MODES
  // ==========================================================================

  static const String home = 'home';
  static const String clinic = 'clinic';
  static const String online = 'online';

  // ==========================================================================
  // GET TIER FROM EXPERIENCE
  // ==========================================================================
  //
  // 1–3 years   → Beginner
  // 4–7 years   → Professional
  // 8–12 years  → Expert
  // 13+ years   → Senior
  //
  // ==========================================================================

  static String getTierFromExperience(
    int experienceYears,
  ) {
    if (experienceYears <= 3) {
      return beginner;
    }

    if (experienceYears <= 7) {
      return professional;
    }

    if (experienceYears <= 12) {
      return expert;
    }

    return senior;
  }

  // ==========================================================================
  // TIER DISPLAY NAME
  // ==========================================================================

  static String getTierName(
    String tier,
  ) {
    switch (tier.toLowerCase()) {
      case beginner:
        return 'Beginner';

      case professional:
        return 'Professional';

      case expert:
        return 'Expert';

      case senior:
        return 'Senior Specialist';

      default:
        return 'Beginner';
    }
  }

  // ==========================================================================
  // TIER DESCRIPTION
  // ==========================================================================

  static String getTierDescription(
    String tier,
  ) {
    switch (tier.toLowerCase()) {
      case beginner:
        return '1–3 years of experience';

      case professional:
        return '4–7 years of experience';

      case expert:
        return '8–12 years of experience';

      case senior:
        return '13+ years of experience';

      default:
        return 'Experience tier';
    }
  }

  // ==========================================================================
  // UNIVERSAL SESSION PRICING
  // ==========================================================================
  //
  // EVERY PHYSIOTHERAPIST IN THE SAME TIER HAS THE SAME PRICE.
  //
  // ==========================================================================

  static const Map<String, Map<String, double>> tierPrices = {
    // ========================================================================
    // BEGINNER
    // 1–3 YEARS
    // ========================================================================

    beginner: {
      home: 599,
      clinic: 499,
      online: 399,
    },

    // ========================================================================
    // PROFESSIONAL
    // 4–7 YEARS
    // ========================================================================

    professional: {
      home: 699,
      clinic: 599,
      online: 499,
    },

    // ========================================================================
    // EXPERT
    // 8–12 YEARS
    // ========================================================================

    expert: {
      home: 899,
      clinic: 749,
      online: 599,
    },

    // ========================================================================
    // SENIOR SPECIALIST
    // 13+ YEARS
    // ========================================================================

    senior: {
      home: 1099,
      clinic: 899,
      online: 699,
    },
  };

  // ==========================================================================
  // GET SESSION PRICE
  // ==========================================================================
  //
  // Example:
  //
  // experience = 5 years
  // tier = Professional
  // mode = Home
  //
  // Result = ₹699
  //
  // ==========================================================================

  static double getSessionPrice({
    required int experienceYears,
    required String careMode,
  }) {
    final tier = getTierFromExperience(
      experienceYears,
    );

    return getPriceForTier(
      tier: tier,
      careMode: careMode,
    );
  }

  // ==========================================================================
  // GET PRICE USING TIER
  // ==========================================================================

  static double getPriceForTier({
    required String tier,
    required String careMode,
  }) {
    final normalizedTier =
        tier.trim().toLowerCase();

    final normalizedMode =
        careMode.trim().toLowerCase();

    return tierPrices[normalizedTier]
            ?[normalizedMode] ??
        0;
  }

  // ==========================================================================
  // PACKAGE CONFIGURATION
  // ==========================================================================

  static const List<PricingPackage> packages = [
    PricingPackage(
      id: 'single',
      title: 'Single Session',
      description:
          'Perfect for trying your first session',
      visits: 1,
      discountPercent: 0,
    ),

    PricingPackage(
      id: 'recovery',
      title: 'Recovery Pack',
      description:
          'A focused plan for early recovery',
      visits: 3,
      discountPercent: 5,
      popular: true,
    ),

    PricingPackage(
      id: 'progress',
      title: 'Progress Pack',
      description:
          'Consistent sessions for better progress',
      visits: 6,
      discountPercent: 10,
    ),

    PricingPackage(
      id: 'complete',
      title: 'Complete Recovery',
      description:
          'Our best value for long-term recovery',
      visits: 10,
      discountPercent: 15,
      bestValue: true,
    ),
  ];

  // ==========================================================================
  // GET PACKAGE
  // ==========================================================================

  static PricingPackage? getPackageById(
    String packageId,
  ) {
    try {
      return packages.firstWhere(
        (package) =>
            package.id == packageId,
      );
    } catch (_) {
      return null;
    }
  }

  // ==========================================================================
  // CALCULATE ORIGINAL PACKAGE PRICE
  // ==========================================================================

  static double calculateOriginalPrice({
    required double sessionPrice,
    required int visits,
  }) {
    return sessionPrice * visits;
  }

  // ==========================================================================
  // CALCULATE DISCOUNT AMOUNT
  // ==========================================================================

  static double calculateDiscount({
    required double originalPrice,
    required double discountPercent,
  }) {
    return originalPrice *
        (discountPercent / 100);
  }

  // ==========================================================================
  // CALCULATE FINAL PACKAGE PRICE
  // ==========================================================================

  static double calculatePackagePrice({
    required double sessionPrice,
    required int visits,
    required double discountPercent,
  }) {
    final originalPrice =
        calculateOriginalPrice(
      sessionPrice: sessionPrice,
      visits: visits,
    );

    final discount =
        calculateDiscount(
      originalPrice: originalPrice,
      discountPercent: discountPercent,
    );

    return originalPrice - discount;
  }

  // ==========================================================================
  // CALCULATE PACKAGE SAVINGS
  // ==========================================================================

  static double calculateSavings({
    required double sessionPrice,
    required int visits,
    required double discountPercent,
  }) {
    final originalPrice =
        calculateOriginalPrice(
      sessionPrice: sessionPrice,
      visits: visits,
    );

    return calculateDiscount(
      originalPrice: originalPrice,
      discountPercent: discountPercent,
    );
  }

  // ==========================================================================
  // GET PACKAGE FINAL PRICE
  // ==========================================================================

  static double getPackagePrice({
    required int experienceYears,
    required String careMode,
    required PricingPackage package,
  }) {
    final sessionPrice = getSessionPrice(
      experienceYears: experienceYears,
      careMode: careMode,
    );

    return calculatePackagePrice(
      sessionPrice: sessionPrice,
      visits: package.visits,
      discountPercent:
          package.discountPercent,
    );
  }

  // ==========================================================================
  // GET COMPLETE PACKAGE PRICING
  // ==========================================================================
  //
  // This is useful for BookingDetailsScreen.
  //
  // ==========================================================================

  static PackagePricing calculatePackagePricing({
    required int experienceYears,
    required String careMode,
    required PricingPackage package,
  }) {
    final tier = getTierFromExperience(
      experienceYears,
    );

    final sessionPrice = getPriceForTier(
      tier: tier,
      careMode: careMode,
    );

    final originalPrice =
        calculateOriginalPrice(
      sessionPrice: sessionPrice,
      visits: package.visits,
    );

    final discount =
        calculateDiscount(
      originalPrice: originalPrice,
      discountPercent:
          package.discountPercent,
    );

    final finalPrice =
        originalPrice - discount;

    return PackagePricing(
      tier: tier,
      tierName: getTierName(tier),
      careMode: careMode,
      sessionPrice: sessionPrice,
      visits: package.visits,
      originalPrice: originalPrice,
      discountAmount: discount,
      discountPercent:
          package.discountPercent,
      finalPrice: finalPrice,
    );
  }

  // ==========================================================================
  // FORMAT CARE MODE
  // ==========================================================================

  static String getCareModeName(
    String careMode,
  ) {
    switch (careMode.toLowerCase()) {
      case home:
        return 'Home Visit';

      case clinic:
        return 'Clinic Visit';

      case online:
        return 'Online Consultation';

      default:
        return 'Physiotherapy Session';
    }
  }
}

// ============================================================================
// PRICING PACKAGE MODEL
// ============================================================================

class PricingPackage {
  final String id;

  final String title;

  final String description;

  final int visits;

  final double discountPercent;

  final bool popular;

  final bool bestValue;

  const PricingPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.visits,
    required this.discountPercent,
    this.popular = false,
    this.bestValue = false,
  });
}

// ============================================================================
// PACKAGE PRICING RESULT
// ============================================================================
//
// Contains the complete calculated pricing information.
//
// ============================================================================

class PackagePricing {
  final String tier;

  final String tierName;

  final String careMode;

  final double sessionPrice;

  final int visits;

  final double originalPrice;

  final double discountAmount;

  final double discountPercent;

  final double finalPrice;

  const PackagePricing({
    required this.tier,
    required this.tierName,
    required this.careMode,
    required this.sessionPrice,
    required this.visits,
    required this.originalPrice,
    required this.discountAmount,
    required this.discountPercent,
    required this.finalPrice,
  });

  // ==========================================================================
  // SAVINGS
  // ==========================================================================

  double get savings => discountAmount;

  // ==========================================================================
  // PRICE PER VISIT
  // ==========================================================================

  double get pricePerVisit {
    if (visits <= 0) {
      return 0;
    }

    return finalPrice / visits;
  }
}