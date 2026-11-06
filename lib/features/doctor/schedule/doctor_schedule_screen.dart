import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Doctor's live daily schedule.
///
/// Reads direct bookings from `bookings` where physiotherapistId is the
/// authenticated doctor's UID. The selected day defaults to today.
class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  static const Color purple = Color(0xFF5548D9);
  static const Color ink = Color(0xFF171B3A);
  static const Color muted = Color(0xFF858BA2);
  static const Color line = Color(0xFFE9EAF2);
  static const Color canvas = Color(0xFFF5F6FB);

  DateTime _selectedDay = _day(DateTime.now());
  int _filter = 0;

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> _scheduleStream() {
    if (_uid.isEmpty) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('physiotherapistId', isEqualTo: _uid)
        .limit(250)
        .snapshots();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime(2000);
    return DateTime(2000);
  }

  String _str(dynamic value, [String fallback = '']) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty || result == 'null' ? fallback : result;
  }

  double _number(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  String _status(Map<String, dynamic> data) =>
      _str(data['bookingStatus'] ?? data['status'], 'pending')
          .replaceAll(' ', '')
          .toLowerCase();

  bool _isScheduleStatus(String status) => const {
        'confirmed',
        'physiotherapistontheway',
        'arrived',
        'inprogress',
        'completed',
      }.contains(status);

  int _timeMinutes(Map<String, dynamic> data) {
    final explicit = data['appointmentTimeMinutes'];
    if (explicit is num) return explicit.toInt();

    final raw = _str(data['appointmentTime'] ?? data['time']);
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$', caseSensitive: false)
        .firstMatch(raw);
    if (match == null) return 9999;

    var hour = int.tryParse(match.group(1)!) ?? 0;
    final minute = int.tryParse(match.group(2)!) ?? 0;
    final period = (match.group(3) ?? '').toUpperCase();
    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    return hour * 60 + minute;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _visibleDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final result = docs.where((doc) {
      final data = doc.data();
      final status = _status(data);
      final date = _date(data['appointmentDate']);
      return _sameDay(date, _selectedDay) && _isScheduleStatus(status);
    }).toList();

    result.sort((a, b) =>
        _timeMinutes(a.data()).compareTo(_timeMinutes(b.data())));

    if (_filter == 1) {
      result.removeWhere((d) =>
          _status(d.data()) == 'completed' ||
          _status(d.data()) == 'cancelled');
    } else if (_filter == 2) {
      result.removeWhere((d) => _status(d.data()) != 'inprogress');
    } else if (_filter == 3) {
      result.removeWhere((d) => _status(d.data()) != 'completed');
    }
    return result;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: purple,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: ink,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDay = _day(picked));
    }
  }

  String _dateHeading(DateTime date) {
    final now = _day(DateTime.now());
    if (_sameDay(date, now)) return "Today's schedule";
    if (_sameDay(date, now.add(const Duration(days: 1)))) {
      return "Tomorrow's schedule";
    }
    return '${_weekday(date.weekday)}, ${date.day} ${_month(date.month)}';
  }

  String _weekday(int value) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][value - 1];

  String _month(int value) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][value - 1];

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) {
      return const Scaffold(
        backgroundColor: canvas,
        body: Center(child: Text('Please sign in to view your schedule.')),
      );
    }

    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _scheduleStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _errorState(
                'We could not load your appointments.',
                snapshot.error.toString(),
              );
            }
            if (!snapshot.hasData) return const _ScheduleLoading();

            final docs = _visibleDocs(snapshot.data!.docs);
            final allForDay = snapshot.data!.docs.where((doc) {
              final data = doc.data();
              return _sameDay(_date(data['appointmentDate']), _selectedDay) &&
                  _isScheduleStatus(_status(data));
            }).toList();

            final active = allForDay
                .where((d) => _status(d.data()) != 'completed')
                .length;
            final completed = allForDay
                .where((d) => _status(d.data()) == 'completed')
                .length;
            final next = allForDay.where((d) {
              final status = _status(d.data());
              return status != 'completed' && status != 'inprogress';
            }).toList()
              ..sort((a, b) => _timeMinutes(a.data()).compareTo(_timeMinutes(b.data())));

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _topBar(),
                      const SizedBox(height: 22),
                      _dateHero(allForDay.length, active, completed),
                      const SizedBox(height: 17),
                      _summaryStrip(allForDay.length, active, completed),
                      const SizedBox(height: 23),
                      _sectionHeader(),
                      const SizedBox(height: 12),
                      _filterBar(),
                      const SizedBox(height: 16),
                      if (next.isNotEmpty && _sameDay(_selectedDay, _day(DateTime.now())))
                        _nextAppointment(next.first),
                      if (allForDay.isEmpty)
                        _emptyState(
                          'No accepted appointments',
                          'There are no accepted sessions for this date. Try another day.',
                          Icons.calendar_month_rounded,
                        )
                      else if (docs.isEmpty)
                        _emptyState(
                          'Nothing in this filter',
                          'Choose another schedule filter to see your appointments.',
                          Icons.filter_list_rounded,
                        )
                      else
                        ...docs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final doc = entry.value;
                          return _AnimatedScheduleCard(
                            key: ValueKey(doc.id),
                            index: index,
                            child: _appointmentCard(doc.id, doc.data()),
                          );
                        }),
                      const SizedBox(height: 12),
                      _footerNote(),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _filteredEmpty(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> all,
  ) {
    if (_filter == 0) return false;
    if (_filter == 1) {
      return all.every((d) => _status(d.data()) == 'completed');
    }
    if (_filter == 2) {
      return all.every((d) => _status(d.data()) != 'inprogress');
    }
    return all.every((d) => _status(d.data()) != 'completed');
  }

  Widget _topBar() => Row(
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: line),
            ),
            child: const Icon(Icons.calendar_month_rounded,
                color: purple, size: 21),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR PRACTICE',
                    style: TextStyle(
                        color: purple,
                        fontSize: 9,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 3),
                Text('Schedule',
                    style: TextStyle(
                        color: ink,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.8)),
              ],
            ),
          ),
          _iconButton(Icons.today_rounded, _pickDate),
          const SizedBox(width: 8),
          _iconButton(Icons.refresh_rounded, () => setState(() {})),
        ],
      );

  Widget _iconButton(IconData icon, VoidCallback action) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: action,
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: line),
            ),
            child: Icon(icon, color: ink, size: 19),
          ),
        ),
      );

  Widget _dateHero(int total, int active, int completed) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(19, 19, 16, 17),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6559E8), Color(0xFF4034B8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: purple.withOpacity(.22),
              blurRadius: 24,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -35,
              child: Container(
                height: 145,
                width: 145,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(.09), width: 22),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text('DAILY OVERVIEW',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w900)),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_calendar_rounded,
                              color: Colors.white70, size: 15),
                          const SizedBox(width: 5),
                          Text(
                            '${_selectedDay.day} ${_month(_selectedDay.month).substring(0, 3)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  _dateHeading(_selectedDay),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  total == 0
                      ? 'A clear day gives you room to recharge.'
                      : '$total scheduled ${total == 1 ? 'appointment' : 'appointments'} on your calendar',
                  style: TextStyle(
                      color: Colors.white.withOpacity(.78),
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 19),
                Row(
                  children: [
                    _heroMetric('$total', 'TOTAL'),
                    _heroDivider(),
                    _heroMetric('$active', 'ACTIVE'),
                    _heroDivider(),
                    _heroMetric('$completed', 'DONE'),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  Widget _heroMetric(String value, String label) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(.7),
                    fontSize: 8,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      );

  Widget _heroDivider() => Container(
        height: 34,
        width: 1,
        margin: const EdgeInsets.only(right: 17),
        color: Colors.white.withOpacity(.2),
      );

  Widget _summaryStrip(int total, int active, int completed) => Row(
        children: [
          Expanded(child: _miniMetric('Appointments', '$total', Icons.event_note_rounded, const Color(0xFFECEBFF), purple)),
          const SizedBox(width: 9),
          Expanded(child: _miniMetric('To attend', '$active', Icons.access_time_rounded, const Color(0xFFFFF2E5), const Color(0xFFE38A35))),
          const SizedBox(width: 9),
          Expanded(child: _miniMetric('Completed', '$completed', Icons.task_alt_rounded, const Color(0xFFE5F7F1), const Color(0xFF199B79))),
        ],
      );

  Widget _miniMetric(String label, String value, IconData icon, Color tint, Color accent) =>
      Container(
        padding: const EdgeInsets.fromLTRB(11, 12, 8, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: accent, size: 15),
            ),
            const SizedBox(height: 9),
            Text(value,
                style: const TextStyle(
                    color: ink, fontSize: 20, fontWeight: FontWeight.w900)),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: muted, fontSize: 8, fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _sectionHeader() => Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appointments',
                    style: TextStyle(
                        color: ink, fontSize: 17, fontWeight: FontWeight.w900)),
                SizedBox(height: 3),
                Text('Your accepted patient sessions',
                    style: TextStyle(
                        color: muted, fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month_rounded, size: 15),
            label: const Text('Change day'),
            style: TextButton.styleFrom(
                foregroundColor: purple,
                textStyle: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w800)),
          ),
        ],
      );

  Widget _filterBar() {
    const labels = ['All', 'Upcoming', 'In progress', 'Completed'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFECEEF5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = _filter == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filter = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: selected
                      ? [BoxShadow(color: ink.withOpacity(.06), blurRadius: 8, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? purple : muted,
                    fontSize: 8.5,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _nextAppointment(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final name = _str(data['patientName'] ?? data['customerName'], 'Patient');
    final time = _str(data['appointmentTime'] ?? data['time'], 'Time pending');
    return Container(
      margin: const EdgeInsets.only(bottom: 17),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EE),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFF5E4C9)),
      ),
      child: Row(
        children: [
          Container(
            height: 37,
            width: 37,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.bolt_rounded, color: Color(0xFFE18A32)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('UP NEXT',
                    style: TextStyle(
                        color: Color(0xFFB87528),
                        fontSize: 8,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text('$name · $time',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: ink, fontSize: 11, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Color(0xFFB87528), size: 12),
        ],
      ),
    );
  }

  Widget _appointmentCard(String id, Map<String, dynamic> data) {
    final name = _str(data['patientName'] ?? data['customerName'], 'Patient');
    final time = _str(data['appointmentTime'] ?? data['time'], 'Time pending');
    final service = _prettyService(data);
    final status = _status(data);
    final mode = _str(data['serviceType'], 'homeVisit').toLowerCase();
    final isHome = mode.contains('home');
    final address = _str(data['address'] ?? data['displayAddress'] ?? data['clinicName']);
    final paid = _str(data['paymentStatus'], 'pending').toLowerCase() == 'paid';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DoctorAppointmentDetailsScreen(bookingId: id),
          ),
        ),
        borderRadius: BorderRadius.circular(19),
        child: Container(
          margin: const EdgeInsets.only(bottom: 11),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: line),
            boxShadow: [
              BoxShadow(color: ink.withOpacity(.025), blurRadius: 13, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFEDEBFF), Color(0xFFF5F2FF)]),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.person_rounded, color: purple, size: 23),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: ink, fontSize: 13, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(service,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: muted, fontSize: 9, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  _StatusPill(status: status),
                ],
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  _detailMeta(Icons.schedule_rounded, time),
                  const SizedBox(width: 13),
                  _detailMeta(
                    isHome ? Icons.home_work_rounded : Icons.local_hospital_rounded,
                    isHome ? 'Home visit' : 'Clinic',
                  ),
                ],
              ),
              if (address.isNotEmpty) ...[
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: muted),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: muted, fontSize: 9, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1, color: line),
              const SizedBox(height: 11),
              Row(
                children: [
                  Icon(paid ? Icons.verified_rounded : Icons.info_outline_rounded,
                      size: 13, color: paid ? const Color(0xFF199B79) : const Color(0xFFE18A32)),
                  const SizedBox(width: 5),
                  Text(paid ? 'Payment received' : 'Payment ${_str(data['paymentStatus'], 'pending')}',
                      style: TextStyle(
                          color: paid ? const Color(0xFF199B79) : const Color(0xFFE18A32),
                          fontSize: 9,
                          fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text('View details',
                      style: const TextStyle(
                          color: purple, fontSize: 9, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 5),
                  const Icon(Icons.arrow_forward_rounded, color: purple, size: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailMeta(IconData icon, String value) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: muted, size: 13),
          const SizedBox(width: 5),
          Text(value,
              style: const TextStyle(
                  color: muted, fontSize: 9, fontWeight: FontWeight.w700)),
        ],
      );

  String _prettyService(Map<String, dynamic> data) {
    final package = _str(data['packageName']);
    if (package.isNotEmpty) return package;
    final raw = _str(data['serviceType'], 'Physiotherapy session');
    if (raw.toLowerCase() == 'homevisit') return 'Home physiotherapy';
    if (raw.toLowerCase() == 'clinicvisit') return 'Clinic physiotherapy';
    return raw;
  }

  Widget _emptyState(String title, String subtitle, IconData icon) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 29),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: line)),
        child: Column(
          children: [
            Container(
              height: 61,
              width: 61,
              decoration: const BoxDecoration(
                  color: Color(0xFFEDEBFF), shape: BoxShape.circle),
              child: Icon(icon, color: purple, size: 27),
            ),
            const SizedBox(height: 13),
            Text(title,
                style: const TextStyle(
                    color: ink, fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: muted, fontSize: 10, height: 1.5)),
          ],
        ),
      );

  Widget _footerNote() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.sync_rounded, color: Color(0xFF9BA1B4), size: 13),
            SizedBox(width: 6),
            Text('Schedule updates automatically',
                style: TextStyle(
                    color: muted, fontSize: 9, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _errorState(String title, String details) => Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: muted, size: 35),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(color: ink, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(details,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: muted, fontSize: 10)),
            ],
          ),
        ),
      );
}

