import 'package:cloud_firestore/cloud_firestore.dart';

// ================================================================
// BOOKING MODEL
// ================================================================
//
// This model represents one appointment / booking between:
//
// User (Patient)
//        ↓
// Physiotherapist
//
// It supports:
//
// ✓ Single session bookings
// ✓ Multi-session packages
// ✓ Home visits
// ✓ Clinic visits
// ✓ Dynamic pricing
// ✓ Travel charges
// ✓ Payment tracking
// ✓ Booking lifecycle
// ✓ Package session tracking
//
// ================================================================

class BookingModel {
  // ==============================================================
  // IDENTIFIERS
  // ==============================================================

  final String id;

  final String userId;
  final String physiotherapistId;

  // ==============================================================
  // SNAPSHOT INFORMATION
  // ==============================================================
  //
  // We save important details as snapshots so that if a user or
  // physiotherapist later changes their profile, old bookings remain
  // historically correct.
  //
  // ==============================================================

  final String physiotherapistName;
  final String? physiotherapistPhotoUrl;
  final String? physiotherapistPhone;

  final String patientName;
  final String patientPhone;
  final String? patientEmail;

  // ==============================================================
  // BOOKING TYPE
  // ==============================================================

  /// Examples:
  ///
  /// singleSession
  /// package
  ///
  final String bookingType;

  // ==============================================================
  // SERVICE TYPE
  // ==============================================================

  /// Examples:
  ///
  /// homeVisit
  /// clinicVisit
  ///
  final String serviceType;

  // ==============================================================
  // PACKAGE INFORMATION
  // ==============================================================

  final String? packageId;
  final String? packageName;

  /// Total sessions purchased in this booking.
  ///
  /// Single session = 1
  /// Package = 3, 5, 10 etc.
  ///
  final int totalSessions;

  /// Sessions already completed.
  final int completedSessions;

  /// Sessions remaining.
  final int remainingSessions;

  /// Validity of the package.
  ///
  /// Null for a normal single-session booking if not required.
  final DateTime? packageExpiryDate;

  // ==============================================================
  // APPOINTMENT DETAILS
  // ==============================================================

  /// First / currently scheduled appointment date.
  final DateTime appointmentDate;

  /// Example:
  ///
  /// 10:00 AM
  /// 02:30 PM
  ///
  final String appointmentTime;

  /// Optional sortable time value.
  ///
  /// Example:
  ///
  /// 600 = 10:00 AM
  ///
  final int? appointmentTimeMinutes;

  // ==============================================================
  // PATIENT ADDRESS
  // ==============================================================

  final String address;

  final String? locality;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;

  final double? latitude;
  final double? longitude;

  // ==============================================================
  // DISTANCE
  // ==============================================================

  /// Distance between physiotherapist and patient.
  final double? distanceKm;

  // ==============================================================
  // PRICING
  // ==============================================================

  /// Price for one physiotherapy session.
  final double baseSessionPrice;

  /// Base session price × number of sessions.
  final double subtotal;

  /// Discount amount from package.
  final double discountAmount;

  /// Discount percentage.
  ///
  /// Example: 10.0 = 10%
  ///
  final double discountPercent;

  /// Travel charge.
  final double travelCharge;

  /// Optional platform/service fee.
  final double platformFee;

  /// GST or tax amount.
  final double taxAmount;

  /// Final amount paid by the user.
  final double totalAmount;

  // ==============================================================
  // PAYMENT
  // ==============================================================

  /// Examples:
  ///
  /// pending
  /// processing
  /// paid
  /// failed
  /// refunded
  /// partiallyRefunded
  ///
  final String paymentStatus;

  /// Examples:
  ///
  /// online
  /// cash
  /// package
  ///
  final String paymentMethod;

  /// Razorpay / payment gateway order ID.
  final String? paymentOrderId;

  /// Payment gateway payment ID.
  final String? paymentId;

  /// Payment transaction reference.
  final String? transactionId;

  /// Amount actually paid.
  final double paidAmount;

