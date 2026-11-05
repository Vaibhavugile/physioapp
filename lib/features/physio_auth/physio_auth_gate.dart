import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/physiotherapist_model.dart';
import '../../services/physiotherapist_service.dart';
import '../physio_onboarding/physio_onboarding_screen.dart';
import 'auth_visuals.dart';
import 'physio_login_screen.dart';
import 'physio_home_screen.dart';

class PhysioAuthGate extends StatelessWidget {
  const PhysioAuthGate({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (
        context,
        authSnapshot,
      ) {
        // ============================================================
        // AUTH LOADING
        // ============================================================

        if (authSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const _PhysioLoadingScreen();
        }

        // ============================================================
        // NOT LOGGED IN
        // ============================================================

        final firebaseUser = authSnapshot.data;

        if (firebaseUser == null) {
          return const PhysioLoginScreen();
        }

        // ============================================================
        // LOGGED IN → LOAD PHYSIOTHERAPIST PROFILE
        // ============================================================

        return StreamBuilder<PhysiotherapistModel?>(
          stream: PhysiotherapistService()
              .streamPhysiotherapist(
            firebaseUser.uid,
          ),

          builder: (
            context,
            profileSnapshot,
          ) {
            // ========================================================
            // PROFILE LOADING
            // ========================================================

            if (profileSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const _PhysioLoadingScreen();
            }

            // ========================================================
            // PROFILE ERROR
            // ========================================================

            if (profileSnapshot.hasError) {
              return _PhysioErrorScreen(
                message: profileSnapshot.error.toString(),
              );
            }

            final physiotherapist = profileSnapshot.data;

            // ========================================================
            // NO PROFILE → START ONBOARDING
            // ========================================================

            if (physiotherapist == null) {
              return const PhysioOnboardingScreen();
            }

            final status = physiotherapist
                .verificationStatus
                .trim()
                .toLowerCase();

            // ========================================================
            // DRAFT → CONTINUE ONBOARDING
            // ========================================================

            // Your current PhysioOnboardingScreen does not yet support
            // an initialStep parameter, so we open onboarding normally.

            if (status.isEmpty || status == 'draft') {
              return const PhysioOnboardingScreen();
            }

            // ========================================================
            // PENDING
            // ========================================================

            if (status == 'pending' || status == 'under_review') {
              return PhysioHomeScreen(
                name: _displayPhysioName(physiotherapist.fullName),
                isPending: true,
                onNotifications: () => _showDemoMessage(context, 'Notifications'),
                onNavigate: () => _showDemoMessage(context, 'Navigation'),
                onStartSession: () => _showDemoMessage(context, 'Sessions'),
                onTabChanged: (tab) => _showDemoMessage(
                  context,
                  const ['Home', 'Schedule', 'Patients', 'Profile'][tab],
                ),
              );
            }

            // ========================================================
            // REJECTED
            // ========================================================

            if (status == 'rejected') {
              return _VerificationRejectedScreen(
                physiotherapist: physiotherapist,
              );
            }

            // ========================================================
            // APPROVED
            // ========================================================

            if (status == 'approved' &&
                physiotherapist.isVerified &&
                physiotherapist.isActive) {
              return PhysioHomeScreen(
                name: _displayPhysioName(physiotherapist.fullName),
                onNotifications: () => _showDemoMessage(context, 'Notifications'),
                onNavigate: () => _showDemoMessage(context, 'Navigation'),
                onStartSession: () => _showDemoMessage(context, 'Sessions'),
                onTabChanged: (tab) => _showDemoMessage(
                  context,
                  const ['Home', 'Schedule', 'Patients', 'Profile'][tab],
                ),
              );
            }

            // ========================================================
            // FALLBACK
            // ========================================================

            return PhysioHomeScreen(
              name: _displayPhysioName(physiotherapist.fullName),
              isPending: true,
              onNotifications: () => _showDemoMessage(context, 'Notifications'),
              onNavigate: () => _showDemoMessage(context, 'Navigation'),
              onStartSession: () => _showDemoMessage(context, 'Sessions'),
              onTabChanged: (tab) => _showDemoMessage(
                context,
                const ['Home', 'Schedule', 'Patients', 'Profile'][tab],
              ),
            );
          },
        );
      },
    );
  }
}

String _displayPhysioName(String fullName) {
  final cleaned = fullName.trim();
  if (cleaned.isEmpty) return 'Dr. Physiotherapist';
  return cleaned.toLowerCase().startsWith('dr.') ? cleaned : 'Dr. $cleaned';
}

void _showDemoMessage(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$feature will be connected after the demo phase.')),
  );
}

// ===================================================================
// STATUS SCREENS (shared premium layout)
// ===================================================================

class _StatusScreen extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String title;
  final String? message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _StatusScreen({
    required this.icon,
    required this.tint,
    required this.title,
    this.message,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AX.bg,
      body: Column(
        children: [
          AXPanel(
            height: 340,
            child: Column(
              children: [
                const AXBrandRow(),
                Expanded(child: Center(child: AXOrb(icon: icon, color: tint))),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AXReveal(
                      delayMs: 100,
                      child: Text(title,
                          textAlign: TextAlign.center, style: AX.display(30)),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 12),
                      AXReveal(
                        delayMs: 200,
                        child: Text(
                          message!,
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14.5, height: 1.5, color: AX.muted),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (primaryLabel != null)
                      AXReveal(
                        delayMs: 300,
                        child: AXPill(label: primaryLabel!, onPressed: onPrimary),
                      ),
                    if (secondaryLabel != null)
                      AXReveal(
                        delayMs: 380,
                        child: TextButton(
                          onPressed: onSecondary,
                          child: Text(
                            secondaryLabel!,
                            style: const TextStyle(
                              color: AX.muted,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
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

class _PhysioLoadingScreen extends StatelessWidget {
  const _PhysioLoadingScreen();

  @override
  Widget build(BuildContext context) => const AXLoadingScreen();
}

class _VerificationPendingScreen extends StatelessWidget {
  const _VerificationPendingScreen();

  @override
  Widget build(BuildContext context) => _StatusScreen(
        icon: Icons.hourglass_top_rounded,
        tint: const Color(0xFFFFC857),
        title: 'Under review',
        message: 'We’ll notify you once your profile is approved.',
        secondaryLabel: 'Sign out',
        onSecondary: () async => FirebaseAuth.instance.signOut(),
      );
}

class _VerificationRejectedScreen extends StatelessWidget {
  final PhysiotherapistModel physiotherapist;

  const _VerificationRejectedScreen({
    required this.physiotherapist,
  });

  @override
  Widget build(BuildContext context) => _StatusScreen(
        icon: Icons.edit_note_rounded,
        tint: const Color(0xFFFF8A80),
        title: 'Needs changes',
        message: 'Update a few details so we can approve your profile.',
        primaryLabel: 'Update profile',
        onPrimary: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PhysioOnboardingScreen()),
          );
        },
        secondaryLabel: 'Sign out',
        onSecondary: () async => FirebaseAuth.instance.signOut(),
      );
}

class _PhysioErrorScreen extends StatelessWidget {
  final String message;

  const _PhysioErrorScreen({
    required this.message,
  });

  @override
  Widget build(BuildContext context) => _StatusScreen(
        icon: Icons.cloud_off_rounded,
        tint: const Color(0xFFFF8A80),
        title: 'Something went wrong',
        message: message,
        primaryLabel: 'Try again',
        onPrimary: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const PhysioAuthGate()),
            (route) => false,
          );
        },
      );
}
