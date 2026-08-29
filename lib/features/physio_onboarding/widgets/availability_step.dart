import 'package:flutter/material.dart';

class AvailabilityStep extends StatelessWidget {
  final Set<String> selectedDays;

  final TimeOfDay startTime;
  final TimeOfDay endTime;

  final bool homeVisitsAvailable;
  final bool clinicVisitsAvailable;
  final bool onlineConsultationAvailable;
  final bool emergencyAvailable;

  final int maxAppointmentsPerDay;

  final ValueChanged<Set<String>> onDaysChanged;

  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final ValueChanged<TimeOfDay> onEndTimeChanged;

  final ValueChanged<bool> onHomeVisitsChanged;
  final ValueChanged<bool> onClinicVisitsChanged;
  final ValueChanged<bool> onOnlineConsultationChanged;
  final ValueChanged<bool> onEmergencyAvailabilityChanged;

  final ValueChanged<int> onMaxAppointmentsChanged;

  const AvailabilityStep({
    super.key,
    required this.selectedDays,
    required this.startTime,
    required this.endTime,
    required this.homeVisitsAvailable,
    required this.clinicVisitsAvailable,
    required this.onlineConsultationAvailable,
    required this.emergencyAvailable,
    required this.maxAppointmentsPerDay,
    required this.onDaysChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onHomeVisitsChanged,
    required this.onClinicVisitsChanged,
    required this.onOnlineConsultationChanged,
    required this.onEmergencyAvailabilityChanged,
    required this.onMaxAppointmentsChanged,
  });

  static const List<String> _days = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =========================================================
        // HEADER
        // =========================================================

