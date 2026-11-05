import 'package:flutter/material.dart';

import 'premium_theme.dart';

class AvailabilityStep extends StatelessWidget {
  final bool homeVisitsAvailable;
  final bool clinicVisitsAvailable;
  final bool onlineConsultationAvailable;
  final bool emergencyAvailable;
  final int maxAppointmentsPerDay;
  final ValueChanged<bool> onHomeVisitsChanged;
  final ValueChanged<bool> onClinicVisitsChanged;
  final ValueChanged<bool> onOnlineConsultationChanged;
  final ValueChanged<bool> onEmergencyAvailabilityChanged;
  final ValueChanged<int> onMaxAppointmentsChanged;
  final Map<String, dynamic> serviceSchedules;
  final ValueChanged<Map<String, dynamic>> onServiceSchedulesChanged;

  const AvailabilityStep({
    super.key,
    required this.homeVisitsAvailable,
    required this.clinicVisitsAvailable,
    required this.onlineConsultationAvailable,
    required this.emergencyAvailable,
    required this.maxAppointmentsPerDay,
    required this.onHomeVisitsChanged,
    required this.onClinicVisitsChanged,
    required this.onOnlineConsultationChanged,
    required this.onEmergencyAvailabilityChanged,
    required this.onMaxAppointmentsChanged,
    this.serviceSchedules = const {},
    required this.onServiceSchedulesChanged,
  });

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final services = [
      _ServiceConfig('home', 'Home visits', 'Travel to patients within your radius',
          Icons.home_work_outlined, homeVisitsAvailable, onHomeVisitsChanged),
      _ServiceConfig('clinic', 'Clinic visits', 'Appointments at your clinic',
          Icons.local_hospital_outlined, clinicVisitsAvailable, onClinicVisitsChanged),
      _ServiceConfig('online', 'Online consultations', 'Video consultations from anywhere',
          Icons.video_call_outlined, onlineConsultationAvailable, onOnlineConsultationChanged),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final service in services)
          _ServiceScheduleCard(
            config: service,
            value: Map<String, dynamic>.from(
              serviceSchedules[service.key] is Map
                  ? serviceSchedules[service.key] as Map
                  : {},
            ),
            onEnabled: service.onChanged,
            onChanged: (value) {
              final updated = Map<String, dynamic>.from(serviceSchedules);
              updated[service.key] = value;
              onServiceSchedulesChanged(updated);
            },
          ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
          decoration: PX.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Booking preferences', style: PX.display(17)),
              const SizedBox(height: 6),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: emergencyAvailable,
                onChanged: onEmergencyAvailabilityChanged,
                title: const Text('Emergency appointments',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                subtitle: const Text('Allow patients to request urgent appointments',
                    style: TextStyle(fontSize: 12, color: PX.muted)),
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text('Maximum appointments per day',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    tooltip: 'Decrease',
                    onPressed: maxAppointmentsPerDay > 1
                        ? () => onMaxAppointmentsChanged(maxAppointmentsPerDay - 1)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$maxAppointmentsPerDay', style: PX.display(18)),
                  IconButton(
                    tooltip: 'Increase',
                    onPressed: maxAppointmentsPerDay < 50
                        ? () => onMaxAppointmentsChanged(maxAppointmentsPerDay + 1)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceConfig {
  final String key, title, subtitle;
  final IconData icon;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  const _ServiceConfig(this.key, this.title, this.subtitle, this.icon,
      this.enabled, this.onChanged);
}

class _ServiceScheduleCard extends StatelessWidget {
  final _ServiceConfig config;
  final Map<String, dynamic> value;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const _ServiceScheduleCard({
    required this.config,
    required this.value,
    required this.onEnabled,
    required this.onChanged,
  });

  Map<String, dynamic> _merge(Map<String, dynamic> patch, List<String> days,
      TimeOfDay start, TimeOfDay end, bool flexible) {
    return {
      ...value,
      'enabled': true,
      'days': days,
      'startTime': _formatTime(start),
      'endTime': _formatTime(end),
      'flexible': flexible,
      ...patch,
    };
  }

  @override
  Widget build(BuildContext context) {
    final days = List<String>.from(
        value['days'] ?? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']);
    final start = _parseTime(value['startTime']?.toString()) ??
        const TimeOfDay(hour: 9, minute: 0);
    final end = _parseTime(value['endTime']?.toString()) ??
        const TimeOfDay(hour: 18, minute: 0);
    final flexible = value['flexible'] == true;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: config.enabled ? PX.teal : PX.line,
          width: config.enabled ? 2 : 1,
        ),
        boxShadow: PX.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: config.enabled ? PX.deep : PX.soft,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(config.icon,
                    color: config.enabled ? PX.mint : PX.teal),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(config.title, style: PX.display(17)),
                    const SizedBox(height: 3),
                    Text(config.subtitle,
                        style: const TextStyle(fontSize: 12, color: PX.muted)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: config.enabled,
                onChanged: (enabled) {
                  onEnabled(enabled);
                  onChanged({
                    ...value,
                    'enabled': enabled,
                    'days': days,
                    'startTime': _formatTime(start),
                    'endTime': _formatTime(end),
                    'flexible': flexible,
                  });
                },
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !config.enabled
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final day in AvailabilityStep._days)
                            _DayChip(
                              day: day,
                              selected: days.contains(day),
                              onTap: () {
                                final next = List<String>.from(days);
                                days.contains(day)
                                    ? next.remove(day)
                                    : next.add(day);
                                onChanged(_merge({'days': next}, days, start, end, flexible));
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: flexible,
                        onChanged: (v) => onChanged(
                            _merge({'flexible': v}, days, start, end, flexible)),
                        title: const Text('Flexible, anytime on these days',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        subtitle: const Text(
                            'Patients can request any time on your selected days',
                            style: TextStyle(fontSize: 11, color: PX.muted)),
                      ),
                      if (!flexible)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: _TimeButton(
                                  label: 'From',
                                  value: start,
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                        context: context, initialTime: start);
                                    if (picked != null) {
                                      onChanged(_merge({
                                        'startTime': _formatTime(picked),
                                        'flexible': false,
                                      }, days, start, end, flexible));
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _TimeButton(
                                  label: 'Until',
                                  value: end,
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                        context: context, initialTime: end);
                                    if (picked != null) {
                                      onChanged(_merge({
                                        'endTime': _formatTime(picked),
                                        'flexible': false,
                                      }, days, start, end, flexible));
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (days.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('Select at least one day for this service.',
                              style: TextStyle(color: PX.danger, fontSize: 12)),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static TimeOfDay? _parseTime(String? value) {
    if (value == null || !value.contains(':')) return null;
    final parts = value.split(':');
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static String _formatTime(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class _DayChip extends StatelessWidget {
  final String day;
  final bool selected;
  final VoidCallback onTap;
  const _DayChip({required this.day, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: day,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? PX.teal : PX.field,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: selected ? PX.teal : PX.line),
          ),
          child: Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : PX.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final TimeOfDay value;
  final VoidCallback onTap;
  const _TimeButton({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: PX.field,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PX.line),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: PX.muted)),
                const SizedBox(height: 2),
                Text(value.format(context), style: PX.display(16)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.schedule_rounded, size: 18, color: PX.teal),
          ],
        ),
      ),
    );
  }
}
