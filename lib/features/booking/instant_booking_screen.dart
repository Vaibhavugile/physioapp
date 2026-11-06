import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_location_model.dart';
import '../core/config/pricing_config.dart';
import '../explore/widgets/location_selection_sheet.dart';

/// Premium guided patient booking experience.
///
/// Creates an unassigned request in `booking_requests`. Provider matching and
/// atomic acceptance must be handled by trusted Firebase backend code.
class InstantBookingScreen extends StatefulWidget {
  final UserLocationModel? initialLocation;
  final String? initialCondition;

  const InstantBookingScreen({
    super.key,
    this.initialLocation,
    this.initialCondition,
  });

  @override
  State<InstantBookingScreen> createState() => _InstantBookingScreenState();
}

class _InstantBookingScreenState extends State<InstantBookingScreen>
    with TickerProviderStateMixin {
  static const Color _ink = Color(0xFF17213D);
  static const Color _muted = Color(0xFF7D879D);
  static const Color _purple = Color(0xFF6558E8);
  static const Color _purpleDark = Color(0xFF39318C);
  static const Color _canvas = Color(0xFFF6F7FC);
  static const Color _line = Color(0xFFE9EBF3);
  static const Color _green = Color(0xFF159A79);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _conditionController = TextEditingController();

  UserLocationModel? _location;
  DateTime _date = DateUtils.dateOnly(DateTime.now().add(const Duration(days: 1)));
  String? _time;
  String _careMode = 'home';
  String? _tierKey;
  int _step = 0;
  int _packageSessions = 1;

  List<PricingTier> _tiers = const [];
  bool _loadingPricing = true;
  bool _submitting = false;
  String? _pricingError;

  static const int _lastStep = 5;

  final List<_RecoveryPackage> _packages = const [
    _RecoveryPackage(
      sessions: 1,
      title: 'Single session',
      subtitle: 'Try a session and get started',
      discount: 0,
      validityDays: 7,
      icon: Icons.spa_rounded,
    ),
    _RecoveryPackage(
      sessions: 5,
      title: 'Recovery pack',
      subtitle: 'Build consistency in your recovery',
      discount: 5,
      validityDays: 30,
      icon: Icons.favorite_rounded,
      popular: true,
    ),
    _RecoveryPackage(
      sessions: 10,
      title: 'Complete rehab',
      subtitle: 'Long-term support for your recovery',
      discount: 10,
      validityDays: 60,
      icon: Icons.workspace_premium_rounded,
      bestValue: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _location = widget.initialLocation;
    if (widget.initialCondition?.trim().isNotEmpty == true) {
      _conditionController.text = widget.initialCondition!.trim();
    }
    if (_location != null) {
      _addressController.text = _location!.displayName;
    }
    _loadPricing();
    _prefillPatient();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  Future<void> _prefillPatient() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _nameController.text = user.displayName ?? '';
    _phoneController.text = user.phoneNumber ?? '';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? {};
      if (!mounted) return;
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = (data['name'] ??
                data['fullName'] ??
                data['displayName'] ??
                '')
            .toString();
      }
      if (_phoneController.text.trim().isEmpty) {
        _phoneController.text =
            (data['phone'] ?? data['phoneNumber'] ?? '').toString();
      }
      setState(() {});
    } catch (_) {
      // Manual entry remains available.
    }
  }

  Future<void> _loadPricing() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('physio_pricing')
          .doc('active')
          .get();
      PricingConfig.configure(snapshot.data());
      final tiers = PricingConfig.tiersForLocation(
        city: _readLocationText('city'),
        locality: _readLocationText('locality'),
      );
      if (!mounted) return;
      setState(() {
        _tiers = tiers;
        _tierKey ??= tiers.isNotEmpty ? tiers.first.key : null;
        _loadingPricing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _tiers = PricingConfig.tiersForLocation(
          city: _readLocationText('city'),
          locality: _readLocationText('locality'),
        );
        _tierKey ??= _tiers.isNotEmpty ? _tiers.first.key : null;
        _loadingPricing = false;
        _pricingError =
            'Showing the saved default rates. Live pricing could not be refreshed.';
      });
    }
  }

  String _readLocationText(String property) {
    final dynamic value = _location;
    if (value == null) return '';
    try {
      if (property == 'city') return (value.city ?? '').toString();
      if (property == 'locality') return (value.locality ?? '').toString();
      if (property == 'state') return (value.state ?? '').toString();
      if (property == 'pincode') return (value.pincode ?? '').toString();
      if (property == 'latitude') return (value.latitude ?? '').toString();
      if (property == 'longitude') return (value.longitude ?? '').toString();
    } catch (_) {}
    return '';
  }

  PricingTier? get _selectedTier {
    for (final tier in _tiers) {
      if (tier.key == _tierKey) return tier;
    }
    return _tiers.isEmpty ? null : _tiers.first;
  }

  _RecoveryPackage get _selectedPackage =>
      _packages.firstWhere((item) => item.sessions == _packageSessions);

  double get _sessionPrice {
    final tier = _selectedTier;
    if (tier == null) return 0;
    switch (_careMode) {
      case 'clinic':
        return tier.clinic;
      case 'online':
        return tier.online;
      default:
        return tier.homeVisit;
    }
  }

  double get _subtotal => _sessionPrice * _selectedPackage.sessions;
  double get _discountAmount =>
      _subtotal * _selectedPackage.discount / 100;
  double get _total => _subtotal - _discountAmount;

  String get _careLabel {
    switch (_careMode) {
      case 'clinic':
        return 'Clinic visit';
      case 'online':
        return 'Online consultation';
      default:
        return 'Home visit';
    }
  }

  List<String> get _timeSlots {
    final slots = <String>[];
    for (int minutes = 8 * 60; minutes <= 20 * 60; minutes += 30) {
      final hour24 = minutes ~/ 60;
      final minute = minutes % 60;
      final suffix = hour24 >= 12 ? 'PM' : 'AM';
      final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
      slots.add('$hour12:${minute.toString().padLeft(2, '0')} $suffix');
    }
    if (DateUtils.isSameDay(_date, DateTime.now())) {
      final now = DateTime.now();
      return slots.where((slot) {
        final parsed = _parseTime(slot);
        final dateTime =
            DateTime(_date.year, _date.month, _date.day, parsed.$1, parsed.$2);
        return dateTime.isAfter(now.add(const Duration(minutes: 15)));
      }).toList();
    }
    return slots;
  }

  Future<void> _chooseLocation() async {
    final selected = await showModalBottomSheet<UserLocationModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationSelectionSheet(selectedLocation: _location),
    );
    if (selected == null || !mounted) return;
    final oldName = _location?.displayName;
    final replaceAddress = _addressController.text.trim().isEmpty ||
        _addressController.text.trim() == (oldName ?? '').trim();
    setState(() {
      _location = selected;
      if (replaceAddress) _addressController.text = selected.displayName;
    });
    await _loadPricing();
  }

  Future<void> _chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(DateUtils.dateOnly(DateTime.now()))
          ? DateUtils.dateOnly(DateTime.now())
          : _date,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateUtils.dateOnly(DateTime.now().add(const Duration(days: 60))),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _purple,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _ink,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _time = null;
    });
  }

  bool _validateStep() {
    switch (_step) {
      case 0:
        if (_location == null) {
          _message('Choose the area where you need care.');
          return false;
        }
        if (_careMode == 'home' && _addressController.text.trim().isEmpty) {
          _message('Add your complete home visit address.');
          return false;
        }
        return true;
      case 1:
        if (_selectedTier == null || _sessionPrice <= 0) {
          _message('Choose an available experience tier.');
          return false;
        }
        return true;
      case 2:
        return true;
      case 3:
        if (_time == null) {
          _message('Choose an appointment time.');
          return false;
        }
        return true;
      case 4:
        if (!_formKey.currentState!.validate()) return false;
        return true;
      default:
        return true;
    }
  }

  void _continue() {
    if (!_validateStep()) return;
    if (_step < _lastStep) {
      FocusScope.of(context).unfocus();
      setState(() => _step++);
    } else {
      _submitRequest();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitRequest() async {
    if (_submitting) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _message('Please sign in before placing an instant booking request.');
      return;
    }
    if (_location == null || _time == null || _selectedTier == null) {
      _message('Please complete the booking details.');
      return;
    }
    if (_careMode == 'home' && _addressController.text.trim().isEmpty) {
      _message('Please enter the complete home visit address.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final location = _location!;
      final dynamic rawLocation = location;
      double? latitude;
      double? longitude;
      try {
        latitude = (rawLocation.latitude as num?)?.toDouble();
      } catch (_) {}
      try {
        longitude = (rawLocation.longitude as num?)?.toDouble();
      } catch (_) {}

      final now = DateTime.now();
      final parsed = _parseTime(_time!);
      final appointmentDateTime =
          DateTime(_date.year, _date.month, _date.day, parsed.$1, parsed.$2);
      final package = _selectedPackage;
      final packageExpiry =
          DateUtils.dateOnly(_date).add(Duration(days: package.validityDays));
      final ref =
          FirebaseFirestore.instance.collection('booking_requests').doc();

      final payload = <String, dynamic>{
        'id': ref.id,
        'requestType': 'instant',
        'userId': user.uid,
        'patientName': _nameController.text.trim(),
        'patientPhone': _phoneController.text.trim(),
        'patientEmail': user.email,
        'bookingType': package.sessions == 1 ? 'singleSession' : 'package',
        'packageId': 'recovery_${package.sessions}',
        'packageName': package.title,
        'totalSessions': package.sessions,
        'completedSessions': 0,
        'remainingSessions': package.sessions,
        'packageValidityDays': package.validityDays,
        'packageExpiryDate': Timestamp.fromDate(packageExpiry),
        'serviceType': _careMode,
        'careMode': _careMode,
        'careModeLabel': _careLabel,
        'condition': _conditionController.text.trim(),
        'patientNotes': _notesController.text.trim(),
        'appointmentDate': Timestamp.fromDate(DateUtils.dateOnly(_date)),
        'appointmentDateTime': Timestamp.fromDate(appointmentDateTime),
        'appointmentTime': _time,
        'appointmentTimeMinutes': parsed.$1 * 60 + parsed.$2,
        'address': _careMode == 'home'
            ? _addressController.text.trim()
            : location.displayName,
        'locationName': location.displayName,
        'locationShortName': location.shortDisplayName,
        'locality': _readLocationText('locality'),
        'city': _readLocationText('city'),
        'state': _readLocationText('state'),
        'pincode': _readLocationText('pincode'),
        'latitude': latitude,
        'longitude': longitude,
        'experienceTier': _selectedTier!.key,
        'experienceTierLabel': _selectedTier!.title,
        'experienceLabel': _selectedTier!.experienceLabel,
        'minExperienceYears': _selectedTier!.minExperience,
        'maxExperienceYears': _selectedTier!.maxExperience,
        'currency': PricingConfig.currency,
        'baseSessionPrice': _sessionPrice,
        'subtotal': _subtotal,
        'discountPercent': package.discount,
        'discountAmount': _discountAmount,
        'travelCharge': 0,
        'totalAmount': _total,
        'pricingSnapshot': {
          'currency': PricingConfig.currency,
          'amount': _total,
          'baseSessionPrice': _sessionPrice,
          'subtotal': _subtotal,
          'discountPercent': package.discount,
          'discountAmount': _discountAmount,
          'totalSessions': package.sessions,
          'packageName': package.title,
          'pricingTier': _selectedTier!.key,
          'pricingTierLabel': _selectedTier!.title,
          'pricingConfigVersion': PricingConfig.version,
          'pricingCity': _readLocationText('city'),
          'pricingLocality': _readLocationText('locality'),
        },
        'paymentStatus': 'pending',
        'paymentMethod': 'online',
        'paidAmount': 0,
        'bookingStatus': 'pendingLooking',
        'requestStatus': 'searching',
        'assignmentStatus': 'unassigned',
        'assignedPhysiotherapistId': null,
        'dispatchStatus': 'queued',
        'dispatchBatch': 0,
        'offersSent': 0,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'expiresAt': Timestamp.fromDate(now.add(const Duration(minutes: 10))),
      };

      await ref.set(payload);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => InstantBookingStatusScreen(requestId: ref.id),
        ),
      );
    } catch (error) {
      if (mounted) _message('Could not place your request. Please try again.');
      debugPrint('Instant booking request failed: $error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  (int, int) _parseTime(String value) {
    final parts = value.split(' ');
    final hm = parts.first.split(':');
    var hour = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    if (parts.length > 1 && parts[1] == 'PM' && hour != 12) hour += 12;
    if (parts.length > 1 && parts[1] == 'AM' && hour == 12) hour = 0;
    return (hour, minute);
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  String _dateLabel(DateTime value) =>
      '${_weekday(value.weekday)}, ${value.day} ${_month(value.month)} ${value.year}';

  String _weekday(int day) => const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ][day - 1];

  String _month(int month) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][month - 1];

  @override
  Widget build(BuildContext context) {
    if (_loadingPricing) {
      return const Scaffold(
        backgroundColor: _canvas,
        body: Center(child: CircularProgressIndicator(color: _purple)),
      );
    }

    return Scaffold(
      backgroundColor: _canvas,
      body: Stack(
        children: [
          const Positioned(
            top: -110,
            right: -90,
            child: _GlowOrb(size: 260, color: Color(0x226B5CE7)),
          ),
          const Positioned(
            top: 320,
            left: -130,
            child: _GlowOrb(size: 220, color: Color(0x1C27B99A)),
          ),
          SafeArea(
            child: Column(
              children: [
                _topBar(),
                _progressHeader(),
                Expanded(
                  child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 340),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: const Offset(.08, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: slide, child: child),
                        );
                      },
                      child: SingleChildScrollView(
                        key: ValueKey(_step),
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
                        child: _stepContent(),
                      ),
                  ),
                ),
                _bottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
        child: Row(
          children: [
            _roundIconButton(Icons.arrow_back_rounded, _back),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Book instantly',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your care, made simple',
                    style: TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.85),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _line),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_rounded, size: 14, color: _green),
                  SizedBox(width: 5),
                  Text(
                    'Secure',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _roundIconButton(IconData icon, VoidCallback onTap) => Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, color: _ink, size: 19),
          ),
        ),
      );

  Widget _progressHeader() {
    final titles = ['Care', 'Experience', 'Recovery plan', 'Schedule', 'Details', 'Review'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'STEP ${_step + 1} OF ${_lastStep + 1}',
                style: const TextStyle(
                  color: _purple,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
              const Spacer(),
              Text(
                titles[_step],
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: List.generate(_lastStep + 1, (index) {
              final active = index <= _step;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  height: 5,
                  margin: EdgeInsets.only(right: index == _lastStep ? 0 : 5),
                  decoration: BoxDecoration(
                    color: active ? _purple : const Color(0xFFE4E6EF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _stepContent() {
    switch (_step) {
      case 0:
        return _careStep();
      case 1:
        return _experienceStep();
      case 2:
        return _packageStep();
      case 3:
        return _scheduleStep();
      case 4:
        return _detailsStep();
      default:
        return _reviewStep();
    }
  }

  Widget _stepHeading(String eyebrow, String title, String subtitle,
          {IconData icon = Icons.auto_awesome_rounded}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 19),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEDEBFF), Color(0xFFF5F2FF)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: _purple, size: 22),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow.toUpperCase(),
                    style: const TextStyle(
                      color: _purple,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 23,
                      height: 1.13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.55,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _careStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeading(
            'Let’s begin',
            'Where would you like your care?',
            'Choose the session style that feels right for you.',
            icon: Icons.health_and_safety_rounded,
          ),
          _heroStrip(),
          const SizedBox(height: 22),
          const _MiniLabel('CARE OPTIONS'),
          const SizedBox(height: 10),
          _careOption(
            'home',
            'Home visit',
            'A physiotherapist comes to you',
            Icons.home_rounded,
            const Color(0xFFEAF8F4),
            _green,
          ),
          const SizedBox(height: 10),
          _careOption(
            'clinic',
            'Clinic visit',
            'Visit a nearby clinic or practice',
            Icons.local_hospital_rounded,
            const Color(0xFFEEF0FF),
            _purple,
          ),
          const SizedBox(height: 10),
          _careOption(
            'online',
            'Online consultation',
            'Get guidance from wherever you are',
            Icons.video_camera_front_rounded,
            const Color(0xFFFFF3E8),
            const Color(0xFFE58A38),
          ),
          const SizedBox(height: 22),
          const _MiniLabel('YOUR AREA'),
          const SizedBox(height: 9),
          _locationCard(),
          if (_careMode == 'home') ...[
            const SizedBox(height: 12),
            _inputField(
              _addressController,
              'Complete home address',
              'Flat, building, street and landmark',
              Icons.home_work_outlined,
              maxLines: 2,
            ),
          ],
        ],
      );

  Widget _heroStrip() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF202653), Color(0xFF5146B9), Color(0xFF7166EA)],
          ),
          boxShadow: [
            BoxShadow(
              color: _purple.withOpacity(.17),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PERSONALISED PHYSIOTHERAPY',
                    style: TextStyle(
                      color: Color(0xFFC8C8FF),
                      fontSize: 8,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'A better way\nto feel better.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tell us what works for you. We’ll find an available professional.',
                    style: TextStyle(
                      color: Color(0xFFE1E2FF),
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.12),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(.18)),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: Color(0xFFB8F1E4),
                size: 34,
              ),
            ),
          ],
        ),
      );

  Widget _careOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
    Color tint,
    Color accent,
  ) {
    final selected = _careMode == value;
    return _SelectableCard(
      selected: selected,
      onTap: () => setState(() => _careMode = value),
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: accent, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: _ink, fontSize: 13, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: _muted, fontSize: 10)),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? _purple : Colors.transparent,
              border: Border.all(
                color: selected ? _purple : const Color(0xFFC9CEDA),
                width: 1.5,
              ),
            ),
            child: selected
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _locationCard() => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: _chooseLocation,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: _line),
            ),
            child: Row(
              children: [
                Container(
                  width: 41,
                  height: 41,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8F4),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: _green),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _location?.shortDisplayName ?? 'Select your location',
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _location?.displayName ??
                            'Use your current location or search an area',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _muted),
              ],
            ),
          ),
        ),
      );

  Widget _experienceStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeading(
            'Your preference',
            'Choose experience level',
            'Select the experience you’d feel most comfortable with.',
            icon: Icons.workspace_premium_rounded,
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFF),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: _purple),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'We’ll match you with an available physiotherapist in your selected tier.',
                    style: TextStyle(
                      color: Color(0xFF514B8B),
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (_tiers.isEmpty)
            _emptyCard('Experience tiers are not available right now.')
          else
            ..._tiers.map((tier) {
              final selected = tier.key == _tierKey;
              final price = _amountFor(tier);
              return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: _SelectableCard(
                  selected: selected,
                  onTap: () => setState(() => _tierKey = tier.key),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tier.title,
                              style: const TextStyle(
                                color: _ink,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            '₹${price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: selected ? _purple : _ink,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.verified_rounded,
                              size: 13, color: _green),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              tier.experienceLabel,
                              style: const TextStyle(
                                  color: _muted, fontSize: 10),
                            ),
                          ),
                          Text(
                            'per session',
                            style: TextStyle(
                              color: _muted.withOpacity(.9),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                      if (selected) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFE0DDFB)),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: _purple, size: 15),
                            SizedBox(width: 6),
                            Text(
                              'Selected experience level',
                              style: TextStyle(
                                color: _purple,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          if (_pricingError != null) ...[
            const SizedBox(height: 5),
            Text(_pricingError!,
                style: const TextStyle(color: _muted, fontSize: 10)),
          ],
        ],
      );

  double _amountFor(PricingTier tier) {
    switch (_careMode) {
      case 'clinic':
        return tier.clinic;
      case 'online':
        return tier.online;
      default:
        return tier.homeVisit;
    }
  }

  Widget _packageStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeading(
            'Plan your progress',
            'Choose a recovery plan',
            'More consistency can make it easier to stay on track.',
            icon: Icons.favorite_rounded,
          ),
          ..._packages.map((package) {
            final selected = package.sessions == _packageSessions;
            final original = _sessionPrice * package.sessions;
            final finalPrice = original * (1 - package.discount / 100);
            final saving = original - finalPrice;
            return Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: _SelectableCard(
                selected: selected,
                onTap: () => setState(
                    () => _packageSessions = package.sessions),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    if (package.popular || package.bestValue)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 7),
                        decoration: BoxDecoration(
                          color: package.bestValue
                              ? const Color(0xFFFFF2E6)
                              : const Color(0xFFEEEDFF),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(19)),
                        ),
                        child: Text(
                          package.bestValue
                              ? 'BEST VALUE  ·  SAVE ${package.discount.toStringAsFixed(0)}%'
                              : 'MOST POPULAR  ·  SAVE ${package.discount.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: package.bestValue
                                ? const Color(0xFFCE7A2F)
                                : _purple,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .8,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 47,
                            height: 47,
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFEEEDFF)
                                  : const Color(0xFFF3F4F8),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              package.icon,
                              color: selected ? _purple : _muted,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(package.title,
                                    style: const TextStyle(
                                      color: _ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    )),
                                const SizedBox(height: 4),
                                Text(package.subtitle,
                                    style: const TextStyle(
                                        color: _muted, fontSize: 9)),
                                const SizedBox(height: 7),
                                Row(
                                  children: [
                                    _tinyPill(
                                        '${package.sessions} sessions'),
                                    const SizedBox(width: 5),
                                    _tinyPill(
                                        '${package.validityDays} days validity'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${finalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: selected ? _purple : _ink,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (package.discount > 0)
                                Text(
                                  '₹${original.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: _muted,
                                    fontSize: 9,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 13),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: _purple, size: 15),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                package.discount > 0
                                    ? 'You save ₹${saving.toStringAsFixed(0)} on this plan'
                                    : 'No commitment — pay for one session',
                                style: const TextStyle(
                                  color: _purple,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              '${package.discount.toStringAsFixed(0)}% off',
                              style: const TextStyle(
                                color: _green,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8F4),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: _green, size: 17),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Unused sessions expire after the package validity period. Your first appointment is the date you choose next.',
                    style: TextStyle(
                      color: Color(0xFF367A6A),
                      fontSize: 9,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _tinyPill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: _muted, fontSize: 8, fontWeight: FontWeight.w700),
        ),
      );

  Widget _scheduleStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeading(
            'Find your time',
            'When should we come?',
            'Choose your preferred first appointment slot.',
            icon: Icons.calendar_month_rounded,
          ),
          const _MiniLabel('APPOINTMENT DATE'),
          const SizedBox(height: 9),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: _chooseDate,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _line),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEDFF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.event_available_rounded,
                          color: _purple),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Preferred date',
                              style: TextStyle(color: _muted, fontSize: 9)),
                          const SizedBox(height: 4),
                          Text(
                            _dateLabel(_date),
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_calendar_rounded,
                        color: _purple, size: 19),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const _MiniLabel('AVAILABLE TIME SLOTS'),
          const SizedBox(height: 5),
          const Text(
            'Pick a time that suits your day.',
            style: TextStyle(color: _muted, fontSize: 10),
          ),
          const SizedBox(height: 13),
          if (_timeSlots.isEmpty)
            _emptyCard('No time slots remain today. Please choose another date.')
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _timeSlots.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 9,
                crossAxisSpacing: 9,
                childAspectRatio: 2.35,
              ),
              itemBuilder: (context, index) {
                final slot = _timeSlots[index];
                final selected = slot == _time;
                return _SelectableCard(
                  selected: selected,
                  onTap: () => setState(() => _time = slot),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Center(
                    child: Text(
                      slot,
                      style: TextStyle(
                        color: selected ? _purple : _ink,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      );

  Widget _detailsStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeading(
            'A little about you',
            'Who is the session for?',
            'Just the essentials, so the right professional can contact you.',
            icon: Icons.person_pin_circle_rounded,
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _inputField(
                  _nameController,
                  'Patient full name',
                  'Enter patient name',
                  Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                _inputField(
                  _phoneController,
                  'Mobile number',
                  'Enter contact number',
                  Icons.phone_iphone_rounded,
                  phone: true,
                ),
                const SizedBox(height: 12),
                _inputField(
                  _conditionController,
                  'What would you like help with?',
                  'e.g. Back pain, knee pain, post-surgery',
                  Icons.accessibility_new_rounded,
                  required: false,
                ),
                const SizedBox(height: 12),
                _inputField(
                  _notesController,
                  'Anything else we should know?',
                  'Optional notes for your physiotherapist',
                  Icons.notes_rounded,
                  required: false,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _line),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: _green, size: 19),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your contact details are shared only to coordinate this booking.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 9,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _inputField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    bool required = true,
    bool phone = false,
    int maxLines = 1,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: phone
            ? TextInputType.phone
            : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
        maxLines: maxLines,
        validator: required
            ? (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'This field is required';
                if (phone &&
                    text.replaceAll(RegExp(r'\D'), '').length < 10) {
                  return 'Enter a valid contact number';
                }
                return null;
              }
            : null,
        style: const TextStyle(
            color: _ink, fontSize: 12, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: _muted),
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: _muted, fontSize: 10),
          hintStyle: const TextStyle(color: Color(0xFFADB3C2), fontSize: 10),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _purple, width: 1.4),
          ),
          errorStyle: const TextStyle(fontSize: 9),
        ),
      );

  Widget _reviewStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeading(
            'Almost there',
            'Review your booking',
            'Everything look right? You can go back and make changes.',
            icon: Icons.fact_check_rounded,
          ),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF202653), Color(0xFF5146B9)],
              ),
              borderRadius: BorderRadius.circular(21),
              boxShadow: [
                BoxShadow(
                  color: _purple.withOpacity(.15),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESTIMATED TOTAL',
                  style: TextStyle(
                    color: Color(0xFFC9C8FF),
                    fontSize: 8,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${_total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 7, bottom: 5),
                      child: Text(
                        'for ${_selectedPackage.sessions} session${_selectedPackage.sessions == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: Color(0xFFE0DFFF),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedPackage.discount > 0) ...[
                  const SizedBox(height: 5),
                  Text(
                    'You save ₹${_discountAmount.toStringAsFixed(0)} with this plan',
                    style: const TextStyle(
                      color: Color(0xFFB8F1E4),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _reviewCard(
            title: 'Care preference',
            icon: Icons.health_and_safety_rounded,
            onEdit: () => setState(() => _step = 0),
            rows: [
              _ReviewRow('Care type', _careLabel),
              _ReviewRow(
                  'Location', _location?.shortDisplayName ?? 'Not selected'),
              if (_careMode == 'home')
                _ReviewRow('Address', _addressController.text.trim()),
            ],
          ),
          const SizedBox(height: 10),
          _reviewCard(
            title: 'Experience & recovery',
            icon: Icons.workspace_premium_rounded,
            onEdit: () => setState(() => _step = 1),
            rows: [
              _ReviewRow('Experience', _selectedTier?.title ?? '—'),
              _ReviewRow('Plan', _selectedPackage.title),
              _ReviewRow('Sessions', '${_selectedPackage.sessions}'),
              _ReviewRow(
                  'Validity', '${_selectedPackage.validityDays} days'),
            ],
          ),
          const SizedBox(height: 10),
          _reviewCard(
            title: 'Appointment',
            icon: Icons.calendar_month_rounded,
            onEdit: () => setState(() => _step = 3),
            rows: [
              _ReviewRow('Date', _dateLabel(_date)),
              _ReviewRow('Time', _time ?? '—'),
            ],
          ),
          const SizedBox(height: 10),
          _reviewCard(
            title: 'Patient',
            icon: Icons.person_outline_rounded,
            onEdit: () => setState(() => _step = 4),
            rows: [
              _ReviewRow('Name', _nameController.text.trim()),
              _ReviewRow('Phone', _phoneController.text.trim()),
              if (_conditionController.text.trim().isNotEmpty)
                _ReviewRow('Concern', _conditionController.text.trim()),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8F4),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_user_rounded, color: _green, size: 19),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Your request will be sent to eligible physiotherapists. Your booking is confirmed only after a professional accepts it.',
                    style: TextStyle(
                      color: Color(0xFF367A6A),
                      fontSize: 9,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _reviewCard({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required List<_ReviewRow> rows,
  }) =>
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _line),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: _purple, size: 17),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          color: _ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w900)),
                ),
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(35, 25),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Edit',
                      style: TextStyle(
                          color: _purple,
                          fontSize: 10,
                          fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 88,
                      child: Text(row.label,
                          style:
                              const TextStyle(color: _muted, fontSize: 9)),
                    ),
                    Expanded(
                      child: Text(
                        row.value.isEmpty ? '—' : row.value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _emptyCard(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _line),
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 10)),
      );

  Widget _bottomBar() => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.96),
          border: const Border(top: BorderSide(color: _line)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF18234A).withOpacity(.05),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              if (_step > 0) ...[
                _roundIconButton(Icons.arrow_back_rounded, _back),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: SizedBox(
                  height: 53,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _purple.withOpacity(.55),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _step == _lastStep
                                    ? 'Find my physiotherapist'
                                    : 'Continue',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _step == _lastStep
                                    ? Icons.bolt_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
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

class _RecoveryPackage {
  final int sessions;
  final String title;
  final String subtitle;
  final double discount;
  final int validityDays;
  final IconData icon;
  final bool popular;
  final bool bestValue;

  const _RecoveryPackage({
    required this.sessions,
    required this.title,
    required this.subtitle,
    required this.discount,
    required this.validityDays,
    required this.icon,
    this.popular = false,
    this.bestValue = false,
  });
}

class _ReviewRow {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);
}

class _MiniLabel extends StatelessWidget {
  final String text;
  const _MiniLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: _InstantBookingScreenState._muted,
          fontSize: 9,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w900,
        ),
      );
}