  // ==============================================================
  // BOOKING STATUS
  // ==============================================================

  /// Booking lifecycle:
  ///
  /// pendingPayment
  /// pendingAcceptance
  /// confirmed
  /// rejected
  /// cancelled
  /// physiotherapistOnTheWay
  /// arrived
  /// inProgress
  /// completed
  /// noShow
  /// refunded
  ///
  final String bookingStatus;

  // ==============================================================
  // CANCELLATION
  // ==============================================================

  final String? cancellationReason;
  final String? cancelledBy;

  final DateTime? cancelledAt;

  // ==============================================================
  // PHYSIOTHERAPIST RESPONSE
  // ==============================================================

  final DateTime? acceptedAt;
  final DateTime? rejectedAt;

  final String? rejectionReason;

  // ==============================================================
  // SESSION STATUS
  // ==============================================================

  final DateTime? physiotherapistOnTheWayAt;
  final DateTime? arrivedAt;
  final DateTime? sessionStartedAt;
  final DateTime? completedAt;

  // ==============================================================
  // PATIENT NOTES
  // ==============================================================

  final String? patientNotes;

  // ==============================================================
  // CREATED / UPDATED
  // ==============================================================

  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ==============================================================
  // CONSTRUCTOR
  // ==============================================================

  const BookingModel({
    required this.id,
    required this.userId,
    required this.physiotherapistId,

    // Physiotherapist snapshot
    required this.physiotherapistName,
    this.physiotherapistPhotoUrl,
    this.physiotherapistPhone,

    // Patient snapshot
    required this.patientName,
    required this.patientPhone,
    this.patientEmail,

    // Booking
    required this.bookingType,
    required this.serviceType,

    // Package
    this.packageId,
    this.packageName,
    required this.totalSessions,
    this.completedSessions = 0,
    required this.remainingSessions,
    this.packageExpiryDate,

    // Appointment
    required this.appointmentDate,
    required this.appointmentTime,
    this.appointmentTimeMinutes,

    // Address
    required this.address,
    this.locality,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.latitude,
    this.longitude,

    // Distance
    this.distanceKm,

    // Pricing
    required this.baseSessionPrice,
    required this.subtotal,
    this.discountAmount = 0,
    this.discountPercent = 0,
    this.travelCharge = 0,
    this.platformFee = 0,
    this.taxAmount = 0,
    required this.totalAmount,

    // Payment
    this.paymentStatus = 'pending',
    this.paymentMethod = 'online',
    this.paymentOrderId,
    this.paymentId,
    this.transactionId,
    this.paidAmount = 0,

    // Status
    this.bookingStatus = 'pendingPayment',

    // Cancellation
    this.cancellationReason,
    this.cancelledBy,
    this.cancelledAt,

    // Physio response
    this.acceptedAt,
    this.rejectedAt,
    this.rejectionReason,

    // Session tracking
    this.physiotherapistOnTheWayAt,
    this.arrivedAt,
    this.sessionStartedAt,
    this.completedAt,

    // Notes
    this.patientNotes,

    // Dates
    this.createdAt,
    this.updatedAt,
  });

  // ==============================================================
  // HELPER: IS PACKAGE
  // ==============================================================

  bool get isPackage {
    return bookingType.trim().toLowerCase() == 'package';
  }

  // ==============================================================
  // HELPER: IS SINGLE SESSION
  // ==============================================================

  bool get isSingleSession {
    return !isPackage;
  }

  // ==============================================================
  // HELPER: IS HOME VISIT
  // ==============================================================

  bool get isHomeVisit {
    return serviceType.trim().toLowerCase() == 'homevisit';
  }

  // ==============================================================
  // HELPER: IS CLINIC VISIT
  // ==============================================================

  bool get isClinicVisit {
    return serviceType.trim().toLowerCase() == 'clinicvisit';
  }

  // ==============================================================
  // HELPER: IS PAID
  // ==============================================================

  bool get isPaid {
    return paymentStatus.trim().toLowerCase() == 'paid';
  }

