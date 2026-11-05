import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../../services/physiotherapist_service.dart';
import 'auth_visuals.dart';
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
                AXPanel(
                  height: 300,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Row(
                          children: [
                            AXBackButton(
                              onTap: _isVerifying
                                  ? null
                                  : () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            const AXSecureBadge(),
                          ],
                        ),
                      ),
                      const Expanded(child: AXShieldArt()),
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
                        child: Text('Enter code', style: AX.display(34)),
                      ),
                      const SizedBox(height: 12),
                      AXReveal(
                        delayMs: 180,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: AX.soft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.sms_rounded,
                                  size: 17, color: AX.teal),
                              const SizedBox(width: 8),
                              Text(
                                widget.phoneNumber,
                                style: const TextStyle(
                                  color: AX.ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      AXReveal(delayMs: 260, child: _otpBoxes()),
                      const SizedBox(height: 24),
                      AXReveal(delayMs: 340, child: _resendRow()),
                      const SizedBox(height: 22),
                      AXReveal(
                        delayMs: 420,
                        child: AXPill(
                          label: 'Verify',
                          loading: _isVerifying,
                          onPressed: _isVerifying ? null : _verifyOtp,
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

  Widget _otpBoxes() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = constraints.maxWidth > 380 ? 10.0 : 7.0;
        final boxWidth = (constraints.maxWidth - spacing * 5) / 6;
        return Row(
          children: List.generate(6, (index) {
            final hasValue = _controllers[index].text.isNotEmpty;
            final focused = _focusNodes[index].hasFocus;
            return Padding(
              padding: EdgeInsets.only(right: index == 5 ? 0 : spacing),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: boxWidth,
                height: 68,
                decoration: BoxDecoration(
                  color: hasValue ? AX.soft : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: focused
                        ? AX.teal
                        : hasValue
                            ? const Color(0xFFBFE3DC)
                            : AX.line,
                    width: focused ? 2 : 1,
                  ),
                  boxShadow: focused
                      ? [
                          BoxShadow(
                            color: AX.teal.withValues(alpha: .14),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : const [],
                ),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  enabled: !_isVerifying,
                  keyboardType: TextInputType.number,
                  textInputAction:
                      index == 5 ? TextInputAction.done : TextInputAction.next,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AX.display(26),
                  onChanged: (value) => _onOtpChanged(value, index),
                  onSubmitted: (_) {
                    if (index == 5 && _otp.length == 6) _verifyOtp();
                  },
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _resendRow() {
    if (_remainingSeconds > 0) {
      return Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(end: (_remainingSeconds / 60).clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 400),
                  builder: (_, v, __) => CircularProgressIndicator(
                    value: v,
                    strokeWidth: 4,
                    backgroundColor: AX.line,
                    color: AX.teal,
                  ),
                ),
                Text('$_remainingSeconds', style: AX.display(15)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.timer_outlined, size: 20, color: AX.muted),
        ],
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: _isResending ? null : _resendOtp,
        icon: _isResending
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AX.teal),
              )
            : const Icon(Icons.refresh_rounded, color: AX.teal),
        label: const Text(
          'Resend code',
          style: TextStyle(
            color: AX.teal,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
