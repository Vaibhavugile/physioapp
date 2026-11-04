import 'package:flutter/material.dart';

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
      _ServiceConfig('home', 'Home visits', 'Travel to patients within your service radius', Icons.home_work_outlined, homeVisitsAvailable, onHomeVisitsChanged),
      _ServiceConfig('clinic', 'Clinic visits', 'Appointments at your registered clinic', Icons.local_hospital_outlined, clinicVisitsAvailable, onClinicVisitsChanged),
      _ServiceConfig('online', 'Online consultations', 'Video consultations from anywhere', Icons.video_call_outlined, onlineConsultationAvailable, onOnlineConsultationChanged),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Your availability', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -.6, color: Color(0xFF173F3B))),
      const SizedBox(height: 7),
      const Text('Turn on the services you offer, then set separate days and timings for each one. You can choose flexible availability when your schedule is open.', style: TextStyle(fontSize: 14, height: 1.55, color: Color(0xFF718D89))),
      const SizedBox(height: 20),
      ...services.map((service) => _ServiceScheduleCard(
        config: service,
        value: Map<String, dynamic>.from(serviceSchedules[service.key] is Map ? serviceSchedules[service.key] as Map : {}),
        onEnabled: service.onChanged,
        onChanged: (value) {
          final updated = Map<String, dynamic>.from(serviceSchedules);
          updated[service.key] = value;
          onServiceSchedulesChanged(updated);
        },
      )),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF5FAF9), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE3EFEC))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Booking preferences', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF234641))),
        const SizedBox(height: 12),
        SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, value: emergencyAvailable, onChanged: onEmergencyAvailabilityChanged, title: const Text('Emergency appointments', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), subtitle: const Text('Allow patients to request urgent appointments', style: TextStyle(fontSize: 11))),
        Row(children: [const Expanded(child: Text('Maximum appointments per day', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700))), IconButton(onPressed: maxAppointmentsPerDay > 1 ? () => onMaxAppointmentsChanged(maxAppointmentsPerDay - 1) : null, icon: const Icon(Icons.remove_circle_outline)), Text('$maxAppointmentsPerDay', style: const TextStyle(fontWeight: FontWeight.w800)), IconButton(onPressed: maxAppointmentsPerDay < 50 ? () => onMaxAppointmentsChanged(maxAppointmentsPerDay + 1) : null, icon: const Icon(Icons.add_circle_outline))]),
      ])),
    ]);
  }
}

class _ServiceConfig {
  final String key, title, subtitle;
  final IconData icon;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  const _ServiceConfig(this.key, this.title, this.subtitle, this.icon, this.enabled, this.onChanged);
}

class _ServiceScheduleCard extends StatelessWidget {
  final _ServiceConfig config;
  final Map<String, dynamic> value;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const _ServiceScheduleCard({required this.config, required this.value, required this.onEnabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final days = List<String>.from(value['days'] ?? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']);
    final start = _parseTime(value['startTime']?.toString()) ?? const TimeOfDay(hour: 9, minute: 0);
    final end = _parseTime(value['endTime']?.toString()) ?? const TimeOfDay(hour: 18, minute: 0);
    final flexible = value['flexible'] == true;
    return AnimatedContainer(duration: const Duration(milliseconds: 180), margin: const EdgeInsets.only(bottom: 13), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: config.enabled ? const Color(0xFFBDE9E2) : const Color(0xFFE3EFEC)), boxShadow: const [BoxShadow(color: Color(0x070D1B2A), blurRadius: 18, offset: Offset(0, 7))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFEAF7F5), borderRadius: BorderRadius.circular(13)), child: Icon(config.icon, color: const Color(0xFF0A9C8C))), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(config.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF26354B))), const SizedBox(height: 3), Text(config.subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF829994)))])), Switch.adaptive(value: config.enabled, onChanged: (enabled) { onEnabled(enabled); onChanged({...value, 'enabled': enabled, 'days': days, 'startTime': _formatTime(start), 'endTime': _formatTime(end), 'flexible': flexible}); })]),
      if (config.enabled) ...[
        const Divider(height: 24),
        Wrap(spacing: 7, runSpacing: 7, children: AvailabilityStep._days.map((day) { final selected = days.contains(day); return InkWell(onTap: () { final next = List<String>.from(days); selected ? next.remove(day) : next.add(day); onChanged({...value, 'enabled': true, 'days': next, 'startTime': _formatTime(start), 'endTime': _formatTime(end), 'flexible': flexible}); }, borderRadius: BorderRadius.circular(10), child: AnimatedContainer(duration: const Duration(milliseconds: 150), width: 39, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: selected ? const Color(0xFF0A9C8C) : const Color(0xFFF3FAF9), borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? const Color(0xFF0A9C8C) : const Color(0xFFE3EFEC))), child: Text(day, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: selected ? Colors.white : const Color(0xFF718D89))))); }).toList()),
        const SizedBox(height: 12),
        SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, dense: true, value: flexible, onChanged: (v) => onChanged({...value, 'enabled': true, 'days': days, 'startTime': _formatTime(start), 'endTime': _formatTime(end), 'flexible': v}), title: const Text('Flexible / anytime availability', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), subtitle: const Text('Patients can request any time on your selected days', style: TextStyle(fontSize: 10))),
        if (!flexible) Row(children: [Expanded(child: _TimeButton(label: 'From', value: start, onTap: () async { final picked = await showTimePicker(context: context, initialTime: start); if (picked != null) onChanged({...value, 'enabled': true, 'days': days, 'startTime': _formatTime(picked), 'endTime': _formatTime(end), 'flexible': false}); })), const SizedBox(width: 10), Expanded(child: _TimeButton(label: 'Until', value: end, onTap: () async { final picked = await showTimePicker(context: context, initialTime: end); if (picked != null) onChanged({...value, 'enabled': true, 'days': days, 'startTime': _formatTime(start), 'endTime': _formatTime(picked), 'flexible': false}); }))]),
        if (days.isEmpty) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Select at least one day for this service.', style: TextStyle(color: Colors.red, fontSize: 11))),
      ],
    ]));
  }

  static TimeOfDay? _parseTime(String? value) { if (value == null || !value.contains(':')) return null; final parts = value.split(':'); final h = int.tryParse(parts[0]); final m = int.tryParse(parts[1]); if (h == null || m == null) return null; return TimeOfDay(hour: h, minute: m); }
  static String _formatTime(TimeOfDay value) => '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class _TimeButton extends StatelessWidget {
  final String label;
  final TimeOfDay value;
  final VoidCallback onTap;
  const _TimeButton({required this.label, required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11), decoration: BoxDecoration(color: const Color(0xFFF5FAF9), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE3EFEC))), child: Row(children: [Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF829994))), const Spacer(), Text(value.format(context), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF234641))), const SizedBox(width: 5), const Icon(Icons.schedule_rounded, size: 15, color: Color(0xFF0A9C8C))])));
}
