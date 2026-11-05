import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/config/pricing_config.dart';

import 'models/booking_model.dart';
import 'services/booking_service.dart';

import 'widgets/booking_header.dart';
import 'widgets/recovery_package_card.dart';
import 'widgets/appointment_date_selector.dart';
import 'widgets/appointment_time_selector.dart';
import 'widgets/patient_details_card.dart';
import 'widgets/booking_summary_card.dart';

// ================================================================
// BOOKING DETAILS SCREEN
// ================================================================

class BookingDetailsScreen extends StatefulWidget {
  // ==============================================================
  // PHYSIOTHERAPIST DATA
  // ==============================================================

  final String physiotherapistId;

  final String doctorName;
  final String doctorImage;
  final String specialty;
  final double rating;

  final String? physiotherapistPhone;

  // ==============================================================
  // UNIVERSAL PRICING INPUT
  // ==============================================================
  //
  // Physiotherapists do not provide their own price.
  // PricingConfig determines:
  // Experience → Tier → Care Mode → Session Price
  //
  // ==============================================================
  final int experienceYears;

  // ==============================================================
  // OPTIONAL PRESELECTED VALUES
  // ==============================================================

  final String initialCareMode;
  final int initialPackageVisits;
  final String? initialTime;
final List<String> workingDays;
  const BookingDetailsScreen({
    super.key,

    required this.physiotherapistId,

    required this.doctorName,

    this.doctorImage = '',

    required this.specialty,

    this.rating = 0,

    this.physiotherapistPhone,

    required this.experienceYears,

    this.initialCareMode = PricingConfig.home,
    this.initialPackageVisits = 1,

    this.initialTime,
    this.workingDays = const [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
],
  });

