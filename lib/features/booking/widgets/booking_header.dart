import 'package:flutter/material.dart';

/// Reusable premium booking header.
/// Keeps the existing constructor/API so the booking flow can drop it in.
class BookingHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackTap;
  final VoidCallback? onHelpTap;

  const BookingHeader({
    super.key,
    this.title = 'Confirm appointment',
    this.subtitle = 'Your care, your way',
    this.onBackTap,
    this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderAction(
          icon: Icons.arrow_back_rounded,
          onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF101A3A),
                  fontSize: 19,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.55,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF18A889),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF78819A),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _HeaderAction(
          icon: Icons.support_agent_rounded,
          onTap: onHelpTap,
          highlighted: true,
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool highlighted;

  const _HeaderAction({
    required this.icon,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            gradient: highlighted
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEDEBFF), Color(0xFFE7F8F4)],
                  )
                : null,
            color: highlighted ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlighted
                  ? const Color(0xFFDDE5F0)
                  : const Color(0xFFE6EAF2),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D2A54).withOpacity(.045),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: highlighted
                ? const Color(0xFF5146D9)
                : const Color(0xFF1D294B),
          ),
        ),
      ),
    );
  }
}