  // ==============================================================
  // HELPER: IS CANCELLED
  // ==============================================================

  bool get isCancelled {
    return bookingStatus.trim().toLowerCase() == 'cancelled';
  }

  // ==============================================================
  // HELPER: IS COMPLETED
  // ==============================================================

  bool get isCompleted {
    return bookingStatus.trim().toLowerCase() == 'completed';
  }

  // ==============================================================
  // HELPER: IS ACTIVE
  // ==============================================================

  bool get isActive {
    final status = bookingStatus.trim().toLowerCase();

    return status != 'completed' &&
        status != 'cancelled' &&
        status != 'rejected' &&
        status != 'refunded';
  }

  // ==============================================================
  // HELPER: PACKAGE COMPLETED
  // ==============================================================

  bool get isPackageCompleted {
    if (!isPackage) {
      return false;
    }

    return remainingSessions <= 0;
  }

  // ==============================================================
  // HELPER: PACKAGE EXPIRED
  // ==============================================================

  bool get isPackageExpired {
    if (packageExpiryDate == null) {
      return false;
    }

    return DateTime.now().isAfter(
      packageExpiryDate!,
    );
  }

  // ==============================================================
  // DISPLAY TOTAL ADDRESS
  // ==============================================================

  String get displayAddress {
    final parts = <String>[];

    if (address.trim().isNotEmpty) {
      parts.add(address.trim());
    }

    void addIfValid(String? value) {
      if (value != null && value.trim().isNotEmpty) {
        if (!parts.contains(value.trim())) {
          parts.add(value.trim());
        }
      }
    }

    addIfValid(locality);
    addIfValid(city);
    addIfValid(state);
    addIfValid(pincode);

    return parts.join(', ');
  }

  // ==============================================================
  // PRICE CALCULATION CHECK
  // ==============================================================

  double get calculatedTotal {
    return subtotal -
        discountAmount +
        travelCharge +
        platformFee +
        taxAmount;
  }

  // ==============================================================
  // COPY WITH
  // ==============================================================

