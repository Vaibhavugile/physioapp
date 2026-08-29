import 'package:flutter/material.dart';

class AppointmentTimeSelector extends StatelessWidget {
  final String? selectedTime;
  final ValueChanged<String>? onTimeSelected;

  /// Optional list of unavailable slots.
  final List<String> unavailableSlots;

  const AppointmentTimeSelector({
    super.key,
    this.selectedTime,
    this.onTimeSelected,
    this.unavailableSlots = const [],
  });

  static const List<String> _defaultSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:30 AM',
    '01:00 PM',
    '02:00 PM',
    '03:30 PM',
    '04:30 PM',
    '05:30 PM',
    '07:00 PM',
    '08:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final slots = _defaultSlots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =========================================================
        // SECTION HEADER
        // =========================================================

        const Text(
          'Choose time',
          style: TextStyle(
            fontSize: 15.5,
            color: Color(0xFF111A3D),
            fontWeight: FontWeight.w900,
            letterSpacing: -.3,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Pick a convenient time for your session',
          style: TextStyle(
            fontSize: 10.5,
            color: Color(0xFF7A839A),
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        // =========================================================
        // AVAILABILITY STATUS
        // =========================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF9F5),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: const Color(0xFFD6F0E9),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: Color(0xFF079F87),
                ),
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'Available slots today',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF087F75),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const Icon(
                Icons.circle,
                size: 7,
                color: Color(0xFF079F87),
              ),

              const SizedBox(width: 4),

              const Text(
                'Available',
                style: TextStyle(
                  fontSize: 8.5,
                  color: Color(0xFF079F87),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // =========================================================
        // TIME GRID
        // =========================================================

        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),

          itemCount: slots.length,

          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 9,
            crossAxisSpacing: 9,
            childAspectRatio: 3.15,
          ),

          itemBuilder: (
            context,
            index,
          ) {
            final time = slots[index];

            final bool unavailable =
                unavailableSlots.contains(time);

            final bool selected =
                selectedTime == time;

            return _TimeSlot(
              time: time,
              selected: selected,
              unavailable: unavailable,
              onTap: unavailable
                  ? null
                  : () {
                      onTimeSelected?.call(
                        time,
                      );
                    },
            );
          },
        ),

        const SizedBox(height: 12),

        // =========================================================
        // SELECTED TIME SUMMARY
        // =========================================================

        AnimatedSwitcher(
          duration:
              const Duration(milliseconds: 220),

          child: selectedTime == null
              ? const _NoTimeSelected()
              : _SelectedTimeSummary(
                  key: ValueKey(
                    selectedTime,
                  ),
                  time: selectedTime!,
                ),
        ),
      ],
    );
  }
}

// ====================================================================
// TIME SLOT
// ====================================================================

class _TimeSlot extends StatelessWidget {
  final String time;
  final bool selected;
  final bool unavailable;
  final VoidCallback? onTap;

  const _TimeSlot({
    required this.time,
    required this.selected,
    required this.unavailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 190),

        curve: Curves.easeOutCubic,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 11,
        ),

        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin:
                      Alignment.topLeft,
                  end:
                      Alignment.bottomRight,
                  colors: [
                    Color(0xFF6A58E8),
                    Color(0xFF5146D9),
                  ],
                )
              : null,

          color: unavailable
              ? const Color(0xFFF2F3F7)
              : selected
                  ? null
                  : Colors.white,

          borderRadius:
              BorderRadius.circular(14),

          border: Border.all(
            color: unavailable
                ? const Color(0xFFE4E6ED)
                : selected
                    ? const Color(
                        0xFF5146D9,
                      )
                    : const Color(
                        0xFFE1E5EE,
                      ),
            width: selected ? 1.2 : .9,
          ),

          boxShadow: [
            if (!unavailable)
              BoxShadow(
                color: selected
                    ? const Color(
                        0xFF5146D9,
                      ).withOpacity(.16)
                    : const Color(
                        0xFF26345C,
                      ).withOpacity(.035),
                blurRadius:
                    selected ? 13 : 9,
                offset:
                    const Offset(0, 4),
              ),
          ],
        ),

        child: Row(
          children: [
            Icon(
              unavailable
                  ? Icons.block_rounded
                  : Icons.access_time_rounded,

              size: 16,

              color: unavailable
                  ? const Color(
                      0xFFA6ACBB,
                    )
                  : selected
                      ? Colors.white
                      : const Color(
                          0xFF5E6680,
                        ),
            ),

            const SizedBox(width: 7),

            Expanded(
              child: Text(
                time,

                style: TextStyle(
                  fontSize: 10.5,

                  color: unavailable
                      ? const Color(
                          0xFFA1A7B5,
                        )
                      : selected
                          ? Colors.white
                          : const Color(
                              0xFF151D3D,
                            ),

                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: Colors.white,
              ),

            if (unavailable)
              const Text(
                'Full',
                style: TextStyle(
                  fontSize: 8,
                  color:
                      Color(0xFFA1A7B5),
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// SELECTED TIME SUMMARY
// ====================================================================

class _SelectedTimeSummary
    extends StatelessWidget {
  final String time;

  const _SelectedTimeSummary({
    super.key,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Color(0xFFF1EFFF),
            Color(0xFFEAF9F6),
          ],
        ),

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color:
              const Color(0xFFE0E2F0),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,

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

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected time',
                  style: TextStyle(
                    fontSize: 8.5,
                    color:
                        Color(0xFF858DA3),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  'Appointment slot',
                  style: TextStyle(
                    fontSize: 10.5,
                    color:
                        Color(0xFF151D3D),
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Text(
            time,

            style:
                const TextStyle(
              fontSize: 11.5,
              color:
                  Color(0xFF079F87),
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(width: 5),

          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color:
                Color(0xFF079F87),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// NO TIME SELECTED
// ====================================================================

class _NoTimeSelected
    extends StatelessWidget {
  const _NoTimeSelected();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color:
            const Color(0xFFF8F9FC),

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color:
              const Color(0xFFE5E8EF),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,

            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(9),
            ),

            child: const Icon(
              Icons.touch_app_rounded,
              size: 16,
              color:
                  Color(0xFF7B849B),
            ),
          ),

          const SizedBox(width: 9),

          const Expanded(
            child: Text(
              'Select a time slot to continue',
              style: TextStyle(
                fontSize: 9.5,
                color:
                    Color(0xFF737C94),
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          const Icon(
            Icons
                .arrow_downward_rounded,
            size: 16,
            color:
                Color(0xFF8B93A7),
          ),
        ],
      ),
    );
  }
}