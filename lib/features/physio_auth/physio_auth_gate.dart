
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/physiotherapist_model.dart';
import '../../services/physiotherapist_service.dart';
import '../physio_onboarding/physio_onboarding_screen.dart';
import '../doctor/home/doctor_home_screen.dart';
import 'auth_visuals.dart';
import 'physio_login_screen.dart';

/// Routes the signed-in physiotherapist to onboarding, verification handling,
/// or the new DoctorHomeScreen.
///
/// This gate intentionally does not import or use PhysioHomeScreen.
class PhysioAuthGate extends StatelessWidget {
  const PhysioAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _PhysioLoadingScreen();
        }

        final firebaseUser = authSnapshot.data;

        if (firebaseUser == null) {
          return const PhysioLoginScreen();
        }

        return StreamBuilder<PhysiotherapistModel?>(
          stream: PhysiotherapistService()
              .streamPhysiotherapist(firebaseUser.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const _PhysioLoadingScreen();
            }

            if (profileSnapshot.hasError) {
              return _PhysioErrorScreen(
                message: profileSnapshot.error.toString(),
              );
            }

            final physiotherapist = profileSnapshot.data;

            if (physiotherapist == null) {
              return const PhysioOnboardingScreen();
            }

            final status =
                physiotherapist.verificationStatus.trim().toLowerCase();

            // New or draft profile: continue the existing onboarding flow.
            if (status.isEmpty || status == 'draft') {
              return const PhysioOnboardingScreen();
            }

            // Rejected profile: allow the physiotherapist to edit and resubmit.
            if (status == 'rejected') {
              return _VerificationRejectedScreen(
                physiotherapist: physiotherapist,
              );
            }

            // Pending, under review, approved, and other non-draft states
            // all enter the new doctor dashboard. The dashboard itself shows
            // verification/availability state and prevents unverified doctors
            // from switching online.
            return const DoctorHomeScreen();
          },
        );
      },
    );
  }
}

// ===========================================================================
// SHARED STATUS SCREENS
// ===========================================================================

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
                Expanded(
                  child: Center(
                    child: AXOrb(
                      icon: icon,
                      color: tint,
                    ),
                  ),
                ),
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
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AX.display(30),
                      ),
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
                            fontSize: 14.5,
                            height: 1.5,
                            color: AX.muted,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (primaryLabel != null)
                      AXReveal(
                        delayMs: 300,
                        child: AXPill(
                          label: primaryLabel!,
                          onPressed: onPrimary,
                        ),
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

// ===========================================================================
// LOADING SCREEN
// ===========================================================================

class _PhysioLoadingScreen extends StatelessWidget {
  const _PhysioLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const AXLoadingScreen();
  }
}

// ===========================================================================
// REJECTED VERIFICATION SCREEN
// ===========================================================================

class _VerificationRejectedScreen extends StatelessWidget {
  final PhysiotherapistModel physiotherapist;

  const _VerificationRejectedScreen({
    required this.physiotherapist,
  });

  @override
  Widget build(BuildContext context) {
    final rejectionReason =
        (physiotherapist.rejectionReason ?? '').trim();

    return _StatusScreen(
      icon: Icons.edit_note_rounded,
      tint: const Color(0xFFFF8A80),
      title: 'Needs changes',
      message: rejectionReason.isNotEmpty
          ? rejectionReason
          : 'Update a few details so we can approve your profile.',
      primaryLabel: 'Update profile',
      onPrimary: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const PhysioOnboardingScreen(),
          ),
        );
      },
      secondaryLabel: 'Sign out',
      onSecondary: () async {
        await FirebaseAuth.instance.signOut();
      },
    );
  }
}

// ===========================================================================
// ERROR SCREEN
// ===========================================================================

class _PhysioErrorScreen extends StatelessWidget {
  final String message;

  const _PhysioErrorScreen({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _StatusScreen(
      icon: Icons.cloud_off_rounded,
      tint: const Color(0xFFFF8A80),
      title: 'Something went wrong',
      message: message,
      primaryLabel: 'Try again',
      onPrimary: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const PhysioAuthGate(),
          ),
          (route) => false,
        );
      },
    );
  }
}