  BookingModel copyWith({
    String? id,
    String? userId,
    String? physiotherapistId,

    String? physiotherapistName,
    String? physiotherapistPhotoUrl,
    String? physiotherapistPhone,

    String? patientName,
    String? patientPhone,
    String? patientEmail,

    String? bookingType,
    String? serviceType,

    String? packageId,
    String? packageName,
    int? totalSessions,
    int? completedSessions,
    int? remainingSessions,
    DateTime? packageExpiryDate,

    DateTime? appointmentDate,
    String? appointmentTime,
    int? appointmentTimeMinutes,

    String? address,
    String? locality,
    String? city,
    String? state,
    String? country,
    String? pincode,

    double? latitude,
    double? longitude,
    double? distanceKm,

    double? baseSessionPrice,
    double? subtotal,
    double? discountAmount,
    double? discountPercent,
    double? travelCharge,
    double? platformFee,
    double? taxAmount,
    double? totalAmount,

    String? paymentStatus,
    String? paymentMethod,
    String? paymentOrderId,
    String? paymentId,
    String? transactionId,
    double? paidAmount,

    String? bookingStatus,

    String? cancellationReason,
    String? cancelledBy,
    DateTime? cancelledAt,

    DateTime? acceptedAt,
    DateTime? rejectedAt,
    String? rejectionReason,

    DateTime? physiotherapistOnTheWayAt,
    DateTime? arrivedAt,
    DateTime? sessionStartedAt,
    DateTime? completedAt,

    String? patientNotes,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      physiotherapistId:
          physiotherapistId ?? this.physiotherapistId,

      physiotherapistName:
          physiotherapistName ??
              this.physiotherapistName,

      physiotherapistPhotoUrl:
          physiotherapistPhotoUrl ??
              this.physiotherapistPhotoUrl,

      physiotherapistPhone:
          physiotherapistPhone ??
              this.physiotherapistPhone,

      patientName:
          patientName ?? this.patientName,

      patientPhone:
          patientPhone ?? this.patientPhone,

      patientEmail:
          patientEmail ?? this.patientEmail,

      bookingType:
          bookingType ?? this.bookingType,

      serviceType:
          serviceType ?? this.serviceType,

      packageId:
          packageId ?? this.packageId,

      packageName:
          packageName ?? this.packageName,

      totalSessions:
          totalSessions ?? this.totalSessions,

      completedSessions:
          completedSessions ?? this.completedSessions,

      remainingSessions:
          remainingSessions ?? this.remainingSessions,

      packageExpiryDate:
          packageExpiryDate ??
              this.packageExpiryDate,

      appointmentDate:
          appointmentDate ?? this.appointmentDate,

      appointmentTime:
          appointmentTime ?? this.appointmentTime,

      appointmentTimeMinutes:
          appointmentTimeMinutes ??
              this.appointmentTimeMinutes,

      address:
          address ?? this.address,

      locality:
          locality ?? this.locality,

      city:
          city ?? this.city,

      state:
          state ?? this.state,

      country:
          country ?? this.country,

      pincode:
          pincode ?? this.pincode,

      latitude:
          latitude ?? this.latitude,

      longitude:
          longitude ?? this.longitude,

      distanceKm:
          distanceKm ?? this.distanceKm,

      baseSessionPrice:
          baseSessionPrice ?? this.baseSessionPrice,

      subtotal:
          subtotal ?? this.subtotal,

      discountAmount:
          discountAmount ?? this.discountAmount,

      discountPercent:
          discountPercent ?? this.discountPercent,

      travelCharge:
          travelCharge ?? this.travelCharge,

      platformFee:
          platformFee ?? this.platformFee,

      taxAmount:
          taxAmount ?? this.taxAmount,

      totalAmount:
          totalAmount ?? this.totalAmount,

      paymentStatus:
          paymentStatus ?? this.paymentStatus,

      paymentMethod:
          paymentMethod ?? this.paymentMethod,

      paymentOrderId:
          paymentOrderId ?? this.paymentOrderId,

      paymentId:
          paymentId ?? this.paymentId,

      transactionId:
          transactionId ?? this.transactionId,

      paidAmount:
          paidAmount ?? this.paidAmount,

      bookingStatus:
          bookingStatus ?? this.bookingStatus,

      cancellationReason:
          cancellationReason ??
              this.cancellationReason,

      cancelledBy:
          cancelledBy ?? this.cancelledBy,

      cancelledAt:
          cancelledAt ?? this.cancelledAt,

      acceptedAt:
          acceptedAt ?? this.acceptedAt,

      rejectedAt:
          rejectedAt ?? this.rejectedAt,

      rejectionReason:
          rejectionReason ??
              this.rejectionReason,

      physiotherapistOnTheWayAt:
          physiotherapistOnTheWayAt ??
              this.physiotherapistOnTheWayAt,

      arrivedAt:
          arrivedAt ?? this.arrivedAt,

      sessionStartedAt:
          sessionStartedAt ?? this.sessionStartedAt,

      completedAt:
          completedAt ?? this.completedAt,

      patientNotes:
          patientNotes ?? this.patientNotes,

      createdAt:
          createdAt ?? this.createdAt,

      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  // ==============================================================
  // FIRESTORE → MAP
  // ==============================================================

  Map<String, dynamic> toMap() {
    return {
      // Identifiers
      'id': id,
      'userId': userId,
      'physiotherapistId': physiotherapistId,

      // Physiotherapist
      'physiotherapistName': physiotherapistName,
      'physiotherapistPhotoUrl': physiotherapistPhotoUrl,
      'physiotherapistPhone': physiotherapistPhone,

      // Patient
      'patientName': patientName,
      'patientPhone': patientPhone,
      'patientEmail': patientEmail,

      // Booking
      'bookingType': bookingType,
      'serviceType': serviceType,

      // Package
      'packageId': packageId,
      'packageName': packageName,
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'remainingSessions': remainingSessions,

      'packageExpiryDate':
          packageExpiryDate != null
              ? Timestamp.fromDate(packageExpiryDate!)
              : null,

      // Appointment
      'appointmentDate':
          Timestamp.fromDate(appointmentDate),

      'appointmentTime': appointmentTime,

      'appointmentTimeMinutes':
          appointmentTimeMinutes,

      // Address
      'address': address,
      'locality': locality,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,

      'latitude': latitude,
      'longitude': longitude,

      // Distance
      'distanceKm': distanceKm,

      // Pricing
      'baseSessionPrice': baseSessionPrice,
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'discountPercent': discountPercent,
      'travelCharge': travelCharge,
      'platformFee': platformFee,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,

      // Payment
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paymentOrderId': paymentOrderId,
      'paymentId': paymentId,
      'transactionId': transactionId,
      'paidAmount': paidAmount,

      // Booking Status
      'bookingStatus': bookingStatus,

      // Cancellation
      'cancellationReason': cancellationReason,
      'cancelledBy': cancelledBy,

      'cancelledAt':
          cancelledAt != null
              ? Timestamp.fromDate(cancelledAt!)
              : null,

      // Physio Response
      'acceptedAt':
          acceptedAt != null
              ? Timestamp.fromDate(acceptedAt!)
              : null,

      'rejectedAt':
          rejectedAt != null
              ? Timestamp.fromDate(rejectedAt!)
              : null,

      'rejectionReason': rejectionReason,

      // Session Tracking
      'physiotherapistOnTheWayAt':
          physiotherapistOnTheWayAt != null
              ? Timestamp.fromDate(
                  physiotherapistOnTheWayAt!,
                )
              : null,

      'arrivedAt':
          arrivedAt != null
              ? Timestamp.fromDate(arrivedAt!)
              : null,

      'sessionStartedAt':
          sessionStartedAt != null
              ? Timestamp.fromDate(sessionStartedAt!)
              : null,

      'completedAt':
          completedAt != null
              ? Timestamp.fromDate(completedAt!)
              : null,

      // Notes
      'patientNotes': patientNotes,

      // Dates
      'createdAt':
          createdAt != null
              ? Timestamp.fromDate(createdAt!)
              : null,

      'updatedAt':
          updatedAt != null
              ? Timestamp.fromDate(updatedAt!)
              : null,
    };
  }

  // ==============================================================
  // MAP → BOOKING MODEL
  // ==============================================================

  factory BookingModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return BookingModel(
      // Identifiers
      id: (map['id'] ?? documentId ?? '').toString(),

      userId: (map['userId'] ?? '').toString(),

      physiotherapistId:
          (map['physiotherapistId'] ?? '').toString(),

      // Physiotherapist
      physiotherapistName:
          (map['physiotherapistName'] ?? '').toString(),

      physiotherapistPhotoUrl:
          map['physiotherapistPhotoUrl']?.toString(),

      physiotherapistPhone:
          map['physiotherapistPhone']?.toString(),

      // Patient
      patientName:
          (map['patientName'] ?? '').toString(),

      patientPhone:
          (map['patientPhone'] ?? '').toString(),

      patientEmail:
          map['patientEmail']?.toString(),

      // Booking
      bookingType:
          (map['bookingType'] ?? 'singleSession').toString(),

      serviceType:
          (map['serviceType'] ?? 'homeVisit').toString(),

      // Package
      packageId:
          map['packageId']?.toString(),

      packageName:
          map['packageName']?.toString(),

      totalSessions:
          _parseInt(map['totalSessions'], 1),

      completedSessions:
          _parseInt(map['completedSessions'], 0),

      remainingSessions:
          _parseInt(map['remainingSessions'], 1),

      packageExpiryDate:
          _parseDate(map['packageExpiryDate']),

      // Appointment
      appointmentDate:
          _parseDate(map['appointmentDate']) ??
              DateTime.now(),

      appointmentTime:
          (map['appointmentTime'] ?? '').toString(),

      appointmentTimeMinutes:
          _parseNullableInt(
        map['appointmentTimeMinutes'],
      ),

      // Address
      address:
          (map['address'] ?? '').toString(),

      locality:
          map['locality']?.toString(),

      city:
          map['city']?.toString(),

      state:
          map['state']?.toString(),

      country:
          map['country']?.toString(),

      pincode:
          map['pincode']?.toString(),

      latitude:
          _parseNullableDouble(
        map['latitude'],
      ),

      longitude:
          _parseNullableDouble(
        map['longitude'],
      ),

      // Distance
      distanceKm:
          _parseNullableDouble(
        map['distanceKm'],
      ),

      // Pricing
      baseSessionPrice:
          _parseDouble(
        map['baseSessionPrice'],
      ),

      subtotal:
          _parseDouble(
        map['subtotal'],
      ),

      discountAmount:
          _parseDouble(
        map['discountAmount'],
      ),

      discountPercent:
          _parseDouble(
        map['discountPercent'],
      ),

      travelCharge:
          _parseDouble(
        map['travelCharge'],
      ),

      platformFee:
          _parseDouble(
        map['platformFee'],
      ),

      taxAmount:
          _parseDouble(
        map['taxAmount'],
      ),

      totalAmount:
          _parseDouble(
        map['totalAmount'],
      ),

      // Payment
      paymentStatus:
          (map['paymentStatus'] ?? 'pending').toString(),

      paymentMethod:
          (map['paymentMethod'] ?? 'online').toString(),

      paymentOrderId:
          map['paymentOrderId']?.toString(),

      paymentId:
          map['paymentId']?.toString(),

      transactionId:
          map['transactionId']?.toString(),

      paidAmount:
          _parseDouble(
        map['paidAmount'],
      ),

      // Booking Status
      bookingStatus:
          (map['bookingStatus'] ??
                  'pendingPayment')
              .toString(),

      // Cancellation
      cancellationReason:
          map['cancellationReason']?.toString(),

      cancelledBy:
          map['cancelledBy']?.toString(),

      cancelledAt:
          _parseDate(map['cancelledAt']),

      // Physio Response
      acceptedAt:
          _parseDate(map['acceptedAt']),

      rejectedAt:
          _parseDate(map['rejectedAt']),

      rejectionReason:
          map['rejectionReason']?.toString(),

      // Session Tracking
      physiotherapistOnTheWayAt:
          _parseDate(
        map['physiotherapistOnTheWayAt'],
      ),

      arrivedAt:
          _parseDate(
        map['arrivedAt'],
      ),

      sessionStartedAt:
          _parseDate(
        map['sessionStartedAt'],
      ),

      completedAt:
          _parseDate(
        map['completedAt'],
      ),

      // Notes
      patientNotes:
          map['patientNotes']?.toString(),

      // Dates
      createdAt:
          _parseDate(
        map['createdAt'],
      ),

      updatedAt:
          _parseDate(
        map['updatedAt'],
      ),
    );
  }

  // ==============================================================
  // FIRESTORE DOCUMENT → MODEL
  // ==============================================================

  factory BookingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return BookingModel.fromMap(
      data,
      documentId: document.id,
    );
  }

  // ==============================================================
  // HELPERS
  // ==============================================================

  static DateTime? _parseDate(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static double _parseDouble(
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

  static double? _parseNullableDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static int _parseInt(
    dynamic value,
    int fallback,
  ) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        fallback;
  }

  static int? _parseNullableInt(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  // ==============================================================
  // DEBUG
  // ==============================================================

  @override
  String toString() {
    return '''
BookingModel(
  id: $id,
  userId: $userId,
  physiotherapistId: $physiotherapistId,
  physiotherapistName: $physiotherapistName,
  bookingType: $bookingType,
  serviceType: $serviceType,
  appointmentDate: $appointmentDate,
  appointmentTime: $appointmentTime,
  totalSessions: $totalSessions,
  remainingSessions: $remainingSessions,
  totalAmount: $totalAmount,
  paymentStatus: $paymentStatus,
  bookingStatus: $bookingStatus,
)
''';
  }
}