  @override
  State<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

// ================================================================
// BOOKING DETAILS STATE
// ================================================================

class _BookingDetailsScreenState
    extends State<BookingDetailsScreen> {

  // ===============================================================
  // CONTROLLERS
  // ===============================================================

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _addressController =
      TextEditingController();

  // ===============================================================
  // SERVICES
  // ===============================================================

  final BookingService _bookingService =
      const BookingService();

  // ===============================================================
  // LOADING STATE
  // ===============================================================

  bool _isCreatingBooking = false;

  // ===============================================================
  // BOOKING STATE
  // ===============================================================

  String _selectedCareMode = PricingConfig.home;

  bool get _homeVisit => _selectedCareMode == PricingConfig.home;
  bool get _onlineVisit => _selectedCareMode == PricingConfig.online;
  String get _careLabel => _homeVisit ? 'Home Visit' : (_onlineVisit ? 'Online Consultation' : 'Clinic Visit');

  int _selectedPackage = 1;

  late DateTime _selectedDate;

  String? _selectedTime;

  // ===============================================================
  // APPOINTMENT AVAILABILITY
  // ===============================================================
  //
  // A time slot is considered booked when ANY booking exists for
  // this physiotherapist on the selected date at that time.
  // Care mode is intentionally NOT considered.
  //
  // Home + Clinic + Online all block the same appointment slot.
  // ===============================================================

  List<String> _unavailableSlots = <String>[];
  bool _isLoadingAvailability = false;
  bool _availabilityLoadFailed = false;

  // ===============================================================
  // PHYSIOTHERAPIST WORKING DAYS
  // ===============================================================
  //
  // These values come from the physiotherapist's onboarding
  // availability configuration stored in Firestore.
  //
  // Example:
  // ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
  //
  // The date selector uses this list to disable weekly off-days.
  // ===============================================================

 List<String> _workingDays = <String>[
  'MON',
  'TUE',
  'WED',
  'THU',
  'FRI',
  'SAT',
  'SUN',
];

  bool _isLoadingWorkingDays = false;

  // ===============================================================
  // CURRENT STEP
  // ===============================================================

  int _currentStep = 0;

  static const int _totalSteps = 5;

  // ===============================================================
  // PHYSIOTHERAPIST-ASSIGNED PRICING SNAPSHOT
  // ===============================================================
  // The onboarding flow saves the assigned rate card directly on the
  // physiotherapist document. Booking reads those saved values; it does
  // NOT recalculate a generic rate from experience years on the patient app.
  // ===============================================================

  double? _homeVisitPrice;
  double? _clinicVisitPrice;
  double? _onlineConsultationPrice;
  double? _followUpPrice;
  String _currency = 'INR';
  String _pricingTierLabel = '';
  String _pricingConfigVersion = '';
  String _pricingCity = '';
  String _pricingLocality = '';
  bool _discountAvailable = false;
  double _discountPercentage = 0;
  bool _travelChargesEnabled = false;
  double _travelCharges = 0;
  bool _homeVisitEnabled = true;
  bool _clinicVisitEnabled = true;
  bool _onlineConsultationEnabled = false;
  bool _pricingReady = false;
  String? _pricingError;
  Map<String, dynamic> _serviceSchedules = <String, dynamic>{};
  List<String> _legacyWorkingDays = <String>[];

  String get _careMode => _selectedCareMode;

  String get _tierName => _pricingTierLabel.isNotEmpty
      ? _pricingTierLabel
      : 'Assigned physiotherapist rate';

  String get _currencyPrefix => _currency.toUpperCase() == 'INR'
      ? '₹'
      : '$_currency ';

  String get _pricingLocationContext {
    final location = [_pricingLocality, _pricingCity]
        .where((value) => value.trim().isNotEmpty)
        .join(', ');
    return location.isEmpty ? '' : ' in $location';
  }

  double get _sessionPrice {
    switch (_selectedCareMode) {
      case PricingConfig.home:
        return _homeVisitPrice ?? 0;
      case PricingConfig.clinic:
        return _clinicVisitPrice ?? 0;
      case PricingConfig.online:
        return _onlineConsultationPrice ?? 0;
      default:
        return 0;
    }
  }

  bool get _selectedCareModeEnabled {
    switch (_selectedCareMode) {
      case PricingConfig.home:
        return _homeVisitEnabled && (_homeVisitPrice ?? 0) > 0;
      case PricingConfig.clinic:
        return _clinicVisitEnabled && (_clinicVisitPrice ?? 0) > 0;
      case PricingConfig.online:
        return _onlineConsultationEnabled &&
            (_onlineConsultationPrice ?? 0) > 0;
      default:
        return false;
    }
  }

  double _priceForMode(String mode) {
    switch (mode) {
      case PricingConfig.home:
        return _homeVisitPrice ?? 0;
      case PricingConfig.clinic:
        return _clinicVisitPrice ?? 0;
      case PricingConfig.online:
        return _onlineConsultationPrice ?? 0;
      default:
        return 0;
    }
  }

  double? _readStoredPrice(dynamic value) {
    if (value is num && value >= 0) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  void _applyPhysiotherapistSnapshot(Map<String, dynamic> data) {
    _homeVisitPrice = _readStoredPrice(data['homeVisitPrice']);
    _clinicVisitPrice = _readStoredPrice(data['clinicVisitPrice']);
    _onlineConsultationPrice =
        _readStoredPrice(data['onlineConsultationPrice']);
    _followUpPrice = _readStoredPrice(data['followUpPrice']);
    _currency = (data['currency'] ?? 'INR').toString();
    _pricingTierLabel = (data['pricingTierLabel'] ?? '').toString().trim();
    _pricingConfigVersion =
        (data['pricingConfigVersion'] ?? '').toString().trim();
    _pricingCity = (data['pricingCity'] ?? data['city'] ?? '').toString();
    _pricingLocality =
        (data['pricingLocality'] ?? data['locality'] ?? '').toString();
    _discountAvailable = data['discountAvailable'] == true;
    _discountPercentage = _readStoredPrice(data['discountPercentage']) ?? 0;
    _travelChargesEnabled = data['travelChargesEnabled'] == true;
    _travelCharges = _readStoredPrice(data['travelCharges']) ?? 0;

    _homeVisitEnabled = data['homeVisitEnabled'] is bool
        ? data['homeVisitEnabled'] as bool
        : true;
    _clinicVisitEnabled = data['clinicVisitEnabled'] is bool
        ? data['clinicVisitEnabled'] as bool
        : true;
    _onlineConsultationEnabled =
        data['onlineConsultationEnabled'] is bool
            ? data['onlineConsultationEnabled'] as bool
            : false;

    final schedules = data['serviceSchedules'];
    _serviceSchedules = schedules is Map
        ? Map<String, dynamic>.from(schedules)
        : <String, dynamic>{};

    final homeSchedule = _serviceSchedules['home'];
    final clinicSchedule = _serviceSchedules['clinic'];
    final onlineSchedule = _serviceSchedules['online'];
    if (homeSchedule is Map && homeSchedule['enabled'] is bool) {
      _homeVisitEnabled = _homeVisitEnabled && homeSchedule['enabled'] == true;
    }
    if (clinicSchedule is Map && clinicSchedule['enabled'] is bool) {
      _clinicVisitEnabled = _clinicVisitEnabled && clinicSchedule['enabled'] == true;
    }
    if (onlineSchedule is Map && onlineSchedule['enabled'] is bool) {
      _onlineConsultationEnabled =
          _onlineConsultationEnabled && onlineSchedule['enabled'] == true;
    }

    _pricingReady =
        (_homeVisitEnabled && (_homeVisitPrice ?? 0) > 0) ||
        (_clinicVisitEnabled && (_clinicVisitPrice ?? 0) > 0) ||
        (_onlineConsultationEnabled &&
            (_onlineConsultationPrice ?? 0) > 0);

    _pricingError = _pricingReady
        ? null
        : 'This physiotherapist does not have a complete active price list. Please contact support.';

    if (!_selectedCareModeEnabled) {
      if (_homeVisitEnabled && (_homeVisitPrice ?? 0) > 0) {
        _selectedCareMode = PricingConfig.home;
      } else if (_clinicVisitEnabled && (_clinicVisitPrice ?? 0) > 0) {
        _selectedCareMode = PricingConfig.clinic;
      } else if (_onlineConsultationEnabled &&
          (_onlineConsultationPrice ?? 0) > 0) {
        _selectedCareMode = PricingConfig.online;
      }
    }

    final legacyDays = data['workingDays'];
    _legacyWorkingDays = legacyDays is List
        ? legacyDays.map((e) => e.toString()).toList()
        : <String>[];
    _applyWorkingDaysForSelectedMode(_legacyWorkingDays);
  }

  void _applyWorkingDaysForSelectedMode(dynamic legacyWorkingDays) {
    final serviceKey = _selectedCareMode == PricingConfig.home
        ? 'home'
        : _selectedCareMode == PricingConfig.clinic
            ? 'clinic'
            : 'online';
    final schedule = _serviceSchedules[serviceKey];
    dynamic rawDays;
    if (schedule is Map && schedule['days'] is List) {
      rawDays = schedule['days'];
    } else {
      rawDays = legacyWorkingDays;
    }
    if (rawDays == null || rawDays is! List || rawDays.isEmpty) {
      rawDays = legacyWorkingDays ?? _legacyWorkingDays;
    }
    if (rawDays is List) {
      final days = rawDays
          .map((day) => _normalizeWorkingDay(day.toString()))
          .where((day) => day.isNotEmpty)
          .toSet()
          .toList();
      if (days.isNotEmpty) _workingDays = days;
    }
  }

  List<_PackageOption> get _packages {
    return PricingConfig.packages.map((config) {
      final safeSessionPrice = _selectedCareModeEnabled ? _sessionPrice : 0.0;
      final original = safeSessionPrice * config.visits;
      final discountPercent = _discountAvailable
          ? _discountPercentage.clamp(0, 100).toDouble()
          : 0.0;
      final savings = original * discountPercent / 100;
      final finalPrice = original - savings;
      return _PackageOption(
        id: config.id,
        visits: config.visits,
        title: config.title,
        description: config.description,
        price: finalPrice.round(),
        savings: savings.round(),
        originalPrice: original.round(),
        sessionPrice: safeSessionPrice,
        discountPercent: discountPercent,
        popular: config.popular,
        bestValue: config.bestValue,
      );
    }).toList();
  }

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();
_workingDays = widget.workingDays
    .map((day) => _normalizeWorkingDay(day))
    .where((day) => day.isNotEmpty)
    .toSet()
    .toList();

if (_workingDays.isEmpty) {
  _workingDays = <String>[
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];
}
    final now = DateTime.now();

    _selectedDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    _selectedPackage = widget.initialPackageVisits;

    // -------------------------------------------------------------
    // INITIAL CARE MODE
    // -------------------------------------------------------------

    final mode =
        widget.initialCareMode
            .trim()
            .toLowerCase();

    _selectedCareMode = mode == PricingConfig.online ||
            mode == 'onlineconsultation' || mode == 'online_consultation'
        ? PricingConfig.online
        : mode == PricingConfig.clinic || mode == 'clinicvisit'
            ? PricingConfig.clinic
            : PricingConfig.home;

    // -------------------------------------------------------------
    // INITIAL TIME
    // -------------------------------------------------------------

    if (widget.initialTime != null &&
        widget.initialTime!.trim().isNotEmpty) {
      _selectedTime =
          widget.initialTime!.trim();
    }

    // Load the physiotherapist's weekly working days first.
    // Once loaded, the first valid working date is selected and
    // booked slots for that date are loaded.
    _loadPhysiotherapistAvailability();
  }

  // ===============================================================
  // LOAD PHYSIOTHERAPIST AVAILABILITY
  // ===============================================================

  Future<void> _loadPhysiotherapistAvailability() async {
    if (widget.physiotherapistId.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _pricingReady = false;
          _pricingError = 'Physiotherapist details are missing, so the assigned price cannot be verified.';
        });
      }
      _loadUnavailableSlots();
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingWorkingDays = true;
      });
    }

    try {
      final document = await FirebaseFirestore.instance
          .collection('physiotherapists')
          .doc(widget.physiotherapistId)
          .get();

      final data = document.data();

      if (data == null) {
        throw StateError('Physiotherapist profile was not found.');
      }

      if (mounted) {
        setState(() {
          _applyPhysiotherapistSnapshot(data);
        });
      }

      final firstValidDate =
          _findNextWorkingDate(_selectedDate);

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedDate = firstValidDate;
        _selectedTime = null;
        _isLoadingWorkingDays = false;
      });

      await _loadUnavailableSlots();
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error loading physiotherapist availability: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      // If availability cannot be loaded, retain the seven-day
      // fallback so the booking screen remains usable.
      setState(() {
        _isLoadingWorkingDays = false;
        _pricingReady = false;
        _pricingError = 'Unable to load this physiotherapist’s saved pricing. Please try again.';
      });

      await _loadUnavailableSlots();
    }
  }

  // ===============================================================
  // NORMALIZE WORKING DAY
  // ===============================================================

  String _normalizeWorkingDay(String value) {
    final normalized = value.trim().toUpperCase();

    if (normalized.startsWith('MON')) return 'MON';
    if (normalized.startsWith('TUE')) return 'TUE';
    if (normalized.startsWith('WED')) return 'WED';
    if (normalized.startsWith('THU')) return 'THU';
    if (normalized.startsWith('FRI')) return 'FRI';
    if (normalized.startsWith('SAT')) return 'SAT';
    if (normalized.startsWith('SUN')) return 'SUN';

    return '';
  }

  // ===============================================================
  // CHECK WORKING DAY
  // ===============================================================

  bool _isWorkingDay(DateTime date) {
    const dayNames = <int, String>{
      DateTime.monday: 'MON',
      DateTime.tuesday: 'TUE',
      DateTime.wednesday: 'WED',
      DateTime.thursday: 'THU',
      DateTime.friday: 'FRI',
      DateTime.saturday: 'SAT',
      DateTime.sunday: 'SUN',
    };

    final dayName = dayNames[date.weekday];

    if (dayName == null) {
      return false;
    }

    return _workingDays.contains(dayName);
  }

  // ===============================================================
  // FIND NEXT WORKING DATE
  // ===============================================================

  DateTime _findNextWorkingDate(DateTime fromDate) {
    final baseDate = DateTime(
      fromDate.year,
      fromDate.month,
      fromDate.day,
    );

    for (int offset = 0; offset < 31; offset++) {
      final candidate =
          baseDate.add(Duration(days: offset));

      if (_isWorkingDay(candidate)) {
        return candidate;
      }
    }

    // Safety fallback. Onboarding validation should always prevent
    // an empty working-days configuration.
    return baseDate;
  }

  // ===============================================================
  // LOAD BOOKED APPOINTMENT SLOTS
  // ===============================================================

  Future<void> _loadUnavailableSlots() async {
    if (widget.physiotherapistId.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _unavailableSlots = <String>[];
          _isLoadingAvailability = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingAvailability = true;
        _availabilityLoadFailed = false;
      });
    }

    try {
      final startOfDay = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );

      final endOfDay = startOfDay.add(
        const Duration(days: 1),
      );

      // We intentionally query by physiotherapist only and filter the
      // selected date locally. This avoids requiring a Firestore
      // composite index for physiotherapistId + appointmentDate.
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where(
            'physiotherapistId',
            isEqualTo: widget.physiotherapistId,
          )
          .get();

      final bookedSlots = <String>{};

      for (final document in snapshot.docs) {
        final data = document.data();

        // Cancelled and rejected appointments should release the
        // time slot again. Pending-payment, pending-acceptance and
        // confirmed bookings continue to block the slot.
        final bookingStatus =
            data['bookingStatus']
                ?.toString()
                .trim()
                .toLowerCase();

        if (bookingStatus == 'cancelled' ||
            bookingStatus == 'rejected') {
          continue;
        }

        final rawDate = data['appointmentDate'];
        final appointmentDate = _parseFirestoreDate(rawDate);

        if (appointmentDate == null) {
          continue;
        }

        final belongsToSelectedDate =
            !appointmentDate.isBefore(startOfDay) &&
            appointmentDate.isBefore(endOfDay);

        if (!belongsToSelectedDate) {
          continue;
        }

        final rawTime = data['appointmentTime'];

        if (rawTime == null) {
          continue;
        }

        final time = rawTime.toString().trim();

        if (time.isNotEmpty) {
          bookedSlots.add(_normalizeAppointmentTime(time));
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _unavailableSlots = bookedSlots.toList();
        _isLoadingAvailability = false;
        _availabilityLoadFailed = false;

        // If the currently selected time became unavailable after a
        // date change or refresh, remove the selection.
        if (_selectedTime != null &&
            bookedSlots.contains(
              _normalizeAppointmentTime(_selectedTime!),
            )) {
          _selectedTime = null;
        }
      });

      debugPrint(
        '📅 Availability loaded: '
        '${bookedSlots.length} booked slot(s) for '
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
      );

      if (bookedSlots.isNotEmpty) {
        debugPrint(
          '⛔ Booked slots: ${bookedSlots.join(', ')}',
        );
      }
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error loading appointment availability: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _unavailableSlots = <String>[];
        _isLoadingAvailability = false;
        _availabilityLoadFailed = true;
      });

      _showMessage(
        'Unable to load appointment availability. Please try again.',
      );
    }
  }

  // ===============================================================
  // FIRESTORE DATE PARSER
  // ===============================================================

  DateTime? _parseFirestoreDate(dynamic value) {
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

  // ===============================================================
  // NORMALIZE APPOINTMENT TIME
  // ===============================================================

  String _normalizeAppointmentTime(String value) {
    return value.trim().toUpperCase();
  }

  String _priceFieldForMode(String mode) {
    switch (mode) {
      case PricingConfig.home:
        return 'homeVisitPrice';
      case PricingConfig.clinic:
        return 'clinicVisitPrice';
      case PricingConfig.online:
        return 'onlineConsultationPrice';
      default:
        return '';
    }
  }

  String _enabledFieldForMode(String mode) {
    switch (mode) {
      case PricingConfig.home:
        return 'homeVisitEnabled';
      case PricingConfig.clinic:
        return 'clinicVisitEnabled';
      case PricingConfig.online:
        return 'onlineConsultationEnabled';
      default:
        return '';
    }
  }

  bool _isModeEnabledInSnapshot(Map<String, dynamic> data, String mode) {
    final value = data[_enabledFieldForMode(mode)];
    var enabled = value is bool
        ? value
        // Backward compatibility for older provider records: home and clinic
        // were the legacy default services; online must be explicitly enabled.
        : mode == PricingConfig.home || mode == PricingConfig.clinic;
    final schedules = data['serviceSchedules'];
    final scheduleKey = mode == PricingConfig.home
        ? 'home'
        : mode == PricingConfig.clinic
            ? 'clinic'
            : 'online';
    if (schedules is Map) {
      final schedule = schedules[scheduleKey];
      if (schedule is Map && schedule['enabled'] is bool) {
        enabled = enabled && schedule['enabled'] == true;
      }
    }
    return enabled;
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  // ===============================================================
  // SELECTED PACKAGE
  // ===============================================================

  _PackageOption get selectedPackage {
    return _packages.firstWhere(
      (package) =>
          package.visits ==
          _selectedPackage,
    );
  }

  // ===============================================================
  // STEP TITLE
  // ===============================================================

  String get _stepTitle {
    switch (_currentStep) {
      case 0:
        return 'Choose your care';

      case 1:
        return 'Choose your recovery plan';

      case 2:
        return 'Pick your appointment';

      case 3:
        return 'Your details';

      case 4:
        return 'Review appointment';

      default:
        return 'Book appointment';
    }
  }

  // ===============================================================
  // STEP SUBTITLE
  // ===============================================================

  String get _stepSubtitle {
    switch (_currentStep) {
      case 0:
        return 'How would you like to receive your session?';

      case 1:
        return 'Choose the number of sessions that suits your recovery plan';

      case 2:
        return 'Choose a convenient date and time';

      case 3:
        return 'Tell us who the appointment is for';

      case 4:
        return 'Everything looks good? Let’s confirm it';

      default:
        return '';
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final package = selectedPackage;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FC),

      body: SafeArea(
        bottom: false,

        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                15,
                18,
                0,
              ),

              child: Column(
                children: [
                  BookingHeader(
                    title:
                        'Book appointment',

                    subtitle:
                        'Your care, your way',

                    onBackTap:
                        _handleBack,

                    onHelpTap:
                        _showHelp,
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  _PremiumStepIndicator(
                    currentStep:
                        _currentStep,

                    totalSteps:
                        _totalSteps,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child:
                  SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),

                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  0,
                  18,
                  30,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    _StepHeading(
                      step:
                          _currentStep + 1,

                      title:
                          _stepTitle,

                      subtitle:
                          _stepSubtitle,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    AnimatedSwitcher(
                      duration:
                          const Duration(
                        milliseconds: 280,
                      ),

                      reverseDuration:
                          const Duration(
                        milliseconds: 220,
                      ),

                      switchInCurve:
                          Curves.easeOutCubic,

                      switchOutCurve:
                          Curves.easeInCubic,

                      transitionBuilder:
                          (
                        child,
                        animation,
                      ) {
                        final offsetAnimation =
                            Tween<Offset>(
                          begin:
                              const Offset(
                            .08,
                            0,
                          ),

                          end:
                              Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent:
                                animation,

                            curve:
                                Curves.easeOutCubic,
                          ),
                        );

                        return FadeTransition(
                          opacity:
                              animation,

                          child:
                              SlideTransition(
                            position:
                                offsetAnimation,

                            child:
                                child,
                          ),
                        );
                      },

                      child:
                          _buildCurrentStep(),
                    ),
                  ],
                ),
              ),
            ),

            _PremiumBottomBar(
              currentStep:
                  _currentStep,

              totalSteps:
                  _totalSteps,

              package:
                  package,

              currencyPrefix: _currencyPrefix,

              onBack:
                  _handleBack,

              onNext:
                  _isCreatingBooking
                      ? () {}
                      : _handleNext,
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // CURRENT STEP
  // ===============================================================

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildCareStep(
          key:
              const ValueKey('care'),
        );

      case 1:
        return _buildPackageStep(
          key:
              const ValueKey('package'),
        );

      case 2:
        return _buildDateTimeStep(
          key:
              const ValueKey('datetime'),
        );

      case 3:
        return _buildPatientStep(
          key:
              const ValueKey('patient'),
        );

      case 4:
        return _buildSummaryStep(
          key:
              const ValueKey('summary'),
        );

      default:
        return _buildCareStep(
          key:
              const ValueKey(
            'care-default',
          ),
        );
    }
  }

  // ===============================================================
  // STEP 1 — CARE
  // ===============================================================

  Widget _buildCareStep({
    required Key key,
  }) {
    return Column(
      key: key,

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        _DoctorMiniCard(
          doctorName:
              widget.doctorName,

          doctorImage:
              widget.doctorImage,

          specialty:
              widget.specialty,

          rating:
              widget.rating,
        ),

        const SizedBox(height: 20),

        if (!_pricingReady && _pricingError != null)
          _PremiumInfoCard(
            icon: Icons.info_outline_rounded,
            title: 'Pricing unavailable',
            description: _pricingError!,
          ),
        _CareTypeSelector(
          careMode: _selectedCareMode,
          homeEnabled: _homeVisitEnabled && (_homeVisitPrice ?? 0) > 0,
          clinicEnabled: _clinicVisitEnabled && (_clinicVisitPrice ?? 0) > 0,
          onlineEnabled: _onlineConsultationEnabled &&
              (_onlineConsultationPrice ?? 0) > 0,
          priceLabel: (mode) =>
              '$_currencyPrefix${_priceForMode(mode).toStringAsFixed(0)} / session',
          onChanged: (value) {
            setState(() {
              _selectedCareMode = value;
              _selectedTime = null;
              _applyWorkingDaysForSelectedMode(null);
              _selectedDate = _findNextWorkingDate(DateTime.now());
            });
            _loadUnavailableSlots();
          },
        ),

        const SizedBox(height: 18),

        _PremiumInfoCard(
          icon: _homeVisit ? Icons.home_rounded :
              (_onlineVisit ? Icons.videocam_rounded : Icons.local_hospital_rounded),
          title: _homeVisit ? 'Care at your doorstep' :
              (_onlineVisit ? 'Consult from anywhere' : 'Visit a trusted clinic'),
          description: _homeVisit
              ? 'A physiotherapist visits your address for hands-on treatment.'
              : _onlineVisit
                  ? 'A remote assessment and guidance session. Hands-on treatment is not included; the joining link must be provided by the platform.'
                  : 'Meet your physiotherapist at the clinic for in-person care.',
        ),
      ],
    );
  }

  // ===============================================================
  // STEP 2 — PACKAGE
  // ===============================================================

  Widget _buildPackageStep({
    required Key key,
  }) {
    return Column(
      key: key,

      children: [
        _PremiumInfoCard(
          icon: Icons.workspace_premium_rounded,
          title:
              '$_tierName • $_currencyPrefix${_sessionPrice.toStringAsFixed(0)} / session',
          description:
              'This is the rate assigned to this physiotherapist during onboarding for ${_careLabel.toLowerCase()}$_pricingLocationContext.',
          compact: true,
        ),

        if ((_followUpPrice ?? 0) > 0) ...[
          const SizedBox(height: 10),
          _PremiumInfoCard(
            icon: Icons.replay_rounded,
            title: 'Follow-up session rate: $_currencyPrefix${(_followUpPrice ?? 0).toStringAsFixed(0)}',
            description: 'This is the follow-up rate saved in the physiotherapist’s onboarding pricing. It is separate from the selected initial-session package.',
            compact: true,
          ),
        ],

        const SizedBox(height: 14),

        Column(
          children:
              _packages.map(
            (item) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 13,
                ),

                child:
                    RecoveryPackageCard(
                  visits:
                      item.visits,

                  title:
                      item.title,

                  description:
                      item.description,

                  price:
                      item.price,

                  savings:
                      item.savings > 0
                          ? item.savings
                          : null,

                  popular:
                      item.popular,

                  bestValue:
                      item.bestValue,

                  selected:
                      _selectedPackage ==
                          item.visits,

                  onTap: () {
                    setState(() {
                      _selectedPackage =
                          item.visits;
                    });
                  },
                ),
              );
            },
          ).toList(),
        ),

        const SizedBox(height: 5),

        _PremiumSavingsCard(
          package: selectedPackage,
          currencyPrefix: _currencyPrefix,
        ),
      ],
    );
  }

  // ===============================================================
  // STEP 3 — DATE & TIME
  // ===============================================================

  Widget _buildDateTimeStep({
    required Key key,
  }) {
    return Column(
      key: key,

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        AppointmentDateSelector(
          selectedDate:
              _selectedDate,

          workingDays:
              _workingDays,

          onDateSelected: (date) {
            if (!_isWorkingDay(date)) {
              return;
            }

            setState(() {
              _selectedDate = date;
              _selectedTime = null;
              _unavailableSlots = <String>[];
            });

            // Every date has its own availability.
            _loadUnavailableSlots();
          },
        ),

        const SizedBox(height: 22),

        AppointmentTimeSelector(
          selectedTime:
              _selectedTime,

          unavailableSlots:
              _unavailableSlots,

          onTimeSelected: (time) {
            setState(() {
              _selectedTime = time;
            });
          },
        ),

        if (_isLoadingWorkingDays || _isLoadingAvailability) ...[
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: Color(0xFF5146D9),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Checking booked appointments...',
                style: TextStyle(
                  fontSize: 9.5,
                  color: Color(0xFF737C94),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 18),

        if (_selectedTime != null)
          _SelectedAppointmentCard(
            date:
                _formatDate(
              _selectedDate,
            ),

            time:
                _selectedTime!,
          ),
      ],
    );
  }

  // ===============================================================
  // STEP 4 — PATIENT
  // ===============================================================

  Widget _buildPatientStep({
    required Key key,
  }) {
    return Column(
      key: key,

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        PatientDetailsCard(
          nameController:
              _nameController,

          phoneController:
              _phoneController,

          addressController:
              _addressController,

          isHomeVisit:
              _homeVisit,
        ),

        const SizedBox(height: 18),

        _PremiumInfoCard(
          icon:
              Icons.lock_outline_rounded,

          title:
              'Your information is secure',

          description:
              'Your personal details are only used to manage your appointment.',

          compact: true,
        ),
      ],
    );
  }

  // ===============================================================
  // STEP 5 — SUMMARY
  // ===============================================================

  Widget _buildSummaryStep({
    required Key key,
  }) {
    return Column(
      key: key,

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        BookingSummaryCard(
          doctorName:
              widget.doctorName,

          specialty:
              widget.specialty,

          doctorImage:
              widget.doctorImage,

          visitType:
              _careLabel,

          date:
              _formatDate(
            _selectedDate,
          ),

          time:
              _selectedTime ??
                  'Not selected',

          packageTitle:
              selectedPackage.title,

          visits:
              selectedPackage.visits,

          price:
              selectedPackage.price,

          originalPrice:
              selectedPackage.originalPrice,

          savings:
              selectedPackage.savings,

          discountPercent:
              selectedPackage.discountPercent,

          sessionPrice:
              selectedPackage.sessionPrice,
        ),

        const SizedBox(height: 18),

        _FinalConfirmationCard(
          package:
              selectedPackage,

          currencyPrefix: _currencyPrefix,

          careMode:
              _selectedCareMode,

          date:
              _formatDate(
            _selectedDate,
          ),

          time:
              _selectedTime ??
                  'Not selected',
        ),

        if (_onlineVisit) ...[
          const SizedBox(height: 12),
          const _PremiumInfoCard(
            icon: Icons.videocam_rounded,
            title: 'Online consultation details',
            description: 'Your consultation is remote. No home address is required. A secure video joining link is not automatically generated by this booking screen; the platform must provide it before the appointment.',
          ),
        ],

        const SizedBox(height: 12),

        _PremiumInfoCard(
          icon: Icons.payments_rounded,
          title:
              '$_tierName • $_currencyPrefix${selectedPackage.price}',
          description:
              '${selectedPackage.visits} sessions • '
              '${selectedPackage.discountPercent.toStringAsFixed(0)}% package discount • '
              'You save $_currencyPrefix${selectedPackage.savings}.',
          compact: true,
        ),
      ],
    );
  }

  // ===============================================================
  // NEXT
  // ===============================================================

  void _handleNext() {
    if (_isCreatingBooking) {
      return;
    }

    if (!_validateCurrentStep()) {
      return;
    }

    if (_currentStep <
        _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });

      return;
    }

    _continueToPayment();
  }

  // ===============================================================
  // BACK
  // ===============================================================

  void _handleBack() {
    if (_isCreatingBooking) {
      return;
    }

    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });

      return;
    }

    Navigator.pop(context);
  }

  // ===============================================================
  // VALIDATION
  // ===============================================================

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (!_pricingReady || !_selectedCareModeEnabled) {
          _showMessage(_pricingError ?? 'This care option is not available for this physiotherapist.');
          return false;
        }
        return true;

      case 1:
        if (!_selectedCareModeEnabled || _sessionPrice <= 0) {
          _showMessage('The selected physiotherapist rate is unavailable. Please choose another care option.');
          return false;
        }
        return true;

      case 2:
        if (_isLoadingAvailability || _isLoadingWorkingDays || _availabilityLoadFailed) {
          _showMessage('Availability is not verified yet. Please retry before booking.');
          return false;
        }
        if (!_isWorkingDay(_selectedDate)) {
          _showMessage(
            'Please select a working day for this physiotherapist.',
          );

          return false;
        }

        if (_selectedTime == null ||
            _selectedTime!.trim().isEmpty) {
          _showMessage(
            'Please select an appointment time.',
          );

          return false;
        }

        return true;

      case 3:
        final name =
            _nameController.text.trim();

        final phone =
            _phoneController.text.trim();

        final address =
            _addressController.text.trim();

        if (name.isEmpty) {
          _showMessage(
            'Please enter the patient name.',
          );

          return false;
        }

        if (phone.isEmpty ||
            phone.length < 10) {
          _showMessage(
            'Please enter a valid phone number.',
          );

          return false;
        }

        if (_homeVisit &&
            address.isEmpty) {
          _showMessage(
            'Please enter your home address.',
          );

          return false;
        }

        return true;

      case 4:
        return true;

      default:
        return true;
    }
  }

  // ===============================================================
  // CREATE BOOKING
  // ===============================================================

  Future<void> _continueToPayment() async {
    if (_isCreatingBooking) {
      return;
    }

    // -------------------------------------------------------------
    // VALIDATE
    // -------------------------------------------------------------

    if (!_validateAllBookingData()) {
      return;
    }

    // -------------------------------------------------------------
    // AUTH USER
    // -------------------------------------------------------------

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please login to continue.',
      );

      return;
    }

    // -------------------------------------------------------------
    // PACKAGE
    // -------------------------------------------------------------

    final package =
        selectedPackage;

    // =============================================================
    // FINAL UNIVERSAL PRICING SNAPSHOT
    // =============================================================
    //
    // Recalculate here instead of trusting a value passed from the
    // previous screen. This keeps the Firestore booking price tied
    // to the central PricingConfig.
    //
    // =============================================================

    if (!_pricingReady || !_selectedCareModeEnabled || _sessionPrice <= 0) {
      _showMessage(
        _pricingError ?? 'This care option is not currently available for this physiotherapist.',
      );
      return;
    }

    // Re-read the provider's saved onboarding rate card immediately before
    // creating the booking. This prevents a stale screen price from being
    // written if the provider's assigned rate was updated while the patient
    // was booking.
    try {
      final latestProvider = await FirebaseFirestore.instance
          .collection('physiotherapists')
          .doc(widget.physiotherapistId)
          .get();
      final latestData = latestProvider.data();
      if (latestData == null ||
          !_isModeEnabledInSnapshot(latestData, _selectedCareMode)) {
        _showMessage('This care option is no longer available. Please choose another option.');
        return;
      }
      final latestRate = _readStoredPrice(latestData[_priceFieldForMode(_selectedCareMode)]);
      if (latestRate == null || latestRate <= 0) {
        _showMessage('The physiotherapist’s saved price is unavailable. Please contact support.');
        return;
      }
      final latestDiscountEnabled = latestData['discountAvailable'] == true;
      final latestDiscountPercent = latestDiscountEnabled
          ? (_readStoredPrice(latestData['discountPercentage']) ?? 0).clamp(0, 100).toDouble()
          : 0.0;
      final latestPackageSubtotal = latestRate * package.visits;
      final latestPackageSavings = latestPackageSubtotal * latestDiscountPercent / 100;
      final latestPackageTotal = latestPackageSubtotal - latestPackageSavings;
      final pricingChanged =
          (latestRate - _sessionPrice).abs() > 0.01 ||
          (latestPackageTotal - package.price).abs() > 0.01 ||
          ((_readStoredPrice(latestData['travelCharges']) ?? 0) - _travelCharges).abs() > 0.01 ||
          (latestData['travelChargesEnabled'] == true) != _travelChargesEnabled ||
          (latestData['pricingConfigVersion'] ?? '').toString() != _pricingConfigVersion ||
          (latestData['currency'] ?? 'INR').toString() != _currency ||
          (latestData['pricingTierLabel'] ?? '').toString() != _pricingTierLabel;
      if (pricingChanged) {
        if (mounted) {
          setState(() {
            _applyPhysiotherapistSnapshot(latestData);
          });
        }
        _showMessage('The physiotherapist’s assigned price has changed. Please review the updated price before confirming.');
        return;
      }
    } catch (error) {
      _showMessage('Unable to verify the latest physiotherapist price. Please try again.');
      return;
    }

    final basePrice = _sessionPrice;
    final totalSessions = package.visits;
    final subtotal = basePrice * totalSessions;
    final discountPercent = _discountAvailable
        ? _discountPercentage.clamp(0, 100).toDouble()
        : 0.0;
    final discountAmount = subtotal * discountPercent / 100;
    final packageFinalPrice = subtotal - discountAmount;

    // -------------------------------------------------------------
    // SERVICE TYPE
    // -------------------------------------------------------------

    final serviceType = _homeVisit
        ? 'homeVisit'
        : (_onlineVisit ? 'onlineConsultation' : 'clinicVisit');

    // -------------------------------------------------------------
    // BOOKING TYPE
    // -------------------------------------------------------------

    final bookingType =
        totalSessions > 1
            ? 'package'
            : 'singleSession';

    // -------------------------------------------------------------
    // PACKAGE EXPIRY
    // -------------------------------------------------------------

    DateTime? packageExpiryDate;

    if (totalSessions > 1) {
      packageExpiryDate =
          _selectedDate.add(
        const Duration(days: 90),
      );
    }

    // -------------------------------------------------------------
    // TIME
    // -------------------------------------------------------------

    final appointmentTime =
        _selectedTime!.trim();

    final appointmentTimeMinutes =
        _parseTimeToMinutes(
      appointmentTime,
    );

    // -------------------------------------------------------------
    // TOTAL
    // -------------------------------------------------------------

    final travelCharge = _homeVisit && _travelChargesEnabled
        ? _travelCharges
        : 0.0;
    final platformFee = 0.0;
    final taxAmount = 0.0;

    final totalAmount =
        packageFinalPrice +
            travelCharge +
            platformFee +
            taxAmount;

    // -------------------------------------------------------------
    // FINAL AVAILABILITY RECHECK
    // -------------------------------------------------------------
    //
    // The slot may have been booked by another patient while this
    // screen was open. Re-check Firestore immediately before creating
    // the booking so we do not knowingly create an already-booked slot.
    // -------------------------------------------------------------

    final latestSlotAvailable =
        await _isSelectedSlotStillAvailable();

    if (!latestSlotAvailable) {
      _showMessage(
        'This appointment slot is no longer available. Please choose another time.',
      );

      await _loadUnavailableSlots();
      return;
    }

    // -------------------------------------------------------------
    // CREATE BOOKING
    // -------------------------------------------------------------

    final now =
        DateTime.now();

    final booking =
        BookingModel(
      // Identifiers
      id: '',

      userId:
          user.uid,

      physiotherapistId:
          widget.physiotherapistId,

      // Physiotherapist snapshot
      physiotherapistName:
          widget.doctorName,

      physiotherapistPhotoUrl:
          widget.doctorImage
                  .trim()
                  .isEmpty
              ? null
              : widget.doctorImage,

      physiotherapistPhone:
          widget.physiotherapistPhone,

      // Patient snapshot
      patientName:
          _nameController.text.trim(),

      patientPhone:
          _phoneController.text.trim(),

      patientEmail:
          user.email,

      // Booking type
      bookingType:
          bookingType,

      serviceType:
          serviceType,

      // Package
      packageId:
          package.id,

      packageName:
          package.title,

      totalSessions:
          totalSessions,

      completedSessions:
          0,

      remainingSessions:
          totalSessions,

      packageExpiryDate:
          packageExpiryDate,

      // Appointment
      appointmentDate:
          _selectedDate,

      appointmentTime:
          appointmentTime,

      appointmentTimeMinutes:
          appointmentTimeMinutes,

      // Address
      address:
          _homeVisit
              ? _addressController.text.trim()
              : '',

      // Distance
      distanceKm:
          null,

      // Pricing
      baseSessionPrice:
          basePrice,

      subtotal:
          subtotal,

      discountAmount:
          discountAmount,

      discountPercent:
          discountPercent,

      travelCharge:
          travelCharge,

      platformFee:
          platformFee,

      taxAmount:
          taxAmount,

      totalAmount:
          totalAmount,

      // Payment
      paymentStatus:
          'pending',

      paymentMethod:
          'online',

      paidAmount:
          0,

      // Booking status
      bookingStatus:
          'pendingPayment',

      // Notes
      patientNotes:
          null,

      // Dates
      createdAt:
          now,

      updatedAt:
          now,
    );

    // -------------------------------------------------------------
    // CREATE FIRESTORE BOOKING
    // -------------------------------------------------------------

    setState(() {
      _isCreatingBooking = true;
    });

    try {
      final createdBooking =
          await _bookingService
              .createBooking(
        booking,
      );

      if (!mounted) {
        return;
      }

      debugPrint(
        '=========================================',
      );

      debugPrint(
        '✅ BOOKING CREATED SUCCESSFULLY',
      );

      debugPrint(
        'Booking ID: ${createdBooking.id}',
      );

      debugPrint(
        'Physiotherapist: '
        '${createdBooking.physiotherapistName}',
      );

      debugPrint(
        'Amount: $_currencyPrefix${createdBooking.totalAmount.toStringAsFixed(0)}',
      );

      debugPrint(
        '=========================================',
      );

      // -----------------------------------------------------------
      // PAYMENT SCREEN NEXT
      // -----------------------------------------------------------
      //
      // Booking is successfully created.
      //
      // Next we will navigate:
      //
      // PaymentScreen(
      //   booking: createdBooking,
      // )
      //
      // -----------------------------------------------------------

      _showBookingCreatedDialog(
        createdBooking,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error creating booking: $error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to create your booking. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingBooking = false;
        });
      }
    }
  }

  // ===============================================================
  // FINAL SLOT AVAILABILITY CHECK
  // ===============================================================

  Future<bool> _isSelectedSlotStillAvailable() async {
    if (_selectedTime == null ||
        _selectedTime!.trim().isEmpty) {
      return false;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where(
            'physiotherapistId',
            isEqualTo: widget.physiotherapistId,
          )
          .get();

      final startOfDay = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );

      final endOfDay =
          startOfDay.add(const Duration(days: 1));

      final selectedTime =
          _normalizeAppointmentTime(_selectedTime!);

      for (final document in snapshot.docs) {
        final data = document.data();

        final bookingStatus =
            data['bookingStatus']
                ?.toString()
                .trim()
                .toLowerCase();

        if (bookingStatus == 'cancelled' ||
            bookingStatus == 'rejected') {
          continue;
        }

        final appointmentDate =
            _parseFirestoreDate(
          data['appointmentDate'],
        );

        if (appointmentDate == null) {
          continue;
        }

        final belongsToSelectedDate =
            !appointmentDate.isBefore(startOfDay) &&
            appointmentDate.isBefore(endOfDay);

        if (!belongsToSelectedDate) {
          continue;
        }

        final rawTime = data['appointmentTime'];

        if (rawTime == null) {
          continue;
        }

        final existingTime =
            _normalizeAppointmentTime(
          rawTime.toString(),
        );

        if (existingTime == selectedTime) {
          return false;
        }
      }

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Final slot availability check failed: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      // Fail closed. If we cannot verify availability, do not create
      // a booking that could collide with another appointment.
      return false;
    }
  }

  // ===============================================================
  // VALIDATE ALL DATA
  // ===============================================================

  bool _validateAllBookingData() {
    final name =
        _nameController.text.trim();

    final phone =
        _phoneController.text.trim();

    final address =
        _addressController.text.trim();

    if (widget.physiotherapistId
        .trim()
        .isEmpty) {
      _showMessage(
        'Physiotherapist information is missing.',
      );

      return false;
    }

    if (_isLoadingAvailability || _isLoadingWorkingDays || _availabilityLoadFailed) {
      _showMessage('Availability is not verified. Please retry.');
      return false;
    }

    if (!_isWorkingDay(_selectedDate)) {
      _showMessage(
        'Please select a working day for this physiotherapist.',
      );

      return false;
    }

    if (_selectedTime == null ||
        _selectedTime!.trim().isEmpty) {
      _showMessage(
        'Please select an appointment time.',
      );

      return false;
    }

    if (_unavailableSlots.contains(
      _normalizeAppointmentTime(_selectedTime!),
    )) {
      _showMessage(
        'That appointment slot has just been booked. Please choose another time.',
      );

      return false;
    }

    if (name.isEmpty) {
      _showMessage(
        'Please enter the patient name.',
      );

      return false;
    }

    if (phone.length < 10) {
      _showMessage(
        'Please enter a valid phone number.',
      );

      return false;
    }

    if (_homeVisit &&
        address.isEmpty) {
      _showMessage(
        'Please enter your home address.',
      );

      return false;
    }

    return true;
  }

  // ===============================================================
  // PARSE TIME
  // ===============================================================

  int? _parseTimeToMinutes(
    String time,
  ) {
    try {
      final value =
          time.trim().toUpperCase();

      final parts =
          value.split(' ');

      if (parts.length != 2) {
        return null;
      }

      final timePart =
          parts[0];

      final period =
          parts[1];

      final timeParts =
          timePart.split(':');

      if (timeParts.length != 2) {
        return null;
      }

      var hour =
          int.parse(timeParts[0]);

      final minute =
          int.parse(timeParts[1]);

      if (period == 'PM' &&
          hour != 12) {
        hour += 12;
      }

      if (period == 'AM' &&
          hour == 12) {
        hour = 0;
      }

      return
          (hour * 60) +
              minute;
    } catch (_) {
      return null;
    }
  }

  // ===============================================================
  // BOOKING CREATED DIALOG
  // ===============================================================

  Future<void> _showBookingCreatedDialog(
    BookingModel booking,
  ) async {
    await showDialog<void>(
      context: context,

      barrierDismissible: false,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              24,
            ),
          ),

          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color:
                    Color(0xFF22A06B),
              ),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Booking created!',
                ),
              ),
            ],
          ),

          content: Text(
            'Your appointment request has been created. '
            'Payment status: Pending.\n\n'
            'Booking ID: ${booking.id}\n'
            'Booking total: $_currencyPrefix${booking.totalAmount.toStringAsFixed(0)}\n\n'
            'You can view the booking in My Bookings.'
            '${booking.serviceType == 'onlineConsultation' ? '\n\nFor online consultation, the platform must provide a video link before your session.' : ''}',
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5146D9),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text('View my bookings'),
            ),
          ],
        );
      },
    );
  }

  // ===============================================================
  // HELP
  // ===============================================================

  void _showHelp() {
    _showMessage(
      'Need help? Our support team is here for you.',
    );
  }

  // ===============================================================
  // MESSAGE
  // ===============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),

          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // ===============================================================
  // DATE FORMAT
  // ===============================================================

  String _formatDate(
    DateTime date,
  ) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }
}
// ==================================================================
// PACKAGE MODEL
// ==================================================================

