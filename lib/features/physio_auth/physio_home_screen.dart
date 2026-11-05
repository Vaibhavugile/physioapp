import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../physio_onboarding/widgets/onboarding_ui.dart';

/// Premium physio-at-home provider dashboard (light theme, fully animated).
///
/// Premium dashboard with intentionally hardcoded demo content for the
/// initial launch. Replace demo values with live services when ready.
class PhysioHomeScreen extends StatefulWidget {
  final String name;
  final bool isPending;
  final VoidCallback? onNavigate;
  final VoidCallback? onStartSession;
  final VoidCallback? onNotifications;
  final ValueChanged<int>? onTabChanged;
  final ValueChanged<bool>? onAcceptingChanged;

  const PhysioHomeScreen({
    super.key,
    this.name = 'Dr. Aarav Mehta',
    this.isPending = false,
    this.onNavigate,
    this.onStartSession,
    this.onNotifications,
    this.onTabChanged,
    this.onAcceptingChanged,
  });

  @override
  State<PhysioHomeScreen> createState() => _PhysioHomeScreenState();
}

class _PhysioHomeScreenState extends State<PhysioHomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _pulse;
  bool _accepting = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _enter.dispose();
    _pulse.dispose();
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _initials {
    final parts = widget.name
        .replaceAll('Dr.', '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Theme(
      data: OB.theme(context),
      child: Scaffold(
        backgroundColor: OB.canvas,
        body: Stack(
          children: [
            // Soft ambient glow behind the header — the only decoration.
            Positioned(
              top: -140,
              right: -90,
              child: IgnorePointer(
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x332FD5B3), Color(0x002FD5B3)],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20, 14, 20, 120 + bottomInset),
                    children: [
                      _Reveal(parent: _enter, order: 0, child: _header()),
                      const SizedBox(height: 18),
                      _Reveal(parent: _enter, order: 1, child: _statusCard()),
                      const SizedBox(height: 18),
                      _Reveal(parent: _enter, order: 2, child: _nextVisit()),
                      const SizedBox(height: 14),
                      _Reveal(parent: _enter, order: 3, child: _earnings()),
                      const SizedBox(height: 12),
                      _Reveal(
                        parent: _enter,
                        order: 4,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _visitsTile()),
                            const SizedBox(width: 12),
                            Expanded(child: _ratingTile()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      _Reveal(parent: _enter, order: 5, child: _quickActions()),
                      const SizedBox(height: 28),
                      _Reveal(
                        parent: _enter,
                        order: 6,
                        child: const _SectionHeader(
                          title: 'Today’s schedule',
                          action: 'See all',
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (int i = 0; i < _demoVisits.length; i++)
                        _Reveal(
                          parent: _enter,
                          order: 7 + i,
                          child: _TimelineRow(
                            visit: _demoVisits[i],
                            isLast: i == _demoVisits.length - 1,
                            pulse: _pulse,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 14 + bottomInset,
              child: _Reveal(
                parent: _enter,
                order: 9,
                from: const Offset(0, .5),
                child: Center(
                  child: _FloatingNav(
                    index: _tab,
                    onChanged: (i) {
                      setState(() => _tab = i);
                      widget.onTabChanged?.call(i);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Header
  // ------------------------------------------------------------------
  Widget _header() => Row(
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(color: OB.ink, shape: BoxShape.circle),
            child: Text(
              _initials,
              style: const TextStyle(
                color: OB.mint,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: .5,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting, style: OB.caption),
                const SizedBox(height: 2),
                Text(
                  widget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.6,
                    color: OB.ink,
                  ),
                ),
              ],
            ),
          ),
          _Pressable(
            onTap: widget.onNotifications,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: OB.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: OB.line),
                  ),
                  child: const Icon(Icons.notifications_none_rounded,
                      color: OB.ink, size: 22),
                ),
                Positioned(
                  top: 10,
                  right: 11,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: OB.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: OB.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  // ------------------------------------------------------------------
  // Accepting-visits status
  // ------------------------------------------------------------------
  Widget _statusCard() => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
        decoration: BoxDecoration(
          color: OB.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: _accepting ? OB.mint : OB.line, width: 1.4),
        ),
        child: Row(
          children: [
            _PulseDot(controller: _pulse, active: widget.isPending ? false : _accepting),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  widget.isPending
                      ? 'Demo dashboard · profile under review'
                      : (_accepting
                          ? 'Accepting new home visits'
                          : 'You’re offline — not taking requests'),
                  key: ValueKey('${widget.isPending}-$_accepting'),
                  style: OB.label,
                ),
              ),
            ),
            if (widget.isPending)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    color: Color(0xFF9A6500),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
              )
            else
              Switch.adaptive(
                value: _accepting,
                onChanged: (v) {
                  setState(() => _accepting = v);
                  widget.onAcceptingChanged?.call(v);
                },
              ),
          ],
        ),
      );

  // ------------------------------------------------------------------
  // Next visit hero
  // ------------------------------------------------------------------
  Widget _nextVisit() => ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: OB.ink),
          child: Stack(
            children: [
              Positioned(
                right: -70,
                top: -70,
                child: _RingDecor(controller: _pulse),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0x1F2FD5B3),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.home_work_outlined,
                                size: 14, color: OB.mint),
                            SizedBox(width: 6),
                            Text('Home visit',
                                style: TextStyle(
                                    color: OB.mint,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Text('Next visit',
                          style: TextStyle(
                              color: Color(0xFF8FA5A0),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ananya Kulkarni',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    height: 1.1,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -.8)),
                            SizedBox(height: 6),
                            Text('Knee rehab · Session 4 of 8',
                                style: TextStyle(
                                    color: Color(0xFF9DB2AD),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: .72),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => SizedBox(
                          width: 88,
                          height: 88,
                          child: CustomPaint(
                            painter: _RingPainter(v),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('42',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          height: 1,
                                          fontWeight: FontWeight.w800)),
                                  SizedBox(height: 2),
                                  Text('min',
                                      style: TextStyle(
                                          color: Color(0xFF8FA5A0),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 16, color: Color(0xFF8FA5A0)),
                      SizedBox(width: 7),
                      Text('10:30 AM',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      SizedBox(width: 14),
                      Icon(Icons.place_outlined,
                          size: 16, color: Color(0xFF8FA5A0)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text('Baner, Pune · 3.2 km',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color(0xFF9DB2AD),
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroButton(
                          label: 'Navigate',
                          icon: Icons.near_me_outlined,
                          onTap: widget.onNavigate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _HeroButton(
                          label: 'Start session',
                          icon: Icons.play_arrow_rounded,
                          primary: true,
                          onTap: widget.onStartSession,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  // ------------------------------------------------------------------
  // Earnings + weekly bars
  // ------------------------------------------------------------------
  Widget _earnings() {
    const bars = [.38, .62, .48, .8, .55, 1.0, .7];
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1;

    return ObSurface(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Today’s earnings', style: OB.caption),
                const SizedBox(height: 8),
                _CountUp(
                  value: 4850,
                  prefix: '₹',
                  style: const TextStyle(
                    fontSize: 34,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.4,
                    color: OB.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: OB.tint,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up_rounded,
                          size: 14, color: OB.pine),
                      SizedBox(width: 5),
                      Text('12% vs last week',
                          style: TextStyle(
                              color: OB.pine,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 128,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < bars.length; i++)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: bars[i]),
                        duration: Duration(milliseconds: 700 + i * 90),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => Container(
                          width: 12,
                          height: 64 * v + 4,
                          decoration: BoxDecoration(
                            color: i == today ? OB.ink : OB.tint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(days[i],
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: i == today ? OB.ink : OB.faint)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _visitsTile() => ObSurface(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Visits today', style: OB.caption),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const _CountUp(
                  value: 3,
                  style: TextStyle(
                    fontSize: 30,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: OB.ink,
                  ),
                ),
                const SizedBox(width: 4),
                Text('/ 6',
                    style: OB.body.copyWith(
                        fontWeight: FontWeight.w700, color: OB.faint)),
              ],
            ),
            const SizedBox(height: 14),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: .5),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: v,
                  minHeight: 6,
                  backgroundColor: OB.line,
                  valueColor: const AlwaysStoppedAnimation(OB.ink),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _ratingTile() => ObSurface(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Patient rating', style: OB.caption),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _CountUp(
                  value: 4.9,
                  decimals: 1,
                  style: TextStyle(
                    fontSize: 30,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: OB.ink,
                  ),
                ),
                const SizedBox(width: 6),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: .4, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.elasticOut,
                  builder: (context, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: const Icon(Icons.star_rounded,
                      color: Color(0xFFF2B01E), size: 24),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('128 reviews', style: OB.caption),
          ],
        ),
      );

  // ------------------------------------------------------------------
  // Quick actions
  // ------------------------------------------------------------------
  Widget _quickActions() {
    const items = [
      (Icons.calendar_month_outlined, 'Availability'),
      (Icons.account_balance_wallet_outlined, 'Earnings'),
      (Icons.groups_2_outlined, 'Patients'),
      (Icons.badge_outlined, 'Profile'),
    ];
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _Pressable(
              onTap: () {},
              child: Column(
                children: [
                  Container(
                    height: 62,
                    decoration: BoxDecoration(
                      color: OB.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: OB.line),
                    ),
                    child: Center(
                        child: Icon(items[i].$1, color: OB.pine, size: 24)),
                  ),
                  const SizedBox(height: 8),
                  Text(items[i].$2,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: OB.muted)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ====================================================================
// SAMPLE DATA
// ====================================================================

enum _VisitState { done, current, upcoming }

class _Visit {
  final String time;
  final String name;
  final String detail;
  final int kind; // 0 home, 1 clinic, 2 online
  final _VisitState state;
  const _Visit(this.time, this.name, this.detail, this.kind, this.state);
}

const List<_Visit> _demoVisits = [
  _Visit('08:00', 'Rohan Deshmukh', 'Lower back pain · Kothrud', 0,
      _VisitState.done),
  _Visit('09:15', 'Meera Iyer', 'Post-surgery rehab · Clinic', 1,
      _VisitState.done),
  _Visit('10:30', 'Ananya Kulkarni', 'Knee rehab · Baner', 0,
      _VisitState.current),
  _Visit('12:00', 'Sanjay Patil', 'Follow-up · Video call', 2,
      _VisitState.upcoming),
  _Visit('15:30', 'Kavita Rao', 'Neck & shoulder · Aundh', 0,
      _VisitState.upcoming),
];

// ====================================================================
// REUSABLE ANIMATED PIECES
// ====================================================================

/// Staggered entrance: fade + rise, driven by one parent controller.
class _Reveal extends StatelessWidget {
  final Animation<double> parent;
  final int order;
  final Widget child;
  final Offset from;

  const _Reveal({
    required this.parent,
    required this.order,
    required this.child,
    this.from = const Offset(0, .07),
  });

  @override
  Widget build(BuildContext context) {
    final start = (order * .07).clamp(0.0, .62);
    final end = (start + .38).clamp(0.0, 1.0);
    final curved = CurvedAnimation(
      parent: parent,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: from, end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}

/// Press-in scale feedback for any tappable.
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _Pressable({required this.child, this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? .94 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}

/// Number that counts up from zero when first shown.
class _CountUp extends StatelessWidget {
  final double value;
  final String prefix;
  final int decimals;
  final TextStyle style;

  const _CountUp({
    required this.value,
    required this.style,
    this.prefix = '',
    this.decimals = 0,
  });

  static String _group(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final last = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '${parts.join(',')},$last';
  }

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: const Duration(milliseconds: 1400),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) {
          final text = decimals == 0
              ? _group(v.round())
              : v.toStringAsFixed(decimals);
          return Text('$prefix$text', style: style);
        },
      );
}

/// Live status dot with an expanding halo.
class _PulseDot extends StatelessWidget {
  final AnimationController controller;
  final bool active;
  const _PulseDot({required this.controller, required this.active});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 26,
        height: 26,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final t = controller.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                if (active)
                  Container(
                    width: 10 + 16 * t,
                    height: 10 + 16 * t,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(47, 213, 179, (1 - t) * .45),
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? OB.mint : OB.faint,
                  ),
                ),
              ],
            );
          },
        ),
      );
}

/// Slow concentric rings drifting behind the hero card.
class _RingDecor extends StatelessWidget {
  final AnimationController controller;
  const _RingDecor({required this.controller});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => SizedBox(
            width: 240,
            height: 240,
            child: CustomPaint(painter: _DecorPainter(controller.value)),
          ),
        ),
      );
}

class _DecorPainter extends CustomPainter {
  final double t;
  _DecorPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (int i = 0; i < 3; i++) {
      final p = (t + i / 3) % 1.0;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Color.fromRGBO(47, 213, 179, (1 - p) * .22);
      canvas.drawCircle(c, 30 + p * 90, paint);
    }
  }

  @override
  bool shouldRepaint(_DecorPainter old) => old.t != t;
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = const Color(0x26FFFFFF);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = OB.mint;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _HeroButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback? onTap;

  const _HeroButton({
    required this.label,
    required this.icon,
    this.primary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => _Pressable(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: primary ? OB.mint : const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(26),
            border: primary ? null : Border.all(color: const Color(0x26FFFFFF)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: primary ? OB.ink : Colors.white),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: primary ? OB.ink : Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.6,
                    color: OB.ink)),
          ),
          if (action != null)
            Text(action!,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: OB.pine)),
        ],
      );
}

// ====================================================================
// SCHEDULE TIMELINE
// ====================================================================

class _TimelineRow extends StatelessWidget {
  final _Visit visit;
  final bool isLast;
  final AnimationController pulse;

  const _TimelineRow({
    required this.visit,
    required this.isLast,
    required this.pulse,
  });

  static const _kindIcons = [
    Icons.home_work_outlined,
    Icons.local_hospital_outlined,
    Icons.videocam_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final done = visit.state == _VisitState.done;
    final current = visit.state == _VisitState.current;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 46,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                visit.time,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: current ? OB.ink : OB.faint,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 26,
            child: Column(
              children: [
                const SizedBox(height: 4),
                if (current)
                  _PulseDot(controller: pulse, active: true)
                else
                  Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? OB.ink : Colors.transparent,
                      border: Border.all(
                          color: done ? OB.ink : OB.lineStrong, width: 1.5),
                    ),
                    child: done
                        ? const Icon(Icons.check_rounded,
                            size: 11, color: OB.mint)
                        : null,
                  ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: done ? OB.ink : OB.line,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: current ? OB.tint : OB.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: current ? OB.ink : OB.line,
                    width: current ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.2,
                              color: done ? OB.muted : OB.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            visit.detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OB.caption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(_kindIcons[visit.kind],
                        size: 20, color: done ? OB.faint : OB.pine),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// FLOATING NAV
// ====================================================================

class _FloatingNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _FloatingNav({required this.index, required this.onChanged});

  static const _icons = [
    Icons.home_rounded,
    Icons.calendar_today_rounded,
    Icons.groups_rounded,
    Icons.person_rounded,
  ];
  static const _labels = ['Home', 'Schedule', 'Patients', 'Profile'];

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xF20E1F1D),
              borderRadius: BorderRadius.circular(34),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x330E1F1D),
                    blurRadius: 30,
                    offset: Offset(0, 14)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < _icons.length; i++)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      height: 48,
                      padding: EdgeInsets.symmetric(
                          horizontal: i == index ? 18 : 15),
                      decoration: BoxDecoration(
                        color: i == index ? OB.mint : Colors.transparent,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _icons[i],
                            size: 22,
                            color: i == index
                                ? OB.ink
                                : const Color(0xFF8FA5A0),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            child: i == index
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      _labels[i],
                                      style: const TextStyle(
                                        color: OB.ink,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
