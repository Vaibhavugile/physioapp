import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/physiotherapist_service.dart';

import 'widgets/availability_step.dart';
import 'widgets/basic_information_step.dart';
import 'widgets/education_qualifications_step.dart';
import 'widgets/experience_work_step.dart';
import 'widgets/fees_pricing_step.dart';
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
  // STEP 6 — FEES & PRICING
  // ==============================================================

  String _currency = 'INR';

  double _homeVisitFee = 0;

  double _clinicVisitFee = 0;

  double _onlineConsultationFee = 0;

  double _followUpFee = 0;

  bool _travelChargesEnabled = false;

  double _travelCharges = 0;

  bool _discountAvailable = false;

  double _discountPercentage = 0;

  // ==============================================================
  // STEP 7 — AVAILABILITY
  // ==============================================================

  Set<String> _selectedDays = {
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  };

  TimeOfDay _startTime =
const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime =
const TimeOfDay(hour: 18, minute: 0);
  bool _homeVisitsAvailable = true;

  bool _clinicVisitsAvailable = true;

  bool _onlineConsultationAvailable = false;

  bool _emergencyAvailable = false;

  int _maxAppointmentsPerDay = 10;

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
          'Share your professional identity and registration details.',
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
      title: 'Fees & Pricing',
      subtitle:
          'Set your consultation and physiotherapy service charges.',
      icon: Icons.currency_rupee_rounded,
    ),

    const _OnboardingStepData(
      title: 'Availability',
      subtitle:
          'Set your working days and preferred consultation hours.',
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

      if (data.email.trim().isEmpty) {
        _showMessage(
          'Please enter your email address.',
          isError: true,
        );
        return false;
      }

      if (data.city.trim().isEmpty) {
        _showMessage(
          'Please enter your city.',
          isError: true,
        );
        return false;
      }

      if (data.state.trim().isEmpty) {
        _showMessage(
          'Please enter your state.',
          isError: true,
        );
        return false;
      }
    }

    // ============================================================
    // STEP 2
    // ============================================================

    if (_currentStep == 1) {
      if (_professionalDetails == null) {
        _showMessage(
          'Please complete your professional details.',
          isError: true,
        );
        return false;
      }

      final data =
          _professionalDetails!;

      if (data.professionalTitle
          .trim()
          .isEmpty) {
        _showMessage(
          'Please select your professional title.',
          isError: true,
        );
        return false;
      }

      if (data.registrationNumber
          .trim()
          .isEmpty) {
        _showMessage(
          'Please enter your registration number.',
          isError: true,
        );
        return false;
      }

      if (data.registrationAuthority
          .trim()
          .isEmpty) {
        _showMessage(
          'Please enter your registration authority.',
          isError: true,
        );
        return false;
      }

      if (data.primarySpecialization
          .trim()
          .isEmpty) {
        _showMessage(
          'Please select your primary specialization.',
          isError: true,
        );
        return false;
      }

      if (data.languages.isEmpty) {
        _showMessage(
          'Please select at least one language.',
          isError: true,
        );
        return false;
      }

      final hasService =
          data.providesHomeVisit ||
              data.providesOnlineConsultation ||
              data.providesClinicVisit;

      if (!hasService) {
        _showMessage(
          'Please select at least one service.',
          isError: true,
        );
        return false;
      }
    }

    // ============================================================
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

    // ============================================================
    // STEP 6
    // ============================================================

    if (_currentStep == 5) {
      final hasFee =
          _homeVisitFee > 0 ||
              _clinicVisitFee > 0 ||
              _onlineConsultationFee > 0;

      if (!hasFee) {
        _showMessage(
          'Please set at least one consultation fee.',
          isError: true,
        );
        return false;
      }
    }

    // ============================================================
    // STEP 7
    // ============================================================

    if (_currentStep == 6) {
      if (_selectedDays.isEmpty) {
        _showMessage(
          'Please select at least one working day.',
          isError: true,
        );
        return false;
      }

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

      final startMinutes =
          (_startTime.hour * 60) +
              _startTime.minute;

      final endMinutes =
          (_endTime.hour * 60) +
              _endTime.minute;

      if (endMinutes <= startMinutes) {
        _showMessage(
          'End time must be after start time.',
          isError: true,
        );
        return false;
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

            'city':
                data.city.trim(),

            'state':
                data.state.trim(),

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
      // STEP 2 — PROFESSIONAL DETAILS
      // ==========================================================

      if (_currentStep == 1 &&
          _professionalDetails != null) {
        final data =
            _professionalDetails!;

        await _physiotherapistService
            .updateFields(
          uid: uid,
          data: {
            'professionalTitle':
                data.professionalTitle
                    .trim(),

            'registrationNumber':
                data.registrationNumber
                    .trim(),

            'registrationCouncil':
                data.registrationAuthority
                    .trim(),

            'primarySpecialization':
                data.primarySpecialization
                    .trim(),

            'languages':
                data.languages,

            'homeVisitEnabled':
                data.providesHomeVisit,

            'clinicVisitEnabled':
                data.providesClinicVisit,

            'onlineConsultationEnabled':
                data.providesOnlineConsultation,
          },
        );
      }

      // ==========================================================
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
      // STEP 6 — PRICING
      // ==========================================================

      if (_currentStep == 5) {
        await _physiotherapistService
            .updateFields(
          uid: uid,
          data: {
            'currency': _currency,

            'homeVisitPrice':
                _homeVisitFee,

            'clinicVisitPrice':
                _clinicVisitFee,

            'onlineConsultationPrice':
                _onlineConsultationFee,

            'followUpPrice':
                _followUpFee,

            'travelChargesEnabled':
                _travelChargesEnabled,

            'travelCharges':
                _travelCharges,

            'discountAvailable':
                _discountAvailable,

            'discountPercentage':
                _discountPercentage,
          },
        );
      }

      // ==========================================================
      // STEP 7 — AVAILABILITY
      // ==========================================================

      if (_currentStep == 6) {
        await _physiotherapistService
            .updateFields(
          uid: uid,
          data: {
            'workingDays':
                _selectedDays.toList(),

            'startTime':
                _formatTime(_startTime),

            'endTime':
                _formatTime(_endTime),

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
              : const Color(0xFF2457F5),
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

          initialCity:
              _basicInformation?.city,

          initialState:
              _basicInformation?.state,

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
        return FeesPricingStep(
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

          onCurrencyChanged: (value) {
            setState(() {
              _currency = value;
            });
          },

          onHomeVisitFeeChanged:
              (value) {
            setState(() {
              _homeVisitFee = value;
            });
          },

          onClinicVisitFeeChanged:
              (value) {
            setState(() {
              _clinicVisitFee = value;
            });
          },

          onOnlineConsultationFeeChanged:
              (value) {
            setState(() {
              _onlineConsultationFee =
                  value;
            });
          },

          onFollowUpFeeChanged:
              (value) {
            setState(() {
              _followUpFee = value;
            });
          },

          onTravelChargesEnabledChanged:
              (value) {
            setState(() {
              _travelChargesEnabled =
                  value;
            });
          },

          onTravelChargesChanged:
              (value) {
            setState(() {
              _travelCharges = value;
            });
          },

          onDiscountAvailableChanged:
              (value) {
            setState(() {
              _discountAvailable =
                  value;
            });
          },

          onDiscountPercentageChanged:
              (value) {
            setState(() {
              _discountPercentage =
                  value;
            });
          },
        );

      // ==========================================================
      // STEP 7
      // ==========================================================

      case 6:
        return AvailabilityStep(
          selectedDays: _selectedDays,

          startTime: _startTime,

          endTime: _endTime,

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

          onDaysChanged: (value) {
            setState(() {
              _selectedDays =
                  Set<String>.from(value);
            });
          },

          onStartTimeChanged: (value) {
            setState(() {
              _startTime = value;
            });
          },

          onEndTimeChanged: (value) {
            setState(() {
              _endTime = value;
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
              _professionalDetails
                  ?.registrationNumber ??
              _verificationRegistrationNumber,

          primarySpecialization:
              _professionalDetails
                  ?.primarySpecialization ??
              '',

          yearsOfExperience:
              _totalExperienceYears ??
              _professionalDetails
                  ?.yearsOfExperience ??
              0,

          qualifications:
              _getQualificationsForReview(),

          specializations:
              _selectedSpecializations,

          services:
              _getSelectedServices(),

          clinicName:
              _currentOrganization,

          address: '',

          city:
              _basicInformation?.city ?? '',

          state:
              _basicInformation?.state ?? '',

          pincode: '',

          workingDays:
              _selectedDays.toList(),

          startTime:
              _formatTime(_startTime),

          endTime:
              _formatTime(_endTime),

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
              _goToStep(4),

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

    final progress =
        (_currentStep + 1) /
            _totalSteps;

    return PopScope(
      canPop:
          !_isSaving &&
          _currentStep == 0,

      onPopInvokedWithResult:
          (didPop, result) {
        if (!didPop &&
            _currentStep > 0 &&
            !_isSaving) {
          _previousStep();
        }
      },

      child: Scaffold(
        backgroundColor:
            const Color(0xFFF5F7FC),

        body: SafeArea(
          child: Column(
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  14,
                  22,
                  0,
                ),

                child: Row(
                  children: [
                    IconButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              if (_currentStep >
                                  0) {
                                _previousStep();
                              } else {
                                Navigator.pop(
                                  context,
                                );
                              }
                            },

                      icon: const Icon(
                        Icons
                            .arrow_back_ios_new_rounded,
                        size: 20,
                        color:
                            Color(0xFF111A3D),
                      ),
                    ),

                    const SizedBox(width: 4),

                    const Expanded(
                      child: Text(
                        'Complete your profile',

                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Color(0xFF111A3D),
                        ),
                      ),
                    ),

                    Text(
                      '${_currentStep + 1}/$_totalSteps',

                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF2457F5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // PROGRESS
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 22,
                ),

                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20),

                  child:
                      LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor:
                        const Color(
                      0xFFE4E8F2,
                    ),
                    valueColor:
                        const AlwaysStoppedAnimation(
                      Color(0xFF2457F5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // TITLE
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 22,
                ),

                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,

                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFEAF0FF),

                        borderRadius:
                            BorderRadius.circular(
                          13,
                        ),
                      ),

                      child: Icon(
                        step.icon,
                        color:
                            const Color(0xFF2457F5),
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Text(
                            step.title,

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w900,
                              color:
                                  Color(0xFF111A3D),
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            step.subtitle,

                            maxLines: 2,

                            overflow:
                                TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.35,
                              color:
                                  Color(0xFF7B849C),
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // CONTENT
              // ==================================================

              Expanded(
                child:
                    SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),

                  padding:
                      const EdgeInsets.fromLTRB(
                    22,
                    0,
                    22,
                    20,
                  ),

                  child: AnimatedSwitcher(
                    duration:
                        const Duration(
                      milliseconds: 250,
                    ),

                    child: KeyedSubtree(
                      key:
                          ValueKey(_currentStep),

                      child:
                          _buildStepContent(),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // BOTTOM BUTTON
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.fromLTRB(
                  22,
                  14,
                  22,
                  22,
                ),

                decoration:
                    const BoxDecoration(
                  color: Colors.white,

                  border: Border(
                    top: BorderSide(
                      color:
                          Color(0xFFE9ECF3),
                    ),
                  ),
                ),

                child: SafeArea(
                  top: false,

                  child: SizedBox(
                    width: double.infinity,
                    height: 54,

                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : _nextStep,

                      style:
                          ElevatedButton.styleFrom(
                        elevation: 0,

                        backgroundColor:
                            const Color(
                          0xFF2457F5,
                        ),

                        disabledBackgroundColor:
                            const Color(
                          0xFFB8C5F5,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),
                      ),

                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,

                              children: [
                                Text(
                                  _currentStep ==
                                          _totalSteps -
                                              1
                                      ? 'Submit Profile'
                                      : 'Continue',

                                  style:
                                      const TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight
                                            .w800,
                                    color:
                                        Colors.white,
                                  ),
                                ),

                                const SizedBox(
                                  width: 8,
                                ),

                                Icon(
                                  _currentStep ==
                                          _totalSteps -
                                              1
                                      ? Icons
                                          .check_circle_rounded
                                      : Icons
                                          .arrow_forward_rounded,

                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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