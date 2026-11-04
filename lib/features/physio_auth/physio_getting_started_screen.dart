import 'package:flutter/material.dart';

/// Shown immediately after successful physiotherapist phone verification.
/// The Start button returns to the app's root route, where the existing
/// authenticated onboarding gate should open the profile flow.
class PhysioGettingStartedScreen extends StatelessWidget {
  final VoidCallback? onStartProfile;

  const PhysioGettingStartedScreen({
    super.key,
    this.onStartProfile,
  });

  void _start(BuildContext context) {
    if (onStartProfile != null) {
      onStartProfile!();
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _JourneyStep(
        number: '01',
        icon: Icons.badge_rounded,
        title: 'Create your professional profile',
        description: 'Add your details, qualifications and areas of expertise so patients can understand your experience.',
        color: const Color(0xFF078F83),
      ),
      _JourneyStep(
        number: '02',
        icon: Icons.verified_user_rounded,
        title: 'Complete verification',
        description: 'Share your professional registration and supporting documents for a trusted profile.',
        color: const Color(0xFF078F83),
      ),
      _JourneyStep(
        number: '03',
        icon: Icons.calendar_month_rounded,
        title: 'Set up your services',
        description: 'Choose your consultation modes, service area, availability and pricing.',
        color: const Color(0xFF0B9B8B),
      ),
      _JourneyStep(
        number: '04',
        icon: Icons.groups_rounded,
        title: 'Get ready for appointments',
        description: 'Once your profile is submitted and approved, you can start building your patient connections.',
        color: const Color(0xFF0B9B8B),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),
      body: Stack(
        children: [
          const Positioned(
            top: -145,
            right: -125,
            child: _IntroGlow(size: 330, color: Color(0xFFE4F6F2)),
          ),
          const Positioned(
            bottom: -170,
            left: -145,
            child: _IntroGlow(size: 340, color: Color(0xFFE8F7F3)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF078F83), Color(0xFF57CDBB)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.health_and_safety_rounded,
                            color: Colors.white, size: 23),
                      ),
                      const SizedBox(width: 11),
                      const Text('PHYSIOTHERAPIST',
                          style: TextStyle(
                            color: Color(0xFF143D3B),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1.25,
                          )),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFE2ECE9)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 13, color: Color(0xFF078F83)),
                            SizedBox(width: 5),
                            Text('YOUR PROFESSIONAL JOURNEY', style: TextStyle(
                              color: Color(0xFF66817E), fontSize: 9,
                              fontWeight: FontWeight.w900, letterSpacing: .7)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 24 * (1 - value)),
                        child: child,
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(22, 25, 22, 23),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF143D3B), Color(0xFF078F83), Color(0xFF0AA895)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(29),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF078F83).withValues(alpha: .20),
                            blurRadius: 32,
                            offset: const Offset(0, 17),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -22, top: -28,
                            child: Icon(Icons.spa_rounded, size: 155,
                                color: Colors.white.withValues(alpha: .07)),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .14),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text('WELCOME, PHYSIOTHERAPIST',
                                  style: TextStyle(color: Color(0xFFD8E7FF),
                                    fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              ),
                              const SizedBox(height: 18),
                              const Text('Welcome, Physiotherapist.\\nYour journey starts here.',
                                style: TextStyle(color: Colors.white, fontSize: 30,
                                  height: 1.08, letterSpacing: -1,
                                  fontWeight: FontWeight.w900)),
                              const SizedBox(height: 12),
                              Text(
                                'Set up your practice, showcase your expertise and get ready to connect with patients looking for physiotherapy care.',
                                style: TextStyle(color: Colors.white.withValues(alpha: .82),
                                  fontSize: 12.5, height: 1.55, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 20),
                              const Row(children: [
                                _HeroStat(icon: Icons.timer_outlined, label: 'Simple guided steps'),
                                SizedBox(width: 18),
                                _HeroStat(icon: Icons.lock_outline_rounded, label: 'Secure details'),
                              ]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 29),
                  const Text('How it works',
                    style: TextStyle(color: Color(0xFF143D3B), fontSize: 22,
                      fontWeight: FontWeight.w900, letterSpacing: -.6)),
                  const SizedBox(height: 6),
                  const Text('Four simple stages. One professional profile built around your practice.',
                    style: TextStyle(color: Color(0xFF78908B), fontSize: 12.5, height: 1.5)),
                  const SizedBox(height: 18),
                  ...List.generate(steps.length, (index) {
                    final step = steps[index];
                    return TweenAnimationBuilder<double>(
                      key: ValueKey(step.number),
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 500 + index * 130),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 18 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 11),
                        child: _JourneyStepCard(step: step),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7F5),
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: const Color(0xFFE8F7F3)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF078F83), size: 19),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You can complete your profile step by step. Keep your professional and identity documents handy for verification.',
                            style: TextStyle(color: Color(0xFF37645F), fontSize: 11.5,
                              height: 1.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 59,
                    child: ElevatedButton(
                      onPressed: () => _start(context),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF078F83),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Start your profile', style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900)),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 19),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Center(
                    child: Text('Your professional journey, at your pace.',
                      style: TextStyle(color: Color(0xFF78908B), fontSize: 10.5,
                        fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyStep {
  final String number;
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  const _JourneyStep({
    required this.number, required this.icon, required this.title,
    required this.description, required this.color,
  });
}

class _JourneyStepCard extends StatelessWidget {
  final _JourneyStep step;
  const _JourneyStepCard({required this.step});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: const Color(0xFFE2ECE9)),
      boxShadow: [
        BoxShadow(color: const Color(0xFF164A45).withValues(alpha: .035),
          blurRadius: 18, offset: const Offset(0, 7)),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 54, height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                step.color.withValues(alpha: .15),
                step.color.withValues(alpha: .055),
              ],
            ),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: step.color.withValues(alpha: .10)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(step.icon, color: step.color, size: 22),
              const SizedBox(height: 3),
              Text(step.number, style: TextStyle(
                color: step.color, fontSize: 8, fontWeight: FontWeight.w900,
                letterSpacing: .5,
              )),
            ],
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('STEP ${step.number}', style: TextStyle(
              color: step.color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .8)),
            const SizedBox(height: 4),
            Text(step.title, style: const TextStyle(
              color: Color(0xFF143D3B), fontSize: 13, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(step.description, style: const TextStyle(
              color: Color(0xFF66817E), fontSize: 10.5, height: 1.45, fontWeight: FontWeight.w500)),
          ]),
        ),
        const SizedBox(width: 5),
        Icon(Icons.check_circle_rounded, color: step.color.withValues(alpha: .7), size: 17),
      ],
    ),
  );
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroStat({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 14, color: const Color(0xFFD0EAE6)),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(color: Colors.white, fontSize: 10,
      fontWeight: FontWeight.w700)),
  ]);
}


class _JourneyMiniMetric extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _JourneyMiniMetric({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: const Color(0xFF078F83), size: 17),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(
          color: Color(0xFF143D3B), fontSize: 15,
          fontWeight: FontWeight.w900, letterSpacing: -.4,
        )),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(
          color: Color(0xFF66817E), fontSize: 8.5,
          fontWeight: FontWeight.w700,
        )),
      ],
    ),
  );
}

class _JourneyMetricDivider extends StatelessWidget {
  const _JourneyMetricDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 38,
    margin: const EdgeInsets.symmetric(horizontal: 7),
    color: const Color(0xFFE8F1EF),
  );
}

class _IntroGlow extends StatelessWidget {
  final double size;
  final Color color;
  const _IntroGlow({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => IgnorePointer(child: Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: .7)),
  ));
}
