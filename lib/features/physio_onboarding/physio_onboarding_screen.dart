import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/physiotherapist_service.dart';
import 'pricing_config.dart';

import 'widgets/availability_step.dart';
import 'widgets/basic_information_step.dart';
import 'widgets/education_qualifications_step.dart';
import 'widgets/experience_work_step.dart';
import 'widgets/physio_location_step.dart';
import 'widgets/professional_details_step.dart';
import 'widgets/professional_verification_step.dart';
import 'widgets/review_submit_step.dart';
import 'widgets/specializations_step.dart';

class PhysioOnboardingScreen extends StatefulWidget {
  const PhysioOnboardingScreen({
    super.key,
  });

  @override
  State<PhysioOnboardingScreen> createState() =>
      _PhysioOnboardingScreenState();
}

class _PhysioOnboardingScreenState
    extends State<PhysioOnboardingScreen> {
  @override
  void initState() {
    super.initState();
    _loadPlatformPricing();
  }

  Future<void> _loadPlatformPricing() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('physio_pricing')
          .doc('active')
          .get();
      if (snapshot.exists) {
        PricingConfig.configure(snapshot.data());
        _currency = PricingConfig.currency;
      }
      if (mounted) setState(() {});
    } catch (error) {
      debugPrint('Unable to load platform pricing config: $error');
    }
  }

  // ==============================================================
  // FIREBASE SERVICE
  // ==============================================================

  final PhysiotherapistService _physiotherapistService =
      PhysiotherapistService();

  // ==============================================================
  // CURRENT STEP
  // ==============================================================

  int _currentStep = 0;

  // ==============================================================
  // TOTAL STEPS
  // ==============================================================

  static const int _totalSteps = 9;

  // ==============================================================
  // LOADING
  // ==============================================================

  bool _isSaving = false;

  // ==============================================================
  // STEP 1 — BASIC INFORMATION
  // ==============================================================

  BasicInformationData? _basicInformation;

  PhysioLocationData _physioLocation = const PhysioLocationData();

  // ==============================================================
  // STEP 2 — PROFESSIONAL DETAILS
  // ==============================================================

  ProfessionalDetailsData? _professionalDetails;

  // ==============================================================
  // STEP 3 — EDUCATION & QUALIFICATIONS
  // ==============================================================

  EducationQualificationsData?
      _educationQualifications;

  // ==============================================================
  // STEP 4 — SPECIALIZATIONS
  // ==============================================================

  List<String> _selectedSpecializations = [];

  // ==============================================================
  // STEP 5 — EXPERIENCE & WORK
  // ==============================================================

  int? _totalExperienceYears;

  String _employmentStatus = '';

  String _currentOrganization = '';

  String _professionalBio = '';

  List<String> _selectedLanguages = [];

  // ==============================================================
  // STEP 6 — PLATFORM PRICING (READ ONLY)
  // ==============================================================

  String _currency = PricingConfig.currency;

  double get _homeVisitFee => PricingConfig.forCity(
    experienceYears: _totalExperienceYears ?? 1,
    city: _physioLocation.city,
    locality: _physioLocation.locality,
  ).homeVisit;

  double get _clinicVisitFee => PricingConfig.forCity(
    experienceYears: _totalExperienceYears ?? 1,
    city: _physioLocation.city,
    locality: _physioLocation.locality,
  ).clinic;

  double get _onlineConsultationFee => PricingConfig.forCity(
    experienceYears: _totalExperienceYears ?? 1,
    city: _physioLocation.city,
    locality: _physioLocation.locality,
  ).online;

  double get _followUpFee => PricingConfig.forCity(
    experienceYears: _totalExperienceYears ?? 1,
    city: _physioLocation.city,
    locality: _physioLocation.locality,
  ).followUp;

  // Platform-managed extras are disabled for the initial rollout.
  bool get _travelChargesEnabled => false;
  double get _travelCharges => 0;
  bool get _discountAvailable => false;
  double get _discountPercentage => 0;

  // ==============================================================
  // STEP 7 — AVAILABILITY

  // Each service owns its own days and hours in _serviceSchedules.
  bool _homeVisitsAvailable = true;

  bool _clinicVisitsAvailable = true;

  bool _onlineConsultationAvailable = false;

  bool _emergencyAvailable = false;

  int _maxAppointmentsPerDay = 10;

  Map<String, dynamic> _serviceSchedules = {
    'home': {'enabled': true, 'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'], 'startTime': '09:00', 'endTime': '18:00', 'flexible': false},
    'clinic': {'enabled': true, 'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'], 'startTime': '09:00', 'endTime': '18:00', 'flexible': false},
    'online': {'enabled': false, 'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'], 'startTime': '09:00', 'endTime': '18:00', 'flexible': false},
  };

  // ==============================================================
  // STEP 8 — PROFESSIONAL VERIFICATION
  // ==============================================================

  String _verificationRegistrationNumber = '';

  String _registrationCouncil = '';

  String _registrationState = '';

  bool _registrationCertificateUploaded =
      false;

  bool _degreeCertificateUploaded = false;

  bool _identityDocumentUploaded = false;

  // ==============================================================
  // STEP 9 — TERMS
  // ==============================================================

  bool _termsAccepted = false;

  // ==============================================================
  // ONBOARDING STEPS
  // ==============================================================

  final List<_OnboardingStepData> _steps = [
    const _OnboardingStepData(
      title: 'Basic Information',
      subtitle:
          'Tell us a little about yourself.',
      icon: Icons.person_outline_rounded,
    ),

    const _OnboardingStepData(
      title: 'Professional Details',
      subtitle:
          'Choose the title shown on your professional profile.',
      icon: Icons.badge_outlined,
    ),

    const _OnboardingStepData(
      title: 'Education & Qualifications',
      subtitle:
          'Add your education and professional qualifications.',
      icon: Icons.school_outlined,
    ),

    const _OnboardingStepData(
      title: 'Specializations',
      subtitle:
          'Choose the areas where you provide expert care.',
      icon:
          Icons.workspace_premium_outlined,
    ),

    const _OnboardingStepData(
      title: 'Experience & Work',
      subtitle:
          'Tell patients about your professional experience.',
      icon: Icons.work_outline_rounded,
    ),

    const _OnboardingStepData(
      title: 'Service Location',
      subtitle:
          'Choose your registered locality, service radius and view your assigned pricing tiers.',
      icon: Icons.location_on_outlined,
    ),

    const _OnboardingStepData(
      title: 'Availability',
      subtitle:
          'Set separate days and timings for home, clinic and online consultations.',
      icon:
          Icons.calendar_month_outlined,
    ),

    const _OnboardingStepData(
      title: 'Professional Verification',
      subtitle:
          'Upload documents required to verify your profile.',
      icon:
          Icons.verified_user_outlined,
    ),

    const _OnboardingStepData(
      title: 'Review & Submit',
      subtitle:
          'Review your complete profile before submitting.',
      icon:
          Icons.check_circle_outline_rounded,
    ),
  ];

  // ==============================================================
  // NEXT STEP
  // ==============================================================

  Future<void> _nextStep() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    final isValid =
        _validateCurrentStep();

    if (!isValid) return;

    // ------------------------------------------------------------
    // FINAL STEP
    // ------------------------------------------------------------

    if (_currentStep == _totalSteps - 1) {
      await _submitOnboarding();
      return;
    }

    // ------------------------------------------------------------
    // SAVE CURRENT STEP
    // ------------------------------------------------------------

    final saved =
        await _saveCurrentStep();

    if (!saved || !mounted) return;

    // ------------------------------------------------------------
    // MOVE TO NEXT STEP
    // ------------------------------------------------------------

    setState(() {
      _currentStep++;
    });

    // ------------------------------------------------------------
    // SAVE PROGRESS
    // ------------------------------------------------------------

    await _saveProgress();
  }

  // ==============================================================
  // VALIDATE CURRENT STEP
  // ==============================================================

  bool _validateCurrentStep() {
    // ============================================================
    // STEP 1
    // ============================================================

    if (_currentStep == 0) {
      if (_basicInformation == null) {
        _showMessage(
          'Please complete your basic information.',
          isError: true,
        );
        return false;
      }

      final data = _basicInformation!;

      if (data.fullName.trim().isEmpty) {
        _showMessage(
          'Please enter your full name.',
          isError: true,
        );
        return false;
      }

      if (data.gender.trim().isEmpty) {
        _showMessage(
          'Please select your gender.',
          isError: true,
        );
        return false;
      }

      if (data.dateOfBirth == null) {
        _showMessage(
          'Please select your date of birth.',
          isError: true,
        );
        return false;
      }

      if (data.email.trim().isEmpty ||
          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(data.email.trim())) {
        _showMessage(
          'Please enter a valid email address.',
          isError: true,
        );
        return false;
      }

    }

    // ============================================================
    // STEP 2 — PROFESSIONAL TITLE ONLY. Registration, experience,
    // specializations, languages and services each have one dedicated step.
    if (_currentStep == 1) {
      if ((_professionalDetails?.professionalTitle ?? '').trim().isEmpty) {
        _showMessage('Please select your professional title.', isError: true);
        return false;
      }
    }

    // STEP 3
    // ============================================================

    if (_currentStep == 2) {
      if (_educationQualifications == null ||
          _educationQualifications!
              .qualifications
              .isEmpty) {
        _showMessage(
          'Please add at least one qualification.',
          isError: true,
        );
        return false;
      }
    }

    // ============================================================
    // STEP 4
    // ============================================================

    if (_currentStep == 3) {
      if (_selectedSpecializations.isEmpty) {
        _showMessage(
          'Please select at least one specialization.',
          isError: true,
        );
        return false;
      }
    }

    // ============================================================
    // STEP 5
    // ============================================================

    if (_currentStep == 4) {
      if (_totalExperienceYears == null) {
        _showMessage(
          'Please select your years of experience.',
          isError: true,
        );
        return false;
      }

      if (_employmentStatus.trim().isEmpty) {
        _showMessage(
          'Please select your employment status.',
          isError: true,
        );
        return false;
      }

      if (_professionalBio.trim().length < 20) {
        _showMessage(
          'Please write a professional bio of at least 20 characters.',
          isError: true,
        );
        return false;
      }

      if (_selectedLanguages.isEmpty) {
        _showMessage(
          'Please select at least one language.',
          isError: true,
        );
        return false;
      }
    }

    // Step 6 is a read-only platform rate card; no fee input is required.

    // ============================================================
    // STEP 6 — SERVICE LOCATION
    if (_currentStep == 5) {
      if (_physioLocation.address.trim().isEmpty || _physioLocation.latitude == 0 || _physioLocation.longitude == 0) {
        _showMessage('Please select your practice location from Google Places.', isError: true);
        return false;
      }
      if (_physioLocation.locality.trim().isEmpty || _physioLocation.city.trim().isEmpty || _physioLocation.state.trim().isEmpty) {
        _showMessage('Please complete your locality, city and state.', isError: true);
        return false;
      }
      if (_homeVisitsAvailable && _physioLocation.homeVisitRadiusKm < 1) {
        _showMessage('Enter a valid home-visit service radius in kilometres.', isError: true);
        return false;
      }
    }

    // STEP 7
    // ============================================================

    if (_currentStep == 6) {
      final hasService =
          _homeVisitsAvailable ||
              _clinicVisitsAvailable ||
              _onlineConsultationAvailable;

      if (!hasService) {
        _showMessage(
          'Please select at least one available service.',
          isError: true,
        );
        return false;
      }

      for (final key in ['home', 'clinic', 'online']) {
        final enabled = key == 'home' ? _homeVisitsAvailable : key == 'clinic' ? _clinicVisitsAvailable : _onlineConsultationAvailable;
        if (!enabled) continue;
        final schedule = Map<String, dynamic>.from(_serviceSchedules[key] as Map? ?? {});
        final days = List<String>.from(schedule['days'] ?? const []);
        if (days.isEmpty) {
          _showMessage('Select at least one day for ${key == 'home' ? 'home visits' : key == 'clinic' ? 'clinic visits' : 'online consultations'}.', isError: true);
          return false;
        }
        if (schedule['flexible'] != true) {
          final start = (schedule['startTime'] ?? '09:00').toString().split(':');
          final end = (schedule['endTime'] ?? '18:00').toString().split(':');
          final startMinutesForService = int.parse(start[0]) * 60 + int.parse(start[1]);
          final endMinutesForService = int.parse(end[0]) * 60 + int.parse(end[1]);
          if (endMinutesForService <= startMinutesForService) {
            _showMessage('End time must be after start time for each enabled service.', isError: true);
            return false;
          }
        }
      }

    }

    // ============================================================
    // STEP 8
    // ============================================================

    if (_currentStep == 7) {
      if (_verificationRegistrationNumber
          .trim()
          .isEmpty) {
        _showMessage(
          'Please enter your registration number.',
          isError: true,
        );
        return false;
      }

      if (_registrationCouncil.trim().isEmpty) {
        _showMessage(
          'Please enter your registration council.',
          isError: true,
        );
        return false;
      }

      if (_registrationState.trim().isEmpty) {
        _showMessage(
          'Please enter your registration state.',
          isError: true,
        );
        return false;
      }

      if (!_registrationCertificateUploaded ||
          !_degreeCertificateUploaded ||
          !_identityDocumentUploaded) {
        _showMessage(
          'Please complete all required verification documents.',
          isError: true,
        );
        return false;
      }
    }

    // ============================================================
    // STEP 9
    // ============================================================

    if (_currentStep == 8) {
      if (!_termsAccepted) {
        _showMessage(
          'Please accept the terms before submitting.',
          isError: true,
        );
        return false;
      }
    }

    return true;
  }

  // ==============================================================
  // SAVE CURRENT STEP TO FIREBASE
  // ==============================================================

  Future<bool> _saveCurrentStep() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Your session has expired. Please login again.',
        isError: true,
      );
      return false;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final uid = user.uid;

      // ==========================================================
      // STEP 1 — BASIC INFORMATION
      // ==========================================================

      if (_currentStep == 0 &&
          _basicInformation != null) {
        final data =
            _basicInformation!;

        await _physiotherapistService
            .updateFields(
          uid: uid,
          data: {
            'uid': uid,
            'phone':
                user.phoneNumber ?? '',

            'fullName':
                data.fullName.trim(),

            'gender':
                data.gender.trim(),

            'dateOfBirth':
                data.dateOfBirth,

            'email':
                data.email.trim(),

            'onboardingStep': 0,

            'verificationStatus':
                'draft',

            'isProfileCompleted':
                false,

            'isVerified':
                false,

            'isActive':
                false,
          },
        );
      }

      // ==========================================================
      // STEP 2 — PROFESSIONAL TITLE (single source of truth)
      if (_currentStep == 1 && _professionalDetails != null) {
        await _physiotherapistService.updateFields(
          uid: uid,
          data: {'professionalTitle': _professionalDetails!.professionalTitle.trim()},
        );
      }

      // STEP 3 — EDUCATION
      // ==========================================================

      if (_currentStep == 2 &&
          _educationQualifications != null) {
        final qualifications =
            _educationQualifications!
                .qualifications
                .map(
                  (qualification) => {
                    'degree':
                        qualification.degree,
                  },
                )
                .toList();

        await _physiotherapistService
            .updateFields(
          uid: uid,
          data: {
            'qualifications':
                qualifications,
          },
        );
      }

      // ==========================================================
      // STEP 4 — SPECIALIZATIONS
      // ==========================================================

      if (_currentStep == 3) {
        await _physiotherapistService
            .updateFields(
          uid: uid,
          data: {
            'specializations':
                _selectedSpecializations,
          },
        );
      }

      // ==========================================================
      // STEP 5 — EXPERIENCE
      // ==========================================================

      if (_currentStep == 4) {
        await _physiotherapistService
            .updateFields(
          uid: uid,
          data: {
            'experienceYears':
                _totalExperienceYears ?? 0,

            'employmentStatus':
                _employmentStatus.trim(),

            'currentOrganization':
                _currentOrganization.trim(),

            'professionalBio':
                _professionalBio.trim(),

            'bio':
                _professionalBio.trim(),

            'languages':
                _selectedLanguages,
          },
        );
      }

      // ==========================================================
      // STEP 6 — SERVICE LOCATION + PLATFORM PRICING
      if (_currentStep == 5) {
        await _physiotherapistService.updateFields(
          uid: uid,
          data: {
            'clinicName': _physioLocation.clinicName.trim(),
            'address': _physioLocation.address.trim(),
            'locality': _physioLocation.locality.trim(),
            'city': _physioLocation.city.trim(),
            'state': _physioLocation.state.trim(),
            'pincode': _physioLocation.pincode.trim(),
            'latitude': _physioLocation.latitude,
            'longitude': _physioLocation.longitude,
            'homeVisitRadiusKm': _homeVisitsAvailable ? _physioLocation.homeVisitRadiusKm : 0,
            ...PricingConfig.firestoreSnapshot(
              experienceYears: _totalExperienceYears ?? 1,
              city: _physioLocation.city,
              locality: _physioLocation.locality,
            ),
          },
        );
      }

      // STEP 7 — AVAILABILITY
      // ==========================================================

      if (_currentStep == 6) {
        await _physiotherapistService
            .updateFields(
          uid: uid,
          data: {
            // Legacy fields are derived from the service-specific schedules
            // for compatibility with older booking screens. They are not
            // separately collected from the physiotherapist.
            'workingDays': _legacyWorkingDays,
            'startTime': _legacyStartTime,
            'endTime': _legacyEndTime,

            'homeVisitEnabled':
                _homeVisitsAvailable,

            'clinicVisitEnabled':
                _clinicVisitsAvailable,

            'onlineConsultationEnabled':
                _onlineConsultationAvailable,

            'emergencyAvailable':
                _emergencyAvailable,

            'maxAppointmentsPerDay':
                _maxAppointmentsPerDay,

            'serviceSchedules': _serviceSchedules,
          },
        );
      }

      // ==========================================================
      // STEP 8 — VERIFICATION
      // ==========================================================

      if (_currentStep == 7) {
        await _physiotherapistService
            .updateFields(
          uid: uid,
          data: {
            'registrationNumber':
                _verificationRegistrationNumber
                    .trim(),

            'registrationCouncil':
                _registrationCouncil.trim(),

            'registrationState':
                _registrationState.trim(),

            'registrationCertificateUploaded':
                _registrationCertificateUploaded,

            'degreeCertificateUploaded':
                _degreeCertificateUploaded,

            'identityDocumentUploaded':
                _identityDocumentUploaded,
          },
        );
      }

      return true;
    } catch (error) {
      debugPrint(
        'Error saving onboarding step: $error',
      );

      if (mounted) {
        _showMessage(
          'Unable to save your information. Please try again.',
          isError: true,
        );
      }

      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ==============================================================
  // SAVE ONBOARDING PROGRESS
  // ==============================================================

  Future<void> _saveProgress() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      await _physiotherapistService
          .updateFields(
        uid: user.uid,
        data: {
          'onboardingStep':
              _currentStep,

          'verificationStatus':
              'draft',

          'isProfileCompleted':
              false,

          'isVerified':
              false,

          'isActive':
              false,
        },
      );
    } catch (error) {
      debugPrint(
        'Error saving onboarding progress: $error',
      );
    }
  }

  // ==============================================================
  // PREVIOUS STEP
  // ==============================================================

  void _previousStep() {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  // ==============================================================
  // GO TO STEP
  // ==============================================================

  void _goToStep(int step) {
    if (_isSaving) return;

    if (step < 0 ||
        step >= _totalSteps) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _currentStep = step;
    });
  }

  // ==============================================================
  // SERVICES FOR REVIEW
  // ==============================================================

  List<String> get _legacyWorkingDays {
    const order = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final collected = <String>{};
    for (final key in ['home', 'clinic', 'online']) {
      final enabled = key == 'home'
          ? _homeVisitsAvailable
          : key == 'clinic'
              ? _clinicVisitsAvailable
              : _onlineConsultationAvailable;
      if (!enabled) continue;
      final raw = _serviceSchedules[key];
      if (raw is Map) collected.addAll(List<String>.from(raw['days'] ?? const []));
    }
    return order.where(collected.contains).toList();
  }

  String get _legacyStartTime {
    for (final key in ['home', 'clinic', 'online']) {
      final enabled = key == 'home'
          ? _homeVisitsAvailable
          : key == 'clinic'
              ? _clinicVisitsAvailable
              : _onlineConsultationAvailable;
      final raw = _serviceSchedules[key];
      if (enabled && raw is Map && raw['flexible'] != true) {
        return _formatScheduleTime((raw['startTime'] ?? '09:00').toString());
      }
    }
    return '12:00 AM';
  }

  String get _legacyEndTime {
    for (final key in ['online', 'clinic', 'home']) {
      final enabled = key == 'home'
          ? _homeVisitsAvailable
          : key == 'clinic'
              ? _clinicVisitsAvailable
              : _onlineConsultationAvailable;
      final raw = _serviceSchedules[key];
      if (enabled && raw is Map && raw['flexible'] != true) {
        return _formatScheduleTime((raw['endTime'] ?? '18:00').toString());
      }
    }
    return '11:59 PM';
  }

  String _formatScheduleTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return value;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) return value;
    return _formatTime(TimeOfDay(hour: hour, minute: minute));
  }

  List<String> _getSelectedServices() {
    final services = <String>[];

    if (_homeVisitsAvailable) {
      services.add('Home Visit');
    }

    if (_clinicVisitsAvailable) {
      services.add('Clinic Visit');
    }

    if (_onlineConsultationAvailable) {
      services.add('Online Consultation');
    }

    if (_emergencyAvailable) {
      services.add('Emergency Availability');
    }

    return services;
  }

  // ==============================================================
  // FORMAT TIME
  // ==============================================================

  String _formatTime(TimeOfDay time) {
    final hour =
        time.hourOfPeriod == 0
            ? 12
            : time.hourOfPeriod;

    final minute =
        time.minute
            .toString()
            .padLeft(2, '0');

    final period =
        time.period == DayPeriod.am
            ? 'AM'
            : 'PM';

    return '$hour:$minute $period';
  }

  // ==============================================================
  // QUALIFICATIONS FOR REVIEW
  // ==============================================================

  List<String>
      _getQualificationsForReview() {
    if (_educationQualifications == null) {
      return [];
    }

    return _educationQualifications!
        .qualifications
        .map(
      (qualification) {
        return qualification.degree;
      },
    ).toList();
  }

  // ==============================================================
  // SUBMIT ONBOARDING
  // ==============================================================

  Future<void> _submitOnboarding() async {
    if (_isSaving) return;

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Your session has expired. Please login again.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // ==========================================================
      // FINAL FIREBASE SUBMISSION
      // ==========================================================

      await _physiotherapistService
          .updateFields(
        uid: user.uid,
        data: {
          'uid': user.uid,

          'phone':
              user.phoneNumber ?? '',

          'onboardingStep':
              _totalSteps,

          'isProfileCompleted':
              true,

          'verificationStatus':
              'pending',

          'isVerified':
              false,

          'isActive':
              false,

          'isFeatured':
              false,

          'rejectionReason':
              null,
        },
      );

      if (!mounted) return;

      _showMessage(
        'Your physiotherapist profile has been submitted for verification.',
      );

      // ==========================================================
      // NEXT:
      //
      // Navigate to Verification Pending Screen
      //
      // Navigator.pushReplacement(...)
      //
      // ==========================================================
    } catch (error) {
      debugPrint(
        'Onboarding submission error: $error',
      );

      if (mounted) {
        _showMessage(
          'Unable to submit your profile. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ==============================================================
  // MESSAGE
  // ==============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          behavior:
              SnackBarBehavior.floating,
          margin:
              const EdgeInsets.fromLTRB(
            18,
            0,
            18,
            18,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
          backgroundColor: isError
              ? const Color(0xFFE05252)
              : const Color(0xFF078F83),
        ),
      );
  }

  // ==============================================================
  // BUILD STEP CONTENT
  // ==============================================================

  Widget _buildStepContent() {
    switch (_currentStep) {
      // ==========================================================
      // STEP 1
      // ==========================================================

      case 0:
        return BasicInformationStep(
          initialFullName:
              _basicInformation?.fullName,

          initialGender:
              _basicInformation?.gender,

          initialDateOfBirth:
              _basicInformation?.dateOfBirth,

          initialEmail:
              _basicInformation?.email,


          phoneNumber:
              FirebaseAuth.instance
                  .currentUser
                  ?.phoneNumber,

          onChanged: (data) {
            setState(() {
              _basicInformation = data;
            });
          },
        );

      // ==========================================================
      // STEP 2
      // ==========================================================

      case 1:
        return ProfessionalDetailsStep(
          initialData:
              _professionalDetails,

          onChanged: (data) {
            setState(() {
              _professionalDetails = data;
            });
          },
        );

      // ==========================================================
      // STEP 3
      // ==========================================================

      case 2:
        return EducationQualificationsStep(
          initialData:
              _educationQualifications,

          onChanged: (data) {
            setState(() {
              _educationQualifications =
                  data;
            });
          },
        );

      // ==========================================================
      // STEP 4
      // ==========================================================

      case 3:
        return SpecializationsStep(
          selectedSpecializations:
              _selectedSpecializations,

          onChanged: (value) {
            setState(() {
              _selectedSpecializations =
                  List<String>.from(value);
            });
          },
        );

      // ==========================================================
      // STEP 5
      // ==========================================================

      case 4:
        return ExperienceWorkStep(
          totalExperienceYears:
              _totalExperienceYears,

          employmentStatus:
              _employmentStatus,

          currentOrganization:
              _currentOrganization,

          professionalBio:
              _professionalBio,

          selectedLanguages:
              _selectedLanguages,

          onExperienceChanged: (value) {
            setState(() {
              _totalExperienceYears =
                  value;
            });
          },

          onEmploymentStatusChanged:
              (value) {
            setState(() {
              _employmentStatus = value;
            });
          },

          onOrganizationChanged:
              (value) {
            setState(() {
              _currentOrganization =
                  value;
            });
          },

          onBioChanged: (value) {
            setState(() {
              _professionalBio = value;
            });
          },

          onLanguagesChanged: (value) {
            setState(() {
              _selectedLanguages =
                  List<String>.from(value);
            });
          },
        );

      // ==========================================================
      // STEP 6
      // ==========================================================

      case 5:
        return PhysioLocationStep(
          initialData: _physioLocation,
          homeVisitsEnabled: _homeVisitsAvailable,
          experienceYears: _totalExperienceYears ?? 1,
          onChanged: (value) {
            setState(() { _physioLocation = value; });
          },
        );

      // ==========================================================
      // STEP 7
      // ==========================================================

      case 6:
        return AvailabilityStep(
          homeVisitsAvailable:
              _homeVisitsAvailable,

          clinicVisitsAvailable:
              _clinicVisitsAvailable,

          onlineConsultationAvailable:
              _onlineConsultationAvailable,

          emergencyAvailable:
              _emergencyAvailable,

          maxAppointmentsPerDay:
              _maxAppointmentsPerDay,

          serviceSchedules: _serviceSchedules,

          onServiceSchedulesChanged: (value) {
            setState(() {
              _serviceSchedules = Map<String, dynamic>.from(value);
            });
          },

          onHomeVisitsChanged: (value) {
            setState(() {
              _homeVisitsAvailable =
                  value;
            });
          },

          onClinicVisitsChanged:
              (value) {
            setState(() {
              _clinicVisitsAvailable =
                  value;
            });
          },

          onOnlineConsultationChanged:
              (value) {
            setState(() {
              _onlineConsultationAvailable =
                  value;
            });
          },

          onEmergencyAvailabilityChanged:
              (value) {
            setState(() {
              _emergencyAvailable =
                  value;
            });
          },

          onMaxAppointmentsChanged:
              (value) {
            setState(() {
              _maxAppointmentsPerDay =
                  value;
            });
          },
        );

      // ==========================================================
      // STEP 8
      // ==========================================================

      case 7:
        return ProfessionalVerificationStep(
          registrationNumber:
              _verificationRegistrationNumber,

          registrationCouncil:
              _registrationCouncil,

          registrationState:
              _registrationState,

          registrationCertificateUploaded:
              _registrationCertificateUploaded,

          degreeCertificateUploaded:
              _degreeCertificateUploaded,

          identityDocumentUploaded:
              _identityDocumentUploaded,

          onRegistrationNumberChanged:
              (value) {
            setState(() {
              _verificationRegistrationNumber =
                  value;
            });
          },

          onRegistrationCouncilChanged:
              (value) {
            setState(() {
              _registrationCouncil =
                  value;
            });
          },

          onRegistrationStateChanged:
              (value) {
            setState(() {
              _registrationState =
                  value;
            });
          },

          onRegistrationCertificateChanged:
              (value) {
            setState(() {
              _registrationCertificateUploaded =
                  value;
            });
          },

          onDegreeCertificateChanged:
              (value) {
            setState(() {
              _degreeCertificateUploaded =
                  value;
            });
          },

          onIdentityDocumentChanged:
              (value) {
            setState(() {
              _identityDocumentUploaded =
                  value;
            });
          },
        );

      // ==========================================================
      // STEP 9
      // ==========================================================

      case 8:
        return ReviewSubmitStep(
          fullName:
              _basicInformation?.fullName ?? '',

          phone:
              FirebaseAuth.instance
                  .currentUser
                  ?.phoneNumber ??
              '',

          email:
              _basicInformation?.email ?? '',

          profileImageUrl: null,

          professionalTitle:
              _professionalDetails
                  ?.professionalTitle ??
              '',

          registrationNumber:
              _verificationRegistrationNumber,

          primarySpecialization:
              _selectedSpecializations.isNotEmpty ? _selectedSpecializations.first : '',

          yearsOfExperience:
              _totalExperienceYears ?? 0,

          qualifications:
              _getQualificationsForReview(),

          specializations:
              _selectedSpecializations,

          services:
              _getSelectedServices(),

          clinicName:
              _physioLocation.clinicName,

          address:
              _physioLocation.address,

          city:
              _physioLocation.city,

          state:
              _physioLocation.state,

          pincode:
              _physioLocation.pincode,

          locality: _physioLocation.locality,
          homeVisitRadiusKm: _homeVisitsAvailable ? _physioLocation.homeVisitRadiusKm : 0,
          pricingTierLabel: PricingConfig.tierForExperience(_totalExperienceYears ?? 1, city: _physioLocation.city, locality: _physioLocation.locality).title,

          workingDays: _legacyWorkingDays,
          startTime: _legacyStartTime,
          endTime: _legacyEndTime,

          serviceSchedules: _serviceSchedules,

          currency: _currency,

          homeVisitFee:
              _homeVisitFee,

          clinicVisitFee:
              _clinicVisitFee,

          onlineConsultationFee:
              _onlineConsultationFee,

          followUpFee:
              _followUpFee,

          travelChargesEnabled:
              _travelChargesEnabled,

          travelCharges:
              _travelCharges,

          discountAvailable:
              _discountAvailable,

          discountPercentage:
              _discountPercentage,

          identityDocumentUploaded:
              _identityDocumentUploaded,

          registrationDocumentUploaded:
              _registrationCertificateUploaded,

          qualificationDocumentUploaded:
              _degreeCertificateUploaded,

          termsAccepted:
              _termsAccepted,

          onTermsChanged: (value) {
            setState(() {
              _termsAccepted = value;
            });
          },

          onEditPersonal: () =>
              _goToStep(0),

          onEditProfessional: () =>
              _goToStep(1),

          onEditQualifications: () =>
              _goToStep(2),

          onEditSpecializations: () =>
              _goToStep(3),

          onEditLocation: () =>
              _goToStep(5),

          onEditAvailability: () =>
              _goToStep(6),

          onEditPricing: () =>
              _goToStep(5),

          onEditVerification: () =>
              _goToStep(7),
        );

      default:
        return const SizedBox();
    }
  }

  // ==============================================================
  // BUILD
  // ==============================================================


  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final progress = (_currentStep + 1) / _totalSteps;
    final width = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: !_isSaving && _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentStep > 0 && !_isSaving) _previousStep();
      },
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color(0xFF087F75),
            secondary: const Color(0xFF57CDBB),
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F8F7),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF8FBFA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            labelStyle: const TextStyle(color: Color(0xFF66817E), fontWeight: FontWeight.w600),
            hintStyle: const TextStyle(color: Color(0xFF9AAEAB)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE0EBE8))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE0EBE8))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF078F83), width: 1.6)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE17C7C))),
          ),
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F8F7),
          body: SafeArea(
            child: Column(
              children: [
                _JourneyTopBar(
                  current: _currentStep,
                  total: _totalSteps,
                  saving: _isSaving,
                  onBack: () {
                    if (_currentStep > 0) {
                      _previousStep();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1320),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 900;
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              wide ? 30 : 17, 10, wide ? 30 : 17, 24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (wide) ...[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 270,
                                        child: _JourneySideRail(
                                          current: _currentStep,
                                          steps: _steps,
                                          progress: progress,
                                        ),
                                      ),
                                      const SizedBox(width: 22),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            _buildFormPanel(step),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  _CompactJourneyProgress(
                                    current: _currentStep,
                                    total: _totalSteps,
                                    title: step.title,
                                    progress: progress,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildFormPanel(step),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                _JourneyBottomBar(
                  saving: _isSaving,
                  isLast: _currentStep == _totalSteps - 1,
                  onContinue: _nextStep,
                  onBack: _currentStep == 0 ? null : _previousStep,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormPanel(_OnboardingStepData step) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(.025, .025),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(_currentStep),
        padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 420 ? 17 : 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE3ECE9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C173F3A),
              blurRadius: 32,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF13A995), Color(0xFF08736C)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26078F83),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(step.icon, color: Colors.white, size: 21),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STEP ${( _currentStep + 1).toString().padLeft(2, '0')}  /  $_totalSteps',
                        style: const TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF078F83),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF143D3B),
                          letterSpacing: -.45,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7F5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '${(progressForStep(_currentStep, _totalSteps) * 100).round()}%',
                    style: const TextStyle(
                      color: Color(0xFF087F75),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStepContent(),
          ],
        ),
      ),
    );
  }

  double progressForStep(int current, int total) => (current + 1) / total;
}


