import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../../services/physiotherapist_service.dart';

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

      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
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

            Navigator.of(context).popUntil(
              (route) => route.isFirst,
            );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          onPressed: _isVerifying
              ? null
              : () {
                  Navigator.pop(context);
                },

          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF111A3D),
            size: 20,
          ),
        ),
      ),

      body: SafeArea(
        top: false,

        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(
            22,
            18,
            22,
            30,
          ),

          // ======================================================
          // IMPORTANT:
          // ONLY A NORMAL COLUMN HERE.
          // NO Spacer().
          // NO Expanded().
          // NO ConstrainedBox with flex layout.
          // ======================================================

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 16),

              // ==================================================
              // ICON
              // ==================================================

              Container(
                width: 66,
                height: 66,

                decoration: BoxDecoration(
                  color: const Color(0xFF2457F5),

                  borderRadius:
                      BorderRadius.circular(21),

                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2457F5)
                          .withValues(alpha: 0.20),

                      blurRadius: 22,

                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 31,
                ),
              ),

              const SizedBox(height: 34),

              // ==================================================
              // TITLE
              // ==================================================

              const Text(
                'Verify your number',

                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  color: Color(0xFF111A3D),
                ),
              ),

              const SizedBox(height: 10),

              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: Color(0xFF7B849C),
                    fontWeight: FontWeight.w500,
                  ),

                  children: [
                    const TextSpan(
                      text:
                          'We sent a 6-digit verification code to ',
                    ),

                    TextSpan(
                      text: widget.phoneNumber,

                      style: const TextStyle(
                        color: Color(0xFF111A3D),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 42),

              // ==================================================
              // OTP LABEL
              // ==================================================

              const Text(
                'Enter verification code',

                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF111A3D),
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // OTP INPUT
              //
              // Using LayoutBuilder makes this responsive.
              // ==================================================

              LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final totalWidth =
                      constraints.maxWidth;

                  final spacing =
                      totalWidth > 380 ? 10.0 : 7.0;

                  final boxWidth =
                      (totalWidth - (spacing * 5)) / 6;

                  return Row(
                    children: List.generate(
                      6,
                      (index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right:
                                index == 5
                                    ? 0
                                    : spacing,
                          ),

                          child: SizedBox(
                            width: boxWidth,
                            height: 58,

                            child: TextField(
                              controller:
                                  _controllers[index],

                              focusNode:
                                  _focusNodes[index],

                              enabled:
                                  !_isVerifying,

                              keyboardType:
                                  TextInputType.number,

                              textInputAction:
                                  index == 5
                                      ? TextInputAction.done
                                      : TextInputAction.next,

                              textAlign:
                                  TextAlign.center,

                              maxLength: 1,

                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly,
                              ],

                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight:
                                    FontWeight.w900,
                                color:
                                    Color(0xFF111A3D),
                              ),

                              onChanged: (value) {
                                _onOtpChanged(
                                  value,
                                  index,
                                );
                              },

                              onSubmitted: (_) {
                                if (index == 5 &&
                                    _otp.length == 6) {
                                  _verifyOtp();
                                }
                              },

                              decoration: InputDecoration(
                                counterText: '',

                                filled: true,

                                fillColor:
                                    Colors.white,

                                contentPadding:
                                    EdgeInsets.zero,

                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    16,
                                  ),

                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFFE1E6EF),
                                  ),
                                ),

                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    16,
                                  ),

                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFFE1E6EF),
                                  ),
                                ),

                                focusedBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    16,
                                  ),

                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFF2457F5),
                                    width: 1.8,
                                  ),
                                ),

                                disabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    16,
                                  ),

                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFFE1E6EF),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 22),

              // ==================================================
              // RESEND
              // ==================================================

              Center(
                child: _remainingSeconds > 0
                    ? Column(
                        children: [
                          const Text(
                            'Didn’t receive the code?',

                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7B849C),
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Resend available in $_formattedTime',

                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7B849C),
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : TextButton(
                        onPressed:
                            _isResending
                                ? null
                                : _resendOtp,

                        child: _isResending
                            ? const SizedBox(
                                width: 18,
                                height: 18,

                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Resend OTP',

                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Color(0xFF2457F5),
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                      ),
              ),

              const SizedBox(height: 48),

              // ==================================================
              // VERIFY BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton(
                  onPressed:
                      _isVerifying
                          ? null
                          : _verifyOtp,

                  style:
                      ElevatedButton.styleFrom(
                    elevation: 0,

                    backgroundColor:
                        const Color(0xFF2457F5),

                    disabledBackgroundColor:
                        const Color(0xFF9AA7C7),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),

                  child: _isVerifying
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
                          'Verify & Continue',

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // SECURITY
              // ==================================================

              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 15,
                      color: Color(0xFF98A1B5),
                    ),

                    SizedBox(width: 6),

                    Text(
                      'Your information is securely protected',

                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF98A1B5),
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
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