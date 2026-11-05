import 'package:flutter/material.dart';

class AppointmentTimeSelector extends StatelessWidget {
  final String? selectedTime;
  final ValueChanged<String>? onTimeSelected;
  final List<String> unavailableSlots;

  const AppointmentTimeSelector({
    super.key,
    this.selectedTime,
    this.onTimeSelected,
    this.unavailableSlots = const [],
  });

  static const _ink = Color(0xFF111A3D);
  static const _muted = Color(0xFF7A839A);
  static const _primary = Color(0xFF5146D9);
  static const _green = Color(0xFF159B7A);

  /// Current app configuration exposes fixed hourly slots from 9 AM–5 PM.
  /// Keep this source unchanged until working-hour fields are supplied by onboarding.
  List<String> _generateSlots() {
    final slots = <String>[];
    for (int hour = 9; hour < 18; hour++) {
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : hour;
      slots.add('${displayHour.toString().padLeft(2, '0')}:00 $period');
    }
    return slots;
  }

  String _normalize(String value) => value.trim().toUpperCase();

  bool _isUnavailable(String time) {
    return unavailableSlots.any((slot) => _normalize(slot) == _normalize(time));
  }

  @override
  Widget build(BuildContext context) {
    final slots = _generateSlots();
    final bookedCount = slots.where(_isUnavailable).length;
    final availableCount = slots.length - bookedCount;
    final selectedNormalized = selectedTime == null ? null : _normalize(selectedTime!);

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
                    'Choose a time',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.45,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Available one-hour appointment windows.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.schedule_rounded, color: _primary, size: 19),
          ],
        ),
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: availableCount > 0
                ? const Color(0xFFEAF8F4)
                : const Color(0xFFFFF1F1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: availableCount > 0
                  ? const Color(0xFFD4EEE5)
                  : const Color(0xFFF3D9D9),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  availableCount > 0
                      ? Icons.event_available_rounded
                      : Icons.event_busy_rounded,
                  color: availableCount > 0 ? _green : const Color(0xFFD05A5A),
                  size: 17,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      availableCount > 0
                          ? '$availableCount time slots available'
                          : 'No time slots available',
                      style: TextStyle(
                        color: availableCount > 0
                            ? const Color(0xFF087F68)
                            : const Color(0xFFB24D4D),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bookedCount > 0
                          ? '$bookedCount already booked for this date'
                          : 'Choose any open time below',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _LegendDot(color: _green, label: 'Open'),
            ],
          ),
        ),
        const SizedBox(height: 13),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 9,
            crossAxisSpacing: 8,
            childAspectRatio: 1.9,
          ),
          itemBuilder: (context, index) {
            final time = slots[index];
            final unavailable = _isUnavailable(time);
            final selected = selectedNormalized == _normalize(time);

            return Semantics(
              button: true,
              selected: selected,
              enabled: !unavailable,
              label: '$time${unavailable ? ', booked' : ', available'}',
              child: GestureDetector(
                onTap: unavailable ? null : () => onTimeSelected?.call(time),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 190),
                  curve: Curves.easeOutCubic,
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
                        : unavailable
                            ? const Color(0xFFF2F3F7)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? _primary
                          : unavailable
                              ? const Color(0xFFE8EAF0)
                              : const Color(0xFFE4E8F1),
                      width: selected ? 1.2 : 1,
                    ),
                    boxShadow: [
                      if (selected)
                        BoxShadow(
                          color: _primary.withOpacity(.18),
                          blurRadius: 13,
                          offset: const Offset(0, 5),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        unavailable
                            ? Icons.lock_clock_rounded
                            : selected
                                ? Icons.check_circle_rounded
                                : Icons.access_time_rounded,
                        size: 13,
                        color: selected
                            ? Colors.white
                            : unavailable
                                ? const Color(0xFFB5BBC8)
                                : _green,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          time,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : unavailable
                                    ? const Color(0xFFADB3C0)
                                    : _ink,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 13),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: selectedTime == null
              ? const _TimeSelectionHint(key: ValueKey('hint'))
              : _SelectedTimeCard(
                  key: ValueKey(selectedNormalized),
                  time: selectedTime!,
                ),
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            _LegendDot(color: _green, label: 'Available'),
            SizedBox(width: 15),
            _LegendDot(color: Color(0xFFB8BECA), label: 'Booked'),
            SizedBox(width: 15),
            _LegendDot(color: _primary, label: 'Selected'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7A839A),
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TimeSelectionHint extends StatelessWidget {
  const _TimeSelectionHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EAF2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.touch_app_rounded, color: Color(0xFF8A91A6), size: 17),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Select an available time to continue.',
              style: TextStyle(
                color: Color(0xFF7A839A),
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedTimeCard extends StatelessWidget {
  final String time;

  const _SelectedTimeCard({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0EEFF), Color(0xFFEAF8F4)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFDDE4EF)),
      ),
      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF159B7A),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Your selected time',
              style: TextStyle(
                color: Color(0xFF7A839A),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF111A3D),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
