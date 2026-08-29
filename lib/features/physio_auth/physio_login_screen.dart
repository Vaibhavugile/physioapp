import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/physiotherapist_service.dart';
import 'physio_otp_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,

          padding: const EdgeInsets.fromLTRB(
            22,
            28,
            22,
            30,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 24),

              // ==================================================
              // LOGO
              // ==================================================

              Container(
                width: 64,
                height: 64,

                decoration: BoxDecoration(
                  color: const Color(0xFF2457F5),

                  borderRadius:
                      BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF2457F5,
                      ).withValues(
                        alpha: 0.20,
                      ),

                      blurRadius: 22,

                      offset: const Offset(
                        0,
                        10,
                      ),
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(height: 38),

              // ==================================================
              // TITLE
              // ==================================================

              const Text(
                'Welcome, Partner 👋',

                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  color: Color(0xFF111A3D),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Login or create your professional physiotherapist profile to start receiving appointments.',

                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: Color(0xFF7B849C),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 42),

              // ==================================================
              // PHONE LABEL
              // ==================================================

              const Text(
                'Mobile number',

                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111A3D),
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // PHONE INPUT
              // ==================================================

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(18),

                  border: Border.all(
                    color: const Color(0xFFE4E8F0),
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),

                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Color(0xFFE4E8F0),
                          ),
                        ),
                      ),

                      child: Text(
                        _selectedCountryCode,

                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111A3D),
                        ),
                      ),
                    ),

                    Expanded(
                      child: TextField(
                        controller: _phoneController,

                        keyboardType:
                            TextInputType.phone,

                        maxLength: 10,

                        enabled: !_isLoading,

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111A3D),
                        ),

                        decoration:
                            const InputDecoration(
                          counterText: '',

                          hintText:
                              'Enter mobile number',

                          hintStyle: TextStyle(
                            color: Color(0xFFADB4C3),
                            fontWeight:
                                FontWeight.w500,
                          ),

                          border: InputBorder.none,

                          contentPadding:
                              EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 17,
                          ),
                        ),

                        onSubmitted: (_) {
                          if (!_isLoading) {
                            _sendOtp();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // INFO
              // ==================================================

              const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 17,
                    color: Color(0xFF7B849C),
                  ),

                  SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      'We will send a one-time verification code to this mobile number.',

                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: Color(0xFF7B849C),
                      ),
                    ),
                  ),
                ],
              ),

              // IMPORTANT:
              // Do NOT use Spacer() here because this Column
              // is inside SingleChildScrollView.

              const SizedBox(height: 52),

              // ==================================================
              // SEND OTP BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _sendOtp,

                  style:
                      ElevatedButton.styleFrom(
                    elevation: 0,

                    backgroundColor:
                        const Color(0xFF2457F5),

                    disabledBackgroundColor:
                        const Color(0xFF9AA7C7),

                    foregroundColor: Colors.white,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),

                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Continue with OTP',

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // TERMS
              // ==================================================

              const Center(
                child: Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy.',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.5,
                    color: Color(0xFF98A1B5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}