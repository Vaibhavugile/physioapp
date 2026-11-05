import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared premium look for the physiotherapist auth screens.
/// Change [AX.brand] to rename the app everywhere.
class AX {
  static const brand = 'PhysioCare';

  static const bg = Color(0xFFF3F6F4);
  static const ink = Color(0xFF0E2B28);
  static const muted = Color(0xFF55706B);
  static const teal = Color(0xFF0B7A70);
  static const deep = Color(0xFF0C3B37);
  static const deep2 = Color(0xFF0A524B);
  static const mint = Color(0xFF3FE0C5);
  static const soft = Color(0xFFE6F4F0);
  static const line = Color(0xFFE3EBE8);

  static const cardShadow = [
    BoxShadow(color: Color(0x120E2B28), blurRadius: 30, offset: Offset(0, 10)),
  ];

  static TextStyle display(double size, {Color color = ink}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -size * 0.03,
        color: color,
      );
}

/// Fade + rise entrance, staggered with [delayMs].
class AXReveal extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const AXReveal({super.key, required this.child, this.delayMs = 0});

  @override
  State<AXReveal> createState() => _AXRevealState();
}

class _AXRevealState extends State<AXReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _a,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, .12), end: Offset.zero)
              .animate(_a),
          child: widget.child,
        ),
      );
}

/// Dark pill call-to-action with a mint arrow.
class AXPill extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  const AXPill({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null && !loading ? .5 : 1,
      child: Material(
        color: AX.deep,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: loading ? null : onPressed,
          child: SizedBox(
            height: 62,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 9, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                        color: AX.mint, shape: BoxShape.circle),
                    child: loading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: AX.deep),
                          )
                        : const Icon(Icons.arrow_forward_rounded,
                            color: AX.deep, size: 23),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Deep-teal rounded header panel that hosts the artwork.
class AXPanel extends StatelessWidget {
  final double height;
  final Widget child;
  const AXPanel({super.key, required this.height, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AX.deep, AX.deep2],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(44)),
        ),
        child: SafeArea(bottom: false, child: child),
      );
}

class AXBrandRow extends StatelessWidget {
  final Widget? trailing;
  const AXBrandRow({super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AX.mint,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.favorite_rounded, color: AX.deep, size: 21),
            ),
            const SizedBox(width: 10),
            Text(AX.brand, style: AX.display(18, color: Colors.white)),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

class AXSecureBadge extends StatelessWidget {
  const AXSecureBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: .16)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_rounded, size: 14, color: AX.mint),
            SizedBox(width: 6),
            Text('Secure',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class AXBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  const AXBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withValues(alpha: .10),
        shape: CircleBorder(
            side: BorderSide(color: Colors.white.withValues(alpha: .16))),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: 46,
            height: 46,
            child: Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
      );
}

// ===================================================================
// HERO ART: orbiting rings, floating glass chips, heartbeat line
// ===================================================================

class AXHeroArt extends StatefulWidget {
  const AXHeroArt({super.key});

  @override
  State<AXHeroArt> createState() => _AXHeroArtState();
}

class _AXHeroArtState extends State<AXHeroArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        double bob(double phase) => math.sin((t + phase) * 2 * math.pi) * 6;
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: CustomPaint(painter: _RingsPainter(t))),
            Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AX.mint.withValues(alpha: .26 + .06 * math.sin(t * 2 * math.pi)),
                  Colors.transparent,
                ]),
              ),
            ),
            Transform.scale(
              scale: 1 + .025 * math.sin(t * 4 * math.pi),
              child: Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F9484), AX.deep],
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: .16)),
                  boxShadow: [
                    BoxShadow(
                      color: AX.mint.withValues(alpha: .25),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: const Icon(Icons.accessibility_new_rounded,
                    size: 70, color: AX.mint),
              ),
            ),
            Align(
              alignment: const Alignment(-.92, -.55),
              child: Transform.translate(
                offset: Offset(0, bob(0)),
                child: const _GlassChip(Icons.verified_rounded, 'Verified'),
              ),
            ),
            Align(
              alignment: const Alignment(.95, -.05),
              child: Transform.translate(
                offset: Offset(0, bob(.33)),
                child: const _GlassChip(Icons.home_work_rounded, 'Home visits'),
              ),
            ),
            Align(
              alignment: const Alignment(-.75, .55),
              child: Transform.translate(
                offset: Offset(0, bob(.66)),
                child: const _GlassChip(Icons.event_available_rounded, 'Booked'),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              height: 44,
              child: CustomPaint(painter: _EcgPainter(t)),
            ),
          ],
        );
      },
    );
  }
}