class _SelectableCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SelectableCard({
    required this.selected,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5F3FF) : Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: selected ? _InstantBookingScreenState._purple : _InstantBookingScreenState._line,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF6558E8).withOpacity(.07)
                  : const Color(0xFF17213D).withOpacity(.025),
              blurRadius: selected ? 15 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(19),
            child: Padding(padding: padding, child: child),
          ),
        ),
      );
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withOpacity(0)],
            ),
          ),
        ),
      );
}

class InstantBookingStatusScreen extends StatelessWidget {
  final String requestId;
  const InstantBookingStatusScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance
        .collection('booking_requests')
        .doc(requestId);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FC),
        surfaceTintColor: const Color(0xFFF6F7FC),
        elevation: 0,
        title: const Text(
          'Booking status',
          style: TextStyle(
            color: Color(0xFF17213D),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF17213D)),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: ref.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load request status.'));
          }
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6558E8)));
          }
          final data = snapshot.data!.data();
          if (data == null) {
            return const Center(
                child: Text('This request is no longer available.'));
          }
          final status = (data['requestStatus'] ?? 'searching').toString();
          final bookingStatus =
              (data['bookingStatus'] ?? 'pendingLooking').toString();
          final assigned =
              (data['assignedPhysiotherapistName'] ??
                      data['physiotherapistName'] ??
                      '')
                  .toString();
          final isAssigned = status == 'assigned' ||
              bookingStatus == 'confirmed' ||
              assigned.isNotEmpty;
          final isExpired = status == 'expired' ||
              bookingStatus == 'noPhysiotherapistFound';
          final isCancelled =
              status == 'cancelled' || bookingStatus == 'cancelled';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 23),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF202653), Color(0xFF5146B9)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.13),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isAssigned
                            ? Icons.check_rounded
                            : isExpired
                                ? Icons.search_off_rounded
                                : Icons.manage_search_rounded,
                        color: isAssigned
                            ? const Color(0xFFB8F1E4)
                            : Colors.white,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isAssigned
                          ? 'Physiotherapist assigned!'
                          : isExpired
                              ? 'No match found yet'
                              : isCancelled
                                  ? 'Request cancelled'
                                  : 'Finding your physiotherapist',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAssigned
                          ? 'Your request has been accepted by $assigned.'
                          : isExpired
                              ? 'We could not find an available professional for this request. You can try another time.'
                              : isCancelled
                                  ? 'This request has been cancelled.'
                                  : 'Your request is in the matching queue. We’ll update this screen when a professional accepts.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE1E2FF),
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _statusSummary(data),
              const SizedBox(height: 14),
              if (!isAssigned && !isExpired && !isCancelled && status == 'searching')
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.update({
                      'requestStatus': 'cancelled',
                      'bookingStatus': 'cancelled',
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
                  },
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Cancel request'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB34B58),
                    side: const BorderSide(color: Color(0xFFE7C7CC)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                'Request ID: $requestId',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF9AA1B2), fontSize: 9),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statusSummary(Map<String, dynamic> data) {
    final date = data['appointmentDate'];
    final dateText = date is Timestamp
        ? '${date.toDate().day}/${date.toDate().month}/${date.toDate().year}'
        : '—';
    final price = data['totalAmount'] ?? data['baseSessionPrice'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9EBF3)),
      ),
      child: Column(
        children: [
          _detail('Care type',
              (data['careModeLabel'] ?? data['serviceType'] ?? '—').toString()),
          _detail('Location',
              (data['locationShortName'] ?? data['locationName'] ?? '—').toString()),
          _detail('Date & time',
              '$dateText · ${(data['appointmentTime'] ?? '—').toString()}'),
          _detail('Experience',
              (data['experienceTierLabel'] ?? '—').toString()),
          _detail('Recovery plan',
              (data['packageName'] ?? 'Single session').toString()),
          _detail('Sessions', (data['totalSessions'] ?? 1).toString()),
          _detail('Estimated total', '₹${price.toString()}'),
          _detail('Status',
              (data['bookingStatus'] ?? 'pendingLooking').toString()),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: Color(0xFF7D879D), fontSize: 10)),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF17213D),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
}
