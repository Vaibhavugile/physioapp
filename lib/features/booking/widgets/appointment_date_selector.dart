import 'package:flutter/material.dart';

class AppointmentDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final int daysToShow;

  const AppointmentDateSelector({
    super.key,
    required this.selectedDate,
    this.onDateSelected,
    this.daysToShow = 7,
  });

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

              return GestureDetector(
                onTap: () {
                  onDateSelected?.call(
                    date,
                  );
                },

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
                    gradient: isSelected
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

                    color: isSelected
                        ? null
                        : Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                      17,
                    ),

                    border: Border.all(
                      color: isSelected
                          ? const Color(
                              0xFF5146D9,
                            )
                          : const Color(
                              0xFFE3E6EF,
                            ),

                      width:
                          isSelected ? 1.2 : .9,
                    ),

                    boxShadow: [
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

                          color: isSelected
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

                          color: isSelected
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

                          color: isSelected
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
                    ],
                  ),
                ),
              );
            },
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

  static String _formattedDate(
    DateTime date,
  ) {
    return '${_dayName(date)}, '
        '${date.day} '
        '${_monthName(date)} '
        '${date.year}';
  }
}