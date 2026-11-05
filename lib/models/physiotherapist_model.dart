import 'package:cloud_firestore/cloud_firestore.dart';

// ================================================================
// PHYSIOTHERAPIST MODEL
// ================================================================
//
// Complete model for:
//
// 1. Basic Information
// 2. Professional Details
// 3. Education & Qualifications
// 4. Specializations
// 5. Experience & Work
// 6. Fees & Pricing
// 7. Availability
// 8. Professional Verification
// 9. Review & Submission
//
// ================================================================

class PhysiotherapistModel {
  // ==============================================================
  // IDENTITY
  // ==============================================================

  final String uid;

  final String fullName;

  final String phone;

  final String email;

  final String? profileImageUrl;

  final String gender;

  final DateTime? dateOfBirth;

  // ==============================================================
  // PROFESSIONAL DETAILS
  // ==============================================================

  final String professionalTitle;

  final String registrationNumber;

  final String registrationCouncil;

  final String registrationState;

  final String primarySpecialization;

  // ==============================================================
  // EDUCATION & QUALIFICATIONS
  // ==============================================================

  final List<Map<String, dynamic>> qualifications;

  final List<Map<String, dynamic>> certifications;

  // Legacy/simple fields for easier searching/display

  final String qualification;

  final String university;

  final int graduationYear;

  // ==============================================================
  // SPECIALIZATIONS
  // ==============================================================

  final List<String> specializations;

  // ==============================================================
  // EXPERIENCE & WORK
  // ==============================================================

  final int experienceYears;

  final String employmentStatus;

  final String currentOrganization;

  final String professionalBio;

  final List<String> languages;

  // ==============================================================
  // SERVICES
  // ==============================================================

  final bool homeVisitEnabled;

  final bool clinicVisitEnabled;

  final bool onlineConsultationEnabled;

  final bool emergencyAvailable;

  // ==============================================================
  // LOCATION
  // ==============================================================

  final String clinicName;

  final String address;

  final String city;

  final String locality;

  final String state;

  final String pincode;

  final double latitude;

  final double longitude;

  final int homeVisitRadiusKm;

  // ==============================================================
  // AVAILABILITY
  // ==============================================================

  final List<String> workingDays;

  final String startTime;

  final String endTime;

  final Map<String, dynamic> availability;

  final Map<String, dynamic> serviceSchedules;

  final int sessionDurationMinutes;

  final int maxAppointmentsPerDay;

  // ==============================================================
  // PRICING
  // ==============================================================

  final String currency;

  /// Platform pricing snapshot assigned during physiotherapist onboarding.
  final String pricingTier;
  final String pricingTierLabel;
  final int pricingExperienceBasis;
  final String pricingCity;
  final String pricingLocality;
  final String pricingConfigVersion;

  final double homeVisitPrice;

  final double clinicVisitPrice;

  final double onlineConsultationPrice;

  final double followUpPrice;

  final bool travelChargesEnabled;

  final double travelCharges;

  final bool discountAvailable;

  final double discountPercentage;

  // ==============================================================
  // DOCUMENTS
  // ==============================================================

  final String? registrationCertificateUrl;

  final String? degreeCertificateUrl;

  final String? governmentIdUrl;

  final List<String> additionalCertificateUrls;

  // ==============================================================
  // VERIFICATION
  // ==============================================================

  final bool registrationCertificateUploaded;

  final bool degreeCertificateUploaded;

  final bool identityDocumentUploaded;

  final String verificationStatus;

  final bool isVerified;

  final String? rejectionReason;

  // ==============================================================
  // PROFILE STATUS
  // ==============================================================

  final bool isActive;

  final bool isFeatured;

  final bool isProfileCompleted;

  final int onboardingStep;

  // ==============================================================
  // STATISTICS
  // ==============================================================

  final double rating;

  final int totalReviews;

  final int totalAppointments;

  final int completedAppointments;

  // ==============================================================
  // TIMESTAMPS
  // ==============================================================

