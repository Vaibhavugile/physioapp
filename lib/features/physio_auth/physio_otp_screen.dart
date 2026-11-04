import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../../services/physiotherapist_service.dart';
import 'physio_getting_started_screen.dart';

class PhysioOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;

  const PhysioOtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
  });

  @override
  State<PhysioOtpScreen> createState() => _PhysioOtpScreenState();
}

class _PhysioOtpScreenState extends State<PhysioOtpScreen> {
  // ==============================================================
  // SERVICES
  // ==============================================================

  final AuthService _authService = AuthService();

  final PhysiotherapistService _physiotherapistService =
      PhysiotherapistService();

  // ==============================================================
  // OTP CONTROLLERS
  // ==============================================================

  final List<TextEditingController> _controllers =
      List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes =
      List.generate(
    6,
    (_) => FocusNode(),
  );

  // ==============================================================
  // STATE
  // ==============================================================

  late String _verificationId;

  int? _resendToken;

  bool _isVerifying = false;
  bool _isResending = false;

  int _remainingSeconds = 60;

  Timer? _timer;

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;

    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  // ==============================================================
  // OTP VALUE
  // ==============================================================

  String get _otp {
    return _controllers
        .map((controller) => controller.text.trim())
        .join();
  }

  // ==============================================================
  // TIMER
  // ==============================================================

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = 60;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_remainingSeconds <= 1) {
          timer.cancel();

          setState(() {
            _remainingSeconds = 0;
          });

          return;
        }

        setState(() {
          _remainingSeconds--;
        });
      },
    );
  }

  // ==============================================================
  // FORMAT TIME
  // ==============================================================

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60)
        .toString()
        .padLeft(2, '0');

    final seconds = (_remainingSeconds % 60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  // ==============================================================
  // OTP INPUT CHANGE
  // ==============================================================

  void _onOtpChanged(
    String value,
    int index,
  ) {
    if (value.length > 1) {
      final digit = value.characters.last;

      _controllers[index].value = TextEditingValue(
        text: digit,
        selection: TextSelection.collapsed(
          offset: digit.length,
        ),
      );
    }

    if (_controllers[index].text.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else if (_otp.length == 6) {
        FocusScope.of(context).unfocus();

        Future.delayed(
          const Duration(milliseconds: 200),
          () {
            if (mounted && !_isVerifying) {
              _verifyOtp();
            }
          },
        );
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (mounted) {
      setState(() {});
    }
  }

  // ==============================================================
  // CLEAR OTP
  // ==============================================================

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }

    if (mounted) {
      _focusNodes.first.requestFocus();

      setState(() {});
    }
  }

  // ==============================================================
  // VERIFY OTP
  // ==============================================================

  Future<void> _verifyOtp() async {
    if (_isVerifying) {
      return;
    }

    FocusScope.of(context).unfocus();

    final otp = _otp;

    if (otp.length != 6) {
      _showMessage(
        'Please enter the complete 6-digit OTP.',
      );

      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final result = await _authService.verifyOtp(
        verificationId: _verificationId,
        smsCode: otp,
      );

      final user = result.user;

      if (user == null) {
        throw Exception(
          'Unable to authenticate user.',
        );
      }

      await _physiotherapistService.createDraftProfileIfNeeded(
        uid: user.uid,
        phone: user.phoneNumber ?? widget.phoneNumber,
        email: user.email ?? '',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isVerifying = false;
      });

      _openGettingStarted();
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isVerifying = false;
      });

      _showMessage(
        _getFirebaseErrorMessage(error),
      );

      _clearOtp();
    } catch (error) {
      debugPrint(
        'Physio OTP verification error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isVerifying = false;
      });

      _showMessage(
        'Verification failed. Please try again.',
      );
    }
  }

  // ==============================================================
  // RESEND OTP
  // ==============================================================

  Future<void> _resendOtp() async {
    if (_remainingSeconds > 0) {
      return;
    }

    if (_isResending) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      await _authService.sendOtp(
        phoneNumber: widget.phoneNumber,

        forceResendingToken: _resendToken,

        // ========================================================
        // OTP SENT
        // ========================================================

        onCodeSent: (
          String verificationId,
          int? resendToken,
        ) {
          if (!mounted) {
            return;
          }

          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isResending = false;
          });

          _clearOtp();

          _startTimer();

          _showMessage(
            'A new OTP has been sent.',
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
                phone:
                    user.phoneNumber ??
                    widget.phoneNumber,
                email: user.email ?? '',
              );
            }

            if (!mounted) {
              return;
            }

            _openGettingStarted();
          } catch (error) {
            debugPrint(
              'Physio auto verification error: $error',
            );

            if (mounted) {
              setState(() {
                _isResending = false;
              });
            }
          }
        },

        // ========================================================
        // VERIFICATION FAILED
        // ========================================================

        verificationFailed: (
          FirebaseAuthException exception,
        ) {
          if (!mounted) {
            return;
          }

          setState(() {
            _isResending = false;
          });

          _showMessage(
            _getFirebaseErrorMessage(exception),
          );
        },

        // ========================================================
        // AUTO RETRIEVAL TIMEOUT
        //
        // IMPORTANT: ONLY ONE PARAMETER
        // ========================================================

        codeAutoRetrievalTimeout: (
          String verificationId,
        ) {
          _verificationId = verificationId;

          if (!mounted) {
            return;
          }

          setState(() {
            _isResending = false;
          });
        },
      );
    } catch (error) {
      debugPrint(
        'Physio resend OTP error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isResending = false;
      });

      _showMessage(
        'Unable to resend OTP. Please try again.',
      );
    }
  }

  // ==============================================================
  // MESSAGE
  // ==============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),

          behavior: SnackBarBehavior.floating,

          margin: const EdgeInsets.all(18),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ==============================================================
  // FIREBASE ERROR MESSAGE
  // ==============================================================

  String _getFirebaseErrorMessage(
    FirebaseAuthException error,
  ) {
    switch (error.code) {
      case 'invalid-verification-code':
        return 'The OTP you entered is incorrect.';

      case 'session-expired':
        return 'This OTP has expired. Please request a new one.';

      case 'invalid-verification-id':
        return 'Verification session is invalid.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      default:
        return error.message ??
            'Something went wrong. Please try again.';
    }
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
    final entered = _otp.length;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: _isVerifying ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF143D3B)),
        ),
      ),
      body: Stack(
        children: [
          const Positioned(top: -140, right: -120,
              child: _OtpGlow(size: 310, color: Color(0xFFE4F6F2))),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: .72, end: 1),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) => Transform.scale(scale: value, child: child),
                      child: Container(
                        width: 82, height: 82,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF078F83), Color(0xFF57CDBB)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(27),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF078F83).withValues(alpha: .23),
                                blurRadius: 28, offset: const Offset(0, 13)),
                          ],
                        ),
                        child: const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 36),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Center(
                    child: Text('One last security check',
                      style: TextStyle(color: Color(0xFF143D3B), fontSize: 25,
                        fontWeight: FontWeight.w900, letterSpacing: -.8)),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text('Enter the 6-digit code sent to',
                      style: TextStyle(color: Color(0xFF66817E), fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFE0EBE8))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.phone_iphone_rounded, color: Color(0xFF078F83), size: 15),
                        const SizedBox(width: 7),
                        Text(widget.phoneNumber, style: const TextStyle(color: Color(0xFF143D3B),
                          fontWeight: FontWeight.w800, fontSize: 13)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 38),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Verification code', style: TextStyle(color: Color(0xFF143D3B),
                        fontSize: 13, fontWeight: FontWeight.w900)),
                      Text('$entered of 6 entered', style: const TextStyle(color: Color(0xFF78908B),
                        fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final spacing = constraints.maxWidth > 380 ? 10.0 : 7.0;
                      final boxWidth = (constraints.maxWidth - spacing * 5) / 6;
                      return Row(
                        children: List.generate(6, (index) {
                          final hasValue = _controllers[index].text.isNotEmpty;
                          return Padding(
                            padding: EdgeInsets.only(right: index == 5 ? 0 : spacing),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: boxWidth, height: 62,
                              decoration: BoxDecoration(
                                color: hasValue ? const Color(0xFFF0F7F5) : Colors.white,
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                  color: _focusNodes[index].hasFocus
                                      ? const Color(0xFF078F83)
                                      : hasValue ? const Color(0xFFD0EAE6) : const Color(0xFFE2ECE9),
                                  width: _focusNodes[index].hasFocus ? 1.8 : 1,
                                ),
                                boxShadow: _focusNodes[index].hasFocus ? [
                                  BoxShadow(color: const Color(0xFF078F83).withValues(alpha: .10),
                                    blurRadius: 14, offset: const Offset(0, 5))
                                ] : [],
                              ),
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                enabled: !_isVerifying,
                                keyboardType: TextInputType.number,
                                textInputAction: index == 5 ? TextInputAction.done : TextInputAction.next,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                                  color: Color(0xFF143D3B)),
                                onChanged: (value) => _onOtpChanged(value, index),
                                onSubmitted: (_) { if (index == 5 && _otp.length == 6) _verifyOtp(); },
                                decoration: const InputDecoration(
                                  counterText: '', border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: _remainingSeconds > 0
                      ? Column(children: [
                          const Text('Didn’t receive the code?', style: TextStyle(
                            color: Color(0xFF66817E), fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text('You can request a new code in $_formattedTime',
                            style: const TextStyle(color: Color(0xFF66817E), fontSize: 12,
                              fontWeight: FontWeight.w800)),
                        ])
                      : TextButton(
                          onPressed: _isResending ? null : _resendOtp,
                          child: _isResending
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Resend verification code',
                                style: TextStyle(color: Color(0xFF078F83), fontWeight: FontWeight.w900)),
                        ),
                  ),
                  const SizedBox(height: 34),
                  SizedBox(
                    width: double.infinity, height: 58,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        elevation: 0, backgroundColor: const Color(0xFF078F83),
                        disabledBackgroundColor: const Color(0xFFD0EAE6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: _isVerifying
                        ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white)),
                            SizedBox(width: 11),
                            Text('Verifying securely…', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                          ])
                        : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('Verify & continue', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                            SizedBox(width: 9),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 19),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.verified_user_rounded, color: Color(0xFF078F83), size: 15),
                    SizedBox(width: 7),
                    Text('Your account is protected with secure verification',
                      style: TextStyle(color: Color(0xFF78908B), fontSize: 10.5, fontWeight: FontWeight.w600)),
                  ])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpGlow extends StatelessWidget {
  final double size;
  final Color color;
  const _OtpGlow({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => IgnorePointer(child: Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: .65)),
  ));
}