// ============================================================================
// APPOINTMENT DETAILS + VISIT LIFECYCLE
// ============================================================================

class DoctorAppointmentDetailsScreen extends StatefulWidget {
  final String bookingId;

  const DoctorAppointmentDetailsScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<DoctorAppointmentDetailsScreen> createState() =>
      _DoctorAppointmentDetailsScreenState();
}

class _DoctorAppointmentDetailsScreenState
    extends State<DoctorAppointmentDetailsScreen> {
  static const Color purple = Color(0xFF5548D9);
  static const Color ink = Color(0xFF171B3A);
  static const Color muted = Color(0xFF858BA2);
  static const Color line = Color(0xFFE9EAF2);

  bool _updating = false;

  DocumentReference<Map<String, dynamic>> get _bookingRef =>
      FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId);

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  String _str(dynamic value, [String fallback = '']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? fallback : text;
  }

  double _num(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _status(Map<String, dynamic> data) =>
      _str(data['bookingStatus'] ?? data['status'], 'pending')
          .replaceAll(' ', '')
          .toLowerCase();

  String _money(dynamic value) => '₹${_num(value).toStringAsFixed(0)}';

  String _dateLabel(dynamic value) {
    final date = _date(value);
    if (date == null) return 'Date not available';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _advance(
    Map<String, dynamic> data,
    String nextStatus,
  ) async {
    if (_updating) return;
    final current = _status(data);
    final allowedNext = <String, String>{
      'confirmed': 'physiotherapistOnTheWay',
      'physiotherapistontheway': 'arrived',
      'arrived': 'inProgress',
      'inprogress': 'completed',
    };

    if (allowedNext[current] != nextStatus) {
      _message('This appointment has already changed. Refresh and try again.');
      return;
    }

    final labels = <String, String>{
      'physiotherapistontheway': 'Start route to patient?',
      'arrived': 'Confirm that you have arrived?',
      'inprogress': 'Start the physiotherapy session?',
      'completed': 'Complete this appointment?',
    };

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(labels[nextStatus] ?? 'Update appointment?'),
        content: Text(_actionDescription(nextStatus)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: purple,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _updating = true);
    try {
      final now = Timestamp.now();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(_bookingRef);
        if (!snapshot.exists) throw StateError('This booking no longer exists.');

        final latest = snapshot.data() ?? <String, dynamic>{};
        final latestStatus = _status(latest);
        if (_str(latest['physiotherapistId']) != _uid) {
          throw StateError('This appointment is not assigned to your account.');
        }
        if (allowedNext[latestStatus] != nextStatus) {
          throw StateError('The appointment status has changed. Please reopen it.');
        }

        final updates = <String, dynamic>{
          'bookingStatus': nextStatus,
          'updatedAt': now,
        };

        switch (nextStatus) {
          case 'physiotherapistontheway':
            updates['physiotherapistOnTheWayAt'] = now;
            break;
          case 'arrived':
            updates['arrivedAt'] = now;
            break;
          case 'inprogress':
            updates['sessionStartedAt'] = now;
            break;
          case 'completed':
            updates['completedAt'] = now;
            break;
        }

        transaction.update(_bookingRef, updates);
      });

      if (mounted) {
        _message(_successMessage(nextStatus));
      }
    } on StateError catch (e) {
      if (mounted) _message(e.message);
    } catch (e) {
      if (mounted) _message('Could not update this appointment. Please try again.');
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  String _actionDescription(String status) {
    switch (status) {
      case 'physiotherapistontheway':
        return 'The patient will see that you have started travelling to their location.';
      case 'arrived':
        return 'This updates the booking to show that you have reached the patient.';
      case 'inprogress':
        return 'Use this when you are with the patient and the session is ready to begin.';
      case 'completed':
        return 'Confirm only after the physiotherapy session has finished.';
      default:
        return 'Update the appointment status.';
    }
  }

  String _successMessage(String status) {
    switch (status) {
      case 'physiotherapistontheway':
        return 'Your patient has been notified that you are on the way.';
      case 'arrived':
        return 'Arrival confirmed.';
      case 'inprogress':
        return 'Session started. Have a great session!';
      case 'completed':
        return 'Appointment marked as completed.';
      default:
        return 'Appointment updated.';
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        margin: const EdgeInsets.all(14),
      ),
    );
  }

  Future<void> _copy(String value, String label) async {
    if (value.trim().isEmpty) {
      _message('$label is not available.');
      return;
    }
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) _message('$label copied.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _bookingRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _simpleState('Unable to load appointment details.');
          }
          if (!snapshot.hasData) {
            return const _ScheduleLoading();
          }
          if (!snapshot.data!.exists) {
            return _simpleState('This appointment could not be found.');
          }

          final data = snapshot.data!.data()!;
          if (_str(data['physiotherapistId']) != _uid) {
            return _simpleState('This appointment is not assigned to your account.');
          }

          final status = _status(data);
          final patient = _str(data['patientName'] ?? data['customerName'], 'Patient');
          final phone = _str(data['patientPhone'] ?? data['customerPhone']);
          final address = _address(data);
          final isHome = _str(data['serviceType']).toLowerCase().contains('home');
          final isCompleted = status == 'completed';

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(),
                        const SizedBox(height: 18),
                        _patientHero(patient, data, status),
                        const SizedBox(height: 16),
                        _journeyCard(status),
                        const SizedBox(height: 18),
                        _sectionTitle('Appointment information'),
                        const SizedBox(height: 10),
                        _infoCard([
                          _infoRow(Icons.calendar_month_rounded, 'Date', _dateLabel(data['appointmentDate'])),
                          _infoRow(Icons.schedule_rounded, 'Time', _str(data['appointmentTime'] ?? data['time'], 'Not specified')),
                          _infoRow(isHome ? Icons.home_work_rounded : Icons.local_hospital_rounded, 'Visit type', isHome ? 'Home visit' : 'Clinic visit'),
                          _infoRow(Icons.medical_services_outlined, 'Service', _str(data['packageName'] ?? data['serviceType'], 'Physiotherapy')),
                          _infoRow(Icons.payments_outlined, 'Amount', _money(data['totalAmount'] ?? data['amount'])),
                          _infoRow(Icons.verified_outlined, 'Payment', _str(data['paymentStatus'], 'pending').toUpperCase()),
                        ]),
                        const SizedBox(height: 18),
                        _sectionTitle('Patient details'),
                        const SizedBox(height: 10),
                        _infoCard([
                          _infoRow(Icons.person_outline_rounded, 'Patient', patient),
                          _infoRow(Icons.phone_outlined, 'Phone', phone.isEmpty ? 'Not provided' : phone),
                          _infoRow(Icons.email_outlined, 'Email', _str(data['patientEmail'], 'Not provided')),
                        ]),
                        if (phone.isNotEmpty) ...[
                          const SizedBox(height: 9),
                          _copyButton('Copy patient phone', phone, Icons.copy_rounded),
                        ],
                        const SizedBox(height: 18),
                        _sectionTitle(isHome ? 'Visit address' : 'Clinic location'),
                        const SizedBox(height: 10),
                        _addressCard(address, data),
                        if (_str(data['patientNotes']).isNotEmpty) ...[
                          const SizedBox(height: 18),
                          _sectionTitle('Patient notes'),
                          const SizedBox(height: 10),
                          _noteCard(_str(data['patientNotes'])),
                        ],
                        const SizedBox(height: 18),
                        _sectionTitle('Appointment timeline'),
                        const SizedBox(height: 10),
                        _timeline(data),
                        const SizedBox(height: 22),
                        if (!isCompleted) _primaryAction(status, data),
                        if (isCompleted) _completedBanner(),
                        const SizedBox(height: 15),
                        _safetyNote(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _address(Map<String, dynamic> data) {
    final parts = <String>[
      _str(data['address']),
      _str(data['locality']),
      _str(data['city']),
      _str(data['state']),
      _str(data['pincode']),
    ].where((e) => e.isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(', ');
    return _str(data['displayAddress'] ?? data['clinicAddress'] ?? data['clinicName']);
  }

  Widget _header() => Row(
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: line)),
                child: const Icon(Icons.arrow_back_rounded, color: ink),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Appointment details',
                style: TextStyle(
                    color: ink, fontSize: 20, fontWeight: FontWeight.w900)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
                color: const Color(0xFFEDEBFF),
                borderRadius: BorderRadius.circular(30)),
            child: const Text('LIVE',
                style: TextStyle(
                    color: purple,
                    fontSize: 8,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w900)),
          ),
        ],
      );

  Widget _patientHero(String patient, Map<String, dynamic> data, String status) {
    final id = _str(data['bookingNumber'] ?? data['bookingCode'] ?? widget.bookingId);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6559E8), Color(0xFF4034B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: purple.withOpacity(.18), blurRadius: 22, offset: const Offset(0, 9)),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(.16),
                borderRadius: BorderRadius.circular(19)),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text('Booking · ${id.length > 18 ? id.substring(0, 18) : id}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(.72),
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _StatusPill(status: status, light: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(
          color: ink, fontSize: 15, fontWeight: FontWeight.w900));

  Widget _infoCard(List<Widget> children) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: line)),
        child: Column(children: children),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                  color: const Color(0xFFF1F0FF),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: purple, size: 16),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 75,
              child: Text(label,
                  style: const TextStyle(
                      color: muted, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: ink, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );

  Widget _addressCard(String address, Map<String, dynamic> data) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: line)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 37,
                  width: 37,
                  decoration: BoxDecoration(
                      color: const Color(0xFFEDEBFF),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.location_on_rounded, color: purple),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    address.isEmpty ? 'Address not provided' : address,
                    style: const TextStyle(
                        color: ink, fontSize: 11, height: 1.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            if (address.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _copy(address, 'Address'),
                  icon: const Icon(Icons.copy_rounded, size: 15),
                  label: const Text('Copy address'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: purple,
                    side: const BorderSide(color: Color(0xFFE4E1FF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            if (data['latitude'] is num && data['longitude'] is num)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Location coordinates are saved with this booking.',
                  style: TextStyle(color: muted, fontSize: 8),
                ),
              ),
          ],
        ),
      );

  Widget _copyButton(String title, String value, IconData icon) => SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _copy(value, title),
          icon: Icon(icon, size: 15),
          label: Text(title),
          style: OutlinedButton.styleFrom(
              foregroundColor: purple,
              side: const BorderSide(color: Color(0xFFE4E1FF)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      );

  Widget _noteCard(String value) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: line)),
        child: Text(value,
            style: const TextStyle(color: ink, fontSize: 10, height: 1.55)),
      );

  Widget _journeyCard(String status) {
    final steps = const [
      ('confirmed', 'Accepted'),
      ('physiotherapistontheway', 'On the way'),
      ('arrived', 'Arrived'),
      ('inprogress', 'Session'),
      ('completed', 'Completed'),
    ];
    final current = steps.indexWhere((s) => s.$1 == status);
    final safeCurrent = current < 0 ? 0 : current;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('VISIT PROGRESS',
              style: TextStyle(
                  color: muted,
                  fontSize: 8,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 15),
          Row(
            children: List.generate(steps.length, (i) {
              final done = i <= safeCurrent;
              return Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                        color: done ? purple : const Color(0xFFF0F1F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        i < safeCurrent ? Icons.check_rounded : Icons.circle,
                        size: i < safeCurrent ? 13 : 7,
                        color: done ? Colors.white : const Color(0xFFB7BBC9),
                      ),
                    ),
                    if (i != steps.length - 1)
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 3,
                          color: i < safeCurrent ? purple : const Color(0xFFE9EAF2),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 9),
          Row(
            children: steps.map((s) {
              final isCurrent = s.$1 == status;
              return Expanded(
                child: Text(
                  s.$2,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    color: isCurrent ? purple : muted,
                    fontSize: 7,
                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _timeline(Map<String, dynamic> data) {
    final entries = <(String, String, IconData)>[
      ('acceptedAt', 'Booking accepted', Icons.check_circle_outline_rounded),
      ('physiotherapistOnTheWayAt', 'You started travelling', Icons.directions_car_rounded),
      ('arrivedAt', 'You arrived', Icons.location_on_outlined),
      ('sessionStartedAt', 'Session started', Icons.play_circle_outline_rounded),
      ('completedAt', 'Session completed', Icons.task_alt_rounded),
    ];
    final active = entries.where((e) => data[e.$1] != null).toList();
    if (active.isEmpty) {
      return _noteCard('Appointment activity will appear here as you update its progress.');
    }
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: line)),
      child: Column(
        children: active.map((entry) {
          final date = _date(data[entry.$1]);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Icon(entry.$3, color: purple, size: 17),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(entry.$2,
                      style: const TextStyle(
                          color: ink, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
                Text(
                  date == null
                      ? 'Recorded'
                      : '${date.day}/${date.month}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      color: muted, fontSize: 8, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _primaryAction(String status, Map<String, dynamic> data) {
    String? next;
    String label = '';
    IconData icon = Icons.arrow_forward_rounded;

    switch (status) {
      case 'confirmed':
        next = 'physiotherapistOnTheWay';
        label = 'Start journey · On the way';
        icon = Icons.directions_car_rounded;
        break;
      case 'physiotherapistontheway':
        next = 'arrived';
        label = 'I have arrived';
        icon = Icons.location_on_rounded;
        break;
      case 'arrived':
        next = 'inProgress';
        label = 'Start physiotherapy session';
        icon = Icons.play_arrow_rounded;
        break;
      case 'inprogress':
        next = 'completed';
        label = 'Complete session';
        icon = Icons.check_circle_rounded;
        break;
      default:
        return _noteCard('This booking is currently ${status.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}')}. No further action is available here.');
    }

    final target = next;
    final isComplete = target == 'completed';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isComplete)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Only complete the session after treatment has finished.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w600),
            ),
          ),
        SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _updating ? null : () => _advance(data, target!),
            icon: _updating
                ? const SizedBox(
                    height: 17,
                    width: 17,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Icon(icon, size: 19),
            label: Text(
              _updating ? 'Updating appointment…' : label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isComplete
                  ? const Color(0xFF159875)
                  : purple,
              foregroundColor: Colors.white,
              disabledBackgroundColor: muted,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _completedBanner() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFFE5F7F1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC9EDE1))),
        child: const Row(
          children: [
            Icon(Icons.verified_rounded, color: Color(0xFF159875), size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text('This appointment has been completed.',
                  style: TextStyle(
                      color: Color(0xFF137A60),
                      fontSize: 11,
                      fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      );

  Widget _safetyNote() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          'Please update each step only when it has actually happened. Status changes are saved to the booking and can be reflected in the patient app.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 8, height: 1.5),
        ),
      );

  Widget _simpleState(String message) => Scaffold(
        backgroundColor: const Color(0xFFF5F6FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F6FB),
          elevation: 0,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, color: ink)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: ink, fontWeight: FontWeight.w800)),
          ),
        ),
      );
}

// ============================================================================
// SHARED PRESENTATION WIDGETS
// ============================================================================

class _StatusPill extends StatelessWidget {
  final String status;
  final bool light;

  const _StatusPill({required this.status, this.light = false});

  String get _label {
    switch (status) {
      case 'confirmed':
        return 'ACCEPTED';
      case 'physiotherapistontheway':
        return 'ON THE WAY';
      case 'arrived':
        return 'ARRIVED';
      case 'inprogress':
        return 'IN SESSION';
      case 'completed':
        return 'COMPLETED';
      default:
        return status.toUpperCase();
    }
  }

  Color get _color {
    switch (status) {
      case 'confirmed':
      case 'physiotherapistontheway':
        return const Color(0xFF5548D9);
      case 'arrived':
        return const Color(0xFF2878C8);
      case 'inprogress':
        return const Color(0xFFE18A32);
      case 'completed':
        return const Color(0xFF159875);
      default:
        return const Color(0xFF858BA2);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: light ? Colors.white.withOpacity(.16) : _color.withOpacity(.09),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          _label,
          style: TextStyle(
              color: light ? Colors.white : _color,
              fontSize: 7,
              letterSpacing: .35,
              fontWeight: FontWeight.w900),
        ),
      );
}

class _AnimatedScheduleCard extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedScheduleCard({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 280 + (index.clamp(0, 5) * 55)),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        ),
      );
}

class _ScheduleLoading extends StatelessWidget {
  const _ScheduleLoading();

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Color(0xFFF5F6FB),
        body: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: Color(0xFF5548D9)),
        ),
      );
}
