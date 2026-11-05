import 'package:flutter/material.dart';

import 'auth_visuals.dart';

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

  static const _stages = [
    _Stage(Icons.badge_rounded, 'Create profile', 'Your details & expertise'),
    _Stage(Icons.verified_user_rounded, 'Get verified', 'Registration & documents'),
    _Stage(Icons.calendar_month_rounded, 'Set services', 'Modes, area & timings'),
    _Stage(Icons.groups_rounded, 'Meet patients', 'Approved and ready'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: AX.bg,
      body: Column(
        children: [
          const AXPanel(
            height: 330,
            child: Column(
              children: [
                AXBrandRow(),
                SizedBox(height: 8),
                Expanded(child: AXHeroArt()),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AXReveal(
                    delayMs: 100,
                    child: Text('Your journey', style: AX.display(32)),
                  ),
                  const SizedBox(height: 18),
                  for (var i = 0; i < _stages.length; i++)
                    AXReveal(
                      delayMs: 200 + i * 110,
                      child: _StageRow(
                        stage: _stages[i],
                        number: i + 1,
                        isLast: i == _stages.length - 1,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(24, 12, 24, bottom > 0 ? 8 : 20),
            decoration: const BoxDecoration(
              color: AX.bg,
              border: Border(top: BorderSide(color: AX.line)),
            ),
            child: AXReveal(
              delayMs: 700,
              child: AXPill(
                label: 'Start your profile',
                onPressed: () => _start(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stage {
  final IconData icon;
  final String title, caption;
  const _Stage(this.icon, this.title, this.caption);
}

class _StageRow extends StatelessWidget {
  final _Stage stage;
  final int number;
  final bool isLast;
  const _StageRow({
    required this.stage,
    required this.number,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: number == 1 ? AX.deep : AX.soft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    stage.icon,
                    size: 24,
                    color: number == 1 ? AX.mint : AX.teal,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCFE3DE),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stage.title, style: AX.display(18)),
                  const SizedBox(height: 4),
                  Text(
                    stage.caption,
                    style: const TextStyle(fontSize: 13, color: AX.muted),
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
