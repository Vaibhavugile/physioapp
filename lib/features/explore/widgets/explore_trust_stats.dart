import 'package:flutter/material.dart';

class ExploreTrustStats extends StatelessWidget {
  const ExploreTrustStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 15, 13, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EAF2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26345C).withOpacity(.045),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'CARE YOU CAN FEEL CONFIDENT ABOUT',
            style: TextStyle(color: Color(0xFF9AA1B2), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.15),
          ),
          const SizedBox(height: 13),
          const Row(
            children: [
              Expanded(child: _TrustStat(value: '100+', label: 'Verified Physios', icon: Icons.verified_rounded)),
              _StatDivider(),
              Expanded(child: _TrustStat(value: '10K+', label: 'Sessions', icon: Icons.people_alt_rounded)),
              _StatDivider(),
              Expanded(child: _TrustStat(value: '4.8', label: 'Average Rating', icon: Icons.star_rounded)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _TrustStat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFF0EEFF), Color(0xFFEAF8F5)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF5146D9)),
        ),
        const SizedBox(height: 7),
        Text(value, style: const TextStyle(fontSize: 16, color: Color(0xFF121A3A), fontWeight: FontWeight.w900, letterSpacing: -.5)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 8, height: 1.2, color: Color(0xFF7B849C), fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 57, margin: const EdgeInsets.symmetric(horizontal: 3),
    color: const Color(0xFFEAECF3),
  );
}
