import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  // PRICING
  // ==============================================================

  final double baseSessionPrice;

  // ==============================================================
  // OPTIONAL PRESELECTED VALUES
  // ==============================================================

  final String initialCareMode;
  final String? initialTime;

  const BookingDetailsScreen({
    super.key,

    required this.physiotherapistId,

    required this.doctorName,

    this.doctorImage = '',

    required this.specialty,

    this.rating = 0,

    this.physiotherapistPhone,

    required this.baseSessionPrice,

    this.initialCareMode = 'home',

    this.initialTime,
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

  bool _homeVisit = true;

  int _selectedPackage = 1;

  late DateTime _selectedDate;

  String? _selectedTime;

  // ===============================================================
  // CURRENT STEP
  // ===============================================================

  int _currentStep = 0;

  static const int _totalSteps = 5;

  // ===============================================================
  // PACKAGE DATA
  // ===============================================================
  //
  // Dynamic pricing based on the physiotherapist's base price.
  //
  // 1 Session → Full price
  // 3 Sessions → 10% discount
  // 5 Sessions → 15% discount
  //
  // ===============================================================

  List<_PackageOption> get _packages {
    final basePrice =
        widget.baseSessionPrice > 0
            ? widget.baseSessionPrice
            : 599;

    final singlePrice =
        basePrice;

    final threeOriginal =
        basePrice * 3;

    final threePrice =
        threeOriginal * 0.90;

    final fiveOriginal =
        basePrice * 5;

    final fivePrice =
        fiveOriginal * 0.85;

    return [
      _PackageOption(
        visits: 1,
        title: 'Single Session',
        description:
            'One-time physiotherapy session',
        price: singlePrice.round(),
        savings: 0,
      ),

      _PackageOption(
        visits: 3,
        title: '3 Visit Recovery Pack',
        description:
            'Build consistency in your recovery',
        price: threePrice.round(),
        savings:
            (threeOriginal - threePrice)
                .round(),
        popular: true,
      ),

      _PackageOption(
        visits: 5,
        title: '5 Visit Recovery Pack',
        description:
            'For ongoing rehabilitation',
        price: fivePrice.round(),
        savings:
            (fiveOriginal - fivePrice)
                .round(),
        bestValue: true,
      ),
    ];
  }

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    // -------------------------------------------------------------
    // INITIAL CARE MODE
    // -------------------------------------------------------------

    final mode =
        widget.initialCareMode
            .trim()
            .toLowerCase();

    _homeVisit =
        mode != 'clinic' &&
        mode != 'clinicvisit';

    // -------------------------------------------------------------
    // INITIAL TIME
    // -------------------------------------------------------------

    if (widget.initialTime != null &&
        widget.initialTime!.trim().isNotEmpty) {
      _selectedTime =
          widget.initialTime!.trim();
    }
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
        return 'Save more with multiple sessions';

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

        _CareTypeSelector(
          homeVisit:
              _homeVisit,

          onChanged: (value) {
            setState(() {
              _homeVisit = value;
            });
          },
        ),

        const SizedBox(height: 18),

        _PremiumInfoCard(
          icon: _homeVisit
              ? Icons.home_rounded
              : Icons.local_hospital_rounded,

          title: _homeVisit
              ? 'Care at your doorstep'
              : 'Visit a trusted clinic',

          description: _homeVisit
              ? 'A verified physiotherapist will visit you at your preferred address.'
              : 'Choose a convenient clinic and meet your physiotherapist there.',
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
          package:
              selectedPackage,
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

          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        ),

        const SizedBox(height: 22),

        AppointmentTimeSelector(
          selectedTime:
              _selectedTime,

          unavailableSlots:
              const [
            '01:00 PM',
            '04:30 PM',
          ],

          onTimeSelected: (time) {
            setState(() {
              _selectedTime = time;
            });
          },
        ),

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
              _homeVisit
                  ? 'Home Visit'
                  : 'Clinic Visit',

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
        ),

        const SizedBox(height: 18),

        _FinalConfirmationCard(
          package:
              selectedPackage,

          homeVisit:
              _homeVisit,

          date:
              _formatDate(
            _selectedDate,
          ),

          time:
              _selectedTime ??
                  'Not selected',
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
        return true;

      case 1:
        return true;

      case 2:
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

    final basePrice =
        widget.baseSessionPrice > 0
            ? widget.baseSessionPrice
            : package.price.toDouble();

    final totalSessions =
        package.visits;

    final subtotal =
        basePrice *
            totalSessions;

    final discountAmount =
        (subtotal -
                package.price)
            .clamp(
              0,
              double.infinity,
            )
            .toDouble();

    final discountPercent =
        subtotal > 0
            ? (discountAmount /
                    subtotal) *
                100
            : 0.0;

    // -------------------------------------------------------------
    // SERVICE TYPE
    // -------------------------------------------------------------

    final serviceType =
        _homeVisit
            ? 'homeVisit'
            : 'clinicVisit';

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

    final travelCharge = 0.0;
    final platformFee = 0.0;
    final taxAmount = 0.0;

    final totalAmount =
        subtotal -
            discountAmount +
            travelCharge +
            platformFee +
            taxAmount;

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
          totalSessions > 1
              ? 'package_$totalSessions'
              : null,

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
        'Amount: ₹${createdBooking.totalAmount}',
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

    if (_selectedTime == null ||
        _selectedTime!.trim().isEmpty) {
      _showMessage(
        'Please select an appointment time.',
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
            'Your appointment has been created successfully. '
            'Booking ID: ${booking.id}\n\n'
            'Total payable: ₹${booking.totalAmount.toStringAsFixed(0)}',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                Navigator.pop(
                  context,
                );
              },

              child:
                  const Text('Done'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                // =================================================
                // NEXT:
                // NAVIGATE TO PAYMENT SCREEN HERE
                // =================================================

                _showMessage(
                  'Payment screen will open next.',
                );
              },

              child:
                  const Text(
                'Continue to payment',
              ),
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
  final int visits;
  final String title;
  final String description;
  final int price;
  final int savings;
  final bool popular;
  final bool bestValue;

  const _PackageOption({
    required this.visits,
    required this.title,
    required this.description,
    required this.price,
    required this.savings,
    this.popular = false,
    this.bestValue = false,
  });
}

// ==================================================================
// PREMIUM STEP INDICATOR
// ==================================================================

class _PremiumStepIndicator
    extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _PremiumStepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(
            totalSteps,
            (index) {
              final completed =
                  index <= currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration:
                          BoxDecoration(
                        gradient:
                            completed
                                ? const LinearGradient(
                                    begin:
                                        Alignment.topLeft,
                                    end:
                                        Alignment.bottomRight,
                                    colors: [
                                      Color(
                                        0xFF6B58E8,
                                      ),
                                      Color(
                                        0xFF5146D9,
                                      ),
                                    ],
                                  )
                                : null,
                        color:
                            completed
                                ? null
                                : const Color(
                                    0xFFE9EBF2,
                                  ),
                        shape:
                            BoxShape.circle,
                        boxShadow:
                            completed
                                ? [
                                    BoxShadow(
                                      color:
                                          const Color(
                                        0xFF5146D9,
                                      ).withOpacity(
                                        .16,
                                      ),
                                      blurRadius:
                                          10,
                                      offset:
                                          const Offset(
                                        0,
                                        4,
                                      ),
                                    ),
                                  ]
                                : null,
                      ),
                      child: Center(
                        child: completed
                            ? index <
                                    currentStep
                                ? const Icon(
                                    Icons
                                        .check_rounded,
                                    size: 16,
                                    color:
                                        Colors.white,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          11,
                                      color:
                                          Colors.white,
                                      fontWeight:
                                          FontWeight.w900,
                                    ),
                                  )
                            : Text(
                                '${index + 1}',
                                style:
                                    const TextStyle(
                                  fontSize:
                                      11,
                                  color:
                                      Color(
                                    0xFF8991A7,
                                  ),
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    if (index <
                        totalSteps - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 5,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                index <
                                        currentStep
                                    ? const Color(
                                        0xFF5A4DE0,
                                      )
                                    : const Color(
                                        0xFFE1E4EC,
                                      ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 9),

        Align(
          alignment:
              Alignment.centerLeft,
          child: Text(
            'Step ${currentStep + 1} of $totalSteps',
            style:
                const TextStyle(
              fontSize: 10,
              color:
                  Color(0xFF737C94),
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// STEP HEADING
// ==================================================================

class _StepHeading
    extends StatelessWidget {
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            fontSize: 22,
            color:
                Color(0xFF111A3D),
            fontWeight:
                FontWeight.w900,
            letterSpacing: -.55,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          subtitle,
          style:
              const TextStyle(
            fontSize: 12,
            height: 1.4,
            color:
                Color(0xFF737C94),
            fontWeight:
                FontWeight.w600,
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
            child: Image.asset(
              doctorImage,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.person_rounded,
                  size: 34,
                  color:
                      Color(0xFF5146D9),
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

class _CareTypeSelector
    extends StatelessWidget {
  final bool homeVisit;
  final ValueChanged<bool> onChanged;

  const _CareTypeSelector({
    required this.homeVisit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CareTypeCard(
          icon:
              Icons.home_rounded,
          title:
              'Home Visit',
          subtitle:
              'Expert care at your doorstep',
          selected:
              homeVisit,
          onTap: () {
            onChanged(true);
          },
        ),

        const SizedBox(height: 12),

        _CareTypeCard(
          icon:
              Icons.local_hospital_rounded,
          title:
              'Clinic Visit',
          subtitle:
              'Visit a trusted clinic',
          selected:
              !homeVisit,
          onTap: () {
            onChanged(false);
          },
        ),
      ],
    );
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
  final VoidCallback onTap;

  const _CareTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior:
          HitTestBehavior.opaque,
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

  const _PremiumSavingsCard({
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    if (package.savings <= 0) {
      return const _PremiumInfoCard(
        icon:
            Icons.verified_rounded,
        title:
            'Flexible single session',
        description:
            'Perfect if you want to try a session before choosing a recovery plan.',
        compact: true,
      );
    }

    return _PremiumInfoCard(
      icon:
          Icons.savings_rounded,
      title:
          'You save ₹${package.savings}',
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
  final bool homeVisit;
  final String date;
  final String time;

  const _FinalConfirmationCard({
    required this.package,
    required this.homeVisit,
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
                homeVisit
                    ? Icons.home_rounded
                    : Icons
                        .local_hospital_rounded,
            title:
                homeVisit
                    ? 'Home Visit'
                    : 'Clinic Visit',
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
                '${package.visits} visit${package.visits > 1 ? 's' : ''} • ₹${package.price}',
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

class _PremiumBottomBar
    extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final _PackageOption package;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _PremiumBottomBar({
    required this.currentStep,
    required this.totalSteps,
    required this.package,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast =
        currentStep ==
            totalSteps - 1;

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        11,
        18,
        12,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color:
                Color(0xFFE5E8F0),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(
              0xFF26345C,
            ).withOpacity(.10),
            blurRadius: 24,
            offset:
                const Offset(
              0,
              -7,
            ),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (currentStep > 0)
              GestureDetector(
                onTap: onBack,
                behavior:
                    HitTestBehavior
                        .opaque,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF4F5F9,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),
                    border: Border.all(
                      color:
                          const Color(
                        0xFFE2E5ED,
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .arrow_back_rounded,
                    size: 20,
                    color:
                        Color(
                      0xFF343D59,
                    ),
                  ),
                ),
              ),

            if (currentStep > 0)
              const SizedBox(
                width: 10,
              ),

            // -------------------------------------------------------
            // PRICE
            // -------------------------------------------------------

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  currentStep == 0
                      ? 'STARTING FROM'
                      : 'TOTAL',
                  style:
                      const TextStyle(
                    fontSize: 8,
                    color:
                        Color(
                      0xFF8C94A8,
                    ),
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing:
                        .45,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  '₹${package.price}',
                  style:
                      const TextStyle(
                    fontSize: 17,
                    color:
                        Color(
                      0xFF079F87,
                    ),
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),

            const SizedBox(
              width: 13,
            ),

            // -------------------------------------------------------
            // NEXT BUTTON
            // -------------------------------------------------------

            Expanded(
              child:
                  GestureDetector(
                onTap: onNext,
                child:
                    Container(
                  height: 50,
                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      begin:
                          Alignment.topLeft,
                      end:
                          Alignment.bottomRight,
                      colors: [
                        Color(
                          0xFF6B58E8,
                        ),
                        Color(
                          0xFF5146D9,
                        ),
                      ],
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      16,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(
                          0xFF5146D9,
                        ).withOpacity(
                          .22,
                        ),
                        blurRadius:
                            15,
                        offset:
                            const Offset(
                          0,
                          6,
                        ),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Text(
                        isLast
                            ? 'Pay & Confirm'
                            : 'Continue',
                        style:
                            const TextStyle(
                          fontSize:
                              12.5,
                          color:
                              Colors.white,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),

                      const SizedBox(
                        width: 7,
                      ),

                      Icon(
                        isLast
                            ? Icons
                                .lock_rounded
                            : Icons
                                .arrow_forward_rounded,
                        size: 16,
                        color:
                            Colors.white,
                      ),
                    ],
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