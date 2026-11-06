import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Premium physiotherapist dashboard home screen.
///
/// Expected Firestore structure:
/// - physiotherapists/{auth.uid}: existing PhysiotherapistModel fields + isOnline
/// - physiotherapists/{auth.uid}/booking_offers/{requestId}: requestId,
///   status: pending|accepted|declined, createdAt, patientName, careModeLabel,
///   appointmentDate, appointmentTime, locationShortName, totalAmount,
///   experienceTierLabel
/// - bookings/{bookingId}: physiotherapistId (or doctorId), patientName,
///   bookingStatus/status, appointmentDate, appointmentTime, careModeLabel,
///   locationShortName, totalAmount
///
/// The screen deliberately reads offers from the provider's own subcollection;
/// do not expose the entire booking_requests collection to every provider.
class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  static const _bg = Color(0xFFF5F6FB);
  static const _ink = Color(0xFF171B3A);
  static const _muted = Color(0xFF8188A1);
  static const _purple = Color(0xFF5548D9);
  static const _teal = Color(0xFF1CA58B);
  static const _line = Color(0xFFE8EAF2);

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  bool _availabilityBusy = false;

  String get _uid => _auth.currentUser?.uid ?? '';
  DocumentReference<Map<String, dynamic>> get _doctorRef =>
      _db.collection('physiotherapists').doc(_uid);
  CollectionReference<Map<String, dynamic>> get _offersRef =>
      _doctorRef.collection('booking_offers');

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) return const _SignedOutView();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _doctorRef.snapshots(),
          builder: (context, profileSnapshot) {
            final profile = profileSnapshot.data?.data() ?? <String, dynamic>{};
            final name = _str(profile['fullName'], fallback: 'Doctor');
            final image = _str(profile['profileImageUrl']);
            final online = profile['isOnline'] == true;
            final verified = profile['isVerified'] == true ||
                _str(profile['verificationStatus']).toLowerCase() == 'approved';

            return RefreshIndicator(
              color: _purple,
              onRefresh: () async {
                await _doctorRef.get(const GetOptions(source: Source.server));
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 15, 18, 30),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _topBar(name: name, image: image, verified: verified),
                        const SizedBox(height: 21),
                        _availabilityCard(online: online, verified: verified),
                        const SizedBox(height: 21),
                        _sectionHeading('Your practice today', 'A quick view of your activity'),
                        const SizedBox(height: 12),
                        _todayStats(),
                        const SizedBox(height: 25),
                        _sectionHeading('Instant booking requests', 'Requests offered to your account'),
                        const SizedBox(height: 12),
                        _instantRequests(),
                        const SizedBox(height: 25),
                        _sectionHeading("Today's schedule", 'Your upcoming patient sessions'),
                        const SizedBox(height: 12),
                        _todaySchedule(),
                        const SizedBox(height: 25),
                        _sectionHeading('Quick access', 'Manage your practice'),
                        const SizedBox(height: 12),
                        _quickActions(context),
                        const SizedBox(height: 25),
                        _professionalCard(profile, verified),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _topBar({required String name, required String image, required bool verified}) {
    final first = name.trim().isEmpty ? 'Doctor' : name.trim().split(RegExp(r'\s+')).first;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    return Row(children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(color: const Color(0xFFE8E7FF), borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: image.isNotEmpty
            ? Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, color: _purple, size: 28))
            : const Icon(Icons.person_rounded, color: _purple, size: 28),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$greeting, $first', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(children: [
          Flexible(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -.4))),
          if (verified) ...[const SizedBox(width: 5), const Icon(Icons.verified_rounded, color: _teal, size: 16)],
        ]),
        const SizedBox(height: 2),
        const Text('Physiotherapist workspace', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w500)),
      ])),
      _roundIcon(Icons.notifications_none_rounded, onTap: () => _message('Notifications screen can be connected next.')),
      const SizedBox(width: 8),
      _roundIcon(Icons.more_horiz_rounded, onTap: () => _message('Account actions can be connected next.')),
    ]);
  }

  Widget _availabilityCard({required bool online, required bool verified}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF171B49), Color(0xFF39358E), Color(0xFF594DDB)]),
        boxShadow: [BoxShadow(color: _purple.withOpacity(.20), blurRadius: 24, offset: const Offset(0, 11))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('YOUR AVAILABILITY', style: TextStyle(color: Color(0xFFCFD0FF), fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w900))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(30)),
            child: Row(children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: online ? const Color(0xFF67E4B8) : const Color(0xFFFFC46B), shape: BoxShape.circle)), const SizedBox(width: 6),
              Text(online ? 'ONLINE' : 'OFFLINE', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .7))]),
          ),
        ]),
        const SizedBox(height: 14),
        Text(online ? 'You are open for\nnew patients.' : 'Ready to see\nnew patients?',
          style: const TextStyle(color: Colors.white, fontSize: 25, height: 1.08, fontWeight: FontWeight.w900, letterSpacing: -.8)),
        const SizedBox(height: 8),
        Text(online ? 'You may receive eligible instant booking offers.' : 'Turn on availability when you are ready to receive requests.',
          style: const TextStyle(color: Color(0xFFDADAF4), fontSize: 11, height: 1.45)),
        const SizedBox(height: 17),
        SizedBox(width: double.infinity, height: 48,
          child: ElevatedButton(
            onPressed: _availabilityBusy ? null : () => _setAvailability(!online, verified),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _purple, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: _availabilityBusy
                ? const SizedBox(width: 19, height: 19, child: CircularProgressIndicator(strokeWidth: 2, color: _purple))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(online ? Icons.pause_circle_outline_rounded : Icons.bolt_rounded, size: 19), const SizedBox(width: 8),
                    Text(online ? 'Go offline' : 'Go online', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  ]),
          ),
        ),
        if (!verified) ...[
          const SizedBox(height: 10),
          const Row(children: [Icon(Icons.info_outline_rounded, color: Color(0xFFFFD38A), size: 14), SizedBox(width: 6),
            Expanded(child: Text('Your profile is not verified yet. Complete verification to receive patient requests.', style: TextStyle(color: Color(0xFFFFE3B5), fontSize: 10, height: 1.4))) ]),
        ],
      ]),
    );
  }

  Future<void> _setAvailability(bool value, bool verified) async {
    if (!verified && value) {
      _message('Your profile must be verified before going online.');
      return;
    }
    setState(() => _availabilityBusy = true);
    try {
      await _doctorRef.set({'isOnline': value, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      _message(value ? 'You are now online.' : 'You are now offline.');
    } catch (e) {
      _message('Could not update availability. Please try again.');
    } finally {
      if (mounted) setState(() => _availabilityBusy = false);
    }
  }

  Widget _todayStats() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('bookings').where('physiotherapistId', isEqualTo: _uid).limit(100).snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final today = DateTime.now();
        final todayDocs = docs.where((d) => _sameDay(_date(d.data()['appointmentDate']), today)).toList();
        final completed = todayDocs.where((d) => _status(d.data()) == 'completed').length;
        final pending = todayDocs.where((d) => !{'completed', 'cancelled', 'rejected'}.contains(_status(d.data()))).length;
        final earnings = todayDocs.where((d) => _status(d.data()) == 'completed').fold<double>(0, (sum, d) => sum + _num(d.data()['totalAmount'] ?? d.data()['amount']));
        return Column(children: [
          Row(children: [
            Expanded(child: _statTile('Appointments', '${todayDocs.length}', Icons.calendar_month_rounded, const Color(0xFFECEBFF), _purple)),
            const SizedBox(width: 9),
            Expanded(child: _statTile('To attend', '$pending', Icons.access_time_rounded, const Color(0xFFFFF2E5), const Color(0xFFE58B35))),
            const SizedBox(width: 9),
            Expanded(child: _statTile('Completed', '$completed', Icons.check_circle_outline_rounded, const Color(0xFFE5F7F1), _teal)),
          ]),
          const SizedBox(height: 9),
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: _line)),
            child: Row(children: [
              Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFFE5F7F1), borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.currency_rupee_rounded, color: _teal, size: 18)),
              const SizedBox(width: 10),
              const Expanded(child: Text("Today's completed-session earnings", style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700))),
              Text('₹${earnings.toStringAsFixed(0)}', style: const TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w900)),
            ]),
          ),
        ]);
      },
    );
  }

  Widget _statTile(String title, String value, IconData icon, Color tint, Color accent) => Container(
    padding: const EdgeInsets.fromLTRB(11, 13, 8, 13),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 31, height: 31, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: accent, size: 17)),
      const SizedBox(height: 12), Text(value, style: const TextStyle(color: _ink, fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: -.7)),
      const SizedBox(height: 2), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w700)),
    ]),
  );

  Widget _instantRequests() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _offersRef.where('status', isEqualTo: 'pending').limit(10).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _emptyCard('Requests are temporarily unavailable.', Icons.cloud_off_rounded);
        if (!snapshot.hasData) return const _LoadingCard();
        final requests = snapshot.data!.docs.toList();
        requests.sort((a, b) => _date(b.data()['createdAt']).compareTo(_date(a.data()['createdAt'])));
        if (requests.isEmpty) return _emptyCard('No new requests right now. Keep your availability updated and we will show offers here.', Icons.inbox_outlined);
        return Column(children: requests.map((doc) => _requestCard(doc.id, doc.data())).toList());
      },
    );
  }

  Widget _requestCard(String id, Map<String, dynamic> data) {
    final patient = _str(data['patientName'] ?? data['customerName'], fallback: 'Patient');
    final mode = _str(data['careModeLabel'] ?? data['serviceType'], fallback: 'Physiotherapy session');
    final date = _date(data['appointmentDate']);
    final time = _str(data['appointmentTime'], fallback: 'Time to be confirmed');
    final place = _str(data['locationShortName'] ?? data['locationName'], fallback: 'Location details available after opening');
    final amount = _num(data['totalAmount'] ?? data['baseSessionPrice']);
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _line),
        boxShadow: [BoxShadow(color: _ink.withOpacity(.025), blurRadius: 14, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFECEBFF), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.person_outline_rounded, color: _purple)),
          const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(patient, style: const TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3), Text(mode, style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w600)),
          ])),
          if (amount > 0) Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(color: _teal, fontSize: 14, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 13),
        _requestInfo(Icons.calendar_today_rounded, date.year > 2000 ? _dateLabel(date) : 'Date not specified'),
        const SizedBox(height: 7), _requestInfo(Icons.schedule_rounded, time),
        const SizedBox(height: 7), _requestInfo(Icons.location_on_outlined, place),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => _declineOffer(id), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF8B91A6), side: const BorderSide(color: _line), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)))),
          const SizedBox(width: 9),
          Expanded(child: ElevatedButton(onPressed: () => _acceptOffer(id, data), style: ElevatedButton.styleFrom(backgroundColor: _purple, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Accept request', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)))),
        ]),
      ]),
    );
  }

  Widget _requestInfo(IconData icon, String text) => Row(children: [Icon(icon, size: 14, color: _muted), const SizedBox(width: 7), Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w600)))]);

  Future<void> _acceptOffer(String offerId, Map<String, dynamic> offer) async {
    final requestId = _str(offer['requestId'], fallback: offerId);
    final requestRef = _db.collection('booking_requests').doc(requestId);
    try {
      await _db.runTransaction((transaction) async {
        final requestSnap = await transaction.get(requestRef);
        if (!requestSnap.exists) throw StateError('This request is no longer available.');
        final request = requestSnap.data() ?? <String, dynamic>{};
        final status = _str(request['requestStatus'], fallback: 'searching').toLowerCase();
        final assigned = _str(request['assignedPhysiotherapistId']);
        if (status != 'searching' || assigned.isNotEmpty) {
          throw StateError('Another physiotherapist has already accepted this request.');
        }
        final profileSnap = await transaction.get(_doctorRef);
        final profile = profileSnap.data() ?? <String, dynamic>{};
        if (profile['isVerified'] != true || profile['isOnline'] != true) {
          throw StateError('You must be verified and online to accept requests.');
        }
        transaction.update(requestRef, {
          'requestStatus': 'assigned',
          'bookingStatus': 'confirmed',
          'assignmentStatus': 'assigned',
          'assignedPhysiotherapistId': _uid,
          'assignedPhysiotherapistName': _str(profile['fullName'], fallback: 'Physiotherapist'),
          'assignedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(_offersRef.doc(offerId), {'status': 'accepted', 'respondedAt': FieldValue.serverTimestamp()});
      });
      _message('Request accepted.');
    } on StateError catch (e) {
      _message(e.message);
    } catch (e) {
      _message('Could not accept this request. Please try again.');
    }
  }

  Future<void> _declineOffer(String offerId) async {
    try {
      await _offersRef.doc(offerId).update({'status': 'declined', 'respondedAt': FieldValue.serverTimestamp()});
      _message('Request declined.');
    } catch (e) {
      _message('Could not decline this request.');
    }
  }

  Widget _todaySchedule() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('bookings').where('physiotherapistId', isEqualTo: _uid).limit(100).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _emptyCard('Unable to load your schedule.', Icons.event_busy_rounded);
        if (!snapshot.hasData) return const _LoadingCard();
        final now = DateTime.now();
        final items = snapshot.data!.docs.where((doc) {
          final d = doc.data();
          final date = _date(d['appointmentDate']);
          final status = _status(d);
          return _sameDay(date, now) && !{'cancelled', 'rejected', 'completed'}.contains(status);
        }).toList();
        items.sort((a, b) => _date(a.data()['appointmentDate']).compareTo(_date(b.data()['appointmentDate'])));
        if (items.isEmpty) return _emptyCard('Your schedule is clear for today. New confirmed sessions will appear here.', Icons.calendar_month_rounded);
        return Column(children: items.take(5).map((doc) => _appointmentTile(doc.data())).toList());
      },
    );
  }

  Widget _appointmentTile(Map<String, dynamic> data) {
    final patient = _str(data['patientName'] ?? data['customerName'], fallback: 'Patient');
    final time = _str(data['appointmentTime'] ?? data['time'], fallback: 'Time pending');
    final mode = _str(data['careModeLabel'] ?? data['serviceType'], fallback: 'Session');
    final status = _status(data);
    return Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: _line)),
      child: Row(children: [
        Container(width: 45, height: 48, decoration: BoxDecoration(color: const Color(0xFFECEBFF), borderRadius: BorderRadius.circular(13)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.schedule_rounded, color: _purple, size: 16), const SizedBox(height: 3), Text(time, maxLines: 1, style: const TextStyle(color: _purple, fontSize: 8, fontWeight: FontWeight.w900))])),
        const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(patient, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4), Text(mode, style: const TextStyle(color: _muted, fontSize: 10)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: _statusTint(status), borderRadius: BorderRadius.circular(9)),
          child: Text(_pretty(status), style: TextStyle(color: _statusColor(status), fontSize: 8, fontWeight: FontWeight.w900))),
      ]),
    );
  }

  Widget _quickActions(BuildContext context) => GridView.count(
    crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 8, childAspectRatio: .82,
    children: [
      _quick('Appointments', Icons.calendar_month_rounded, const Color(0xFFECEBFF), _purple, () => _message('Connect your appointments screen here.')),
      _quick('Patients', Icons.people_alt_outlined, const Color(0xFFE5F7F1), _teal, () => _message('Connect your patient list here.')),
      _quick('Earnings', Icons.account_balance_wallet_outlined, const Color(0xFFFFF2E5), const Color(0xFFE58B35), () => _message('Connect your earnings screen here.')),
      _quick('Profile', Icons.person_outline_rounded, const Color(0xFFFFEDEF), const Color(0xFFD75A72), () => _message('Connect your doctor profile screen here.')),
    ],
  );

  Widget _quick(String title, IconData icon, Color tint, Color color, VoidCallback onTap) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(16), child: Column(children: [
      Container(width: 53, height: 53, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: _line)),
        child: Center(child: Container(width: 36, height: 36, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 19)))),
      const SizedBox(height: 7), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ink, fontSize: 9, fontWeight: FontWeight.w800)),
    ]));

  Widget _professionalCard(Map<String, dynamic> profile, bool verified) {
    final specialty = _str(profile['primarySpecialization'] ?? profile['professionalTitle'], fallback: 'Physiotherapy');
    final experience = _num(profile['experienceYears']).toInt();
    final city = _str(profile['city']);
    final rating = _num(profile['rating']);
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Expanded(child: Text('Professional profile', style: TextStyle(color: _ink, fontSize: 14, fontWeight: FontWeight.w900))),
          Text(verified ? 'Verified' : 'Verification pending', style: TextStyle(color: verified ? _teal : const Color(0xFFE58B35), fontSize: 9, fontWeight: FontWeight.w900))]),
        const SizedBox(height: 12), Text(specialty, style: const TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 9), Wrap(spacing: 15, runSpacing: 8, children: [
          _profileMeta(Icons.workspace_premium_outlined, '$experience yrs experience'),
          if (city.isNotEmpty) _profileMeta(Icons.location_on_outlined, city),
          if (rating > 0) _profileMeta(Icons.star_rounded, rating.toStringAsFixed(1)),
        ]),
      ]));
  }

  Widget _profileMeta(IconData icon, String label) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 13, color: _muted), const SizedBox(width: 5), Text(label, style: const TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w600))]);

  Widget _sectionHeading(String title, String subtitle) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -.35)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w500))])),
  ]);

  Widget _emptyCard(String message, IconData icon) => Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _line)),
    child: Column(children: [Icon(icon, color: const Color(0xFFB2B7C7), size: 27), const SizedBox(height: 9), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 10, height: 1.5))]));

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating,
      backgroundColor: _ink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)), margin: const EdgeInsets.all(14)));
  }

  Widget _roundIcon(IconData icon, {required VoidCallback onTap}) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14),
    child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _line)), child: Icon(icon, color: _ink, size: 20)));

  bool _sameDay(DateTime date, DateTime other) => date.year == other.year && date.month == other.month && date.day == other.day;
  DateTime _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime(2000);
    return DateTime(2000);
  }
  double _num(dynamic value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;
  String _str(dynamic value, {String fallback = ''}) { final s = value?.toString().trim() ?? ''; return s.isEmpty || s == 'null' ? fallback : s; }
  String _status(Map<String, dynamic> data) => _str(data['bookingStatus'] ?? data['status'], fallback: 'pending').toLowerCase().replaceAll(' ', '');
  String _dateLabel(DateTime d) => '${_weekday(d.weekday)}, ${d.day} ${_month(d.month)}';
  String _weekday(int n) => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][n - 1];
  String _month(int n) => const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][n - 1];
  String _pretty(String value) => value.isEmpty ? 'Pending' : value[0].toUpperCase() + value.substring(1);
  Color _statusColor(String s) => s == 'confirmed' ? _teal : s == 'pending' ? const Color(0xFFE58B35) : _muted;
  Color _statusTint(String s) => s == 'confirmed' ? const Color(0xFFE5F7F1) : s == 'pending' ? const Color(0xFFFFF2E5) : const Color(0xFFF0F1F6);
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) => Container(height: 105, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE8EAF2))), child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5548D9))));
}

class _SignedOutView extends StatelessWidget {
  const _SignedOutView();
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Color(0xFFF5F6FB), body: Center(child: Text('Please sign in to open your doctor dashboard.')));
}
