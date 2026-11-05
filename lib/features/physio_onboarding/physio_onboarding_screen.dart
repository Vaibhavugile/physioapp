import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/physiotherapist_service.dart';
import 'pricing_config.dart';

import 'widgets/availability_step.dart';
import 'widgets/premium_theme.dart';
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

    return PopScope(
      canPop: !_isSaving && _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentStep > 0 && !_isSaving) _previousStep();
      },
      child: Theme(
        data: PX.theme(Theme.of(context)),
        child: Scaffold(
          backgroundColor: PX.bg,
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
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        child: _buildFormPanel(step),
                      ),
                    ),
                  ),
                ),
                _JourneyBottomBar(
                  saving: _isSaving,
                  isLast: _currentStep == _totalSteps - 1,
                  current: _currentStep,
                  total: _totalSteps,
                  onContinue: _nextStep,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormPanel(_OnboardingStepData step) {
    final chapter = PXChapters.of(_currentStep);
    final chapterNo = PXChapters.indexOf(_currentStep) + 1;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, .03),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Column(
        key: ValueKey(_currentStep),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 14),
          Text(
            'CHAPTER $chapterNo  ·  ${chapter.name.toUpperCase()}',
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w800,
              color: PX.teal,
            ),
          ),
          const SizedBox(height: 8),
          Text(step.title, style: PX.display(30)),
          const SizedBox(height: 8),
          Text(
            step.subtitle,
            style: const TextStyle(fontSize: 14.5, height: 1.5, color: PX.muted),
          ),
          const SizedBox(height: 22),
          _buildStepContent(),
        ],
      ),
    );
  }

  double progressForStep(int current, int total) => (current + 1) / total;
}

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
  final int current, total;
  final bool saving;
  final VoidCallback onBack;
  const _JourneyTopBar({
    required this.current,
    required this.total,
    required this.saving,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
        child: Row(
          children: [
            Material(
              color: Colors.white,
              shape: const CircleBorder(side: BorderSide(color: PX.line)),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: saving ? null : onBack,
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(Icons.arrow_back_rounded, color: PX.ink),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: PXSegmentedProgress(current: current)),
            const SizedBox(width: 16),
            Text(
              '${current + 1}/$total',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: PX.muted,
              ),
            ),
          ],
        ),
      );
}

class _JourneyBottomBar extends StatelessWidget {
  final bool saving, isLast;
  final int current, total;
  final VoidCallback onContinue;
  const _JourneyBottomBar({
    required this.saving,
    required this.isLast,
    required this.current,
    required this.total,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottom > 0 ? 8 : 18),
      decoration: const BoxDecoration(
        color: PX.bg,
        border: Border(top: BorderSide(color: PX.line)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Step ${current + 1} of $total  ·  saved automatically',
                style: const TextStyle(fontSize: 12, color: PX.muted),
              ),
              const SizedBox(height: 10),
              PXPillButton(
                label: isLast ? 'Submit for verification' : 'Continue',
                loading: saving,
                onPressed: saving ? null : onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
