import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../../services/physiotherapist_service.dart';
import 'auth_visuals.dart';
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
      backgroundColor: AX.bg,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                const AXPanel(
                  height: 380,
                  child: Column(
                    children: [
                      AXBrandRow(trailing: AXSecureBadge()),
                      SizedBox(height: 8),
                      Expanded(child: AXHeroArt()),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AXReveal(
                        delayMs: 100,
                        child: Text('Welcome back', style: AX.display(34)),
                      ),
                      const SizedBox(height: 8),
                      const AXReveal(
                        delayMs: 180,
                        child: Text(
                          'Sign in with your mobile number',
                          style: TextStyle(fontSize: 15, color: AX.muted),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AXReveal(delayMs: 260, child: _phoneField()),
                      const SizedBox(height: 18),
                      AXReveal(
                        delayMs: 340,
                        child: AXPill(
                          label: 'Get OTP',
                          loading: _isLoading,
                          onPressed: _isLoading ? null : _sendOtp,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AXReveal(
                        delayMs: 420,
                        child: Center(
                          child: TextButton.icon(
                            onPressed: _isLoading ? null : _openGettingStarted,
                            icon: const Icon(Icons.play_circle_outline_rounded,
                                size: 20, color: AX.teal),
                            label: const Text(
                              'How it works',
                              style: TextStyle(
                                color: AX.teal,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const AXReveal(
                        delayMs: 480,
                        child: Center(
                          child: Text(
                            'By continuing you accept our Terms & Privacy Policy',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11.5, color: AX.muted),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _phoneField() {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      child: Builder(
        builder: (context) {
          final focused = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: focused ? AX.teal : AX.line,
                width: focused ? 2 : 1,
              ),
              boxShadow: focused
                  ? [
                      BoxShadow(
                        color: AX.teal.withValues(alpha: .14),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : AX.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AX.soft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _selectedCountryCode,
                    style: AX.display(16, color: AX.teal),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    enabled: !_isLoading,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AX.ink,
                    ),
                    onSubmitted: (_) {
                      if (!_isLoading) _sendOtp();
                    },
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: 'Mobile number',
                      hintStyle: TextStyle(
                        color: Color(0xFF5F7B76),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
