import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/physiotherapist_model.dart';
import '../../services/physiotherapist_service.dart';
import '../physio_onboarding/physio_onboarding_screen.dart';
import 'physio_login_screen.dart';

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

            if (status == 'pending') {
              return const _VerificationPendingScreen();
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
              return _PhysioDashboardScreen(
                physiotherapist: physiotherapist,
              );
            }

            // ========================================================
            // FALLBACK
            // ========================================================

            return const _VerificationPendingScreen();
          },
        );
      },
    );
  }
}

// ===================================================================
// LOADING SCREEN
// ===================================================================

class _PhysioLoadingScreen extends StatelessWidget {
  const _PhysioLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F7FC),

      body: Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Color(0xFF2457F5),
        ),
      ),
    );
  }
}

// ===================================================================
// VERIFICATION PENDING SCREEN
// ===================================================================

class _VerificationPendingScreen extends StatelessWidget {
  const _VerificationPendingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Container(
                  width: 88,
                  height: 88,

                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    size: 42,
                    color: Color(0xFFFFA726),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Profile Under Review',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111A3D),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Our team is reviewing your professional details and documents. '
                  'We will notify you once your profile has been reviewed.',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF7B849C),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: OutlinedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },

                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE1E6EF),
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    child: const Text(
                      'Sign out',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111A3D),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// VERIFICATION REJECTED SCREEN
// ===================================================================

class _VerificationRejectedScreen extends StatelessWidget {
  final PhysiotherapistModel physiotherapist;

  const _VerificationRejectedScreen({
    required this.physiotherapist,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Container(
                  width: 88,
                  height: 88,

                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 44,
                    color: Colors.redAccent,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Verification Needs Changes',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111A3D),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Some details in your profile need to be updated before '
                  'your profile can be approved.',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF7B849C),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const PhysioOnboardingScreen(),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2457F5),
                      foregroundColor: Colors.white,
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    child: const Text(
                      'Update Profile',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },

                    child: const Text(
                      'Sign out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7B849C),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// PHYSIOTHERAPIST DASHBOARD PLACEHOLDER
// ===================================================================

class _PhysioDashboardScreen extends StatelessWidget {
  final PhysiotherapistModel physiotherapist;

  const _PhysioDashboardScreen({
    required this.physiotherapist,
  });

  @override
  Widget build(BuildContext context) {
    final name = physiotherapist.fullName.trim().isEmpty
        ? 'Physiotherapist'
        : physiotherapist.fullName;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Container(
                  width: 88,
                  height: 88,

                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF0FF),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.dashboard_rounded,
                    size: 42,
                    color: Color(0xFF2457F5),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Welcome, $name',
                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111A3D),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Your physiotherapist account has been approved.',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7B849C),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: OutlinedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },

                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE1E6EF),
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    child: const Text(
                      'Sign out',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111A3D),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// ERROR SCREEN
// ===================================================================

class _PhysioErrorScreen extends StatelessWidget {
  final String message;

  const _PhysioErrorScreen({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Container(
                  width: 88,
                  height: 88,

                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.cloud_off_rounded,
                    size: 42,
                    color: Colors.redAccent,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Something went wrong',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111A3D),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF7B849C),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 52,

                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) =>
                              const PhysioAuthGate(),
                        ),
                        (route) => false,
                      );
                    },

                    child: const Text(
                      'Try Again',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}