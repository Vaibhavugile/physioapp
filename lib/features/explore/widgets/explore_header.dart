import 'package:flutter/material.dart';

class ExploreHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const ExploreHeader({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 214,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF171B4B), Color(0xFF39318C), Color(0xFF5146D9)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF342C91).withOpacity(.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -62,
            top: -92,
            child: _GlowOrb(size: 240, color: const Color(0xFF9D91FF)),
          ),
          Positioned(
            right: 54,
            bottom: -118,
            child: _GlowOrb(size: 220, color: const Color(0xFF28D5B5)),
          ),
          Positioned(
            right: 18,
            bottom: 22,
            child: Container(
              width: 122,
              height: 122,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(.12), width: 1.2),
              ),
              child: Center(
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.08),
                    border: Border.all(color: Colors.white.withOpacity(.16)),
                  ),
                  child: const Icon(
                    Icons.accessibility_new_rounded,
                    size: 58,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 111,
            bottom: 100,
            child: _FloatingIcon(icon: Icons.favorite_rounded, color: Color(0xFFFF8DAB)),
          ),
          Positioned(
            right: 24,
            bottom: 145,
            child: _FloatingIcon(icon: Icons.health_and_safety_rounded, color: Color(0xFF77E4D1)),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                _HeaderAction(
                  icon: Icons.notifications_none_rounded,
                  onTap: onNotificationTap,
                  showDot: true,
                ),
                const SizedBox(width: 9),
                _HeaderAction(
                  icon: Icons.person_outline_rounded,
                  onTap: onProfileTap,
                ),
              ],
            ),
          ),
          Positioned(
            left: 22,
            top: 25,
            right: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(.18)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 11, color: Color(0xFF9EF0DE)),
                      SizedBox(width: 5),
                      Text(
                        'PERSONALISED CARE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 17),
                const Text(
                  'Move better.\nFeel stronger.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Find the right physiotherapist for your recovery.',
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.76),
                    fontSize: 10.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 22,
            bottom: 16,
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF83E5D2)),
                const SizedBox(width: 5),
                Text(
                  'Trusted professionals • Care that fits you',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.86),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(.30), color.withOpacity(.08), Colors.transparent],
        ),
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _FloatingIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.16),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withOpacity(.2)),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool showDot;

  const _HeaderAction({
    required this.icon,
    this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.13),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 39,
          height: 39,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              if (showDot)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF8DAB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
