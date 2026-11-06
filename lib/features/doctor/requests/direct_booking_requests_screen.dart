import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Direct booking requests for the signed-in physiotherapist.
///
/// Reads only bookings assigned to the current physiotherapist from:
///   bookings/{bookingId}
///
/// A booking appears in New Requests after payment succeeds and the customer
/// booking flow sets bookingStatus = `pendingAcceptance`.
///
/// Accept/reject operations re-check the current owner and status in a
/// Firestore transaction before changing the booking.
class DirectBookingRequestsScreen extends StatefulWidget {
  const DirectBookingRequestsScreen({super.key});

  @override
  State<DirectBookingRequestsScreen> createState() =>
      _DirectBookingRequestsScreenState();
}

class _DirectBookingRequestsScreenState
    extends State<DirectBookingRequestsScreen>
    with TickerProviderStateMixin {
  static const Color _ink = Color(0xFF191A38);
  static const Color _muted = Color(0xFF8589A2);
  static const Color _purple = Color(0xFF5B4BE0);
  static const Color _purpleDark = Color(0xFF39318F);
  static const Color _bg = Color(0xFFF6F6FC);
  static const Color _line = Color(0xFFE9E9F2);
  static const Color _green = Color(0xFF159B79);
  static const Color _red = Color(0xFFD85D70);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final AnimationController _introController;
  int _selectedTab = 0;
  final Set<String> _busyIds = <String>{};

  String get _uid => _auth.currentUser?.uid ?? '';
  CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection('bookings');

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) return const _SignedOutRequests();

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const _AmbientBackground(),
          SafeArea(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              // Deliberately no bookingStatus filter here. We receive only this
              // doctor's assigned bookings, then categorize their statuses.
              stream: _bookings
                  .where('physiotherapistId', isEqualTo: _uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _errorState(snapshot.error.toString());
                }
                if (!snapshot.hasData) return _loadingState();

                final docs = snapshot.data!.docs.toList()
                  ..sort((a, b) => _createdAt(b.data()).compareTo(_createdAt(a.data())));
                final pending = docs.where((d) => _status(d.data()) == 'pendingacceptance').toList();
                final accepted = docs.where((d) => _status(d.data()) == 'confirmed').toList();
                final history = docs.where((d) => const {
                  'rejected', 'cancelled', 'completed', 'physiotherapistontheway',
                  'arrived', 'inprogress',
                }.contains(_status(d.data()))).toList();
                final selected = [_sortForDate(pending), _sortForDate(accepted), _sortForDate(history)][_selectedTab];

                return RefreshIndicator(
                  color: _purple,
                  onRefresh: () async {
                    await _bookings.where('physiotherapistId', isEqualTo: _uid)
                        .get(const GetOptions(source: Source.server));
                  },
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(19, 13, 19, 34),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildTopBar(),
                            const SizedBox(height: 22),
                            _buildHero(pending.length, accepted.length),
                            const SizedBox(height: 22),
                            _buildSummary(pending.length, accepted.length, history.length),
                            const SizedBox(height: 25),
                            _buildSectionHeader(),
                            const SizedBox(height: 14),
                            _buildTabs(pending.length, accepted.length),
                            const SizedBox(height: 15),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) => FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(begin: const Offset(.035, 0), end: Offset.zero).animate(animation),
                                  child: child,
                                ),
                              ),
                              child: selected.isEmpty
                                  ? _emptyState(key: ValueKey('empty-$_selectedTab'))
                                  : Column(
                                      key: ValueKey('list-$_selectedTab-${selected.length}'),
                                      children: [
                                        for (var i = 0; i < selected.length; i++)
                                          _animatedCard(selected[i], i),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 15),
                            _buildSafetyNote(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() => _entrance(
        0,
        Row(
          children: [
            _iconButton(Icons.arrow_back_rounded, () => Navigator.maybePop(context)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('PATIENT MANAGEMENT', style: TextStyle(color: _muted, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Booking requests', style: TextStyle(color: _ink, fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: -.7)),
              ]),
            ),
            _iconButton(Icons.tune_rounded, _showInfo),
          ],
        ),
      );

  Widget _buildHero(int pending, int accepted) => _entrance(
        1,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(19, 20, 19, 19),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_purpleDark, Color(0xFF5146C7), Color(0xFF7968F2)],
            ),
            boxShadow: [BoxShadow(color: _purple.withOpacity(.22), blurRadius: 25, offset: const Offset(0, 12))],
          ),
          child: Stack(
            children: [
              Positioned(right: -20, top: -32, child: Container(width: 142, height: 142,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(.09), width: 24)))),
              Positioned(right: 28, bottom: -48, child: Container(width: 100, height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.045)))),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 35, height: 35, decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 18)),
                  const SizedBox(width: 9),
                  const Text('YOUR PRACTICE', style: TextStyle(color: Color(0xFFE1DEFF), fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.13), borderRadius: BorderRadius.circular(30)),
                    child: const Row(children: [Icon(Icons.lock_person_outlined, color: Colors.white, size: 12), SizedBox(width: 5),
                      Text('PRIVATE REQUESTS', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .5))])),
                ]),
                const SizedBox(height: 18),
                const Text('Patients who chose\nyou, specifically.', style: TextStyle(color: Colors.white, fontSize: 25, height: 1.12, fontWeight: FontWeight.w900, letterSpacing: -.8)),
                const SizedBox(height: 9),
                const Text('Review their appointment details and respond to each direct booking.',
                  style: TextStyle(color: Color(0xFFE1DEFF), fontSize: 10, height: 1.5, fontWeight: FontWeight.w500)),
                const SizedBox(height: 18),
                Row(children: [
                  _heroMetric('$pending', 'Awaiting response'),
                  Container(width: 1, height: 30, color: Colors.white.withOpacity(.2), margin: const EdgeInsets.symmetric(horizontal: 18)),
                  _heroMetric('$accepted', 'Accepted bookings'),
                ]),
              ]),
            ],
          ),
        ),
      );

  Widget _heroMetric(String value, String label) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -.5)),
    const SizedBox(height: 2), Text(label, style: const TextStyle(color: Color(0xFFDAD7FF), fontSize: 9, fontWeight: FontWeight.w600)),
  ]);

  Widget _buildSummary(int pending, int accepted, int history) => _entrance(
        2,
        Row(children: [
          Expanded(child: _summaryTile('New', '$pending', Icons.mark_email_unread_outlined, const Color(0xFFFFF1E5), const Color(0xFFE58A35))),
          const SizedBox(width: 9),
          Expanded(child: _summaryTile('Accepted', '$accepted', Icons.event_available_rounded, const Color(0xFFE5F7F1), _green)),
          const SizedBox(width: 9),
          Expanded(child: _summaryTile('Past', '$history', Icons.history_rounded, const Color(0xFFECEBFF), _purple)),
        ]),
      );

  Widget _summaryTile(String label, String value, IconData icon, Color tint, Color accent) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: _line)),
        child: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: accent, size: 16)),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w900)),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 8, fontWeight: FontWeight.w700)),
          ])),
        ]),
      );

  Widget _buildSectionHeader() => _entrance(3, const Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Your requests', style: TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -.4)),
      SizedBox(height: 3), Text('Only bookings assigned to your profile appear here.', style: TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w500)),
    ])),
    Icon(Icons.shield_outlined, color: _green, size: 19),
  ]));

  Widget _buildTabs(int pending, int accepted) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: const Color(0xFFEDEDF6), borderRadius: BorderRadius.circular(15)),
        child: Row(children: [
          _tab('New', 0, pending), _tab('Accepted', 1, accepted), _tab('History', 2, null),
        ]),
      );

  Widget _tab(String label, int index, int? count) {
    final active = _selectedTab == index;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240), curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 5),
        decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(11),
          boxShadow: active ? [BoxShadow(color: _ink.withOpacity(.07), blurRadius: 9, offset: const Offset(0, 3))] : []),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, style: TextStyle(color: active ? _ink : _muted, fontSize: 10, fontWeight: FontWeight.w900)),
          if (count != null) ...[const SizedBox(width: 5), AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(color: active ? const Color(0xFFECEBFF) : const Color(0xFFE2E3ED), borderRadius: BorderRadius.circular(20)),
            child: Text('$count', style: TextStyle(color: active ? _purple : _muted, fontSize: 8, fontWeight: FontWeight.w900)))],
        ]),
      ),
    ));
  }

  Widget _animatedCard(QueryDocumentSnapshot<Map<String, dynamic>> doc, int index) {
    final data = doc.data();
    final status = _status(data);
    final isPending = status == 'pendingacceptance';
    final isBusy = _busyIds.contains(doc.id);
    return TweenAnimationBuilder<double>(
      key: ValueKey(doc.id), tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + (index.clamp(0, 5) * 75)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(opacity: value,
        child: Transform.translate(offset: Offset(0, 17 * (1 - value)), child: child)),
      child: _bookingCard(doc.id, data, status, isPending, isBusy),
    );
  }

  Widget _bookingCard(String id, Map<String, dynamic> data, String status, bool isPending, bool isBusy) {
    final name = _text(data['patientName'], 'Patient');
    final date = _asDate(data['appointmentDate']);
    final time = _text(data['appointmentTime'], 'Time not specified');
    final service = _text(data['serviceType'], _text(data['bookingType'], 'Physiotherapy session'));
    final package = _text(data['packageName'], 'Single session');
    final amount = _money(data['totalAmount']);
    final address = _text(data['address'], 'Address not provided');
    final phone = _text(data['patientPhone'], 'Not provided');
    final email = _text(data['patientEmail'], 'Not provided');
    final sessions = _integer(data['totalSessions'], 1);
    final notes = _text(data['patientNotes'], 'No additional notes from the patient.');

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: _line),
        boxShadow: [BoxShadow(color: _ink.withOpacity(.035), blurRadius: 18, offset: const Offset(0, 7))]),
      child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(15, 15, 15, 13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _patientAvatar(data), const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ink, fontSize: 14, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4), Text('Booking ID  •  ${id.length > 12 ? id.substring(0, 12) : id}', style: const TextStyle(color: _muted, fontSize: 8, fontWeight: FontWeight.w600)),
            ])),
            _statusPill(status),
          ]),
          const SizedBox(height: 15),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF7F7FC), borderRadius: BorderRadius.circular(15)),
            child: Row(children: [
              Expanded(child: _detailCell(Icons.calendar_month_rounded, 'DATE', date == null ? 'Not specified' : _dateLabel(date))),
              Container(width: 1, height: 31, color: _line, margin: const EdgeInsets.symmetric(horizontal: 9)),
              Expanded(child: _detailCell(Icons.schedule_rounded, 'TIME', time)),
            ])),
          const SizedBox(height: 13),
          Row(children: [
            Expanded(child: _iconLine(Icons.medical_services_outlined, service)),
            const SizedBox(width: 8),
            Text(amount, style: const TextStyle(color: _purple, fontSize: 16, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 9),
          _iconLine(Icons.inventory_2_outlined, '$package  •  $sessions ${sessions == 1 ? 'session' : 'sessions'}'),
          const SizedBox(height: 8),
          _iconLine(Icons.location_on_outlined, address, maxLines: 2),
          const SizedBox(height: 12),
          InkWell(onTap: () => _showBookingDetails(name, phone, email, address, notes, package, sessions, amount),
            borderRadius: BorderRadius.circular(10), child: const Padding(padding: EdgeInsets.symmetric(vertical: 5), child: Row(children: [
              Text('View patient & booking details', style: TextStyle(color: _purple, fontSize: 10, fontWeight: FontWeight.w900)),
              SizedBox(width: 5), Icon(Icons.arrow_forward_rounded, color: _purple, size: 14),
            ]))),
        ])),
        if (isPending) ...[
          Container(height: 1, color: _line),
          Padding(padding: const EdgeInsets.all(13), child: Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: isBusy ? null : () => _confirmReject(id),
              style: OutlinedButton.styleFrom(foregroundColor: _red, side: BorderSide(color: _red.withOpacity(.25)), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Decline', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
            )),
            const SizedBox(width: 9),
            Expanded(flex: 2, child: ElevatedButton(
              onPressed: isBusy ? null : () => _accept(id),
              style: ElevatedButton.styleFrom(backgroundColor: _purple, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: isBusy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_rounded, size: 16), SizedBox(width: 6), Text('Accept booking', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))]),
            )),
          ])),
        ] else if (status == 'confirmed') ...[
          Container(height: 1, color: _line),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), child: Row(children: [
            const Icon(Icons.check_circle_rounded, color: _green, size: 16), const SizedBox(width: 7),
            const Expanded(child: Text('You have accepted this booking.', style: TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w800))),
          ])),
        ],
      ]),
    );
  }

  Widget _patientAvatar(Map<String, dynamic> data) {
    final url = _text(data['patientPhotoUrl'] ?? data['profileImageUrl'], '');
    return Container(width: 47, height: 47, decoration: BoxDecoration(color: const Color(0xFFECEBFF), borderRadius: BorderRadius.circular(16)), clipBehavior: Clip.antiAlias,
      child: url.isEmpty ? const Icon(Icons.person_rounded, color: _purple, size: 25)
          : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, color: _purple, size: 25)));
  }

  Widget _detailCell(IconData icon, String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Icon(icon, size: 12, color: _purple), const SizedBox(width: 5), Text(label, style: const TextStyle(color: _muted, fontSize: 8, letterSpacing: .8, fontWeight: FontWeight.w900))]),
    const SizedBox(height: 5), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ink, fontSize: 10, fontWeight: FontWeight.w900)),
  ]);

  Widget _iconLine(IconData icon, String value, {int maxLines = 1}) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 14, color: _muted), const SizedBox(width: 7), Expanded(child: Text(value, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 9, height: 1.4, fontWeight: FontWeight.w600))),
  ]);

  Widget _statusPill(String status) {
    final pending = status == 'pendingacceptance';
    final accepted = status == 'confirmed';
    final color = pending ? const Color(0xFFE18A35) : accepted ? _green : _muted;
    final bg = pending ? const Color(0xFFFFF2E5) : accepted ? const Color(0xFFE5F7F1) : const Color(0xFFF0F0F6);
    final label = pending ? 'NEW REQUEST' : accepted ? 'ACCEPTED' : _pretty(status).toUpperCase();
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
      child: Text(label, style: TextStyle(color: color, fontSize: 7, letterSpacing: .45, fontWeight: FontWeight.w900)));
  }

  Widget _emptyState({Key? key}) {
    final title = ['All caught up!', 'No accepted bookings yet', 'Nothing in your history'][_selectedTab];
    final body = [
      'When a patient books you directly and completes payment, their request will appear here.',
      'Bookings you accept will be listed here so you can quickly review them.',
      'Completed, declined and cancelled bookings will be available here.',
    ][_selectedTab];
    final icon = [Icons.mark_email_read_outlined, Icons.event_available_outlined, Icons.history_rounded][_selectedTab];
    return Container(key: key, width: double.infinity, padding: const EdgeInsets.fromLTRB(25, 30, 25, 30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(23), border: Border.all(color: _line)),
      child: Column(children: [
        Container(width: 76, height: 76, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFECEBFF)), child: Icon(icon, color: _purple, size: 32)),
        const SizedBox(height: 16), Text(title, style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 7), Text(body, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 10, height: 1.55)),
        if (_selectedTab == 0) ...[
          const SizedBox(height: 15), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFF4F3FF), borderRadius: BorderRadius.circular(30)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.bolt_rounded, color: _purple, size: 13), SizedBox(width: 5), Text('Waiting for direct bookings', style: TextStyle(color: _purple, fontSize: 9, fontWeight: FontWeight.w800))])),
        ],
      ]),
    );
  }

  Widget _buildSafetyNote() => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFEDEFFC).withOpacity(.75), borderRadius: BorderRadius.circular(15)),
    child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.shield_outlined, color: _purple, size: 16), SizedBox(width: 8),
      Expanded(child: Text('Direct bookings are private to the physiotherapist selected by the patient. These requests are separate from the instant-booking matching pool.', style: TextStyle(color: _muted, fontSize: 9, height: 1.5, fontWeight: FontWeight.w500))),
    ]));

  Future<void> _accept(String id) async {
    await _runDecision(id, accept: true);
  }

  Future<void> _confirmReject(String id) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Text('Decline this booking?', style: TextStyle(color: _ink, fontWeight: FontWeight.w900)),
      content: const Text('The booking will be marked as rejected. The patient will see the updated status.', style: TextStyle(color: _muted, fontSize: 12, height: 1.5)),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep request')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Decline booking', style: TextStyle(color: _red, fontWeight: FontWeight.w800)))],
    ));
    if (confirmed == true) await _runDecision(id, accept: false);
  }

  Future<void> _runDecision(String id, {required bool accept}) async {
    if (_busyIds.contains(id)) return;
    setState(() => _busyIds.add(id));
    try {
      final ref = _bookings.doc(id);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);
        if (!snapshot.exists) throw StateError('This booking is no longer available.');
        final data = snapshot.data() ?? <String, dynamic>{};
        if (_text(data['physiotherapistId'], '') != _uid) {
          throw StateError('This booking is not assigned to your account.');
        }
        if (_status(data) != 'pendingacceptance') {
          throw StateError('This request has already been updated.');
        }
        final now = FieldValue.serverTimestamp();
        transaction.update(ref, {
          'bookingStatus': accept ? 'confirmed' : 'rejected',
          if (accept) 'acceptedAt': now,
          if (!accept) 'rejectedAt': now,
          if (!accept) 'rejectionReason': 'Declined by physiotherapist',
          'updatedAt': now,
        });
      });
      if (mounted) _toast(accept ? 'Booking accepted successfully.' : 'Booking declined.');
    } on StateError catch (e) {
      if (mounted) _toast(e.message);
    } catch (e) {
      if (mounted) _toast('Unable to ${accept ? 'accept' : 'decline'} this booking. Please try again.');
    } finally {
      if (mounted) setState(() => _busyIds.remove(id));
    }
  }

  void _showBookingDetails(String name, String phone, String email, String address,
      String notes, String package, int sessions, String amount) {
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(21, 12, 21, MediaQuery.of(context).viewInsets.bottom + 25),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: SafeArea(top: false, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: _line, borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 19), const Text('Patient details', style: TextStyle(color: _ink, fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 15), _bottomDetail(Icons.person_outline_rounded, 'Patient', name),
          _bottomDetail(Icons.phone_outlined, 'Phone', phone), _bottomDetail(Icons.email_outlined, 'Email', email),
          _bottomDetail(Icons.location_on_outlined, 'Address', address), _bottomDetail(Icons.inventory_2_outlined, 'Package', '$package • $sessions sessions'),
          _bottomDetail(Icons.currency_rupee_rounded, 'Booking amount', amount), _bottomDetail(Icons.notes_rounded, 'Patient notes', notes),
          const SizedBox(height: 9), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: _purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
            child: const Text('Close details', style: TextStyle(fontWeight: FontWeight.w900)))),
        ])),
      ),
    );
  }

  Widget _bottomDetail(IconData icon, String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 13), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 31, height: 31, decoration: BoxDecoration(color: const Color(0xFFF1F0FF), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: _purple, size: 15)),
    const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(value, style: const TextStyle(color: _ink, fontSize: 11, fontWeight: FontWeight.w800))])),
  ]));

  Widget _loadingState() => const Center(child: CircularProgressIndicator(color: _purple, strokeWidth: 2.4));
  Widget _errorState(String error) => Center(child: Padding(padding: const EdgeInsets.all(25), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.cloud_off_rounded, color: _red, size: 35), const SizedBox(height: 12), const Text('Could not load booking requests', style: TextStyle(color: _ink, fontWeight: FontWeight.w900)),
    const SizedBox(height: 7), Text(error, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 10)),
  ])));

  Widget _entrance(int index, Widget child) => AnimatedBuilder(
    animation: _introController,
    builder: (context, _) {
      final start = (index * .12).clamp(0.0, .7);
      final t = ((_introController.value - start) / (1 - start)).clamp(0.0, 1.0);
      final curved = Curves.easeOutCubic.transform(t);
      return Opacity(opacity: curved, child: Transform.translate(offset: Offset(0, 17 * (1 - curved)), child: child));
    },
  );

  Widget _iconButton(IconData icon, VoidCallback onTap) => Material(
    color: Colors.white, borderRadius: BorderRadius.circular(14), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14),
      child: Container(width: 42, height: 42, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: _line)), child: Icon(icon, color: _ink, size: 19))));

  void _showInfo() => showDialog<void>(context: context, builder: (context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Text('Direct booking requests'),
    content: const Text('This screen shows bookings where the customer selected your physiotherapist profile. Instant booking requests are handled separately.'),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
  ));

  void _toast(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message), behavior: SnackBarBehavior.floating, backgroundColor: _ink,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)), margin: const EdgeInsets.all(14)));

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortForDate(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    docs.sort((a, b) => (_asDate(a.data()['appointmentDate']) ?? DateTime(2100))
        .compareTo(_asDate(b.data()['appointmentDate']) ?? DateTime(2100)));
    return docs;
  }

  String _status(Map<String, dynamic> data) => _text(data['bookingStatus'] ?? data['status'], 'pending').toLowerCase().replaceAll(' ', '').replaceAll('_', '');
  String _text(dynamic value, [String fallback = '']) { final s = value?.toString().trim() ?? ''; return s.isEmpty || s == 'null' ? fallback : s; }
  int _integer(dynamic value, int fallback) => value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
  DateTime _createdAt(Map<String, dynamic> data) => _asDate(data['createdAt']) ?? DateTime(2000);
  DateTime? _asDate(dynamic value) { if (value is Timestamp) return value.toDate(); if (value is DateTime) return value; if (value is String) return DateTime.tryParse(value); return null; }
  String _dateLabel(DateTime date) => '${const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1]}, ${date.day} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]}';
  String _money(dynamic value) { final amount = value is num ? value.toDouble() : double.tryParse('$value') ?? 0; return '₹${amount.toStringAsFixed(0)}'; }
  String _pretty(String value) => value.isEmpty ? 'Pending' : value[0].toUpperCase() + value.substring(1);
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();
  @override
  Widget build(BuildContext context) => Positioned.fill(child: IgnorePointer(child: Stack(children: [
    Positioned(top: -115, right: -75, child: _blurOrb(245, const Color(0xFFDBD8FF).withOpacity(.55))),
    Positioned(top: 360, left: -125, child: _blurOrb(210, const Color(0xFFE8E4FF).withOpacity(.45))),
  ])));
  Widget _blurOrb(double size, Color color) => ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 35, sigmaY: 35), child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color)));
}

class _SignedOutRequests extends StatelessWidget {
  const _SignedOutRequests();
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Color(0xFFF6F6FC), body: Center(child: Text('Please sign in to view your booking requests.')));
}