  final DateTime? createdAt;

  final DateTime? updatedAt;

  // ==============================================================
  // CONSTRUCTOR
  // ==============================================================

  const PhysiotherapistModel({
    // Identity
    required this.uid,
    required this.fullName,
    required this.phone,
    required this.email,
    this.profileImageUrl,
    required this.gender,
    this.dateOfBirth,

    // Professional
    required this.professionalTitle,
    required this.registrationNumber,
    required this.registrationCouncil,
    required this.registrationState,
    required this.primarySpecialization,

    // Education
    required this.qualifications,
    this.certifications = const [],
    required this.qualification,
    required this.university,
    required this.graduationYear,

    // Specializations
    required this.specializations,

    // Experience
    required this.experienceYears,
    required this.employmentStatus,
    required this.currentOrganization,
    required this.professionalBio,
    required this.languages,

    // Services
    required this.homeVisitEnabled,
    required this.clinicVisitEnabled,
    required this.onlineConsultationEnabled,
    required this.emergencyAvailable,

    // Location
    required this.clinicName,
    required this.address,
    required this.city,
    this.locality = '',
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.homeVisitRadiusKm,

    // Availability
    required this.workingDays,
    required this.startTime,
    required this.endTime,
    required this.availability,
    this.serviceSchedules = const {},
    required this.sessionDurationMinutes,
    required this.maxAppointmentsPerDay,

    // Pricing
    required this.currency,
    this.pricingTier = '',
    this.pricingTierLabel = '',
    this.pricingExperienceBasis = 0,
    this.pricingCity = '',
    this.pricingLocality = '',
    this.pricingConfigVersion = '',
    required this.homeVisitPrice,
    required this.clinicVisitPrice,
    required this.onlineConsultationPrice,
    required this.followUpPrice,
    required this.travelChargesEnabled,
    required this.travelCharges,
    required this.discountAvailable,
    required this.discountPercentage,

    // Documents
    this.registrationCertificateUrl,
    this.degreeCertificateUrl,
    this.governmentIdUrl,
    required this.additionalCertificateUrls,

    // Verification
    required this.registrationCertificateUploaded,
    required this.degreeCertificateUploaded,
    required this.identityDocumentUploaded,
    required this.verificationStatus,
    required this.isVerified,
    this.rejectionReason,

    // Profile status
    required this.isActive,
    required this.isFeatured,
    required this.isProfileCompleted,
    required this.onboardingStep,

    // Statistics
    required this.rating,
    required this.totalReviews,
    required this.totalAppointments,
    required this.completedAppointments,

    // Timestamps
    this.createdAt,
    this.updatedAt,
  });

  // ==============================================================
  // EMPTY MODEL
  // ==============================================================

  factory PhysiotherapistModel.empty({
    required String uid,
    required String phone,
  }) {
    return PhysiotherapistModel(
      // Identity
      uid: uid,
      fullName: '',
      phone: phone,
      email: '',
      profileImageUrl: null,
      gender: '',
      dateOfBirth: null,

      // Professional
      professionalTitle: 'Physiotherapist',
      registrationNumber: '',
      registrationCouncil: '',
      registrationState: '',
      primarySpecialization: '',

      // Education
      qualifications: const [],
      certifications: const [],
      qualification: '',
      university: '',
      graduationYear: 0,

      // Specializations
      specializations: const [],

      // Experience
      experienceYears: 0,
      employmentStatus: '',
      currentOrganization: '',
      professionalBio: '',
      languages: const [],

      // Services
      homeVisitEnabled: false,
      clinicVisitEnabled: false,
      onlineConsultationEnabled: false,
      emergencyAvailable: false,

      // Location
      clinicName: '',
      address: '',
      city: '',
      locality: '',
      state: '',
      pincode: '',
      latitude: 0,
      longitude: 0,
      homeVisitRadiusKm: 0,

      // Availability
      workingDays: const [],
      startTime: '09:00 AM',
      endTime: '06:00 PM',
      availability: const {},
      serviceSchedules: const {},
      sessionDurationMinutes: 60,
      maxAppointmentsPerDay: 10,

      // Pricing
      currency: 'INR',
      homeVisitPrice: 0,
      clinicVisitPrice: 0,
      onlineConsultationPrice: 0,
      followUpPrice: 0,
      travelChargesEnabled: false,
      travelCharges: 0,
      discountAvailable: false,
      discountPercentage: 0,

      // Documents
      registrationCertificateUrl: null,
      degreeCertificateUrl: null,
      governmentIdUrl: null,
      additionalCertificateUrls: const [],

      // Verification
      registrationCertificateUploaded: false,
      degreeCertificateUploaded: false,
      identityDocumentUploaded: false,
      verificationStatus: 'draft',
      isVerified: false,
      rejectionReason: null,

      // Profile
      isActive: false,
      isFeatured: false,
      isProfileCompleted: false,
      onboardingStep: 0,

      // Statistics
      rating: 0,
      totalReviews: 0,
      totalAppointments: 0,
      completedAppointments: 0,

      // Timestamps
      createdAt: null,
      updatedAt: null,
    );
  }

