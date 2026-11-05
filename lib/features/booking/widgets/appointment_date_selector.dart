import 'package:flutter/material.dart';

class AppointmentDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final int daysToShow;

  /// Working days configured by the physiotherapist.
  ///
  /// Values can be stored as either:
  /// Mon / Tue / Wed / Thu / Fri / Sat / Sun
  /// or:
  /// MON / TUE / WED / THU / FRI / SAT / SUN
  ///
  /// Dates outside these working days are shown but cannot be selected.
  final List<String> workingDays;

  const AppointmentDateSelector({
    super.key,
    required this.selectedDate,
    this.onDateSelected,
    this.daysToShow = 7,
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

  // ===============================================================
  // WORKING-DAY HELPERS
  // ===============================================================

  /// Converts any supported working-day value into a standard
  /// three-letter uppercase value.
  static String _normalizeWorkingDay(String value) {
    final normalized = value.trim().toUpperCase();

    if (normalized.length <= 3) {
      return normalized;
    }

    return normalized.substring(0, 3);
  }

  bool _isWorkingDay(DateTime date) {
    final day = _dayName(date);

    return workingDays.any(
      (workingDay) =>
          _normalizeWorkingDay(workingDay) == day,
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    final dates = List.generate(
      daysToShow,
      (index) => DateTime(
        today.year,
        today.month,
        today.day + index,
      ),
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // =========================================================
        // SECTION TITLE
        // =========================================================

        const Text(
          'Choose date',
          style: TextStyle(
            fontSize: 15.5,
            color: Color(0xFF111A3D),
            fontWeight: FontWeight.w900,
            letterSpacing: -.3,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Select a convenient day for your session',
          style: TextStyle(
            fontSize: 10.5,
            color: Color(0xFF7A839A),
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        // =========================================================
        // DATE SELECTOR
        // =========================================================

        SizedBox(
          height: 96,

          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            physics:
                const BouncingScrollPhysics(),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 1,
            ),

            itemCount: dates.length,

            separatorBuilder: (_, __) =>
                const SizedBox(width: 9),

            itemBuilder: (
              context,
              index,
            ) {
              final date = dates[index];

              final isSelected =
                  _isSameDay(
                date,
                selectedDate,
              );

              final isToday =
                  _isSameDay(
                date,
                today,
              );

              final isWorkingDay =
                  _isWorkingDay(date);

              return GestureDetector(
                onTap: isWorkingDay
                    ? () {
                        onDateSelected?.call(
                          date,
                        );
                      }
                    : null,

                behavior:
                    HitTestBehavior.opaque,

                child:
                    AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 200,
                  ),

                  curve:
                      Curves.easeOutCubic,

                  width: 72,

                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 9,
                  ),

                  decoration:
                      BoxDecoration(
                    gradient: isSelected && isWorkingDay
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

                    color: isWorkingDay
                        ? (isSelected
                            ? null
                            : Colors.white)
                        : const Color(0xFFF4F5F8),

                    borderRadius:
                        BorderRadius.circular(
                      17,
                    ),

                    border: Border.all(
                      color: !isWorkingDay
                          ? const Color(0xFFE7E9EF)
                          : isSelected
                              ? const Color(
                                  0xFF5146D9,
                                )
                              : const Color(
                                  0xFFE3E6EF,
                                ),

                      width:
                          isSelected && isWorkingDay
                              ? 1.2
                              : .9,
                    ),

                    boxShadow: [
                      if (isWorkingDay)
                        BoxShadow(
                          color: isSelected
                              ? const Color(
                                  0xFF5146D9,
                                ).withOpacity(.18)
                              : const Color(
                                  0xFF26345C,
                                ).withOpacity(.045),

                          blurRadius:
                              isSelected ? 15 : 11,

                          offset:
                              const Offset(0, 5),
                        ),
                    ],
                  ),

                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      // -------------------------------------------------
                      // DAY NAME
                      // -------------------------------------------------

                      Text(
                        isToday
                            ? 'TODAY'
                            : _dayName(date),

                        style: TextStyle(
                          fontSize: 8.5,

                          color: !isWorkingDay
                              ? const Color(0xFFB0B5C2)
                              : isSelected
                                  ? Colors.white
                                  : const Color(
                                      0xFF7B849B,
                                    ),

                          fontWeight:
                              FontWeight.w900,

                          letterSpacing: .35,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // -------------------------------------------------
                      // DATE NUMBER
                      // -------------------------------------------------

                      Text(
                        '${date.day}',

                        style: TextStyle(
                          fontSize: 20,

                          color: !isWorkingDay
                              ? const Color(0xFF9FA5B4)
                              : isSelected
                                  ? Colors.white
                                  : const Color(
                                      0xFF151D3D,
                                    ),

                          fontWeight:
                              FontWeight.w900,

                          height: 1,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // -------------------------------------------------
                      // MONTH
                      // -------------------------------------------------

                      Text(
                        _monthName(date),

                        style: TextStyle(
                          fontSize: 8.5,

                          color: !isWorkingDay
                              ? const Color(0xFFB2B7C3)
                              : isSelected
                                  ? Colors.white
                                      .withOpacity(.82)
                                  : const Color(
                                      0xFF8A92A8,
                                    ),

                          fontWeight:
                              FontWeight.w700,

                          letterSpacing: .3,
                        ),
                      ),

                      if (!isWorkingDay) ...[
                        const SizedBox(height: 3),
                        const Text(
                          'OFF',
                          style: TextStyle(
                            fontSize: 6.5,
                            color: Color(0xFFB0B5C2),
                            fontWeight: FontWeight.w900,
                            letterSpacing: .4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // =========================================================
        // WORKING-DAY INFO
        // =========================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: const Color(0xFFE5E8EF),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF9F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  size: 14,
                  color: Color(0xFF079F87),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _workingDaysLabel(),
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF69738B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // =========================================================
        // SELECTED DATE SUMMARY
        // =========================================================

        Container(
          width: double.infinity,

          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),

          decoration: BoxDecoration(
            gradient:
                const LinearGradient(
              begin:
                  Alignment.centerLeft,
              end:
                  Alignment.centerRight,
              colors: [
                Color(0xFFF2F0FF),
                Color(0xFFEAF9F6),
              ],
            ),

            borderRadius:
                BorderRadius.circular(14),

            border: Border.all(
              color:
                  const Color(0xFFE1E3F0),
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,

                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withOpacity(.85),

                  borderRadius:
                      BorderRadius.circular(9),
                ),

                child: const Icon(
                  Icons
                      .event_available_rounded,
                  size: 16,
                  color:
                      Color(0xFF5146D9),
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Selected date',
                      style:
                          TextStyle(
                        fontSize: 8.5,
                        color:
                            Color(0xFF858DA3),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      _formattedDate(
                        selectedDate,
                      ),

                      style:
                          const TextStyle(
                        fontSize: 11,
                        color:
                            Color(0xFF151D3D),
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .check_circle_rounded,
                size: 18,
                color:
                    Color(0xFF079F87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // HELPERS
  // ===============================================================

  static bool _isSameDay(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  static String _dayName(
    DateTime date,
  ) {
    const days = [
      'MON',
      'TUE',
      'WED',
      'THU',
      'FRI',
      'SAT',
      'SUN',
    ];

    return days[date.weekday - 1];
  }

  static String _monthName(
    DateTime date,
  ) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return months[date.month - 1];
  }

  String _workingDaysLabel() {
    final normalizedDays = workingDays
        .map(_normalizeWorkingDay)
        .where(
          (day) => const {
            'MON',
            'TUE',
            'WED',
            'THU',
            'FRI',
            'SAT',
            'SUN',
          }.contains(day),
        )
        .toSet();

    const order = [
      'MON',
      'TUE',
      'WED',
      'THU',
      'FRI',
      'SAT',
      'SUN',
    ];

    final selected = order
        .where(normalizedDays.contains)
        .toList();

    if (selected.isEmpty) {
      return 'No working days configured';
    }

    return 'Available on ${selected.join(', ')}';
  }

  static String _formattedDate(
    DateTime date,
  ) {
    return '${_dayName(date)}, '
        '${date.day} '
        '${_monthName(date)} '
        '${date.year}';
  }
}