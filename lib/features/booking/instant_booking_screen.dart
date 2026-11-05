import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_location_model.dart';
import '../core/config/pricing_config.dart';
import '../explore/widgets/location_selection_sheet.dart';

/// Patient-facing on-demand booking flow.
///
/// This intentionally writes to `booking_requests`, not `bookings`, because
/// BookingModel currently requires an already-assigned physiotherapist. A
/// trusted backend should listen for new requests, dispatch provider offers,
/// and atomically assign the first accepting provider.
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

class _InstantBookingScreenState extends State<InstantBookingScreen> {
  static const _ink = Color(0xFF171D3B);
  static const _muted = Color(0xFF7D849B);
  static const _purple = Color(0xFF5146D9);
  static const _canvas = Color(0xFFF5F6FB);

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
  List<PricingTier> _tiers = const [];
  bool _loadingPricing = true;
  bool _submitting = false;
  String? _pricingError;

  @override
  void initState() {
    super.initState();
    _location = widget.initialLocation;
    if (widget.initialCondition?.trim().isNotEmpty == true) {
      _conditionController.text = widget.initialCondition!;
    }
    _loadPricing();
    _prefillPatient();
    if (_location != null) _addressController.text = _location!.displayName;
  }

  Future<void> _prefillPatient() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _nameController.text = user.displayName ?? '';
    _phoneController.text = user.phoneNumber ?? '';
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      if (!mounted) return;
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = (data['name'] ?? data['fullName'] ?? data['displayName'] ?? '').toString();
      }
      if (_phoneController.text.trim().isEmpty) {
        _phoneController.text = (data['phone'] ?? data['phoneNumber'] ?? '').toString();
      }
    } catch (_) {
      // Patient can enter details manually if the profile document is unavailable.
    }
  }

  Future<void> _loadPricing() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('physio_pricing').doc('active').get();
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
        _pricingError = 'Showing the default rate card. Live pricing could not be refreshed.';
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

  double get _price {
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
        final slotDateTime = DateTime(_date.year, _date.month, _date.day, parsed.$1, parsed.$2);
        return slotDateTime.isAfter(now.add(const Duration(minutes: 15)));
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
    final previousDisplayName = _location?.displayName;
    final shouldReplaceAddress = _addressController.text.trim().isEmpty ||
        _addressController.text.trim() == (previousDisplayName ?? '').trim();
    setState(() {
      _location = selected;
      if (shouldReplaceAddress) _addressController.text = selected.displayName;
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
          colorScheme: const ColorScheme.light(primary: _purple, onPrimary: Colors.white, surface: Colors.white, onSurface: _ink),
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

  Future<void> _submitRequest() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _message('Please sign in before placing an instant booking request.');
      return;
    }
    if (_location == null) {
      _message('Please select your service location.');
      return;
    }
    if (_time == null) {
      _message('Please select an appointment time.');
      return;
    }
    if (_careMode == 'home' && _addressController.text.trim().isEmpty) {
      _message('Please enter the complete home visit address.');
      return;
    }
    final tier = _selectedTier;
    if (tier == null || _price <= 0) {
      _message('Pricing is not available for this selection.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final location = _location!;
      final dynamic rawLocation = location;
      double? latitude;
      double? longitude;
      try { latitude = (rawLocation.latitude as num?)?.toDouble(); } catch (_) {}
      try { longitude = (rawLocation.longitude as num?)?.toDouble(); } catch (_) {}
      final now = DateTime.now();
      final dateTime = DateTime(_date.year, _date.month, _date.day, _parseTime(_time!).$1, _parseTime(_time!).$2);
      final ref = FirebaseFirestore.instance.collection('booking_requests').doc();
      final payload = <String, dynamic>{
        'id': ref.id,
        'requestType': 'instant',
        'userId': user.uid,
        'patientName': _nameController.text.trim(),
        'patientPhone': _phoneController.text.trim(),
        'patientEmail': user.email,
        'bookingType': 'singleSession',
        'serviceType': _careMode,
        'careMode': _careMode,
        'careModeLabel': _careLabel,
        'condition': _conditionController.text.trim(),
        'patientNotes': _notesController.text.trim(),
        'appointmentDate': Timestamp.fromDate(_date),
        'appointmentDateTime': Timestamp.fromDate(dateTime),
        'appointmentTime': _time,
        'appointmentTimeMinutes': _parseTime(_time!).$1 * 60 + _parseTime(_time!).$2,
        'address': _careMode == 'home' ? _addressController.text.trim() : location.displayName,
        'locationName': location.displayName,
        'locationShortName': location.shortDisplayName,
        'locality': _readLocationText('locality'),
        'city': _readLocationText('city'),
        'state': _readLocationText('state'),
        'pincode': _readLocationText('pincode'),
        'latitude': latitude,
        'longitude': longitude,
        'experienceTier': tier.key,
        'experienceTierLabel': tier.title,
        'experienceLabel': tier.experienceLabel,
        'minExperienceYears': tier.minExperience,
        'maxExperienceYears': tier.maxExperience,
        'pricingSnapshot': {
          'currency': PricingConfig.currency,
          'amount': _price,
          'baseSessionPrice': _price,
          'pricingTier': tier.key,
          'pricingTierLabel': tier.title,
          'pricingConfigVersion': PricingConfig.version,
          'pricingCity': _readLocationText('city'),
          'pricingLocality': _readLocationText('locality'),
        },
        'currency': PricingConfig.currency,
        'baseSessionPrice': _price,
        'totalAmount': _price,
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
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => InstantBookingStatusScreen(requestId: ref.id),
      ));
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value), behavior: SnackBarBehavior.floating));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        surfaceTintColor: _canvas,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: _ink), onPressed: () => Navigator.pop(context)),
        title: const Text('Book instantly', style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        top: false,
        child: _loadingPricing
            ? const Center(child: CircularProgressIndicator(color: _purple))
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                  children: [
                    _hero(),
                    const SizedBox(height: 20),
                    _sectionTitle('01', 'Choose your care type', 'How would you like to meet your physiotherapist?'),
                    const SizedBox(height: 12),
                    _careModeSelector(),
                    const SizedBox(height: 22),
                    _sectionTitle('02', 'Where do you need care?', 'We use this location to find eligible nearby professionals.'),
                    const SizedBox(height: 12),
                    _locationCard(),
                    if (_careMode == 'home') ...[
                      const SizedBox(height: 10),
                      _field(_addressController, 'Complete home address', 'Flat / building, street, landmark', icon: Icons.home_work_outlined, maxLines: 2),
                    ],
                    const SizedBox(height: 22),
                    _sectionTitle('03', 'Choose date & time', 'Select your preferred appointment slot.'),
                    const SizedBox(height: 12),
                    _dateCard(),
                    const SizedBox(height: 12),
                    _timeGrid(),
                    const SizedBox(height: 22),
                    _sectionTitle('04', 'Physiotherapist experience', 'Choose the experience level you prefer.'),
                    const SizedBox(height: 12),
                    _tierSelector(),
                    const SizedBox(height: 22),
                    _sectionTitle('05', 'About your requirement', 'Help the physiotherapist understand your needs.'),
                    const SizedBox(height: 12),
                    _field(_conditionController, 'Condition / body area (optional)', 'e.g. Back pain, knee pain, stroke recovery', icon: Icons.accessibility_new_rounded, required: false),
                    const SizedBox(height: 10),
                    _field(_notesController, 'Additional notes (optional)', 'Tell us anything the physiotherapist should know', icon: Icons.notes_rounded, required: false, maxLines: 3),
                    const SizedBox(height: 22),
                    _sectionTitle('06', 'Patient details', 'Who should the physiotherapist contact?'),
                    const SizedBox(height: 12),
                    _field(_nameController, 'Patient full name', 'Enter patient name', icon: Icons.person_outline_rounded),
                    const SizedBox(height: 10),
                    _field(_phoneController, 'Contact number', 'Enter 10-digit mobile number', icon: Icons.phone_outlined, phone: true),
                    const SizedBox(height: 18),
                    _priceSummary(),
                    if (_pricingError != null) ...[
                      const SizedBox(height: 8),
                      Text(_pricingError!, style: const TextStyle(color: _muted, fontSize: 11)),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(backgroundColor: _purple, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                        child: _submitting
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bolt_rounded), SizedBox(width: 8), Text('Find my physiotherapist', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15))]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Your request will be sent for physiotherapist matching. You will see its status on the next screen.', textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 11, height: 1.5)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _hero() => Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF171B4B), Color(0xFF39318C), Color(0xFF5146D9)]),
          boxShadow: [BoxShadow(color: _purple.withOpacity(.18), blurRadius: 22, offset: const Offset(0, 10))],
        ),
        child: const Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ON-DEMAND CARE', style: TextStyle(color: Color(0xFFBFC4FF), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.4)), SizedBox(height: 7), Text('The right care,\nwithout the search.', style: TextStyle(color: Colors.white, fontSize: 23, height: 1.12, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text('Tell us when and where. We’ll look for an available physiotherapist.', style: TextStyle(color: Color(0xFFD9DBF5), fontSize: 11, height: 1.45))])),
          SizedBox(width: 10),
          Icon(Icons.health_and_safety_rounded, color: Color(0xFF9CE8D8), size: 48),
        ]),
      );

  Widget _sectionTitle(String number, String title, String subtitle) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 29, height: 29, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFEEEDFF), borderRadius: BorderRadius.circular(10)), child: Text(number, style: const TextStyle(color: _purple, fontSize: 10, fontWeight: FontWeight.w900))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: _muted, fontSize: 11, height: 1.4))])),
      ]);

  Widget _careModeSelector() => Row(children: [
        _modeTile('home', 'Home visit', Icons.home_rounded, 'At your address'),
        const SizedBox(width: 8),
        _modeTile('clinic', 'Clinic', Icons.local_hospital_rounded, 'Visit a clinic'),
        const SizedBox(width: 8),
        _modeTile('online', 'Online', Icons.video_camera_front_rounded, 'Video session'),
      ]);

  Widget _modeTile(String value, String title, IconData icon, String subtitle) {
    final selected = _careMode == value;
    return Expanded(child: InkWell(
      onTap: () => setState(() => _careMode = value),
      borderRadius: BorderRadius.circular(17),
      child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 13), decoration: BoxDecoration(color: selected ? const Color(0xFFEEEDFF) : Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: selected ? _purple : const Color(0xFFE7E9F1), width: selected ? 1.5 : 1)), child: Column(children: [Icon(icon, color: selected ? _purple : _muted, size: 21), const SizedBox(height: 7), Text(title, maxLines: 1, style: TextStyle(color: selected ? _purple : _ink, fontSize: 10, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(color: _muted, fontSize: 8))])),
    ));
  }

  Widget _locationCard() => InkWell(
        onTap: _chooseLocation,
        borderRadius: BorderRadius.circular(17),
        child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE7E9F1))), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFEAF8F5), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.location_on_rounded, color: Color(0xFF168C79))), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_location?.shortDisplayName ?? 'Select your location', style: const TextStyle(color: _ink, fontWeight: FontWeight.w900, fontSize: 12)), const SizedBox(height: 3), Text(_location?.displayName ?? 'Use current location or search an area', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 10))])), const Icon(Icons.chevron_right_rounded, color: _muted)])),
      );

  Widget _dateCard() => InkWell(onTap: _chooseDate, borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE7E9F1))), child: Row(children: [const Icon(Icons.calendar_month_rounded, color: _purple), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Appointment date', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text('${_weekday(_date.weekday)}, ${_date.day} ${_month(_date.month)} ${_date.year}', style: const TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w900))])), const Icon(Icons.edit_calendar_rounded, color: _muted, size: 19)])));

  Widget _timeGrid() => Wrap(spacing: 8, runSpacing: 8, children: _timeSlots.map((slot) {
        final selected = _time == slot;
        return InkWell(onTap: () => setState(() => _time = slot), borderRadius: BorderRadius.circular(11), child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: selected ? _purple : Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: selected ? _purple : const Color(0xFFE7E9F1))), child: Text(slot, style: TextStyle(color: selected ? Colors.white : _ink, fontSize: 10, fontWeight: FontWeight.w800))));
      }).toList());

  Widget _tierSelector() => Column(children: _tiers.map((tier) {
        final selected = tier.key == _tierKey;
        final amount = _amountFor(tier);
        return Padding(padding: const EdgeInsets.only(bottom: 8), child: InkWell(onTap: () => setState(() => _tierKey = tier.key), borderRadius: BorderRadius.circular(15), child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: selected ? const Color(0xFFF0EFFF) : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: selected ? _purple : const Color(0xFFE7E9F1), width: selected ? 1.5 : 1)), child: Row(children: [Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? _purple : const Color(0xFFB4BAC9), size: 19), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tier.title, style: const TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(tier.experienceLabel, style: const TextStyle(color: _muted, fontSize: 10))])), Text('₹${amount.toStringAsFixed(0)}', style: TextStyle(color: selected ? _purple : _ink, fontSize: 14, fontWeight: FontWeight.w900)), const Text(' / session', style: TextStyle(color: _muted, fontSize: 9))]))));
      }).toList());

  double _amountFor(PricingTier tier) {
    switch (_careMode) {
      case 'clinic': return tier.clinic;
      case 'online': return tier.online;
      default: return tier.homeVisit;
    }
  }

  Widget _field(TextEditingController controller, String label, String hint, {required IconData icon, bool required = true, bool phone = false, int maxLines = 1}) => TextFormField(
        controller: controller,
        keyboardType: phone ? TextInputType.phone : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
        maxLines: maxLines,
        validator: required ? (value) { final text = value?.trim() ?? ''; if (text.isEmpty) return 'This field is required'; if (phone && text.replaceAll(RegExp(r'\D'), '').length < 10) return 'Enter a valid contact number'; return null; } : null,
        decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon, size: 19), filled: true, fillColor: Colors.white, labelStyle: const TextStyle(color: _muted, fontSize: 11), hintStyle: const TextStyle(color: Color(0xFFADB3C2), fontSize: 11), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE7E9F1))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE7E9F1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _purple, width: 1.4)), errorStyle: const TextStyle(fontSize: 10)),
      );

  Widget _priceSummary() => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: const Color(0xFF171B4B), borderRadius: BorderRadius.circular(19)), child: Column(children: [Row(children: [const Expanded(child: Text('YOUR ESTIMATED SESSION PRICE', style: TextStyle(color: Color(0xFFBFC4FF), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))), Text('${PricingConfig.currency} · $_careLabel', style: const TextStyle(color: Colors.white70, fontSize: 9))]), const SizedBox(height: 9), Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('₹${_price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)), const Padding(padding: EdgeInsets.only(bottom: 5, left: 5), child: Text('/ session', style: TextStyle(color: Colors.white70, fontSize: 10))), const Spacer(), const Icon(Icons.verified_rounded, color: Color(0xFF9CE8D8))]), const SizedBox(height: 8), Text('${_selectedTier?.title ?? 'Experience tier'} · ${_selectedTier?.experienceLabel ?? ''}. Final confirmation is subject to a physiotherapist accepting your request.', style: const TextStyle(color: Color(0xFFD9DBF5), fontSize: 10, height: 1.45))]));

  String _weekday(int day) => const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][day - 1];
  String _month(int month) => const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];
}

