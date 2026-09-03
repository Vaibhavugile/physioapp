import '../models/booking_model.dart';

// ================================================================
// BOOKING PRICING SERVICE
// ================================================================
//
// This service calculates:
//
// ✓ Single session price
// ✓ Package prices
// ✓ Package discounts
// ✓ Travel charges
// ✓ Platform fees
// ✓ Taxes
// ✓ Final payable amount
//
// IMPORTANT:
//
// The physiotherapist's baseSessionPrice is the starting point.
//
// Example:
//
// Base session price = ₹799
//
// 1 Session  → ₹799
// 3 Sessions → Discount applied
// 5 Sessions → Bigger discount
// 10 Sessions → Highest discount
//
// ================================================================

class BookingPricingService {
  const BookingPricingService();

  // ==============================================================
  // PACKAGE CONFIGURATION
  // ==============================================================
  //
  // You can easily change these discounts later.
  //
  // ==============================================================

  static const Map<int, double> packageDiscounts = {
    1: 0.0,
    3: 5.0,
    5: 10.0,
    10: 15.0,
  };

  // ==============================================================
  // GET DISCOUNT PERCENTAGE
  // ==============================================================

  double getDiscountPercent(
    int totalSessions,
  ) {
    return packageDiscounts[totalSessions] ?? 0.0;
  }

  // ==============================================================
  // GET PACKAGE NAME
  // ==============================================================

  String getPackageName(
    int totalSessions,
  ) {
    switch (totalSessions) {
      case 1:
        return 'Single Session';

      case 3:
        return '3 Session Recovery Plan';

      case 5:
        return '5 Session Recovery Plan';

      case 10:
        return '10 Session Recovery Plan';

      default:
        return '$totalSessions Session Package';
    }
  }

  // ==============================================================
  // GET BOOKING TYPE
  // ==============================================================

  String getBookingType(
    int totalSessions,
  ) {
    if (totalSessions <= 1) {
      return 'singleSession';
    }

    return 'package';
  }

  // ==============================================================
  // CALCULATE PRICING
  // ==============================================================

  BookingPricingResult calculate({
    required double baseSessionPrice,
    required int totalSessions,

    double travelCharge = 0,
    double platformFee = 0,
    double taxPercent = 0,
  }) {
    // ------------------------------------------------------------
    // VALIDATION
    // ------------------------------------------------------------

    final safeBasePrice =
        baseSessionPrice < 0
            ? 0.0
            : baseSessionPrice;

    final safeSessions =
        totalSessions < 1
            ? 1
            : totalSessions;

    final safeTravelCharge =
        travelCharge < 0
            ? 0.0
            : travelCharge;

    final safePlatformFee =
        platformFee < 0
            ? 0.0
            : platformFee;

    final safeTaxPercent =
        taxPercent < 0
            ? 0.0
            : taxPercent;

    // ------------------------------------------------------------
    // SUBTOTAL
    // ------------------------------------------------------------

    final subtotal =
        safeBasePrice * safeSessions;

    // ------------------------------------------------------------
    // PACKAGE DISCOUNT
    // ------------------------------------------------------------

    final discountPercent =
        getDiscountPercent(
      safeSessions,
    );

    final discountAmount =
        subtotal * discountPercent / 100;

    // ------------------------------------------------------------
    // AMOUNT AFTER DISCOUNT
    // ------------------------------------------------------------

    final amountAfterDiscount =
        subtotal - discountAmount;

    // ------------------------------------------------------------
    // TAX
    // ------------------------------------------------------------
    //
    // Tax is calculated after package discount.
    //
    // ------------------------------------------------------------

    final taxAmount =
        amountAfterDiscount *
            safeTaxPercent /
            100;

    // ------------------------------------------------------------
    // FINAL TOTAL
    // ------------------------------------------------------------

    final totalAmount =
        amountAfterDiscount +
            safeTravelCharge +
            safePlatformFee +
            taxAmount;

    // ------------------------------------------------------------
    // RETURN RESULT
    // ------------------------------------------------------------

    return BookingPricingResult(
      baseSessionPrice:
          _round(safeBasePrice),

      totalSessions:
          safeSessions,

      subtotal:
          _round(subtotal),

      discountPercent:
          discountPercent,

      discountAmount:
          _round(discountAmount),

      travelCharge:
          _round(safeTravelCharge),

      platformFee:
          _round(safePlatformFee),

      taxPercent:
          safeTaxPercent,

      taxAmount:
          _round(taxAmount),

      totalAmount:
          _round(totalAmount),

      packageName:
          getPackageName(
        safeSessions,
      ),

      bookingType:
          getBookingType(
        safeSessions,
      ),
    );
  }