class _CompactJourneyProgress extends StatelessWidget {
  final int current;
  final int total;
  final String title;
  final double progress;

  const _CompactJourneyProgress({
    required this.current,
    required this.total,
    required this.title,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 14, 17, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4ECE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'REGISTRATION PROGRESS',
                style: TextStyle(
                  color: Color(0xFF78908B),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.15,
                ),
              ),
              const Spacer(),
              Text(
                '$percent% complete',
                style: const TextStyle(
                  color: Color(0xFF087F75),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFEAF1EF),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF0B9B8B)),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              const Icon(Icons.circle, size: 7, color: Color(0xFF0B9B8B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'STEP ${current + 1} OF $total  ·  $title',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF234B46),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ONBOARDING STEP DATA
// ================================================================

class _OnboardingStepData {
  final String title;
  final String subtitle;
  final IconData icon;

  const _OnboardingStepData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _JourneyTopBar extends StatelessWidget {
  final int current, total; final bool saving; final VoidCallback onBack;
  const _JourneyTopBar({required this.current, required this.total, required this.saving, required this.onBack});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(17, 10, 19, 2),
    child: Row(children: [
      InkWell(onTap: saving ? null : onBack, borderRadius: BorderRadius.circular(15), child: Container(
        width: 42, height: 42, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Color(0x0D164A45), blurRadius: 12, offset: Offset(0, 4))]),
        child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF174A46)),
      )),
      const SizedBox(width: 12),
      Container(width: 35, height: 35, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0AA895), Color(0xFF075E5B)]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 20)),
      const SizedBox(width: 9),
      const Expanded(child: Text('PhysioCare', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF123F3B), letterSpacing: -.4))),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFE4F6F2), borderRadius: BorderRadius.circular(30)), child: Text('${(current + 1).toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}', style: const TextStyle(color: Color(0xFF078779), fontSize: 11, fontWeight: FontWeight.w900))),
    ]),
  );
}


