import 'package:cloud_firestore/cloud_firestore.dart';

// ================================================================
// APPOINTMENT MODEL
// ================================================================

class AppointmentModel {
  // ==============================================================
  // BASIC IDS
  // ==============================================================

  final String id;

  final String userId;

  final String? physiotherapistId;

  final String? clinicId;

  // ==============================================================
  // APPOINTMENT TYPE
  // ==============================================================
  //
  // homeVisit
  // clinicVisit
  // online
  // ==============================================================

  final String appointmentType;

  // ==============================================================
  // BOOKING STATUS
  // ==============================================================
  //
  // pending
  // confirmed
  // assigned
  // checkedIn
  // inProgress
  // completed
  // cancelled
  // rescheduled
  // noShow
  // ==============================================================

  final String status;

  // ==============================================================
  // PHYSIOTHERAPIST DETAILS
  // ==============================================================

  final String physiotherapistName;

  final String physiotherapistImageUrl;

  final String physiotherapistSpecialization;

  final bool isPhysiotherapistAssigned;

  // ==============================================================
  // CLINIC DETAILS
  // ==============================================================

  final String? clinicName;

  final String? clinicAddress;

  final String? clinicImageUrl;

  // ==============================================================
  // APPOINTMENT DATE & TIME
  // ==============================================================

  final DateTime appointmentDate;

  final String startTime;

  final String endTime;

  final int durationMinutes;

  // ==============================================================
  // LOCATION
  // ==============================================================

  final String locationLabel;

  final String? address;

  final double? latitude;

  final double? longitude;

  // ==============================================================
  // PATIENT / PROBLEM DETAILS
  // ==============================================================

  final String concern;

  final String? painArea;

  final String? patientNotes;

  final List<String> symptoms;

  // ==============================================================
  // PACKAGE DETAILS
  // ==============================================================

  final bool isPackageBooking;

  final String? packageId;

  final String? packageName;

  final int? totalSessions;

  final int? completedSessions;

  final int? remainingSessions;

  // ==============================================================
  // PRICING
  // ==============================================================

  final double consultationFee;

  final double discountAmount;

  final double totalAmount;

  final String currency;

  // ==============================================================
  // PAYMENT
  // ==============================================================
  //
  // pending
  // paid
  // failed
  // refunded
  // partial
  // ==============================================================

  final String paymentStatus;

  final String? paymentMethod;

  final String? transactionId;

  // ==============================================================
  // CANCELLATION
  // ==============================================================

  final String? cancellationReason;

  final DateTime? cancelledAt;

  final String? cancelledBy;

  // ==============================================================
  // RESCHEDULE
  // ==============================================================

  final bool isRescheduled;

  final DateTime? originalAppointmentDate;

  final String? originalStartTime;

  final String? rescheduleReason;

  // ==============================================================
  // SESSION DETAILS
  // ==============================================================

  final DateTime? checkedInAt;

  final DateTime? sessionStartedAt;

  final DateTime? sessionCompletedAt;

  // ==============================================================
  // RATING & REVIEW
  // ==============================================================

  final double? rating;

  final String? review;

  final DateTime? reviewedAt;

  // ==============================================================
  // SYSTEM TIMESTAMPS
  // ==============================================================

  final DateTime? createdAt;

  final DateTime? updatedAt;

  // ==============================================================
  // CONSTRUCTOR
  // ==============================================================

  const AppointmentModel({
    required this.id,
    required this.userId,

    this.physiotherapistId,
    this.clinicId,

    required this.appointmentType,
    required this.status,

    this.physiotherapistName = '',
    this.physiotherapistImageUrl = '',
    this.physiotherapistSpecialization = '',
    this.isPhysiotherapistAssigned = false,

    this.clinicName,
    this.clinicAddress,
    this.clinicImageUrl,

    required this.appointmentDate,
    required this.startTime,
    this.endTime = '',
    this.durationMinutes = 60,

    this.locationLabel = '',
    this.address,
    this.latitude,
    this.longitude,

    this.concern = '',
    this.painArea,
    this.patientNotes,
    this.symptoms = const [],

    this.isPackageBooking = false,
    this.packageId,
    this.packageName,
    this.totalSessions,
    this.completedSessions,
    this.remainingSessions,

    this.consultationFee = 0,
    this.discountAmount = 0,
    this.totalAmount = 0,
    this.currency = 'INR',

    this.paymentStatus = 'pending',
    this.paymentMethod,
    this.transactionId,

    this.cancellationReason,
    this.cancelledAt,
    this.cancelledBy,

    this.isRescheduled = false,
    this.originalAppointmentDate,
    this.originalStartTime,
    this.rescheduleReason,

    this.checkedInAt,
    this.sessionStartedAt,
    this.sessionCompletedAt,

    this.rating,
    this.review,
    this.reviewedAt,

    this.createdAt,
    this.updatedAt,
  });

