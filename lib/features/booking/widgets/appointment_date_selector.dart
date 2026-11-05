import 'package:flutter/material.dart';

class AppointmentDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final int daysToShow;
  final List<String> workingDays;

  const AppointmentDateSelector({
    super.key,
    required this.selectedDate,
    this.onDateSelected,
    this.daysToShow = 14,
    this.workingDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  });

  static const _ink = Color(0xFF111A3D);
  static const _muted = Color(0xFF7A839A);
  static const _primary = Color(0xFF5146D9);
  static const _line = Color(0xFFE7EAF2);

  static String _normalizeWorkingDay(String value) {
    final normalized = value.trim().toUpperCase();
    return normalized.length <= 3 ? normalized : normalized.substring(0, 3);
  }

  bool _isWorkingDay(DateTime date) {
    final day = _dayName(date);
    return workingDays.any((value) => _normalizeWorkingDay(value) == day);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = List.generate(
      daysToShow,
      (index) => DateTime(today.year, today.month, today.day + index),
    );
    final selectedLabel =
        '${_weekdayFull(selectedDate.weekday)}, ${selectedDate.day} ${_monthName(selectedDate)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose your date',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.45,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Select a day that works best for you.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0FF),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                _monthName(selectedDate),
                style: const TextStyle(
                  color: _primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 2, right: 2),
            itemCount: dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              final date = dates[index];
              final selected = _sameDay(date, selectedDate);
              final todayDate = _sameDay(date, today);
              final working = _isWorkingDay(date);

              return Semantics(
                button: true,
                selected: selected,
                enabled: working,
                label: '${_weekdayFull(date.weekday)} ${date.day} ${_monthName(date)}${working ? '' : ', unavailable'}',
                child: GestureDetector(
                  onTap: working ? () => onDateSelected?.call(date) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 67,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF7064ED), Color(0xFF4F45D2)],
                            )
                          : null,
                      color: selected
                          ? null
                          : working
                              ? Colors.white
                              : const Color(0xFFF3F4F8),
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF5146D9)
                            : _line,
                        width: selected ? 1.3 : 1,
                      ),
                      boxShadow: [
                        if (working)
                          BoxShadow(
                            color: selected
                                ? _primary.withOpacity(.20)
                                : const Color(0xFF1D2A54).withOpacity(.035),
                            blurRadius: selected ? 16 : 10,
                            offset: const Offset(0, 5),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          todayDate ? 'TODAY' : _dayName(date),
                          style: TextStyle(
                            color: !working
                                ? const Color(0xFFB0B5C2)
                                : selected
                                    ? Colors.white.withOpacity(.82)
                                    : _muted,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .5,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: !working
                                ? const Color(0xFFAEB4C2)
                                : selected
                                    ? Colors.white
                                    : _ink,
                            fontSize: 22,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.7,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _monthShort(date),
                          style: TextStyle(
                            color: !working
                                ? const Color(0xFFB9BECA)
                                : selected
                                    ? Colors.white.withOpacity(.82)
                                    : _muted,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!working) ...[
                          const SizedBox(height: 3),
                          const Text(
                            'OFF',
                            style: TextStyle(
                              color: Color(0xFFB0B5C2),
                              fontSize: 6,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FC),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE9FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  size: 17,
                  color: _primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected appointment date',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      selectedLabel,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF18A889),
                size: 19,
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        const Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 13, color: _muted),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Days marked OFF follow the physiotherapist’s weekly schedule.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 9,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _dayName(DateTime date) {
    const names = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return names[date.weekday - 1];
  }

  static String _weekdayFull(int weekday) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[weekday - 1];
  }

  static String _monthName(DateTime date) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[date.month - 1];
  }

  static String _monthShort(DateTime date) {
    return _monthName(date).substring(0, 3).toUpperCase();
  }
}