class _GlassChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GlassChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: .18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: AX.mint),
            const SizedBox(width: 7),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _RingsPainter extends CustomPainter {
  final double t;
  _RingsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final base = math.min(size.width, size.height) / 2;
    final radii = [base * .52, base * .74, base * .96];
    const dashes = 36;
    for (var i = 0; i < radii.length; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: .10 + .03 * i);
      final dir = i.isEven ? 1 : -1;
      final start = t * 2 * math.pi * dir / (i + 1);
      for (var k = 0; k < dashes; k++) {
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: radii[i]),
          start + k * 2 * math.pi / dashes,
          2 * math.pi / dashes * .55,
          false,
          paint,
        );
      }
    }
    final a = -t * 2 * math.pi;
    canvas.drawCircle(
      c + Offset(math.cos(a), math.sin(a)) * radii[1],
      4.5,
      Paint()..color = AX.mint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) => old.t != t;
}

class _EcgPainter extends CustomPainter {
  final double t;
  _EcgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, m = h / 2;
    final path = Path()
      ..moveTo(0, m)
      ..lineTo(w * .30, m)
      ..lineTo(w * .34, m - h * .18)
      ..lineTo(w * .38, m + h * .10)
      ..lineTo(w * .43, m - h * .45)
      ..lineTo(w * .48, m + h * .42)
      ..lineTo(w * .53, m)
      ..lineTo(w * .62, m)
      ..lineTo(w * .66, m - h * .12)
      ..lineTo(w * .70, m)
      ..lineTo(w, m);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: .12),
    );
    final metric = path.computeMetrics().first;
    final s = t * metric.length;
    final e = math.min(s + metric.length * .25, metric.length);
    canvas.drawPath(
      metric.extractPath(s, e),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round
        ..color = AX.mint,
    );
  }

  @override
  bool shouldRepaint(covariant _EcgPainter old) => old.t != t;
}

// ===================================================================
// SHIELD ART (OTP): ripples around a secure badge
// ===================================================================

class AXShieldArt extends StatefulWidget {
  const AXShieldArt({super.key});

  @override
  State<AXShieldArt> createState() => _AXShieldArtState();
}

class _AXShieldArtState extends State<AXShieldArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Stack(
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < 3; i++)
              Builder(builder: (context) {
                final v = (_c.value + i / 3) % 1.0;
                return Opacity(
                  opacity: (1 - v) * .55,
                  child: Transform.scale(
                    scale: .7 + v * .95,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AX.mint, width: 1.5),
                      ),
                    ),
                  ),
                );
              }),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F9484), AX.deep],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: .18)),
                boxShadow: [
                  BoxShadow(
                      color: AX.mint.withValues(alpha: .28), blurRadius: 36),
                ],
              ),
              child: const Icon(Icons.verified_user_rounded,
                  size: 46, color: AX.mint),
            ),
          ],
        ),
      );
}

// ===================================================================
// ORB (status screens) + LOADING
// ===================================================================

class AXOrb extends StatefulWidget {
  final IconData icon;
  final Color color;
  const AXOrb({super.key, required this.icon, this.color = AX.mint});

  @override
  State<AXOrb> createState() => _AXOrbState();
}

class _AXOrbState extends State<AXOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Stack(
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < 2; i++)
              Builder(builder: (context) {
                final v = (_c.value + i / 2) % 1.0;
                return Opacity(
                  opacity: (1 - v) * .5,
                  child: Transform.scale(
                    scale: .8 + v * .7,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: widget.color, width: 1.5),
                      ),
                    ),
                  ),
                );
              }),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .08),
                border: Border.all(color: widget.color.withValues(alpha: .6)),
              ),
              child: Icon(widget.icon, size: 44, color: widget.color),
            ),
          ],
        ),
      );
}

class AXLoadingScreen extends StatelessWidget {
  const AXLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: AX.deep,
        body: Center(child: AXOrb(icon: Icons.favorite_rounded)),
      );
}
