import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Incoming instant-booking offers dispatched to this physiotherapist.
/// Offers are expected at physiotherapists/{uid}/booking_offers/{requestId}.
/// Each offer should contain requestId and a snapshot of the customer request.
class DoctorRequestsScreen extends StatefulWidget {
  const DoctorRequestsScreen({super.key});

  @override
  State<DoctorRequestsScreen> createState() => _DoctorRequestsScreenState();
}

class _DoctorRequestsScreenState extends State<DoctorRequestsScreen> {
  static const _bg = Color(0xFFF5F6FB);
  static const _ink = Color(0xFF171B3A);
  static const _muted = Color(0xFF8188A1);
  static const _purple = Color(0xFF5548D9);
  static const _teal = Color(0xFF159B80);
  static const _line = Color(0xFFE8EAF2);
  final _db = FirebaseFirestore.instance;
  final Set<String> _busy = {};

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  DocumentReference<Map<String, dynamic>> get _doctorRef => _db.collection('physiotherapists').doc(_uid);
  CollectionReference<Map<String, dynamic>> get _offers => _doctorRef.collection('booking_offers');

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) return const _signedOut();
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(19, 18, 19, 28),
              sliver: SliverList(delegate: SliverChildListDelegate([
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                    Text('INCOMING OPPORTUNITIES', style: TextStyle(color: _purple, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
                    SizedBox(height: 7),
                    Text('Booking requests', style: TextStyle(color: _ink, fontSize: 25, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -.8)),
                    SizedBox(height: 5),
                    Text('Review the patient’s needs and respond to offers.', style: TextStyle(color: _muted, fontSize: 11)),
                  ])),
                  Container(width: 45, height: 45, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _line)), child: const Icon(Icons.tune_rounded, color: _purple)),
                ]),
                const SizedBox(height: 20),
                _liveBanner(),
                const SizedBox(height: 19),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _offers.where('status', isEqualTo: 'pending').limit(30).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return _messageCard('We could not load your offers. Please check your connection and try again.', Icons.cloud_off_rounded);
                    if (!snapshot.hasData) return const _loadingCard();
                    final docs = snapshot.data!.docs.toList()..sort((a,b) => _asDate(b.data()['createdAt']).compareTo(_asDate(a.data()['createdAt'])));
                    if (docs.isEmpty) return _emptyState();
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [const Text('Available for you', style: TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w900)), const Spacer(), _countBadge('${docs.length} NEW')]),
                      const SizedBox(height: 12),
                      ...docs.asMap().entries.map((entry) => _offerCard(entry.value.id, entry.value.data(), entry.key)),
                    ]);
                  },
                ),
              ])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _liveBanner() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF201D58), Color(0xFF5548D9)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(21), boxShadow: [BoxShadow(color: _purple.withOpacity(.16), blurRadius: 20, offset: const Offset(0, 8))]),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(.13), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22)),
      const SizedBox(width: 11),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Instant care network', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('New requests appear here when they are matched to your profile.', style: TextStyle(color: Color(0xFFDAD9F8), fontSize: 9, height: 1.4))])),
      const Icon(Icons.wifi_tethering_rounded, color: Color(0xFF7DE6C2), size: 21),
    ]),
  );

  Widget _offerCard(String offerId, Map<String, dynamic> data, int index) {
    final patient = _str(data['patientName'] ?? data['customerName'], 'Patient');
    final mode = _str(data['careModeLabel'] ?? data['serviceType'], 'Physiotherapy');
    final modeKey = _str(data['careMode'] ?? data['serviceType']).toLowerCase();
    final package = _str(data['packageName'], _str(data['bookingType'], 'Single session'));
    final sessions = _int(data['totalSessions'], 1);
    final tier = _str(data['experienceTierLabel'], 'Experience tier not specified');
    final condition = _str(data['condition'], 'Not specified');
    final notes = _str(data['patientNotes']);
    final date = _asDate(data['appointmentDateTime'] ?? data['appointmentDate']);
    final time = _str(data['appointmentTime'], date.year > 2000 ? _time(date) : 'Time not specified');
    final address = _locationText(data, modeKey);
    final pricingSnapshot = data['pricingSnapshot'];
    final snapshotAmount = pricingSnapshot is Map ? pricingSnapshot['amount'] : null;
    final amount = _num(data['totalAmount'] ?? snapshotAmount ?? data['baseSessionPrice']);
    final distance = _str(data['distanceLabel'], _num(data['distanceKm']) > 0 ? '${_num(data['distanceKm']).toStringAsFixed(1)} km away' : '');
    final isBusy = _busy.contains(offerId);

    return TweenAnimationBuilder<double>(
      key: ValueKey(offerId), tween: Tween(begin: 0, end: 1), duration: Duration(milliseconds: 360 + (index.clamp(0, 5) * 65).toInt()), curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 13), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(23), border: Border.all(color: _line), boxShadow: [BoxShadow(color: _ink.withOpacity(.035), blurRadius: 18, offset: const Offset(0, 7))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 45, height: 45, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFEDEBFF), Color(0xFFF5F3FF)]), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.person_rounded, color: _purple, size: 23)),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(patient, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ink, fontSize: 14, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(_str(data['patientPhone'], 'Contact details after acceptance'), style: const TextStyle(color: _muted, fontSize: 10))])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(color: _teal, fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 3), const Text('OFFER VALUE', style: TextStyle(color: _muted, fontSize: 8, letterSpacing: .8, fontWeight: FontWeight.w800))]),
          ]),
          const SizedBox(height: 14),
          Wrap(spacing: 7, runSpacing: 7, children: [
            _tag(mode, Icons.medical_services_outlined, const Color(0xFFECEBFF), _purple),
            _tag(package, Icons.inventory_2_outlined, const Color(0xFFE6F7F2), _teal),
            if (distance.isNotEmpty) _tag(distance, Icons.near_me_outlined, const Color(0xFFFFF2E5), const Color(0xFFD78B37)),
          ]),
          const SizedBox(height: 15),
          _sectionLabel('PATIENT REQUIREMENT'),
          const SizedBox(height: 8),
          _detailRow(Icons.healing_outlined, 'Condition', condition),
          if (notes.isNotEmpty) ...[const SizedBox(height: 7), _detailRow(Icons.notes_rounded, 'Patient notes', notes)],
          const SizedBox(height: 13),
          _sectionLabel('SESSION DETAILS'),
          const SizedBox(height: 8),
          _detailRow(Icons.calendar_month_rounded, 'Date & time', '${date.year > 2000 ? _dateLabel(date) : 'Date not specified'} · $time'),
          const SizedBox(height: 7),
          _detailRow(Icons.workspace_premium_outlined, 'Preferred experience', tier),
          const SizedBox(height: 7),
          _detailRow(Icons.repeat_rounded, 'Package', '$package · $sessions ${sessions == 1 ? 'session' : 'sessions'}'),
          const SizedBox(height: 13),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF7F7FC), borderRadius: BorderRadius.circular(15)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.location_on_rounded, color: _purple, size: 17), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(modeKey == 'clinic' ? 'CLINIC / SELECTED AREA' : modeKey == 'online' ? 'ONLINE CONSULTATION' : 'PATIENT LOCATION', style: const TextStyle(color: _muted, fontSize: 8, letterSpacing: .8, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(address, style: const TextStyle(color: _ink, fontSize: 10, height: 1.4, fontWeight: FontWeight.w700))]))])),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: isBusy ? null : () => _respond(offerId, data, accept: false), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF8B91A6), side: const BorderSide(color: _line), padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))), child: isBusy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Reject', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)))),
            const SizedBox(width: 9),
            Expanded(flex: 2, child: ElevatedButton(onPressed: isBusy ? null : () => _respond(offerId, data, accept: true), style: ElevatedButton.styleFrom(backgroundColor: _purple, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_outline_rounded, size: 17), SizedBox(width: 7), Text('Accept booking', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))]))),
          ]),
        ]),
      ),
    );
  }

  Future<void> _respond(String offerId, Map<String, dynamic> offer, {required bool accept}) async {
    setState(() => _busy.add(offerId));
    try {
      final requestId = _str(offer['requestId'], offerId);
      final requestRef = _db.collection('booking_requests').doc(requestId);
      if (!accept) {
        await _offers.doc(offerId).update({'status': 'declined', 'respondedAt': FieldValue.serverTimestamp()});
        _toast('Request declined.');
        return;
      }
      await _db.runTransaction((tx) async {
        final requestSnap = await tx.get(requestRef);
        if (!requestSnap.exists) throw StateError('This booking request is no longer available.');
        final request = requestSnap.data() ?? <String, dynamic>{};
        final requestStatus = _str(request['requestStatus'], 'searching').toLowerCase();
        if (requestStatus != 'searching' || _str(request['assignedPhysiotherapistId']).isNotEmpty) throw StateError('Another physiotherapist has already accepted this request.');
        final doctorSnap = await tx.get(_doctorRef);
        final doctor = doctorSnap.data() ?? <String, dynamic>{};
        final verified = doctor['isVerified'] == true || _str(doctor['verificationStatus']).toLowerCase() == 'approved';
        if (!verified || doctor['isActive'] == false || doctor['isOnline'] != true) throw StateError('Your profile must be verified, active and online to accept bookings.');
        tx.update(requestRef, {'requestStatus': 'assigned', 'bookingStatus': 'confirmed', 'assignmentStatus': 'assigned', 'assignedPhysiotherapistId': _uid, 'assignedPhysiotherapistName': _str(doctor['fullName'], 'Physiotherapist'), 'assignedAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
        tx.update(_offers.doc(offerId), {'status': 'accepted', 'respondedAt': FieldValue.serverTimestamp()});
      });
      _toast('Booking accepted successfully.');
    } on StateError catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast('Could not update this request. Please try again.');
    } finally {
      if (mounted) setState(() => _busy.remove(offerId));
    }
  }

  Widget _emptyState() => Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(22, 31, 22, 28), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(23), border: Border.all(color: _line)), child: Column(children: [Container(width: 66, height: 66, decoration: const BoxDecoration(color: Color(0xFFECEBFF), shape: BoxShape.circle), child: const Icon(Icons.inbox_rounded, color: _purple, size: 30)), const SizedBox(height: 14), const Text('You’re all caught up', style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 6), const Text('New patient requests matched to your profile will appear here. Keep your availability switched on to receive eligible offers.', textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 11, height: 1.55))]));
  Widget _messageCard(String message, IconData icon) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _line)), child: Row(children: [Icon(icon, color: _muted), const SizedBox(width: 10), Expanded(child: Text(message, style: const TextStyle(color: _muted, fontSize: 11)))]));
  Widget _loadingCard() => Container(height: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _line)), child: const Center(child: CircularProgressIndicator(color: _purple, strokeWidth: 2)));
  Widget _tag(String text, IconData icon, Color bg, Color fg) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: fg), const SizedBox(width: 5), Text(text, style: TextStyle(color: fg, fontSize: 9, fontWeight: FontWeight.w900))]));
  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(color: _muted, fontSize: 8, letterSpacing: 1.1, fontWeight: FontWeight.w900));
  Widget _detailRow(IconData icon, String label, String value) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: _muted, size: 14), const SizedBox(width: 8), SizedBox(width: 104, child: Text(label, style: const TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w600))), Expanded(child: Text(value, style: const TextStyle(color: _ink, fontSize: 10, fontWeight: FontWeight.w800)))]);
  Widget _countBadge(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFECEBFF), borderRadius: BorderRadius.circular(9)), child: Text(text, style: const TextStyle(color: _purple, fontSize: 8, letterSpacing: .5, fontWeight: FontWeight.w900)));
  String _locationText(Map<String, dynamic> d, String mode) {
    if (mode == 'online') return 'Online session. No travel required.';
    final parts = <String>[];
    final main = _str(d['address'] ?? d['locationName'] ?? d['locationShortName']);
    if (main.isNotEmpty) parts.add(main);
    for (final key in ['locality', 'city', 'state', 'pincode']) { final v = _str(d[key]); if (v.isNotEmpty && !parts.any((p) => p.contains(v))) parts.add(v); }
    if (mode == 'clinic') {
      final clinic = _str(d['clinicName']);
      if (clinic.isNotEmpty && !parts.contains(clinic)) parts.insert(0, clinic);
    }
    return parts.isEmpty ? 'Location details are not included in this offer.' : parts.join(', ');
  }
  DateTime _asDate(dynamic value) { if (value is Timestamp) return value.toDate(); if (value is DateTime) return value; if (value is String) return DateTime.tryParse(value) ?? DateTime(2000); return DateTime(2000); }
  String _str(dynamic v, [String fallback = '']) { final s = v?.toString().trim() ?? ''; return s.isEmpty || s == 'null' ? fallback : s; }
  double _num(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;
  int _int(dynamic v, int fallback) => v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? fallback;
  String _dateLabel(DateTime d) => '${const ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d.weekday - 1]}, ${d.day} ${const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.month - 1]}';
  String _time(DateTime d) { final h = d.hour % 12 == 0 ? 12 : d.hour % 12; return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'AM' : 'PM'}'; }
  void _toast(String message) { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, backgroundColor: _ink, margin: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))); }
  Widget _signedOut() => const Scaffold(backgroundColor: _bg, body: Center(child: Text('Please sign in to view booking requests.')));
}