class _JourneyProgress extends StatelessWidget {
  final int current;
  final List<_OnboardingStepData> steps;
  final double progress;
  final bool wide;

  const _JourneyProgress({
    required this.current,
    required this.steps,
    required this.progress,
    required this.wide,
  });

  @override
  Widget build(BuildContext context) {
    final active = steps[current];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFFE2ECE9)),
        boxShadow: const [
          BoxShadow(color: Color(0x08164A45), blurRadius: 20, offset: Offset(0, 7)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'YOUR REGISTRATION JOURNEY',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.25,
                    color: Color(0xFF718D89),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}% complete',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF078779),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE8F1EF),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF0AA895)),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7F3),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(active.icon, color: const Color(0xFF078779), size: 15),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Step ${current + 1} of ${steps.length} · ${active.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF234B46),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (wide)
                Text(
                  '${steps.length - current - 1} steps left',
                  style: const TextStyle(
                    color: Color(0xFF8BA09C),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (wide) ...[
            const SizedBox(height: 14),
            Row(
              children: List.generate(
                steps.length,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == steps.length - 1 ? 0 : 5),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 5,
                      decoration: BoxDecoration(
                        color: i <= current
                            ? const Color(0xFF0AA895)
                            : const Color(0xFFE6EFED),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _JourneySideRail extends StatelessWidget {
  final int current;
  final List<_OnboardingStepData> steps;
  final double progress;

  const _JourneySideRail({
    required this.current,
    required this.steps,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE2ECE9)),
        boxShadow: const [
          BoxShadow(color: Color(0x08164A45), blurRadius: 22, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROFILE SETUP',
            style: TextStyle(
              color: Color(0xFF078F83),
              fontSize: 9,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Your journey\nto get discovered.',
            style: TextStyle(
              color: Color(0xFF143D3B),
              fontSize: 22,
              height: 1.12,
              fontWeight: FontWeight.w900,
              letterSpacing: -.7,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE8F1EF),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF0AA895)),
            ),
          ),
          const SizedBox(height: 19),
          ...List.generate(steps.length, (i) {
            final isCurrent = i == current;
            final isDone = i < current;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFFEAF7F4) : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: isCurrent ? const Color(0xFFCDEBE4) : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF0A9A89)
                            : isCurrent
                                ? const Color(0xFF087F75)
                                : const Color(0xFFF0F4F3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDone ? Icons.check_rounded : steps[i].icon,
                        size: 13,
                        color: isDone || isCurrent ? Colors.white : const Color(0xFF9AAEAA),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        steps[i].title,
                        maxLines: 2,
                        style: TextStyle(
                          color: isCurrent
                              ? const Color(0xFF14534C)
                              : isDone
                                  ? const Color(0xFF66817C)
                                  : const Color(0xFF91A39F),
                          fontSize: 10.5,
                          fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9F8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFF078F83), size: 17),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your details are protected and used to build your professional profile.',
                    style: TextStyle(
                      color: Color(0xFF718984),
                      fontSize: 9.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyArtwork extends StatelessWidget {
  final int step; final String title, subtitle; final bool compact;
  const _JourneyArtwork({required this.step, required this.title, required this.subtitle, required this.compact});
  static const _icons = [Icons.person_pin_rounded, Icons.workspace_premium_rounded, Icons.school_rounded, Icons.spa_rounded, Icons.medical_services_rounded, Icons.location_on_rounded, Icons.calendar_month_rounded, Icons.verified_user_rounded, Icons.task_alt_rounded];
  static const _kickers = ['A great profile starts with you', 'Define your professional identity', 'Showcase your learning journey', 'Highlight the care you specialise in', 'Let patients know your experience', 'Help patients find your practice', 'Make time for better care', 'Build trust with verified credentials', 'One final look before you go live'];
  @override Widget build(BuildContext context) {
    final art = Container(
      height: compact ? 174 : 440,
      decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF087C75), Color(0xFF07534F), Color(0xFF123D46)]), borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Color(0x30066B63), blurRadius: 28, offset: Offset(0, 13))]),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Positioned(right: -65, top: -75, child: _orb(220, const Color(0x335DE5D0))),
        Positioned(left: -70, bottom: -100, child: _orb(230, const Color(0x2254D5C4))),
        Positioned(right: 24, top: 28, child: _floating(Icons.favorite_rounded, const Color(0xFF7CE6D4), 44)),
        Positioned(left: 24, bottom: compact ? 24 : 68, child: _floating(Icons.health_and_safety_rounded, const Color(0xFFB5F1E8), 42)),
        Positioned(right: compact ? 26 : 35, bottom: compact ? 17 : 45, child: _floating(Icons.auto_awesome_rounded, const Color(0xFFFFD98B), 34)),
        Positioned.fill(child: Padding(padding: EdgeInsets.all(compact ? 18 : 28), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(.13), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(.17))), child: Text('STEP ${step + 1}  •  PHYSIOCARE', style: const TextStyle(color: Color(0xFFB9F3E9), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))),
            SizedBox(height: compact ? 9 : 22), Text(_kickers[step], maxLines: compact ? 2 : 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: compact ? 17 : 28, height: 1.15, fontWeight: FontWeight.w900, letterSpacing: -.5)),
            if (!compact) ...[const SizedBox(height: 12), Text(subtitle, style: const TextStyle(color: Color(0xFFD0EAE6), fontSize: 13, height: 1.5)), const SizedBox(height: 22), const Row(children: [Icon(Icons.verified_rounded, color: Color(0xFF75E2D0), size: 16), SizedBox(width: 7), Text('A trusted professional network', style: TextStyle(color: Color(0xFFD0EAE6), fontSize: 11, fontWeight: FontWeight.w600))])],
          ])),
          SizedBox(width: compact ? 8 : 12),
          SizedBox(width: compact ? 116 : 190, child: Stack(alignment: Alignment.center, children: [
            Container(width: compact ? 105 : 178, height: compact ? 105 : 178, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF8CE8DA).withOpacity(.12), border: Border.all(color: Colors.white.withOpacity(.17), width: 1.5))),
            Container(width: compact ? 82 : 145, height: compact ? 82 : 145, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(colors: [Color(0xFFBDF7EC), Color(0xFF48BFB0)]), boxShadow: const [BoxShadow(color: Color(0x6659D9C7), blurRadius: 28)]), child: Icon(_icons[step], size: compact ? 43 : 78, color: const Color(0xFF075D58))),
            Positioned(top: compact ? 2 : 20, right: 0, child: _floating(Icons.add_rounded, Colors.white, compact ? 25 : 34)),
            Positioned(bottom: compact ? 4 : 20, left: 0, child: _floating(Icons.favorite_rounded, const Color(0xFFFFAFAF), compact ? 25 : 34)),
          ])),
        ]))),
      ]),
    );
    return TweenAnimationBuilder<double>(tween: Tween(begin: .94, end: 1), duration: const Duration(milliseconds: 650), curve: Curves.easeOutBack, builder: (context, value, child) => Transform.scale(scale: value, child: child), child: art);
  }
  Widget _orb(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  Widget _floating(IconData icon, Color color, double size) => Container(width: size, height: size, decoration: BoxDecoration(color: Colors.white.withOpacity(.94), borderRadius: BorderRadius.circular(size * .32), boxShadow: const [BoxShadow(color: Color(0x33002020), blurRadius: 14, offset: Offset(0, 5))]), child: Icon(icon, color: color == Colors.white ? const Color(0xFF078779) : color, size: size * .52));
}