        const Text(
          'Availability & working hours',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111A3D),
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Set when you are available so patients can book appointments according to your schedule.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF7B849C),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 28),

        // =========================================================
        // AVAILABLE DAYS
        // =========================================================

        const _SectionHeader(
          title: 'Working days',
          subtitle: 'Select the days when you are available.',
        ),

        const SizedBox(height: 16),

        Wrap(
          spacing: 9,
          runSpacing: 10,
          children: _days.map((day) {
            final isSelected = selectedDays.contains(day);

            return InkWell(
              onTap: () {
                final updatedDays = Set<String>.from(selectedDays);

                if (isSelected) {
                  updatedDays.remove(day);
                } else {
                  updatedDays.add(day);
                }

                onDaysChanged(updatedDays);
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 58,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF246BFD)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF246BFD)
                        : const Color(0xFFE1E6EF),
                  ),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF59637A),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 30),

        // =========================================================
        // WORKING HOURS
        // =========================================================

        const _SectionHeader(
          title: 'Working hours',
          subtitle: 'Set your usual availability for appointments.',
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _TimeCard(
                title: 'Start time',
                time: startTime,
                icon: Icons.login_rounded,
                onTap: () async {
                  final selectedTime =
                      await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );

                  if (selectedTime != null) {
                    onStartTimeChanged(selectedTime);
                  }
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _TimeCard(
                title: 'End time',
                time: endTime,
                icon: Icons.logout_rounded,
                onTap: () async {
                  final selectedTime =
                      await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );

                  if (selectedTime != null) {
                    onEndTimeChanged(selectedTime);
                  }
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // =========================================================
        // CONSULTATION TYPES
        // =========================================================

        const _SectionHeader(
          title: 'Services you provide',
          subtitle: 'Choose how patients can consult with you.',
        ),

        const SizedBox(height: 16),

        _AvailabilityOption(
          icon: Icons.home_work_outlined,
          title: 'Home visits',
          subtitle:
              'Visit patients at their home or preferred location.',
          value: homeVisitsAvailable,
          onChanged: onHomeVisitsChanged,
        ),

        const SizedBox(height: 12),

        _AvailabilityOption(
          icon: Icons.local_hospital_outlined,
          title: 'Clinic appointments',
          subtitle:
              'Provide treatment at your clinic or practice location.',
          value: clinicVisitsAvailable,
          onChanged: onClinicVisitsChanged,
        ),

        const SizedBox(height: 12),

        _AvailabilityOption(
          icon: Icons.video_call_outlined,
          title: 'Online consultation',
          subtitle:
              'Offer virtual consultations and follow-up sessions.',
          value: onlineConsultationAvailable,
          onChanged: onOnlineConsultationChanged,
        ),

        const SizedBox(height: 28),

        // =========================================================
        // DAILY APPOINTMENT LIMIT
        // =========================================================

        const _SectionHeader(
          title: 'Daily appointment limit',
          subtitle:
              'Control how many patient appointments you want to accept per day.',
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE1E6EF),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: Color(0xFF246BFD),
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maximum appointments',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF27314D),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Maximum bookings accepted per day',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF7B849C),
                      ),
                    ),
                  ],
                ),
              ),

              _CounterButton(
                icon: Icons.remove,
                onTap: maxAppointmentsPerDay > 1
                    ? () {
                        onMaxAppointmentsChanged(
                          maxAppointmentsPerDay - 1,
                        );
                      }
                    : null,
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$maxAppointmentsPerDay',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111A3D),
                  ),
                ),
              ),

              _CounterButton(
                icon: Icons.add,
                onTap: maxAppointmentsPerDay < 50
                    ? () {
                        onMaxAppointmentsChanged(
                          maxAppointmentsPerDay + 1,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // =========================================================
        // EMERGENCY AVAILABILITY
        // =========================================================

        const _SectionHeader(
          title: 'Additional availability',
          subtitle:
              'Enable emergency availability if you accept urgent appointments.',
        ),

        const SizedBox(height: 16),

        _AvailabilityOption(
          icon: Icons.emergency_outlined,
          title: 'Emergency appointments',
          subtitle:
              'Allow patients to request urgent physiotherapy sessions.',
          value: emergencyAvailable,
          onChanged:
              onEmergencyAvailabilityChanged,
          isEmergency: true,
        ),

        const SizedBox(height: 24),

        // =========================================================
        // INFORMATION BOX
        // =========================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFD5E4FF),
            ),
          ),
          child: const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF246BFD),
              ),

              SizedBox(width: 11),

              Expanded(
                child: Text(
                  'You can update your availability later from your professional dashboard. Patients will only see available appointment slots.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF4B5B78),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}

// ================================================================
// SECTION HEADER
// ================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111A3D),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            height: 1.45,
            color: Color(0xFF7B849C),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// TIME CARD
// ================================================================

class _TimeCard extends StatelessWidget {
  final String title;
  final TimeOfDay time;
  final IconData icon;
  final VoidCallback onTap;

  const _TimeCard({
    required this.title,
    required this.time,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE1E6EF),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 21,
              color: const Color(0xFF246BFD),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF7B849C),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              time.format(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111A3D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// AVAILABILITY OPTION
// ================================================================

class _AvailabilityOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isEmergency;

  const _AvailabilityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isEmergency
        ? const Color(0xFFE5484D)
        : const Color(0xFF246BFD);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: value
            ? activeColor.withValues(alpha: 0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: value
              ? activeColor.withValues(alpha: 0.35)
              : const Color(0xFFE1E6EF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: value
                  ? activeColor.withValues(alpha: 0.12)
                  : const Color(0xFFF3F6FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: value
                  ? activeColor
                  : const Color(0xFF59637A),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF27314D),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: Color(0xFF7B849C),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Switch(
            value: value,
            activeThumbColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// COUNTER BUTTON
// ================================================================

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: enabled
          ? const Color(0xFFEAF2FF)
          : const Color(0xFFF1F3F6),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 19,
            color: enabled
                ? const Color(0xFF246BFD)
                : const Color(0xFFB0B7C3),
          ),
        ),
      ),
    );
  }
}