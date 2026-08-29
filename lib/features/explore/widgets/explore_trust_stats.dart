import 'package:flutter/material.dart';

class ExploreTrustStats extends StatelessWidget {
  const ExploreTrustStats({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF1F1FF),
            Color(0xFFEAF9F6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3E6F1),
        ),
      ),
      child: Row(
        children: const [
          Expanded(
            child: _TrustStat(
              value: '100+',
              label: 'Verified Physios',
              icon: Icons.verified_rounded,
            ),
          ),

          _StatDivider(),

          Expanded(
            child: _TrustStat(
              value: '10K+',
              label: 'Sessions',
              icon: Icons.people_alt_rounded,
            ),
          ),

          _StatDivider(),

          Expanded(
            child: _TrustStat(
              value: '4.8',
              label: 'Average Rating',
              icon: Icons.star_rounded,
            ),
          ),
        ],
      ),
    );
  }
}


// ===============================================================
// TRUST STAT
// ===============================================================

class _TrustStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _TrustStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 29,
          height: 29,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.75),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 14,
            color: const Color(0xFF5146D9),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF121A3A),
            fontWeight: FontWeight.w900,
            letterSpacing: -.3,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
            fontSize: 7.5,
            height: 1.15,
            color: Color(0xFF69728D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}


// ===============================================================
// DIVIDER
// ===============================================================

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: const Color(0xFFDDE1EC),
    );
  }
}