class _JourneyBottomBar extends StatelessWidget {
  final bool saving, isLast; final VoidCallback onContinue; final VoidCallback? onBack;
  const _JourneyBottomBar({required this.saving, required this.isLast, required this.onContinue, required this.onBack});
  @override Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(18, 12, 18, MediaQuery.paddingOf(context).bottom > 0 ? 9 : 17),
    decoration: BoxDecoration(color: Colors.white, border: const Border(top: BorderSide(color: Color(0xFFE5EFED))), boxShadow: const [BoxShadow(color: Color(0x0B174A45), blurRadius: 20, offset: Offset(0, -5))]),
    child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: Row(children: [
      if (onBack != null) ...[OutlinedButton(onPressed: saving ? null : onBack, style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF37645F), side: const BorderSide(color: Color(0xFFDCEAE7)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w800))), const SizedBox(width: 10)],
      Expanded(child: SizedBox(height: 54, child: DecoratedBox(decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0AA895), Color(0xFF08766F)]), borderRadius: BorderRadius.circular(17), boxShadow: const [BoxShadow(color: Color(0x33078F83), blurRadius: 17, offset: Offset(0, 7))]), child: ElevatedButton(onPressed: saving ? null : onContinue, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, disabledBackgroundColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))), child: saving ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(isLast ? 'Submit for verification' : 'Continue your journey', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)), const SizedBox(width: 9), Icon(isLast ? Icons.verified_rounded : Icons.arrow_forward_rounded, color: Colors.white, size: 19)]))))),
    ]))),
  );
}
