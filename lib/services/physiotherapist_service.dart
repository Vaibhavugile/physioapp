import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/physiotherapist_model.dart';

// ================================================================
// PHYSIOTHERAPIST SERVICE
// ================================================================
//
// Handles:
//
// • Create physiotherapist profile
// • Create onboarding draft
// • Get profile
// • Stream profile
// • Update full profile
// • Save onboarding progress
// • Submit profile for verification
// • Admin approval/rejection
// • Featured physiotherapists
// • Search/filter physiotherapists
// • Rating and appointment statistics
//
// ================================================================

class PhysiotherapistService {
  // ==============================================================
  // FIRESTORE
  // ==============================================================

  final FirebaseFirestore _firestore;

  PhysiotherapistService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  // ==============================================================
  // COLLECTION
  // ==============================================================

  static const String _collectionName =
      'physiotherapists';

  CollectionReference<Map<String, dynamic>>
      get _collection =>
          _firestore.collection(
            _collectionName,
          );

  // ==============================================================
  // DOCUMENT
  // ==============================================================

  DocumentReference<Map<String, dynamic>>
      _doc(String uid) {
    return _collection.doc(uid);
  }

  // ==============================================================
  // CREATE PHYSIOTHERAPIST
  // ==============================================================

  Future<void> createPhysiotherapist({
    required PhysiotherapistModel physiotherapist,
  }) async {
    final doc =
        _doc(physiotherapist.uid);

    final snapshot =
        await doc.get();

    // Don't overwrite an existing profile.
    if (snapshot.exists) {
      return;
    }

    await doc.set({
      ...physiotherapist.toFirestore(),

      'createdAt':
          FieldValue.serverTimestamp(),

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // CREATE DRAFT PROFILE IF NEEDED
  // ==============================================================
  //
  // Called after physiotherapist authentication.
  //
  // Existing profile:
  // → Return existing
  //
  // New user:
  // → Create empty draft
  //
  // ==============================================================

  Future<PhysiotherapistModel>
      createDraftProfileIfNeeded({
    required String uid,
    required String phone,
    String? email,
  }) async {
    final existing =
        await getPhysiotherapist(uid);

    if (existing != null) {
      return existing;
    }

    final physiotherapist =
        PhysiotherapistModel.empty(
      uid: uid,
      phone: phone,
    ).copyWith(
      email: email ?? '',
      verificationStatus: 'draft',
      onboardingStep: 0,
      isProfileCompleted: false,
      isActive: false,
      isVerified: false,
    );

    await createPhysiotherapist(
      physiotherapist: physiotherapist,
    );

    return physiotherapist;
  }

  // ==============================================================
  // GET PHYSIOTHERAPIST
  // ==============================================================

  Future<PhysiotherapistModel?>
      getPhysiotherapist(
    String uid,
  ) async {
    final snapshot =
        await _doc(uid).get();

    if (!snapshot.exists) {
      return null;
    }

    return PhysiotherapistModel.fromFirestore(
      snapshot,
    );
  }

  // ==============================================================
  // CHECK IF PROFILE EXISTS
  // ==============================================================

  Future<bool> physiotherapistExists(
    String uid,
  ) async {
    final snapshot =
        await _doc(uid).get();

    return snapshot.exists;
  }

  // ==============================================================
  // STREAM PHYSIOTHERAPIST
  // ==============================================================

  Stream<PhysiotherapistModel?>
      streamPhysiotherapist(
    String uid,
  ) {
    return _doc(uid).snapshots().map(
      (snapshot) {
        if (!snapshot.exists) {
          return null;
        }

        return PhysiotherapistModel
            .fromFirestore(snapshot);
      },
    );
  }

  // ==============================================================
  // UPDATE FULL PROFILE
  // ==============================================================

  Future<void> updatePhysiotherapist({
    required PhysiotherapistModel physiotherapist,
  }) async {
    await _doc(
      physiotherapist.uid,
    ).set(
      {
        ...physiotherapist.toFirestore(),

        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ==============================================================
  // UPDATE SPECIFIC FIELDS
  // ==============================================================

  Future<void> updateFields({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _doc(uid).set(
      {
        ...data,

        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ==============================================================
  // SAVE ONBOARDING STEP
  // ==============================================================
  //
  // Saves current onboarding progress.
  //
  // This allows the physiotherapist to:
  //
  // • Close app
  // • Logout
  // • Return later
  //
  // without losing progress.
  //
  // ==============================================================

  Future<void> saveOnboardingStep({
    required String uid,
    required int onboardingStep,
    required Map<String, dynamic> data,
  }) async {
    await _doc(uid).set(
      {
        ...data,

        'onboardingStep':
            onboardingStep,

        'verificationStatus':
            'draft',

        'isProfileCompleted':
            false,

        'isActive':
            false,

        'isVerified':
            false,

        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ==============================================================
  // SAVE ONBOARDING MODEL
  // ==============================================================
  //
  // Useful when saving the entire model as a draft.
  //
  // ==============================================================

  Future<void> saveOnboardingDraft({
    required PhysiotherapistModel physiotherapist,
    required int onboardingStep,
  }) async {
    await _doc(
      physiotherapist.uid,
    ).set(
      {
        ...physiotherapist.toFirestore(),

        'onboardingStep':
            onboardingStep,

        'verificationStatus':
            'draft',

        'isProfileCompleted':
            false,

        'isActive':
            false,

        'isVerified':
            false,

        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ==============================================================
  // UPDATE PERSONAL DETAILS
  // ==============================================================

  Future<void> updatePersonalDetails({
    required String uid,
    required String fullName,
    required String email,
    required String gender,
    DateTime? dateOfBirth,
    String? profileImageUrl,
  }) async {
    await updateFields(
      uid: uid,
      data: {
        'fullName':
            fullName.trim(),

        'email':
            email.trim(),

        'gender':
            gender.trim(),

        'dateOfBirth':
            dateOfBirth != null
                ? Timestamp.fromDate(
                    dateOfBirth,
                  )
                : null,

        'profileImageUrl':
            profileImageUrl,
      },
    );
  }

  // ==============================================================
  // UPDATE PROFESSIONAL DETAILS
  // ==============================================================

  Future<void> updateProfessionalDetails({
    required String uid,
    required String professionalTitle,
    required String registrationNumber,
    required String registrationCouncil,
    required String registrationState,
    required String primarySpecialization,
    required List<String> specializations,
    required List<String> languages,
  }) async {
    await updateFields(
      uid: uid,
      data: {
        'professionalTitle':
            professionalTitle.trim(),

        'registrationNumber':
            registrationNumber.trim(),

        'registrationCouncil':
            registrationCouncil.trim(),

        'registrationState':
            registrationState.trim(),

        'primarySpecialization':
            primarySpecialization.trim(),

        'specializations':
            specializations,

        'languages':
            languages,
      },
    );
  }

  // ==============================================================
  // UPDATE QUALIFICATIONS
  // ==============================================================

  Future<void> updateQualifications({
    required String uid,
    required List<Map<String, dynamic>>
        qualifications,
    String qualification = '',
    String university = '',
    int graduationYear = 0,
  }) async {
    await updateFields(
      uid: uid,
      data: {
        'qualifications':
            qualifications,

        'qualification':
            qualification.trim(),

        'university':
            university.trim(),

        'graduationYear':
            graduationYear,
      },
    );
  }

  // ==============================================================
  // UPDATE EXPERIENCE & WORK
  // ==============================================================

  Future<void> updateExperienceAndWork({
    required String uid,
    required int experienceYears,
    required String employmentStatus,
    required String currentOrganization,
    required String professionalBio,
    required List<String> languages,
  }) async {
    await updateFields(
      uid: uid,
      data: {
        'experienceYears':
            experienceYears,

        'employmentStatus':
            employmentStatus.trim(),

        'currentOrganization':
            currentOrganization.trim(),

        'professionalBio':
            professionalBio.trim(),

        'bio':
            professionalBio.trim(),

        'languages':
            languages,
      },
    );
  }

  // ==============================================================
  // UPDATE SERVICES
  // ==============================================================

  Future<void> updateServices({
    required String uid,
    required bool homeVisitEnabled,
    required bool clinicVisitEnabled,
    required bool onlineConsultationEnabled,
    required bool emergencyAvailable,
  }) async {
    await updateFields(
      uid: uid,
      data: {
        'homeVisitEnabled':
            homeVisitEnabled,

        'clinicVisitEnabled':
            clinicVisitEnabled,

        'onlineConsultationEnabled':
            onlineConsultationEnabled,

        'emergencyAvailable':
            emergencyAvailable,
      },
    );
  }

  // ==============================================================
  // UPDATE LOCATION
  // ==============================================================

  Future<void> updateLocation({
    required String uid,
    required String clinicName,
    required String address,
    required String city,
    String? locality,
    required String state,
    required String pincode,
    double latitude = 0,
    double longitude = 0,
    int homeVisitRadiusKm = 0,
  }) async {
    await updateFields(
      uid: uid,
      data: {
        'clinicName':
            clinicName.trim(),

        'address':
            address.trim(),

        'city':
            city.trim(),

        if (locality != null) 'locality': locality.trim(),

        'state':
            state.trim(),

        'pincode':
            pincode.trim(),

        'latitude':
            latitude,

        'longitude':
            longitude,

        'homeVisitRadiusKm':
            homeVisitRadiusKm,
      },
    );
  }

  // ==============================================================
  // UPDATE AVAILABILITY
  // ==============================================================

  Future<void> updateAvailability({
    required String uid,
    required List<String> workingDays,
    required String startTime,
    required String endTime,
    required Map<String, dynamic> availability,
    required int sessionDurationMinutes,
    required int maxAppointmentsPerDay,
    Map<String, dynamic>? serviceSchedules,
  }) async {
    await updateFields(
      uid: uid,
      data: {
        'workingDays':
            workingDays,

        'startTime':
            startTime,

        'endTime':
            endTime,

        'availability':
            availability,

        if (serviceSchedules != null) 'serviceSchedules': serviceSchedules,

        'sessionDurationMinutes':
            sessionDurationMinutes,

        'maxAppointmentsPerDay':
            maxAppointmentsPerDay,
      },
    );
  }

  // ==============================================================
  // UPDATE PRICING
  // ==============================================================

  Future<void> updatePricing({
    required String uid,
    required String currency,
    required double homeVisitPrice,
    required double clinicVisitPrice,
    required double onlineConsultationPrice,
    required double followUpPrice,
    required bool travelChargesEnabled,
    required double travelCharges,
    required bool discountAvailable,
    required double discountPercentage,
  }) async {
    await updateFields(
      uid: uid,
      data: {
        'currency':
            currency,

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
      },
    );
  }


  // ==============================================================
  // UPDATE DOCUMENTS
  // ==============================================================

  Future<void> updateVerificationDocuments({
    required String uid,
    String? registrationCertificateUrl,
    String? degreeCertificateUrl,
    String? governmentIdUrl,
    List<String>? additionalCertificateUrls,
  }) async {
    await updateFields(
      uid: uid,
      data: {
        'registrationCertificateUrl':
            registrationCertificateUrl,

        'degreeCertificateUrl':
            degreeCertificateUrl,

        'governmentIdUrl':
            governmentIdUrl,

        'additionalCertificateUrls':
            additionalCertificateUrls ?? [],

        'registrationCertificateUploaded':
            registrationCertificateUrl != null &&
                registrationCertificateUrl.isNotEmpty,

        'degreeCertificateUploaded':
            degreeCertificateUrl != null &&
                degreeCertificateUrl.isNotEmpty,

        'identityDocumentUploaded':
            governmentIdUrl != null &&
                governmentIdUrl.isNotEmpty,
      },
    );
  }

  // ==============================================================
  // COMPLETE ONBOARDING
  // ==============================================================

  Future<void> completeOnboarding({
    required PhysiotherapistModel physiotherapist,
  }) async {
    await _doc(
      physiotherapist.uid,
    ).set(
      {
        ...physiotherapist.toFirestore(),

        'onboardingStep': 9,

        'isProfileCompleted': true,

        'verificationStatus':
            'pending',

        'isVerified': false,

        'isActive': false,

        'isFeatured': false,

        'rejectionReason': null,

        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ==============================================================
  // SUBMIT FOR VERIFICATION
  // ==============================================================

  Future<void> submitForVerification({
    required String uid,
  }) async {
    await _doc(uid).update({
      'onboardingStep': 9,

      'isProfileCompleted': true,

      'verificationStatus':
          'pending',

      'isVerified':
          false,

      'isActive':
          false,

      'rejectionReason':
          null,

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // APPROVE PHYSIOTHERAPIST
  // ==============================================================
  //
  // ADMIN ONLY
  //
  // ==============================================================

  Future<void> approvePhysiotherapist({
    required String uid,
  }) async {
    await _doc(uid).update({
      'verificationStatus':
          'approved',

      'isVerified':
          true,

      'isActive':
          true,

      'rejectionReason':
          null,

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // REJECT PHYSIOTHERAPIST
  // ==============================================================
  //
  // ADMIN ONLY
  //
  // ==============================================================

  Future<void> rejectPhysiotherapist({
    required String uid,
    String? reason,
  }) async {
    await _doc(uid).update({
      'verificationStatus':
          'rejected',

      'isVerified':
          false,

      'isActive':
          false,

      'rejectionReason':
          reason?.trim() ?? '',

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // RESUBMIT REJECTED PROFILE
  // ==============================================================

  Future<void> resubmitForVerification({
    required String uid,
  }) async {
    await _doc(uid).update({
      'verificationStatus':
          'pending',

      'isVerified':
          false,

      'isActive':
          false,

      'rejectionReason':
          null,

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // ACTIVATE / DEACTIVATE
  // ==============================================================

  Future<void> setPhysiotherapistActive({
    required String uid,
    required bool isActive,
  }) async {
    await _doc(uid).update({
      'isActive':
          isActive,

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // FEATURE / UNFEATURE
  // ==============================================================

  Future<void> setPhysiotherapistFeatured({
    required String uid,
    required bool isFeatured,
  }) async {
    await _doc(uid).update({
      'isFeatured':
          isFeatured,

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // APPROVED PHYSIOTHERAPISTS
  // ==============================================================

  Stream<List<PhysiotherapistModel>>
      streamApprovedPhysiotherapists({
    int limit = 50,
  }) {
    return _collection
        .where(
          'isActive',
          isEqualTo: true,
        )
        .where(
          'isVerified',
          isEqualTo: true,
        )
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  PhysiotherapistModel
                      .fromFirestore,
                )
                .toList();
          },
        );
  }

  // ==============================================================
  // FEATURED PHYSIOTHERAPISTS
  // ==============================================================

  Stream<List<PhysiotherapistModel>>
      streamFeaturedPhysiotherapists({
    int limit = 10,
  }) {
    return _collection
        .where(
          'isActive',
          isEqualTo: true,
        )
        .where(
          'isVerified',
          isEqualTo: true,
        )
        .where(
          'isFeatured',
          isEqualTo: true,
        )
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  PhysiotherapistModel
                      .fromFirestore,
                )
                .toList();
          },
        );
  }

  // ==============================================================
  // PHYSIOS BY SPECIALIZATION
  // ==============================================================

  Stream<List<PhysiotherapistModel>>
      streamBySpecialization({
    required String specialization,
    int limit = 30,
  }) {
    return _collection
        .where(
          'isActive',
          isEqualTo: true,
        )
        .where(
          'isVerified',
          isEqualTo: true,
        )
        .where(
          'specializations',
          arrayContains: specialization,
        )
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  PhysiotherapistModel
                      .fromFirestore,
                )
                .toList();
          },
        );
  }

  // ==============================================================
  // PHYSIOS BY CITY
  // ==============================================================

  Stream<List<PhysiotherapistModel>>
      streamByCity({
    required String city,
    int limit = 30,
  }) {
    return _collection
        .where(
          'isActive',
          isEqualTo: true,
        )
        .where(
          'isVerified',
          isEqualTo: true,
        )
        .where(
          'city',
          isEqualTo: city.trim(),
        )
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  PhysiotherapistModel
                      .fromFirestore,
                )
                .toList();
          },
        );
  }

  // ==============================================================
  // GET APPROVED SINGLE PHYSIOTHERAPIST
  // ==============================================================

  Future<PhysiotherapistModel?>
      getApprovedPhysiotherapist(
    String uid,
  ) async {
    final physiotherapist =
        await getPhysiotherapist(uid);

    if (physiotherapist == null) {
      return null;
    }

    if (!physiotherapist.isActive ||
        !physiotherapist.isVerified) {
      return null;
    }

    return physiotherapist;
  }

  // ==============================================================
  // UPDATE RATING
  // ==============================================================
  //
  // Ideally controlled by Cloud Functions/backend.
  //
  // ==============================================================

  Future<void> updateRating({
    required String uid,
    required double rating,
    required int totalReviews,
  }) async {
    await _doc(uid).update({
      'rating':
          rating,

      'totalReviews':
          totalReviews,

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // INCREMENT APPOINTMENTS
  // ==============================================================

  Future<void> incrementAppointments({
    required String uid,
  }) async {
    await _doc(uid).update({
      'totalAppointments':
          FieldValue.increment(1),

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // INCREMENT COMPLETED APPOINTMENTS
  // ==============================================================

  Future<void> incrementCompletedAppointments({
    required String uid,
  }) async {
    await _doc(uid).update({
      'completedAppointments':
          FieldValue.increment(1),

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // DELETE PROFILE
  // ==============================================================

  Future<void> deletePhysiotherapist(
    String uid,
  ) async {
    await _doc(uid).delete();
  }
}