class InstantBookingStatusScreen extends StatelessWidget {
  final String requestId;
  const InstantBookingStatusScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('booking_requests').doc(requestId);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: AppBar(backgroundColor: const Color(0xFFF5F6FB), elevation: 0, title: const Text('Finding your physiotherapist', style: TextStyle(color: Color(0xFF171D3B), fontSize: 16, fontWeight: FontWeight.w900)), iconTheme: const IconThemeData(color: Color(0xFF171D3B))),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: ref.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Unable to load request status.'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF5146D9)));
          final data = snapshot.data!.data();
          if (data == null) return const Center(child: Text('This request is no longer available.'));
          final status = (data['requestStatus'] ?? 'searching').toString();
          final bookingStatus = (data['bookingStatus'] ?? 'pendingLooking').toString();
          final assigned = (data['assignedPhysiotherapistName'] ?? data['physiotherapistName'] ?? '').toString();
          final isAssigned = status == 'assigned' || bookingStatus == 'confirmed' || assigned.isNotEmpty;
          final isExpired = status == 'expired' || bookingStatus == 'noPhysiotherapistFound';
          final isCancelled = status == 'cancelled' || bookingStatus == 'cancelled';
          return ListView(padding: const EdgeInsets.all(20), children: [
            const SizedBox(height: 28),
            Center(child: Container(width: 104, height: 104, decoration: BoxDecoration(color: isAssigned ? const Color(0xFFE5F8EF) : const Color(0xFFEEEDFF), shape: BoxShape.circle), child: Icon(isAssigned ? Icons.check_rounded : isExpired ? Icons.search_off_rounded : Icons.manage_search_rounded, size: 48, color: isAssigned ? const Color(0xFF168C63) : const Color(0xFF5146D9)))),
            const SizedBox(height: 24),
            Text(isAssigned ? 'Physiotherapist assigned!' : isExpired ? 'No match found yet' : isCancelled ? 'Request cancelled' : 'Looking for a physiotherapist', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF171D3B), fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 9),
            Text(isAssigned ? 'Your request has been accepted by $assigned.' : isExpired ? 'We could not find an available professional for this request. You can try another time.' : isCancelled ? 'This request has been cancelled.' : 'Your request is submitted. We are waiting for an eligible physiotherapist to accept it.', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF7D849B), fontSize: 12, height: 1.5)),
            const SizedBox(height: 24),
            _statusCard(data),
            const SizedBox(height: 16),
            if (!isAssigned && !isExpired && !isCancelled && status == 'searching')
              OutlinedButton.icon(onPressed: () async { await ref.update({'requestStatus': 'cancelled', 'bookingStatus': 'cancelled', 'updatedAt': FieldValue.serverTimestamp()}); }, icon: const Icon(Icons.close_rounded), label: const Text('Cancel request'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFB34B58), side: const BorderSide(color: Color(0xFFE7C7CC)), padding: const EdgeInsets.symmetric(vertical: 14))),
            const SizedBox(height: 12),
            Text('Request ID: $requestId', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF9AA1B2), fontSize: 9)),
          ]);
        },
      ),
    );
  }

  Widget _statusCard(Map<String, dynamic> data) {
    final date = data['appointmentDate'];
    final dateText = date is Timestamp ? '${date.toDate().day}/${date.toDate().month}/${date.toDate().year}' : '—';
    final price = data['totalAmount'] ?? data['baseSessionPrice'] ?? 0;
    return Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: const Color(0xFFE7E9F1)), boxShadow: [BoxShadow(color: const Color(0xFF202B50).withOpacity(.04), blurRadius: 16, offset: const Offset(0, 6))]), child: Column(children: [ _detail('Care type', (data['careModeLabel'] ?? data['serviceType'] ?? '—').toString()), _detail('Location', (data['locationShortName'] ?? data['locationName'] ?? '—').toString()), _detail('Date & time', '$dateText · ${(data['appointmentTime'] ?? '—').toString()}'), _detail('Experience', (data['experienceTierLabel'] ?? '—').toString()), _detail('Estimated price', '₹${price.toString()}'), _detail('Status', (data['bookingStatus'] ?? 'pendingLooking').toString())]));
  }

  Widget _detail(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF7D849B), fontSize: 11))), Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF171D3B), fontSize: 11, fontWeight: FontWeight.w800)))]));
}