  // ==============================================================
  // FROM FIRESTORE
  // ==============================================================

  factory PhysiotherapistModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};

    return PhysiotherapistModel.fromMap(
      {
        ...data,
        'uid': data['uid'] ?? snapshot.id,
      },
    );
  }

  // ==============================================================
  // FROM MAP
  // ==============================================================

  factory PhysiotherapistModel.fromMap(
    Map<String, dynamic> data,
  ) {
    return PhysiotherapistModel(
      // ==========================================================
      // IDENTITY
      // ==========================================================

      uid: data['uid'] ?? '',

      fullName: data['fullName'] ?? '',

      phone: data['phone'] ?? '',

      email: data['email'] ?? '',

      profileImageUrl:
          data['profileImageUrl'] as String?,

      gender: data['gender'] ?? '',

      dateOfBirth:
          _timestampToDateTime(
        data['dateOfBirth'],
      ),

      // ==========================================================
      // PROFESSIONAL
      // ==========================================================

      professionalTitle:
          data['professionalTitle'] ??
              'Physiotherapist',

      registrationNumber:
          data['registrationNumber'] ?? '',

      registrationCouncil:
          data['registrationCouncil'] ?? '',

      registrationState:
          data['registrationState'] ?? '',

      primarySpecialization:
          data['primarySpecialization'] ?? '',

      // ==========================================================
      // EDUCATION
      // ==========================================================

      qualifications:
          _mapList(
        data['qualifications'],
      ),

      certifications:
          _mapList(
        data['certifications'],
      ),

      qualification:
          data['qualification'] ?? '',

      university:
          data['university'] ?? '',

      graduationYear:
          _toInt(
        data['graduationYear'],
      ),

      // ==========================================================
      // SPECIALIZATIONS
      // ==========================================================

      specializations:
          _stringList(
        data['specializations'],
      ),

      // ==========================================================
      // EXPERIENCE
      // ==========================================================

      experienceYears:
          _toInt(
        data['experienceYears'],
      ),

      employmentStatus:
          data['employmentStatus'] ?? '',

      currentOrganization:
          data['currentOrganization'] ?? '',

      professionalBio:
          data['professionalBio'] ??
              data['bio'] ??
              '',

      languages:
          _stringList(
        data['languages'],
      ),

      // ==========================================================
      // SERVICES
      // ==========================================================

      homeVisitEnabled:
          data['homeVisitEnabled'] ?? false,

      clinicVisitEnabled:
          data['clinicVisitEnabled'] ?? false,

      onlineConsultationEnabled:
          data['onlineConsultationEnabled'] ??
              false,

      emergencyAvailable:
          data['emergencyAvailable'] ?? false,

      // ==========================================================
      // LOCATION
      // ==========================================================

      clinicName:
          data['clinicName'] ?? '',

      address:
          data['address'] ?? '',

      city:
          data['city'] ?? '',

      locality:
          data['locality'] ?? '',

      state:
          data['state'] ?? '',

      pincode:
          data['pincode'] ?? '',

      latitude:
          _toDouble(
        data['latitude'],
      ),

      longitude:
          _toDouble(
        data['longitude'],
      ),

      homeVisitRadiusKm:
          _toInt(
        data['homeVisitRadiusKm'],
      ),

      // ==========================================================
      // AVAILABILITY
      // ==========================================================

      workingDays:
          _stringList(
        data['workingDays'],
      ),

      startTime:
          data['startTime'] ??
              '09:00 AM',

      endTime:
          data['endTime'] ??
              '06:00 PM',

      availability:
          _map(
        data['availability'],
      ),

      serviceSchedules:
          _map(data['serviceSchedules']),

      sessionDurationMinutes:
          _toInt(
        data['sessionDurationMinutes'],
        defaultValue: 60,
      ),

      maxAppointmentsPerDay:
          _toInt(
        data['maxAppointmentsPerDay'],
        defaultValue: 10,
      ),

      // ==========================================================
      // PRICING
      // ==========================================================

      currency:
          data['currency'] ?? 'INR',

      pricingTier: (data['pricingTier'] ?? '').toString(),
      pricingTierLabel: (data['pricingTierLabel'] ?? '').toString(),
      pricingExperienceBasis: _toInt(data['pricingExperienceBasis']),
      pricingCity: (data['pricingCity'] ?? '').toString(),
      pricingLocality: (data['pricingLocality'] ?? '').toString(),
      pricingConfigVersion: (data['pricingConfigVersion'] ?? '').toString(),

      homeVisitPrice:
          _toDouble(
        data['homeVisitPrice'],
      ),

      clinicVisitPrice:
          _toDouble(
        data['clinicVisitPrice'],
      ),

      onlineConsultationPrice:
          _toDouble(
        data['onlineConsultationPrice'],
      ),

      followUpPrice:
          _toDouble(
        data['followUpPrice'] ??
            data['followUpFee'],
      ),

      travelChargesEnabled:
          data['travelChargesEnabled'] ??
              false,

      travelCharges:
          _toDouble(
        data['travelCharges'],
      ),

      discountAvailable:
          data['discountAvailable'] ?? false,

      discountPercentage:
          _toDouble(
        data['discountPercentage'],
      ),

      // ==========================================================
      // DOCUMENTS
      // ==========================================================

      registrationCertificateUrl:
          data['registrationCertificateUrl']
              as String?,

      degreeCertificateUrl:
          data['degreeCertificateUrl']
              as String?,

      governmentIdUrl:
          data['governmentIdUrl']
              as String?,

      additionalCertificateUrls:
          _stringList(
        data['additionalCertificateUrls'],
      ),

      // ==========================================================
      // VERIFICATION
      // ==========================================================

      registrationCertificateUploaded:
          data['registrationCertificateUploaded'] ??
              false,

      degreeCertificateUploaded:
          data['degreeCertificateUploaded'] ??
              false,

      identityDocumentUploaded:
          data['identityDocumentUploaded'] ??
              false,

      verificationStatus:
          data['verificationStatus'] ??
              'draft',

      isVerified:
          data['isVerified'] ?? false,

      rejectionReason:
          data['rejectionReason'] as String?,

      // ==========================================================
      // PROFILE STATUS
      // ==========================================================

      isActive:
          data['isActive'] ?? false,

      isFeatured:
          data['isFeatured'] ?? false,

      isProfileCompleted:
          data['isProfileCompleted'] ??
              false,

      onboardingStep:
          _toInt(
        data['onboardingStep'],
      ),

      // ==========================================================
      // STATISTICS
      // ==========================================================

      rating:
          _toDouble(
        data['rating'],
      ),

      totalReviews:
          _toInt(
        data['totalReviews'],
      ),

      totalAppointments:
          _toInt(
        data['totalAppointments'],
      ),

      completedAppointments:
          _toInt(
        data['completedAppointments'],
      ),

      // ==========================================================
      // TIMESTAMPS
      // ==========================================================

      createdAt:
          _timestampToDateTime(
        data['createdAt'],
      ),

      updatedAt:
          _timestampToDateTime(
        data['updatedAt'],
      ),
    );
  }

  // ==============================================================
  // TO FIRESTORE
  // ==============================================================

  Map<String, dynamic> toFirestore() {
    return {
      // ==========================================================
      // IDENTITY
      // ==========================================================

      'uid': uid,

      'fullName': fullName,

      'phone': phone,

      'email': email,

      'profileImageUrl': profileImageUrl,

      'gender': gender,

      'dateOfBirth':
          dateOfBirth != null
              ? Timestamp.fromDate(
                  dateOfBirth!,
                )
              : null,

      // ==========================================================
      // PROFESSIONAL
      // ==========================================================

      'professionalTitle':
          professionalTitle,

      'registrationNumber':
          registrationNumber,

      'registrationCouncil':
          registrationCouncil,

      'registrationState':
          registrationState,

      'primarySpecialization':
          primarySpecialization,

      // ==========================================================
      // EDUCATION
      // ==========================================================

      'qualifications':
          qualifications,

      'certifications':
          certifications,

      'qualification':
          qualification,

      'university':
          university,

      'graduationYear':
          graduationYear,

      // ==========================================================
      // SPECIALIZATIONS
      // ==========================================================

      'specializations':
          specializations,

      // ==========================================================
      // EXPERIENCE
      // ==========================================================

      'experienceYears':
          experienceYears,

      'employmentStatus':
          employmentStatus,

      'currentOrganization':
          currentOrganization,

      'professionalBio':
          professionalBio,

      'bio':
          professionalBio,

      'languages':
          languages,

      // ==========================================================
      // SERVICES
      // ==========================================================

      'homeVisitEnabled':
          homeVisitEnabled,

      'clinicVisitEnabled':
          clinicVisitEnabled,

      'onlineConsultationEnabled':
          onlineConsultationEnabled,

      'emergencyAvailable':
          emergencyAvailable,

      // ==========================================================
      // LOCATION
      // ==========================================================

      'clinicName':
          clinicName,

      'address':
          address,

      'city':
          city,

      'locality':
          locality,

      'state':
          state,

      'pincode':
          pincode,

      'latitude':
          latitude,

      'longitude':
          longitude,

      'homeVisitRadiusKm':
          homeVisitRadiusKm,

      // ==========================================================
      // AVAILABILITY
      // ==========================================================

      'workingDays':
          workingDays,

      'startTime':
          startTime,

      'endTime':
          endTime,

      'availability':
          availability,

      'serviceSchedules':
          serviceSchedules,

      'sessionDurationMinutes':
          sessionDurationMinutes,

      'maxAppointmentsPerDay':
          maxAppointmentsPerDay,

      // ==========================================================
      // PRICING
      // ==========================================================

      'currency':
          currency,

      'pricingTier': pricingTier,
      'pricingTierLabel': pricingTierLabel,
      'pricingExperienceBasis': pricingExperienceBasis,
      'pricingCity': pricingCity,
      'pricingLocality': pricingLocality,
      'pricingConfigVersion': pricingConfigVersion,

      'homeVisitPrice':
          homeVisitPrice,

      'clinicVisitPrice':
          clinicVisitPrice,

      'onlineConsultationPrice':
          onlineConsultationPrice,

      'followUpPrice':
          followUpPrice,

      'travelChargesEnabled':
          travelChargesEnabled,

      'travelCharges':
          travelCharges,

      'discountAvailable':
          discountAvailable,

      'discountPercentage':
          discountPercentage,

      // ==========================================================
      // DOCUMENTS
      // ==========================================================

      'registrationCertificateUrl':
          registrationCertificateUrl,

      'degreeCertificateUrl':
          degreeCertificateUrl,

      'governmentIdUrl':
          governmentIdUrl,

      'additionalCertificateUrls':
          additionalCertificateUrls,

      // ==========================================================
      // VERIFICATION
      // ==========================================================

      'registrationCertificateUploaded':
          registrationCertificateUploaded,

      'degreeCertificateUploaded':
          degreeCertificateUploaded,

      'identityDocumentUploaded':
          identityDocumentUploaded,

      'verificationStatus':
          verificationStatus,

      'isVerified':
          isVerified,

      'rejectionReason':
          rejectionReason,

      // ==========================================================
      // PROFILE STATUS
      // ==========================================================

      'isActive':
          isActive,

      'isFeatured':
          isFeatured,

      'isProfileCompleted':
          isProfileCompleted,

      'onboardingStep':
          onboardingStep,

      // ==========================================================
      // STATISTICS
      // ==========================================================

      'rating':
          rating,

      'totalReviews':
          totalReviews,

      'totalAppointments':
          totalAppointments,

      'completedAppointments':
          completedAppointments,
    };
  }

  // ==============================================================
  // TO MAP
  // ==============================================================

  Map<String, dynamic> toMap() {
    return {
      ...toFirestore(),

      'createdAt':
          createdAt != null
              ? Timestamp.fromDate(
                  createdAt!,
                )
              : null,

      'updatedAt':
          updatedAt != null
              ? Timestamp.fromDate(
                  updatedAt!,
                )
              : null,
    };
  }

  // ==============================================================
  // COPY WITH
  // ==============================================================

  PhysiotherapistModel copyWith({
    String? uid,
    String? fullName,
    String? phone,
    String? email,
    String? profileImageUrl,
    String? gender,
    DateTime? dateOfBirth,

    String? professionalTitle,
    String? registrationNumber,
    String? registrationCouncil,
    String? registrationState,
    String? primarySpecialization,

    List<Map<String, dynamic>>? qualifications,
    List<Map<String, dynamic>>? certifications,
    String? qualification,
    String? university,
    int? graduationYear,

    List<String>? specializations,

    int? experienceYears,
    String? employmentStatus,
    String? currentOrganization,
    String? professionalBio,
    List<String>? languages,

    bool? homeVisitEnabled,
    bool? clinicVisitEnabled,
    bool? onlineConsultationEnabled,
    bool? emergencyAvailable,

    String? clinicName,
    String? address,
    String? city,
    String? locality,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
    int? homeVisitRadiusKm,

    List<String>? workingDays,
    String? startTime,
    String? endTime,
    Map<String, dynamic>? availability,
    Map<String, dynamic>? serviceSchedules,
    int? sessionDurationMinutes,
    int? maxAppointmentsPerDay,

    String? currency,
    String? pricingTier,
    String? pricingTierLabel,
    int? pricingExperienceBasis,
    String? pricingCity,
    String? pricingLocality,
    String? pricingConfigVersion,
    double? homeVisitPrice,
    double? clinicVisitPrice,
    double? onlineConsultationPrice,
    double? followUpPrice,
    bool? travelChargesEnabled,
    double? travelCharges,
    bool? discountAvailable,
    double? discountPercentage,

    String? registrationCertificateUrl,
    String? degreeCertificateUrl,
    String? governmentIdUrl,
    List<String>? additionalCertificateUrls,

    bool? registrationCertificateUploaded,
    bool? degreeCertificateUploaded,
    bool? identityDocumentUploaded,
    String? verificationStatus,
    bool? isVerified,
    String? rejectionReason,

    bool? isActive,
    bool? isFeatured,
    bool? isProfileCompleted,
    int? onboardingStep,

    double? rating,
    int? totalReviews,
    int? totalAppointments,
    int? completedAppointments,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PhysiotherapistModel(
      // Identity
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImageUrl:
          profileImageUrl ??
              this.profileImageUrl,
      gender: gender ?? this.gender,
      dateOfBirth:
          dateOfBirth ??
              this.dateOfBirth,

      // Professional
      professionalTitle:
          professionalTitle ??
              this.professionalTitle,

      registrationNumber:
          registrationNumber ??
              this.registrationNumber,

      registrationCouncil:
          registrationCouncil ??
              this.registrationCouncil,

      registrationState:
          registrationState ??
              this.registrationState,

      primarySpecialization:
          primarySpecialization ??
              this.primarySpecialization,

      // Education
      qualifications:
          qualifications ??
              this.qualifications,

      certifications:
          certifications ??
              this.certifications,

      qualification:
          qualification ??
              this.qualification,

      university:
          university ??
              this.university,

      graduationYear:
          graduationYear ??
              this.graduationYear,

      // Specializations
      specializations:
          specializations ??
              this.specializations,

      // Experience
      experienceYears:
          experienceYears ??
              this.experienceYears,

      employmentStatus:
          employmentStatus ??
              this.employmentStatus,

      currentOrganization:
          currentOrganization ??
              this.currentOrganization,

      professionalBio:
          professionalBio ??
              this.professionalBio,

      languages:
          languages ??
              this.languages,

      // Services
      homeVisitEnabled:
          homeVisitEnabled ??
              this.homeVisitEnabled,

      clinicVisitEnabled:
          clinicVisitEnabled ??
              this.clinicVisitEnabled,

      onlineConsultationEnabled:
          onlineConsultationEnabled ??
              this.onlineConsultationEnabled,

      emergencyAvailable:
          emergencyAvailable ??
              this.emergencyAvailable,

      // Location
      clinicName:
          clinicName ??
              this.clinicName,

      address:
          address ??
              this.address,

      city:
          city ??
              this.city,

      locality:
          locality ??
              this.locality,

      state:
          state ??
              this.state,

      pincode:
          pincode ??
              this.pincode,

      latitude:
          latitude ??
              this.latitude,

      longitude:
          longitude ??
              this.longitude,

      homeVisitRadiusKm:
          homeVisitRadiusKm ??
              this.homeVisitRadiusKm,

      // Availability
      workingDays:
          workingDays ??
              this.workingDays,

      startTime:
          startTime ??
              this.startTime,

      endTime:
          endTime ??
              this.endTime,

      availability:
          availability ??
              this.availability,

      serviceSchedules:
          serviceSchedules ??
              this.serviceSchedules,

      sessionDurationMinutes:
          sessionDurationMinutes ??
              this.sessionDurationMinutes,

      maxAppointmentsPerDay:
          maxAppointmentsPerDay ??
              this.maxAppointmentsPerDay,

      // Pricing
      currency:
          currency ??
              this.currency,

      pricingTier: pricingTier ?? this.pricingTier,
      pricingTierLabel: pricingTierLabel ?? this.pricingTierLabel,
      pricingExperienceBasis: pricingExperienceBasis ?? this.pricingExperienceBasis,
      pricingCity: pricingCity ?? this.pricingCity,
      pricingLocality: pricingLocality ?? this.pricingLocality,
      pricingConfigVersion: pricingConfigVersion ?? this.pricingConfigVersion,

      homeVisitPrice:
          homeVisitPrice ??
              this.homeVisitPrice,

      clinicVisitPrice:
          clinicVisitPrice ??
              this.clinicVisitPrice,

      onlineConsultationPrice:
          onlineConsultationPrice ??
              this.onlineConsultationPrice,

      followUpPrice:
          followUpPrice ??
              this.followUpPrice,

      travelChargesEnabled:
          travelChargesEnabled ??
              this.travelChargesEnabled,

      travelCharges:
          travelCharges ??
              this.travelCharges,

      discountAvailable:
          discountAvailable ??
              this.discountAvailable,

      discountPercentage:
          discountPercentage ??
              this.discountPercentage,

      // Documents
      registrationCertificateUrl:
          registrationCertificateUrl ??
              this.registrationCertificateUrl,

      degreeCertificateUrl:
          degreeCertificateUrl ??
              this.degreeCertificateUrl,

      governmentIdUrl:
          governmentIdUrl ??
              this.governmentIdUrl,

      additionalCertificateUrls:
          additionalCertificateUrls ??
              this.additionalCertificateUrls,

      // Verification
      registrationCertificateUploaded:
          registrationCertificateUploaded ??
              this.registrationCertificateUploaded,

      degreeCertificateUploaded:
          degreeCertificateUploaded ??
              this.degreeCertificateUploaded,

      identityDocumentUploaded:
          identityDocumentUploaded ??
              this.identityDocumentUploaded,

      verificationStatus:
          verificationStatus ??
              this.verificationStatus,

      isVerified:
          isVerified ??
              this.isVerified,

      rejectionReason:
          rejectionReason ??
              this.rejectionReason,

      // Profile
      isActive:
          isActive ??
              this.isActive,

      isFeatured:
          isFeatured ??
              this.isFeatured,

      isProfileCompleted:
          isProfileCompleted ??
              this.isProfileCompleted,

      onboardingStep:
          onboardingStep ??
              this.onboardingStep,

      // Statistics
      rating:
          rating ??
              this.rating,

      totalReviews:
          totalReviews ??
              this.totalReviews,

      totalAppointments:
          totalAppointments ??
              this.totalAppointments,

      completedAppointments:
          completedAppointments ??
              this.completedAppointments,

      // Timestamps
      createdAt:
          createdAt ??
              this.createdAt,

      updatedAt:
          updatedAt ??
              this.updatedAt,
    );
  }

  // ==============================================================
  // STATUS HELPERS
  // ==============================================================

  bool get isPendingApproval =>
      verificationStatus == 'pending';

  bool get isApproved =>
      verificationStatus == 'approved';

  bool get isRejected =>
      verificationStatus == 'rejected';

  bool get isDraft =>
      verificationStatus == 'draft';

  // ==============================================================
  // DISPLAY HELPERS
  // ==============================================================

  String get primaryQualification {
    if (qualification.trim().isNotEmpty) {
      return qualification;
    }

    if (qualifications.isNotEmpty) {
      return qualifications.first['degree']
              ?.toString() ??
          '';
    }

    return '';
  }

  String get displaySpecialization {
    if (primarySpecialization.trim().isNotEmpty) {
      return primarySpecialization;
    }

    if (specializations.isNotEmpty) {
      return specializations.first;
    }

    return 'Physiotherapist';
  }

  bool get hasCompletedVerification {
    return registrationCertificateUploaded &&
        degreeCertificateUploaded &&
        identityDocumentUploaded;
  }

  bool get canAcceptAppointments {
    return isProfileCompleted &&
        isVerified &&
        isActive;
  }

  // ==============================================================
  // HELPERS
  // ==============================================================

  static int _toInt(
    dynamic value, {
    int defaultValue = 0,
  }) {
    if (value == null) {
      return defaultValue;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        defaultValue;
  }

  static double _toDouble(
    dynamic value, {
    double defaultValue = 0,
  }) {
    if (value == null) {
      return defaultValue;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        defaultValue;
  }

  static DateTime? _timestampToDateTime(
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

  static List<String> _stringList(
    dynamic value,
  ) {
    if (value == null) {
      return [];
    }

    if (value is List) {
      return value
          .map(
            (item) => item.toString(),
          )
          .toList();
    }

    return [];
  }

  static List<Map<String, dynamic>> _mapList(
    dynamic value,
  ) {
    if (value == null) {
      return [];
    }

    if (value is List) {
      return value.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(
            item,
          );
        }

        return <String, dynamic>{};
      }).toList();
    }

    return [];
  }

  static Map<String, dynamic> _map(
    dynamic value,
  ) {
    if (value == null) {
      return {};
    }

    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return {};
  }
}