  // ==============================================================
  // FIRESTORE → MODEL
  // ==============================================================

  factory AppointmentModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    return AppointmentModel(
      // BASIC
      id: documentId,

      userId: map['userId'] ?? '',

      physiotherapistId:
          map['physiotherapistId'],

      clinicId: map['clinicId'],

      // TYPE + STATUS
      appointmentType:
          map['appointmentType'] ?? 'homeVisit',

      status:
          map['status'] ?? 'pending',

      // PHYSIOTHERAPIST
      physiotherapistName:
          map['physiotherapistName'] ?? '',

      physiotherapistImageUrl:
          map['physiotherapistImageUrl'] ?? '',

      physiotherapistSpecialization:
          map['physiotherapistSpecialization'] ?? '',

      isPhysiotherapistAssigned:
          map['isPhysiotherapistAssigned'] ?? false,

      // CLINIC
      clinicName: map['clinicName'],

      clinicAddress: map['clinicAddress'],

      clinicImageUrl: map['clinicImageUrl'],

      // DATE + TIME
      appointmentDate:
          _dateTimeFromFirestore(
            map['appointmentDate'],
          ) ??
              DateTime.now(),

      startTime:
          map['startTime'] ?? '',

      endTime:
          map['endTime'] ?? '',

      durationMinutes:
          _toInt(
            map['durationMinutes'],
          ),

      // LOCATION
      locationLabel:
          map['locationLabel'] ?? '',

      address:
          map['address'],

      latitude:
          _toDouble(
            map['latitude'],
          ),

      longitude:
          _toDouble(
            map['longitude'],
          ),

      // PATIENT DETAILS
      concern:
          map['concern'] ?? '',

      painArea:
          map['painArea'],

      patientNotes:
          map['patientNotes'],

      symptoms:
          List<String>.from(
            map['symptoms'] ?? [],
          ),

      // PACKAGE
      isPackageBooking:
          map['isPackageBooking'] ?? false,

      packageId:
          map['packageId'],

      packageName:
          map['packageName'],

      totalSessions:
          _toNullableInt(
            map['totalSessions'],
          ),

      completedSessions:
          _toNullableInt(
            map['completedSessions'],
          ),

      remainingSessions:
          _toNullableInt(
            map['remainingSessions'],
          ),

      // PRICING
      consultationFee:
          _toDouble(
            map['consultationFee'],
          ) ??
              0,

      discountAmount:
          _toDouble(
            map['discountAmount'],
          ) ??
              0,

      totalAmount:
          _toDouble(
            map['totalAmount'],
          ) ??
              0,

      currency:
          map['currency'] ?? 'INR',

      // PAYMENT
      paymentStatus:
          map['paymentStatus'] ?? 'pending',

      paymentMethod:
          map['paymentMethod'],

      transactionId:
          map['transactionId'],

      // CANCELLATION
      cancellationReason:
          map['cancellationReason'],

      cancelledAt:
          _dateTimeFromFirestore(
            map['cancelledAt'],
          ),

      cancelledBy:
          map['cancelledBy'],

      // RESCHEDULE
      isRescheduled:
          map['isRescheduled'] ?? false,

      originalAppointmentDate:
          _dateTimeFromFirestore(
            map[
              'originalAppointmentDate'
            ],
          ),

      originalStartTime:
          map['originalStartTime'],

      rescheduleReason:
          map['rescheduleReason'],

      // SESSION
      checkedInAt:
          _dateTimeFromFirestore(
            map['checkedInAt'],
          ),

      sessionStartedAt:
          _dateTimeFromFirestore(
            map['sessionStartedAt'],
          ),

      sessionCompletedAt:
          _dateTimeFromFirestore(
            map['sessionCompletedAt'],
          ),

      // REVIEW
      rating:
          _toDouble(
            map['rating'],
          ),

      review:
          map['review'],

      reviewedAt:
          _dateTimeFromFirestore(
            map['reviewedAt'],
          ),

      // SYSTEM
      createdAt:
          _dateTimeFromFirestore(
            map['createdAt'],
          ),

      updatedAt:
          _dateTimeFromFirestore(
            map['updatedAt'],
          ),
    );
  }

  // ==============================================================
  // DOCUMENT SNAPSHOT → MODEL
  // ==============================================================

  factory AppointmentModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return AppointmentModel.fromMap(
      document.data() ?? {},
      documentId: document.id,
    );
  }

  // ==============================================================
  // MODEL → FIRESTORE
  // ==============================================================

  Map<String, dynamic> toMap() {
    return {
      // BASIC
      'userId': userId,

      'physiotherapistId':
          physiotherapistId,

      'clinicId': clinicId,

      // TYPE + STATUS
      'appointmentType':
          appointmentType,

      'status': status,

      // PHYSIOTHERAPIST
      'physiotherapistName':
          physiotherapistName,

      'physiotherapistImageUrl':
          physiotherapistImageUrl,

      'physiotherapistSpecialization':
          physiotherapistSpecialization,

      'isPhysiotherapistAssigned':
          isPhysiotherapistAssigned,

      // CLINIC
      'clinicName': clinicName,

      'clinicAddress':
          clinicAddress,

      'clinicImageUrl':
          clinicImageUrl,

      // DATE + TIME
      'appointmentDate':
          Timestamp.fromDate(
            appointmentDate,
          ),

      'startTime': startTime,

      'endTime': endTime,

      'durationMinutes':
          durationMinutes,

      // LOCATION
      'locationLabel':
          locationLabel,

      'address': address,

      'latitude': latitude,

      'longitude': longitude,

      // PATIENT DETAILS
      'concern': concern,

      'painArea': painArea,

      'patientNotes':
          patientNotes,

      'symptoms': symptoms,

      // PACKAGE
      'isPackageBooking':
          isPackageBooking,

      'packageId': packageId,

      'packageName': packageName,

      'totalSessions':
          totalSessions,

      'completedSessions':
          completedSessions,

      'remainingSessions':
          remainingSessions,

      // PRICING
      'consultationFee':
          consultationFee,

      'discountAmount':
          discountAmount,

      'totalAmount':
          totalAmount,

      'currency': currency,

      // PAYMENT
      'paymentStatus':
          paymentStatus,

      'paymentMethod':
          paymentMethod,

      'transactionId':
          transactionId,

      // CANCELLATION
      'cancellationReason':
          cancellationReason,

      'cancelledAt':
          cancelledAt != null
              ? Timestamp.fromDate(
                  cancelledAt!,
                )
              : null,

      'cancelledBy':
          cancelledBy,

      // RESCHEDULE
      'isRescheduled':
          isRescheduled,

      'originalAppointmentDate':
          originalAppointmentDate != null
              ? Timestamp.fromDate(
                  originalAppointmentDate!,
                )
              : null,

      'originalStartTime':
          originalStartTime,

      'rescheduleReason':
          rescheduleReason,

      // SESSION
      'checkedInAt':
          checkedInAt != null
              ? Timestamp.fromDate(
                  checkedInAt!,
                )
              : null,

      'sessionStartedAt':
          sessionStartedAt != null
              ? Timestamp.fromDate(
                  sessionStartedAt!,
                )
              : null,

      'sessionCompletedAt':
          sessionCompletedAt != null
              ? Timestamp.fromDate(
                  sessionCompletedAt!,
                )
              : null,

      // REVIEW
      'rating': rating,

      'review': review,

      'reviewedAt':
          reviewedAt != null
              ? Timestamp.fromDate(
                  reviewedAt!,
                )
              : null,

      // SYSTEM
      'createdAt':
          createdAt != null
              ? Timestamp.fromDate(
                  createdAt!,
                )
              : FieldValue.serverTimestamp(),

      'updatedAt':
          FieldValue.serverTimestamp(),
    };
  }

  // ==============================================================
  // COPY WITH
  // ==============================================================

  AppointmentModel copyWith({
    String? id,
    String? userId,
    String? physiotherapistId,
    String? clinicId,
    String? appointmentType,
    String? status,

    String? physiotherapistName,
    String? physiotherapistImageUrl,
    String? physiotherapistSpecialization,
    bool? isPhysiotherapistAssigned,

    String? clinicName,
    String? clinicAddress,
    String? clinicImageUrl,

    DateTime? appointmentDate,
    String? startTime,
    String? endTime,
    int? durationMinutes,

    String? locationLabel,
    String? address,
    double? latitude,
    double? longitude,

    String? concern,
    String? painArea,
    String? patientNotes,
    List<String>? symptoms,

    bool? isPackageBooking,
    String? packageId,
    String? packageName,
    int? totalSessions,
    int? completedSessions,
    int? remainingSessions,

    double? consultationFee,
    double? discountAmount,
    double? totalAmount,
    String? currency,

    String? paymentStatus,
    String? paymentMethod,
    String? transactionId,

    String? cancellationReason,
    DateTime? cancelledAt,
    String? cancelledBy,

    bool? isRescheduled,
    DateTime? originalAppointmentDate,
    String? originalStartTime,
    String? rescheduleReason,

    DateTime? checkedInAt,
    DateTime? sessionStartedAt,
    DateTime? sessionCompletedAt,

    double? rating,
    String? review,
    DateTime? reviewedAt,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,

      userId: userId ?? this.userId,

      physiotherapistId:
          physiotherapistId ??
              this.physiotherapistId,

      clinicId:
          clinicId ?? this.clinicId,

      appointmentType:
          appointmentType ??
              this.appointmentType,

      status:
          status ?? this.status,

      physiotherapistName:
          physiotherapistName ??
              this.physiotherapistName,

      physiotherapistImageUrl:
          physiotherapistImageUrl ??
              this.physiotherapistImageUrl,

      physiotherapistSpecialization:
          physiotherapistSpecialization ??
              this.physiotherapistSpecialization,

      isPhysiotherapistAssigned:
          isPhysiotherapistAssigned ??
              this.isPhysiotherapistAssigned,

      clinicName:
          clinicName ?? this.clinicName,

      clinicAddress:
          clinicAddress ??
              this.clinicAddress,

      clinicImageUrl:
          clinicImageUrl ??
              this.clinicImageUrl,

      appointmentDate:
          appointmentDate ??
              this.appointmentDate,

      startTime:
          startTime ?? this.startTime,

      endTime:
          endTime ?? this.endTime,

      durationMinutes:
          durationMinutes ??
              this.durationMinutes,

      locationLabel:
          locationLabel ??
              this.locationLabel,

      address:
          address ?? this.address,

      latitude:
          latitude ?? this.latitude,

      longitude:
          longitude ?? this.longitude,

      concern:
          concern ?? this.concern,

      painArea:
          painArea ?? this.painArea,

      patientNotes:
          patientNotes ??
              this.patientNotes,

      symptoms:
          symptoms ?? this.symptoms,

      isPackageBooking:
          isPackageBooking ??
              this.isPackageBooking,

      packageId:
          packageId ?? this.packageId,

      packageName:
          packageName ??
              this.packageName,

      totalSessions:
          totalSessions ??
              this.totalSessions,

      completedSessions:
          completedSessions ??
              this.completedSessions,

      remainingSessions:
          remainingSessions ??
              this.remainingSessions,

      consultationFee:
          consultationFee ??
              this.consultationFee,

      discountAmount:
          discountAmount ??
              this.discountAmount,

      totalAmount:
          totalAmount ??
              this.totalAmount,

      currency:
          currency ?? this.currency,

      paymentStatus:
          paymentStatus ??
              this.paymentStatus,

      paymentMethod:
          paymentMethod ??
              this.paymentMethod,

      transactionId:
          transactionId ??
              this.transactionId,

      cancellationReason:
          cancellationReason ??
              this.cancellationReason,

      cancelledAt:
          cancelledAt ?? this.cancelledAt,

      cancelledBy:
          cancelledBy ?? this.cancelledBy,

      isRescheduled:
          isRescheduled ??
              this.isRescheduled,

      originalAppointmentDate:
          originalAppointmentDate ??
              this.originalAppointmentDate,

      originalStartTime:
          originalStartTime ??
              this.originalStartTime,

      rescheduleReason:
          rescheduleReason ??
              this.rescheduleReason,

      checkedInAt:
          checkedInAt ??
              this.checkedInAt,

      sessionStartedAt:
          sessionStartedAt ??
              this.sessionStartedAt,

      sessionCompletedAt:
          sessionCompletedAt ??
              this.sessionCompletedAt,

      rating:
          rating ?? this.rating,

      review:
          review ?? this.review,

      reviewedAt:
          reviewedAt ?? this.reviewedAt,

      createdAt:
          createdAt ?? this.createdAt,

      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  // ==============================================================
  // HELPER METHODS
  // ==============================================================

  static DateTime? _dateTimeFromFirestore(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 60;

    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return 60;
  }

  static int? _toNullableInt(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return null;
  }

  static double? _toDouble(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  // ==============================================================
  // UI HELPER
  // ==============================================================

  bool get isUpcoming {
    return appointmentDate.isAfter(
      DateTime.now().subtract(
        const Duration(minutes: 1),
      ),
    );
  }

  bool get isCancelled =>
      status == 'cancelled';

  bool get isCompleted =>
      status == 'completed';

  bool get isActive {
    return !isCancelled &&
        !isCompleted;
  }

  String get displayLocation {
    switch (appointmentType) {
      case 'homeVisit':
        return 'At Home';

      case 'clinicVisit':
        return clinicName ?? 'Clinic Visit';

      case 'online':
        return 'Online Consultation';

      default:
        return locationLabel.isNotEmpty
            ? locationLabel
            : 'Appointment';
    }
  }

  String get displayPhysiotherapistName {
    if (!isPhysiotherapistAssigned) {
      return 'Physiotherapist will be assigned';
    }

    if (physiotherapistName.isEmpty) {
      return 'Physiotherapist';
    }

    return physiotherapistName;
  }

  int get packageProgressPercentage {
    if (!isPackageBooking ||
        totalSessions == null ||
        totalSessions == 0) {
      return 0;
    }

    final completed =
        completedSessions ?? 0;

    return ((completed / totalSessions!) * 100)
        .round();
  }
}