  // ==============================================================
  // CALCULATE SINGLE SESSION
  // ==============================================================

  BookingPricingResult calculateSingleSession({
    required double baseSessionPrice,
    double travelCharge = 0,
    double platformFee = 0,
    double taxPercent = 0,
  }) {
    return calculate(
      baseSessionPrice: baseSessionPrice,
      totalSessions: 1,
      travelCharge: travelCharge,
      platformFee: platformFee,
      taxPercent: taxPercent,
    );
  }

  // ==============================================================
  // CALCULATE PACKAGE
  // ==============================================================

  BookingPricingResult calculatePackage({
    required double baseSessionPrice,
    required int totalSessions,
    double travelCharge = 0,
    double platformFee = 0,
    double taxPercent = 0,
  }) {
    return calculate(
      baseSessionPrice: baseSessionPrice,
      totalSessions: totalSessions,
      travelCharge: travelCharge,
      platformFee: platformFee,
      taxPercent: taxPercent,
    );
  }

  // ==============================================================
  // GET SAVINGS
  // ==============================================================

  double getSavings({
    required double baseSessionPrice,
    required int totalSessions,
  }) {
    final result = calculate(
      baseSessionPrice: baseSessionPrice,
      totalSessions: totalSessions,
    );

    return result.discountAmount;
  }

  // ==============================================================
  // ROUND TO 2 DECIMALS
  // ==============================================================

  double _round(
    double value,
  ) {
    return double.parse(
      value.toStringAsFixed(2),
    );
  }
}

// ================================================================
// BOOKING PRICING RESULT
// ================================================================
//
// This object contains the complete calculated pricing.
//
// ==============================================================

class BookingPricingResult {
  // ==============================================================
  // BASE
  // ==============================================================

  final double baseSessionPrice;

  final int totalSessions;

  // ==============================================================
  // PACKAGE
  // ==============================================================

  final String packageName;

  final String bookingType;

  // ==============================================================
  // SUBTOTAL
  // ==============================================================

  final double subtotal;

  // ==============================================================
  // DISCOUNT
  // ==============================================================

  final double discountPercent;

  final double discountAmount;

  // ==============================================================
  // EXTRA CHARGES
  // ==============================================================

  final double travelCharge;

  final double platformFee;

  // ==============================================================
  // TAX
  // ==============================================================

  final double taxPercent;

  final double taxAmount;

  // ==============================================================
  // FINAL
  // ==============================================================

  final double totalAmount;

  const BookingPricingResult({
    required this.baseSessionPrice,
    required this.totalSessions,

    required this.packageName,
    required this.bookingType,

    required this.subtotal,

    required this.discountPercent,
    required this.discountAmount,

    required this.travelCharge,
    required this.platformFee,

    required this.taxPercent,
    required this.taxAmount,

    required this.totalAmount,
  });

  // ==============================================================
  // AMOUNT AFTER DISCOUNT
  // ==============================================================

  double get amountAfterDiscount {
    return subtotal - discountAmount;
  }

  // ==============================================================
  // IS PACKAGE
  // ==============================================================

  bool get isPackage {
    return bookingType == 'package';
  }

  // ==============================================================
  // IS SINGLE SESSION
  // ==============================================================

  bool get isSingleSession {
    return bookingType == 'singleSession';
  }

  // ==============================================================
  // TOTAL SAVINGS
  // ==============================================================

  double get totalSavings {
    return discountAmount;
  }

  // ==============================================================
  // EFFECTIVE PRICE PER SESSION
  // ==============================================================

  double get effectiveSessionPrice {
    if (totalSessions <= 0) {
      return 0;
    }

    return totalAmount / totalSessions;
  }

  // ==============================================================
  // FORMATTED PRICE
  // ==============================================================

  String formatPrice(
    double amount,
  ) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  // ==============================================================
  // DEBUG
  // ==============================================================

  @override
  String toString() {
    return '''
BookingPricingResult(
  packageName: $packageName,
  bookingType: $bookingType,
  totalSessions: $totalSessions,
  baseSessionPrice: $baseSessionPrice,
  subtotal: $subtotal,
  discountPercent: $discountPercent,
  discountAmount: $discountAmount,
  travelCharge: $travelCharge,
  platformFee: $platformFee,
  taxAmount: $taxAmount,
  totalAmount: $totalAmount,
)
''';
  }
}