class _PackageOption {
  final String id;
  final int visits;
  final String title;
  final String description;

  // Final package price after the configured discount.
  final int price;

  // Savings compared with individual sessions.
  final int savings;

  // Original price before package discount.
  final int originalPrice;

  // Session price saved on the selected physiotherapist profile.
  final double sessionPrice;

  // Discount saved on the selected physiotherapist profile.
  final double discountPercent;

  final bool popular;
  final bool bestValue;

  const _PackageOption({
    required this.id,
    required this.visits,
    required this.title,
    required this.description,
    required this.price,
    required this.savings,
    required this.originalPrice,
    required this.sessionPrice,
    required this.discountPercent,
    this.popular = false,
    this.bestValue = false,
  });
}

// ==================================================================
// PREMIUM STEP INDICATOR
// ==================================================================

class _PremiumStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _PremiumStepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  static const _labels = ['Care', 'Plan', 'Time', 'Details', 'Review'];

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / totalSteps;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE6EAF2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D2A54).withOpacity(.035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.route_rounded, color: Color(0xFF5146D9), size: 16),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'YOUR BOOKING JOURNEY',
                  style: const TextStyle(
                    color: Color(0xFF737C94),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                '${currentStep + 1} / $totalSteps',
                style: const TextStyle(
                  color: Color(0xFF5146D9),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 5,
                backgroundColor: const Color(0xFFEEF0F6),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF5A4DE0)),
              ),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: List.generate(totalSteps, (index) {
              final complete = index < currentStep;
              final active = index == currentStep;
              final label = index < _labels.length ? _labels[index] : 'Step';
              return Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: active ? 24 : 19,
                      height: active ? 24 : 19,
                      decoration: BoxDecoration(
                        color: complete || active
                            ? const Color(0xFF5146D9)
                            : const Color(0xFFF0F2F7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: complete || active
                              ? const Color(0xFF5146D9)
                              : const Color(0xFFE3E7EF),
                        ),
                      ),
                      child: Icon(
                        complete ? Icons.check_rounded : Icons.circle,
                        size: complete ? 13 : 5,
                        color: complete || active
                            ? Colors.white
                            : const Color(0xFFB5BBC8),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          color: active
                              ? const Color(0xFF5146D9)
                              : complete
                                  ? const Color(0xFF3F4965)
                                  : const Color(0xFFA0A7B7),
                          fontSize: 8,
                          fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// STEP HEADING
// ==================================================================

class _StepHeading extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;

  const _StepHeading({
    required this.step,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EFFF),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            'STEP ${step.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Color(0xFF5146D9),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 25,
            height: 1.08,
            color: Color(0xFF111A3D),
            fontWeight: FontWeight.w900,
            letterSpacing: -.8,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11.5,
            height: 1.45,
            color: Color(0xFF737C94),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// DOCTOR MINI CARD
// ==================================================================

class _DoctorMiniCard
    extends StatelessWidget {
  final String doctorName;
  final String doctorImage;
  final String specialty;
  final double rating;

  const _DoctorMiniCard({
    required this.doctorName,
    required this.doctorImage,
    required this.specialty,
    required this.rating,
  });

  ImageProvider<Object>? _doctorImageProvider() {
    final value = doctorImage.trim();
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      return NetworkImage(value);
    }
    return AssetImage(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color:
              const Color(0xFFE3E6EF),
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF26345C)
                    .withOpacity(.055),
            blurRadius: 20,
            offset:
                const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xFFEDEBFF),
                  Color(0xFFEAF9F6),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            clipBehavior:
                Clip.antiAlias,
            child: _doctorImageProvider() == null
                ? const Icon(
                    Icons.person_rounded,
                    size: 34,
                    color: Color(0xFF5146D9),
                  )
                : Image(
                    image: _doctorImageProvider()!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person_rounded,
                        size: 34,
                        color: Color(0xFF5146D9),
                      );
                    },
                  ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        doctorName,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 15,
                          color:
                              Color(
                            0xFF111A3D,
                          ),
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    const Icon(
                      Icons
                          .verified_rounded,
                      size: 16,
                      color:
                          Color(0xFF079F87),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  specialty,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color:
                        Color(0xFF737C94),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 15,
                      color:
                          Color(0xFFFFB21A),
                    ),

                    const SizedBox(
                      width: 4,
                    ),

                    Text(
                      rating
                          .toStringAsFixed(
                        1,
                      ),
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color:
                            Color(
                          0xFF151D3D,
                        ),
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      width: 7,
                    ),

                    const Text(
                      'Verified physiotherapist',
                      style:
                          TextStyle(
                        fontSize: 9.5,
                        color:
                            Color(
                          0xFF7A839A,
                        ),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// CARE TYPE SELECTOR
// ==================================================================

class _CareTypeSelector extends StatelessWidget {
  final String careMode;
  final bool homeEnabled;
  final bool clinicEnabled;
  final bool onlineEnabled;
  final String Function(String mode) priceLabel;
  final ValueChanged<String> onChanged;

  const _CareTypeSelector({
    required this.careMode,
    required this.homeEnabled,
    required this.clinicEnabled,
    required this.onlineEnabled,
    required this.priceLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _CareTypeCard(
        icon: Icons.home_rounded,
        title: 'Home Visit',
        subtitle: homeEnabled ? priceLabel(PricingConfig.home) : 'Not offered by this physiotherapist',
        selected: careMode == PricingConfig.home,
        enabled: homeEnabled,
        onTap: () => onChanged(PricingConfig.home),
      ),
      const SizedBox(height: 12),
      _CareTypeCard(
        icon: Icons.local_hospital_rounded,
        title: 'Clinic Visit',
        subtitle: clinicEnabled ? priceLabel(PricingConfig.clinic) : 'Not offered by this physiotherapist',
        selected: careMode == PricingConfig.clinic,
        enabled: clinicEnabled,
        onTap: () => onChanged(PricingConfig.clinic),
      ),
      const SizedBox(height: 12),
      _CareTypeCard(
        icon: Icons.videocam_rounded,
        title: 'Online Consultation',
        subtitle: onlineEnabled ? priceLabel(PricingConfig.online) : 'Not offered by this physiotherapist',
        selected: careMode == PricingConfig.online,
        enabled: onlineEnabled,
        onTap: () => onChanged(PricingConfig.online),
      ),
    ]);
  }
}

// ==================================================================
// CARE TYPE CARD
// ==================================================================

class _CareTypeCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _CareTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior:
          HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : .48,
        child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 220,
        ),
        padding:
            const EdgeInsets.all(16),
        decoration:
            BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin:
                      Alignment.topLeft,
                  end:
                      Alignment.bottomRight,
                  colors: [
                    Color(0xFFF2EFFF),
                    Color(0xFFEAF9F6),
                  ],
                )
              : null,
          color: selected
              ? null
              : Colors.white,
          borderRadius:
              BorderRadius.circular(
            21,
          ),
          border: Border.all(
            color: selected
                ? const Color(
                    0xFF6556E6,
                  )
                : const Color(
                    0xFFE3E6EF,
                  ),
            width:
                selected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  const Color(
                0xFF26345C,
              ).withOpacity(
                selected
                    ? .075
                    : .035,
              ),
              blurRadius:
                  selected ? 18 : 13,
              offset:
                  const Offset(
                0,
                6,
              ),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withOpacity(
                  .82,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  15,
                ),
              ),
              child: Icon(
                icon,
                size: 24,
                color: selected
                    ? const Color(
                        0xFF5146D9,
                      )
                    : const Color(
                        0xFF69728D,
                      ),
              ),
            ),

            const SizedBox(
              width: 13,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 14,
                      color:
                          Color(
                        0xFF151D3D,
                      ),
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      fontSize: 10.5,
                      color:
                          Color(
                        0xFF737C94,
                      ),
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 200,
              ),
              width: 26,
              height: 26,
              decoration:
                  BoxDecoration(
                color: selected
                    ? const Color(
                        0xFF079F87,
                      )
                    : Colors.transparent,
                shape:
                    BoxShape.circle,
                border: selected
                    ? null
                    : Border.all(
                        color:
                            const Color(
                          0xFFD9DDE7,
                        ),
                      ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 17,
                      color:
                          Colors.white,
                    )
                  : null,
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ==================================================================
// PREMIUM INFO CARD
// ==================================================================

class _PremiumInfoCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool compact;

  const _PremiumInfoCard({
    required this.icon,
    required this.title,
    required this.description,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.all(
        compact ? 13 : 15,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFFF2F1FF),
            Color(0xFFECFAF7),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
              const Color(0xFFE2E5EF),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: compact
                ? 36
                : 42,
            height: compact
                ? 36
                : 42,
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withOpacity(
                .78,
              ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              icon,
              size:
                  compact ? 18 : 21,
              color:
                  const Color(
                0xFF5146D9,
              ),
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        Color(
                      0xFF151D3D,
                    ),
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  description,
                  style:
                      const TextStyle(
                    fontSize: 10.5,
                    height: 1.4,
                    color:
                        Color(
                      0xFF737C94,
                    ),
                    fontWeight:
                        FontWeight.w600,
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

// ==================================================================
// SAVINGS CARD
// ==================================================================

class _PremiumSavingsCard
    extends StatelessWidget {
  final _PackageOption package;
  final String currencyPrefix;

  const _PremiumSavingsCard({
    required this.package,
    required this.currencyPrefix,
  });

  @override
  Widget build(BuildContext context) {
    if (package.savings <= 0) {
      return const _PremiumInfoCard(
        icon:
            Icons.verified_rounded,
        title:
            'Transparent session pricing',
        description:
            'Each session uses this physiotherapist’s assigned onboarding rate. No package discount is currently applied.',
        compact: true,
      );
    }

    return _PremiumInfoCard(
      icon:
          Icons.savings_rounded,
      title:
          'You save $currencyPrefix${package.savings}',
      description:
          'Compared with booking ${package.visits} individual sessions.',
      compact: true,
    );
  }
}

// ==================================================================
// SELECTED APPOINTMENT
// ==================================================================

class _SelectedAppointmentCard
    extends StatelessWidget {
  final String date;
  final String time;

  const _SelectedAppointmentCard({
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          17,
        ),
        border: Border.all(
          color:
              const Color(0xFFE2E5EF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEAF8F5,
              ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              size: 21,
              color:
                  Color(0xFF079F87),
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                const Text(
                  'Selected appointment',
                  style:
                      TextStyle(
                    fontSize: 9,
                    color:
                        Color(
                      0xFF858DA3,
                    ),
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  '$date  •  $time',
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        Color(
                      0xFF151D3D,
                    ),
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle_rounded,
            size: 21,
            color:
                Color(0xFF079F87),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// FINAL CONFIRMATION
// ==================================================================

class _FinalConfirmationCard
    extends StatelessWidget {
  final _PackageOption package;
  final String currencyPrefix;
  final String careMode;
  final String date;
  final String time;

  const _FinalConfirmationCard({
    required this.package,
    required this.currencyPrefix,
    required this.careMode,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFFF1F0FF),
            Color(0xFFEAF9F6),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          19,
        ),
        border: Border.all(
          color:
              const Color(0xFFE0E4EF),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.verified_rounded,
                size: 19,
                color:
                    Color(0xFF079F87),
              ),
              SizedBox(width: 7),
              Text(
                'Ready to confirm',
                style:
                    TextStyle(
                  fontSize: 13,
                  color:
                      Color(
                    0xFF151D3D,
                  ),
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _ReviewLine(
            icon:
                careMode == PricingConfig.home ? Icons.home_rounded : (careMode == PricingConfig.online ? Icons.videocam_rounded : Icons.local_hospital_rounded),
            title:
                careMode == PricingConfig.home ? 'Home Visit' : (careMode == PricingConfig.online ? 'Online Consultation' : 'Clinic Visit'),
          ),

          const SizedBox(height: 8),

          _ReviewLine(
            icon:
                Icons.event_rounded,
            title: date,
          ),

          const SizedBox(height: 8),

          _ReviewLine(
            icon:
                Icons.access_time_rounded,
            title: time,
          ),

          const SizedBox(height: 8),

          _ReviewLine(
            icon:
                Icons
                    .medical_services_rounded,
            title:
                '${package.visits} visit${package.visits > 1 ? 's' : ''} • $currencyPrefix${package.price}',
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// REVIEW LINE
// ==================================================================

class _ReviewLine
    extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ReviewLine({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color:
              const Color(
            0xFF5146D9,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style:
              const TextStyle(
            fontSize: 11,
            color:
                Color(0xFF4D5670),
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// BOTTOM BAR
// ==================================================================

class _PremiumBottomBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final _PackageOption package;
  final String currencyPrefix;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _PremiumBottomBar({
    required this.currentStep,
    required this.totalSteps,
    required this.package,
    required this.currencyPrefix,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep == totalSteps - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE7EAF2))),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D2A54).withOpacity(.09),
            blurRadius: 24,
            offset: const Offset(0, -7),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (currentStep > 0) ...[
              Material(
                color: const Color(0xFFF4F5FA),
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(15),
                  child: const SizedBox(
                    width: 48,
                    height: 50,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF34405E),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentStep == 0 ? 'SELECTED PLAN' : 'PLAN TOTAL',
                    style: const TextStyle(
                      color: Color(0xFF8A92A7),
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .9,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$currencyPrefix${package.price}',
                    style: const TextStyle(
                      color: Color(0xFF111A3D),
                      fontSize: 19,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.6,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${package.visits} ${package.visits == 1 ? 'session' : 'sessions'}'
                    '${package.savings > 0 ? ' • Save $currencyPrefix${package.savings}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF159B7A),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onNext,
                  borderRadius: BorderRadius.circular(16),
                  child: Ink(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF7165EC), Color(0xFF4F45D2)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5146D9).withOpacity(.22),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            isLast ? 'Create booking' : 'Continue',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Icon(
                          isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                          size: 17,
                          color: Colors.white,
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
    );
  }
}
