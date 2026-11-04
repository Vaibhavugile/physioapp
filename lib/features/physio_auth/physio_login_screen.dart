import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/physiotherapist_service.dart';
import 'physio_otp_screen.dart';
import 'physio_getting_started_screen.dart';

class PhysioLoginScreen extends StatefulWidget {
  const PhysioLoginScreen({
    super.key,
  });

  @override
  State<PhysioLoginScreen> createState() =>
      _PhysioLoginScreenState();
}

class _PhysioLoginScreenState
    extends State<PhysioLoginScreen> {
  // ==============================================================
  // SERVICES
  // ==============================================================

  final AuthService _authService = AuthService();

  final PhysiotherapistService _physiotherapistService =
      PhysiotherapistService();

  // ==============================================================
  // CONTROLLER
  // ==============================================================

  final TextEditingController _phoneController =
      TextEditingController();

  // ==============================================================
  // STATE
  // ==============================================================

  bool _isLoading = false;

  final String _selectedCountryCode = '+91';

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ==============================================================
  // GET FULL PHONE NUMBER
  // ==============================================================

  String get _fullPhoneNumber {
    final phone = _phoneController.text
        .trim()
        .replaceAll(' ', '');

    return '$_selectedCountryCode$phone';
  }

  // ==============================================================
  // VALIDATE PHONE
  // ==============================================================

  bool _validatePhoneNumber() {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showMessage(
        'Please enter your mobile number.',
      );

      return false;
    }

    if (phone.length != 10) {
      _showMessage(
        'Please enter a valid 10-digit mobile number.',
      );

      return false;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showMessage(
        'Mobile number should contain only numbers.',
      );

      return false;
    }

    return true;
  }

  // ==============================================================
  // SEND OTP
  // ==============================================================

  Future<void> _sendOtp() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    if (!_validatePhoneNumber()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.sendOtp(
        phoneNumber: _fullPhoneNumber,

        // ========================================================
        // OTP SENT
        // ========================================================

        onCodeSent: (
          String verificationId,
          int? resendToken,
        ) {
          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PhysioOtpScreen(
                phoneNumber: _fullPhoneNumber,
                verificationId: verificationId,
                resendToken: resendToken,
              ),
            ),
          );
        },

        // ========================================================
        // AUTO VERIFICATION
        // ========================================================

        verificationCompleted: (
          PhoneAuthCredential credential,
        ) async {
          try {
            final result =
                await _authService.signInWithCredential(
              credential: credential,
            );

            final user = result.user;

            if (user != null) {
              await _physiotherapistService
                  .createDraftProfileIfNeeded(
                uid: user.uid,
                phone: user.phoneNumber ?? '',
                email: user.email ?? '',
              );
              _openGettingStarted();
            }
          } catch (error) {
            debugPrint(
              'Physio auto login error: $error',
            );

            if (mounted) {
              _showMessage(
                'Unable to complete automatic verification.',
              );
            }
          }

          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });
        },

        // ========================================================
        // VERIFICATION FAILED
        // ========================================================

        verificationFailed: (
          FirebaseAuthException exception,
        ) {
          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          _showMessage(
            exception.message ??
                'Unable to send OTP. Please try again.',
          );
        },

        // ========================================================
        // AUTO RETRIEVAL TIMEOUT
        // ========================================================

        codeAutoRetrievalTimeout: (
          String verificationId,
        ) {
          debugPrint(
            'OTP auto retrieval timeout: $verificationId',
          );

          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint(
        'Send OTP error: $error',
      );

      _showMessage(
        'Something went wrong. Please try again.',
      );
    }
  }

  // ==============================================================
  // SHOW MESSAGE
  // ==============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),

          behavior: SnackBarBehavior.floating,

          margin: const EdgeInsets.fromLTRB(
            18,
            0,
            18,
            18,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ==============================================================
  // BUILD
  // ==============================================================


  void _openGettingStarted() {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PhysioGettingStartedScreen(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),
      body: Stack(
        children: [
          const Positioned(
            top: -130,
            right: -110,
            child: _LoginGlow(size: 330, color: Color(0xFFE4F6F2)),
          ),
          const Positioned(
            bottom: -150,
            left: -130,
            child: _LoginGlow(size: 320, color: Color(0xFFE8F7F3)),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 52,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF078F83), Color(0xFF0AA895)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF078F83).withValues(alpha: .22),
                                    blurRadius: 22,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.health_and_safety_rounded,
                                  color: Colors.white, size: 25),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('PHYSIOTHERAPIST',
                                    style: TextStyle(
                                      color: Color(0xFF143D3B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.35,
                                    )),
                                SizedBox(height: 3),
                                Text('Your practice. Your growth.',
                                    style: TextStyle(
                                      color: Color(0xFF66817E),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                            const Spacer(),
                            const _SecurePill(),
                          ],
                        ),
                        const SizedBox(height: 38),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 750),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) => Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 22 * (1 - value)),
                              child: child,
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(22, 25, 22, 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF143D3B), Color(0xFF078F83), Color(0xFF08766F)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF078F83).withValues(alpha: .20),
                                  blurRadius: 34,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -25,
                                  top: -38,
                                  child: Icon(Icons.health_and_safety_rounded,
                                      size: 170, color: Colors.white.withValues(alpha: .07)),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: .13),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(color: Colors.white.withValues(alpha: .16)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.auto_awesome_rounded, size: 13, color: Color(0xFFD0EAE6)),
                                          SizedBox(width: 6),
                                          Text('A better way to grow your practice',
                                              style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    const Text('Welcome,\\nPhysiotherapist.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          height: 1.08,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -1.1,
                                        )),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Build your professional presence, connect with patients and manage your physiotherapy services — all in one place.',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: .82),
                                        fontSize: 13,
                                        height: 1.55,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    const Row(
                                      children: [
                                        _HeroMiniFeature(icon: Icons.verified_user_rounded, label: 'Verified profile'),
                                        SizedBox(width: 15),
                                        _HeroMiniFeature(icon: Icons.calendar_month_rounded, label: 'Appointments'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text('Get started with your mobile number',
                            style: TextStyle(
                              color: Color(0xFF143D3B),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.55,
                            )),
                        const SizedBox(height: 7),
                        const Text('We’ll send you a secure one-time password to continue.',
                            style: TextStyle(color: Color(0xFF66817E), fontSize: 12.5, height: 1.5)),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(color: const Color(0xFFE0EBE8)),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF164A45).withValues(alpha: .045),
                                  blurRadius: 22, offset: const Offset(0, 9)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F7F5),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  children: [
                                    Text('🇮🇳', style: TextStyle(fontSize: 17)),
                                    SizedBox(width: 7),
                                    Text('+91', style: TextStyle(color: Color(0xFF143D3B), fontSize: 14, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  enabled: !_isLoading,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF143D3B), letterSpacing: 1),
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    hintText: 'Enter mobile number',
                                    hintStyle: TextStyle(color: Color(0xFF9AAEAB), fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                                  ),
                                  onSubmitted: (_) { if (!_isLoading) _sendOtp(); },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 13),
                        const Row(
                          children: [
                            Icon(Icons.lock_rounded, color: Color(0xFF78908B), size: 14),
                            SizedBox(width: 7),
                            Expanded(child: Text('Your number is used only for secure account verification.',
                                style: TextStyle(color: Color(0xFF78908B), fontSize: 11, height: 1.4))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendOtp,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFF078F83),
                              disabledBackgroundColor: const Color(0xFFD0EAE6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 22, height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Continue with OTP', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                                      SizedBox(width: 10),
                                      Icon(Icons.arrow_forward_rounded, size: 19),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Center(
                          child: Text('By continuing, you agree to our Terms of Service and Privacy Policy.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF78908B), fontSize: 10.5, height: 1.5)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginGlow extends StatelessWidget {
  final double size;
  final Color color;
  const _LoginGlow({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: .72)),
    ),
  );
}

class _SecurePill extends StatelessWidget {
  const _SecurePill();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.shield_rounded, size: 13, color: Color(0xFF078F83)),
      SizedBox(width: 5),
      Text('SECURE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF078F83), letterSpacing: .7)),
    ]),
  );
}

class _HeroMiniFeature extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroMiniFeature({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, color: const Color(0xFFD0EAE6), size: 15),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700)),
  ]);
}
