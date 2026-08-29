import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../navigation/main_navigation.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  // ==============================================================
  // SERVICES
  // ==============================================================

  final AuthService _authService = AuthService();

  // ==============================================================
  // CONTROLLERS
  // ==============================================================

  final TextEditingController _otpController =
      TextEditingController();

  final FocusNode _otpFocusNode = FocusNode();

  // ==============================================================
  // ANIMATIONS
  // ==============================================================

  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ==============================================================
  // FIREBASE OTP STATE
  // ==============================================================

  late String _verificationId;

  int? _resendToken;

  // ==============================================================
  // UI STATE
  // ==============================================================

  bool _loading = false;

  bool _resending = false;

  String? _error;

  int _resendSeconds = 30;

  bool _canResend = false;

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    // Save the initial verification ID.
    _verificationId = widget.verificationId;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 800,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    _startResendTimer();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _otpFocusNode.requestFocus();
        }
      },
    );
  }

  // ==============================================================
  // RESEND TIMER
  // ==============================================================

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(
        const Duration(seconds: 1),
      );

      if (!mounted) {
        return false;
      }

      if (_resendSeconds <= 1) {
        setState(() {
          _resendSeconds = 0;
          _canResend = true;
        });

        return false;
      }

      setState(() {
        _resendSeconds--;
      });

      return true;
    });
  }

  // ==============================================================
  // MASK PHONE NUMBER
  // ==============================================================

  String get _maskedPhone {
    final phone = widget.phoneNumber;

    if (phone.length < 7) {
      return phone;
    }

    return '${phone.substring(0, 3)} •••• '
        '${phone.substring(phone.length - 4)}';
  }

  // ==============================================================
  // VERIFY OTP
  // ==============================================================

  Future<void> _verifyOtp() async {
    if (_loading || _resending) {
      return;
    }

    final otp = _otpController.text.trim();

    // ------------------------------------------------------------
    // VALIDATE OTP
    // ------------------------------------------------------------

    if (otp.length != 6) {
      setState(() {
        _error =
            'Please enter the complete 6-digit code.';
      });

      _shakeError();

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // ----------------------------------------------------------
      // VERIFY OTP
      // ----------------------------------------------------------

      await _authService.verifyOtp(
        verificationId: _verificationId,
        smsCode: otp,
      );

      // ----------------------------------------------------------
      // CREATE FIRESTORE USER IF NEW USER
      // ----------------------------------------------------------

      await _authService.createUserProfileIfNeeded();

      if (!mounted) {
        return;
      }

      // ----------------------------------------------------------
      // NAVIGATE TO MAIN APP
      // ----------------------------------------------------------

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) {
            return const MainNavigation();
          },

          transitionDuration:
              const Duration(milliseconds: 500),

          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            final fadeAnimation =
                CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );

            final scaleAnimation =
                Tween<double>(
              begin: 0.98,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
        ),

        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = _firebaseErrorMessage(e);
      });

      _shakeError();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;

        _error =
            'Unable to verify the code. Please try again.';
      });

      _shakeError();
    }
  }

  // ==============================================================
  // AUTO VERIFIED LOGIN
  // ==============================================================

  Future<void> _handleAutoVerification(
    PhoneAuthCredential credential,
  ) async {
    if (_loading) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // ----------------------------------------------------------
      // AUTO SIGN IN
      // ----------------------------------------------------------

      await _authService.signInWithCredential(
        credential: credential,
      );

      // ----------------------------------------------------------
      // CREATE FIRESTORE USER
      // ----------------------------------------------------------

      await _authService
          .createUserProfileIfNeeded();

      if (!mounted) {
        return;
      }

      // ----------------------------------------------------------
      // NAVIGATE
      // ----------------------------------------------------------

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              const MainNavigation(),
        ),

        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = _firebaseErrorMessage(e);
      });

      _shakeError();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error =
            'Unable to complete verification automatically.';
      });
    }
  }

  // ==============================================================
  // FIREBASE ERROR MESSAGE
  // ==============================================================

  String _firebaseErrorMessage(
    FirebaseAuthException error,
  ) {
    switch (error.code) {
      case 'invalid-verification-code':
        return 'That code is incorrect. Please check the OTP and try again.';

      case 'session-expired':
        return 'This verification code has expired. Please request a new one.';

      case 'invalid-verification-id':
        return 'This verification session has expired. Please request a new OTP.';

      case 'too-many-requests':
        return 'Too many attempts. Please wait before trying again.';

      case 'network-request-failed':
        return 'Check your internet connection and try again.';

      case 'invalid-phone-number':
        return 'The mobile number is invalid. Please try again.';

      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';

      default:
        return error.message ??
            'Something went wrong. Please try again.';
    }
  }

  // ==============================================================
  // ERROR ANIMATION
  // ==============================================================

  void _shakeError() {
    _animationController
      ..reset()
      ..forward();
  }

  // ==============================================================
  // RESEND OTP
  // ==============================================================

  Future<void> _resendOtp() async {
    if (!_canResend ||
        _loading ||
        _resending) {
      return;
    }

    setState(() {
      _resending = true;
      _canResend = false;
      _error = null;
    });

    try {
      await _authService.sendOtp(
        phoneNumber: widget.phoneNumber,

        // --------------------------------------------------------
        // AUTO VERIFICATION
        // --------------------------------------------------------

        verificationCompleted:
            (PhoneAuthCredential credential) async {
          await _handleAutoVerification(
            credential,
          );
        },

        // --------------------------------------------------------
        // VERIFICATION FAILED
        // --------------------------------------------------------

        verificationFailed:
            (FirebaseAuthException exception) {
          if (!mounted) {
            return;
          }

          setState(() {
            _resending = false;
            _canResend = true;

            _error =
                _firebaseErrorMessage(
              exception,
            );
          });

          _shakeError();
        },

        // --------------------------------------------------------
        // OTP SENT
        // --------------------------------------------------------

        onCodeSent: (
          String verificationId,
          int? resendToken,
        ) {
          if (!mounted) {
            return;
          }

          setState(() {
            // IMPORTANT:
            // Save the NEW verification ID.
            _verificationId = verificationId;

            // Save resend token.
            _resendToken = resendToken;

            _otpController.clear();

            _resending = false;

            _canResend = false;

            _resendSeconds = 30;

            _error = null;
          });

          _startResendTimer();

          _otpFocusNode.requestFocus();

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              behavior:
                  SnackBarBehavior.floating,

              margin:
                  const EdgeInsets.all(18),

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),

              backgroundColor:
                  const Color(0xFF172033),

              content: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF49D58A),
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'A new OTP has been sent.',
                    ),
                  ),
                ],
              ),
            ),
          );
        },

        // --------------------------------------------------------
        // AUTO RETRIEVAL TIMEOUT
        // --------------------------------------------------------

        codeAutoRetrievalTimeout:
            (String verificationId) {
          // Keep the latest ID.

          _verificationId = verificationId;
        },

        // --------------------------------------------------------
        // RESEND TOKEN
        // --------------------------------------------------------

        forceResendingToken:
            _resendToken,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _resending = false;
        _canResend = true;

        _error =
            'Unable to resend the OTP. Please try again.';
      });

      _shakeError();
    }
  }

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    _otpController.dispose();

    _otpFocusNode.dispose();

    _animationController.dispose();

    super.dispose();
  }

  // ==============================================================
  // UI
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FB),

      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          // ═══════════════════════════════════════════
          // PREMIUM BACKGROUND
          // ═══════════════════════════════════════════

          const Positioned(
            top: -130,
            right: -110,
            child: _GlowOrb(
              size: 330,
              color: Color(0xFF6575FF),
            ),
          ),

          const Positioned(
            top: 290,
            left: -180,
            child: _GlowOrb(
              size: 300,
              color: Color(0xFF38C8B4),
            ),
          ),

          const Positioned(
            bottom: -190,
            right: -130,
            child: _GlowOrb(
              size: 370,
              color: Color(0xFFA393FF),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,

              child: SlideTransition(
                position: _slideAnimation,

                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    18,
                    24,
                    30 + bottomInset,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // ═══════════════════════════════
                      // TOP BAR
                      // ═══════════════════════════════

                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },

                            child:
                                const _GlassIconButton(
                              icon:
                                  Icons.arrow_back_rounded,
                            ),
                          ),

                          const Spacer(),

                          const _BrandMark(),
                        ],
                      ),

                      const SizedBox(height: 45),

                      // ═══════════════════════════════
                      // SECURITY ICON
                      // ═══════════════════════════════

                      Center(
                        child: Container(
                          width: 88,
                          height: 88,

                          decoration: BoxDecoration(
                            gradient:
                                const LinearGradient(
                              begin: Alignment.topLeft,
                              end:
                                  Alignment.bottomRight,

                              colors: [
                                Color(0xFF4358F5),
                                Color(0xFF28B8A6),
                              ],
                            ),

                            shape: BoxShape.circle,

                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF4358F5)
                                        .withOpacity(.22),

                                blurRadius: 30,

                                offset:
                                    const Offset(0, 15),
                              ),
                            ],
                          ),

                          child: Stack(
                            alignment:
                                Alignment.center,

                            children: [
                              Container(
                                width: 70,
                                height: 70,

                                decoration:
                                    BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(.12),

                                  shape:
                                      BoxShape.circle,
                                ),
                              ),

                              const Icon(
                                Icons
                                    .verified_user_rounded,

                                color: Colors.white,

                                size: 38,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ═══════════════════════════════
                      // TITLE
                      // ═══════════════════════════════

                      const Center(
                        child: Text(
                          'Verify your\nmobile number',

                          textAlign:
                              TextAlign.center,

                          style: TextStyle(
                            fontSize: 38,

                            height: 1.04,

                            letterSpacing: -1.6,

                            fontWeight:
                                FontWeight.w800,

                            color:
                                Color(0xFF121827),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Center(
                        child: Text(
                          'We sent a secure verification code to',

                          textAlign:
                              TextAlign.center,

                          style: TextStyle(
                            fontSize: 14,

                            color:
                                Color(0xFF7A8292),

                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      // ═══════════════════════════════
                      // PHONE NUMBER
                      // ═══════════════════════════════

                      Center(
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(.70),

                            borderRadius:
                                BorderRadius.circular(30),

                            border: Border.all(
                              color: Colors.white,
                            ),
                          ),

                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,

                            children: [
                              const Icon(
                                Icons.phone_rounded,

                                size: 14,

                                color:
                                    Color(0xFF4358F5),
                              ),

                              const SizedBox(width: 7),

                              Text(
                                _maskedPhone,

                                style: const TextStyle(
                                  fontSize: 13,

                                  fontWeight:
                                      FontWeight.w800,

                                  color:
                                      Color(0xFF263047),

                                  letterSpacing: .4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      // ═══════════════════════════════
                      // OTP CARD
                      // ═══════════════════════════════

                      _GlassContainer(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                            18,
                            20,
                            18,
                            18,
                          ),

                          child: Column(
                            children: [
                              const Align(
                                alignment:
                                    Alignment.centerLeft,

                                child: Text(
                                  'Enter 6-digit code',

                                  style: TextStyle(
                                    fontSize: 13,

                                    fontWeight:
                                        FontWeight.w800,

                                    color:
                                        Color(0xFF263047),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // INVISIBLE INPUT

                              SizedBox(
                                height: 1,
                                width: 1,

                                child: TextField(
                                  controller:
                                      _otpController,

                                  focusNode:
                                      _otpFocusNode,

                                  keyboardType:
                                      TextInputType.number,

                                  maxLength: 6,

                                  autofocus: true,

                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly,
                                  ],

                                  onChanged: (value) {
                                    setState(() {
                                      _error = null;
                                    });

                                    if (value.length == 6) {
                                      _verifyOtp();
                                    }
                                  },

                                  decoration:
                                      const InputDecoration(
                                    border:
                                        InputBorder.none,

                                    counterText: '',
                                  ),
                                ),
                              ),

                              // OTP BOXES

                              GestureDetector(
                                onTap: () {
                                  _otpFocusNode
                                      .requestFocus();
                                },

                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,

                                  children: List.generate(
                                    6,
                                    (index) {
                                      final otp =
                                          _otpController.text;

                                      final hasValue =
                                          index < otp.length;

                                      final char = hasValue
                                          ? otp[index]
                                          : '';

                                      return AnimatedContainer(
                                        duration:
                                            const Duration(
                                          milliseconds: 180,
                                        ),

                                        width: 45,
                                        height: 56,

                                        decoration:
                                            BoxDecoration(
                                          color: hasValue
                                              ? const Color(
                                                  0xFFEEF0FF,
                                                )
                                              : Colors.white
                                                  .withOpacity(
                                                  .80,
                                                ),

                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            15,
                                          ),

                                          border:
                                              Border.all(
                                            color: _error !=
                                                    null
                                                ? const Color(
                                                    0xFFE5484D,
                                                  )
                                                : hasValue
                                                    ? const Color(
                                                        0xFF4358F5,
                                                      )
                                                    : Colors
                                                        .white,

                                            width: hasValue
                                                ? 1.5
                                                : 1,
                                          ),
                                        ),

                                        child: Center(
                                          child: hasValue
                                              ? Text(
                                                  char,

                                                  style:
                                                      const TextStyle(
                                                    fontSize: 22,

                                                    fontWeight:
                                                        FontWeight
                                                            .w800,

                                                    color: Color(
                                                      0xFF263047,
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  width: 6,
                                                  height: 6,

                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color(
                                                      0xFFD6DAE3,
                                                    ),

                                                    shape:
                                                        BoxShape
                                                            .circle,
                                                  ),
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              if (_error != null) ...[
                                const SizedBox(
                                  height: 14,
                                ),

                                Container(
                                  width:
                                      double.infinity,

                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 13,
                                    vertical: 11,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xFFFFF0F1,
                                    ),

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      13,
                                    ),
                                  ),

                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [
                                      const Icon(
                                        Icons
                                            .error_outline_rounded,

                                        size: 17,

                                        color:
                                            Color(
                                          0xFFE5484D,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 8,
                                      ),

                                      Expanded(
                                        child: Text(
                                          _error!,

                                          style:
                                              const TextStyle(
                                            fontSize: 12,

                                            height: 1.35,

                                            fontWeight:
                                                FontWeight
                                                    .w600,

                                            color:
                                                Color(
                                              0xFFD33D45,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ═══════════════════════════════
                      // VERIFY BUTTON
                      // ═══════════════════════════════

                      GestureDetector(
                        onTap: _loading ||
                                _resending
                            ? null
                            : _verifyOtp,

                        child: Container(
                          height: 58,
                          width: double.infinity,

                          decoration: BoxDecoration(
                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(0xFF4358F5),
                                Color(0xFF6375FF),
                              ],
                            ),

                            borderRadius:
                                BorderRadius.circular(18),

                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF4358F5)
                                        .withOpacity(.24),

                                blurRadius: 25,

                                offset:
                                    const Offset(0, 12),
                              ),
                            ],
                          ),

                          child: Center(
                            child: _loading
                                ? const SizedBox(
                                    width: 23,
                                    height: 23,

                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.5,

                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,

                                    children: [
                                      Text(
                                        'Verify & continue',

                                        style: TextStyle(
                                          color:
                                              Colors.white,

                                          fontSize: 15,

                                          fontWeight:
                                              FontWeight
                                                  .w800,
                                        ),
                                      ),

                                      SizedBox(width: 10),

                                      Icon(
                                        Icons
                                            .arrow_forward_rounded,

                                        color:
                                            Colors.white,

                                        size: 19,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ═══════════════════════════════
                      // RESEND OTP
                      // ═══════════════════════════════

                      Center(
                        child: AnimatedSwitcher(
                          duration:
                              const Duration(
                            milliseconds: 250,
                          ),

                          child: _resending
                              ? const SizedBox(
                                  key:
                                      ValueKey('resending'),

                                  width: 22,
                                  height: 22,

                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : _canResend
                                  ? GestureDetector(
                                      key:
                                          const ValueKey(
                                        'resend',
                                      ),

                                      onTap:
                                          _resendOtp,

                                      child: Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color: Colors.white
                                              .withOpacity(
                                            .72,
                                          ),

                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            30,
                                          ),

                                          border: Border.all(
                                            color:
                                                Colors.white,
                                          ),
                                        ),

                                        child: const Row(
                                          mainAxisSize:
                                              MainAxisSize.min,

                                          children: [
                                            Icon(
                                              Icons
                                                  .refresh_rounded,

                                              size: 16,

                                              color:
                                                  Color(
                                                0xFF4358F5,
                                              ),
                                            ),

                                            SizedBox(width: 7),

                                            Text(
                                              'Resend OTP',

                                              style:
                                                  TextStyle(
                                                fontSize: 12,

                                                fontWeight:
                                                    FontWeight
                                                        .w800,

                                                color:
                                                    Color(
                                                  0xFF4358F5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : RichText(
                                      key:
                                          const ValueKey(
                                        'timer',
                                      ),

                                      text: TextSpan(
                                        style:
                                            const TextStyle(
                                          fontSize: 12,

                                          color: Color(
                                            0xFF8991A1,
                                          ),
                                        ),

                                        children: [
                                          const TextSpan(
                                            text:
                                                'Resend code in ',
                                          ),

                                          TextSpan(
                                            text:
                                                '00:${_resendSeconds.toString().padLeft(2, '0')}',

                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .w800,

                                              color:
                                                  Color(
                                                0xFF4358F5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ═══════════════════════════════
                      // CHANGE NUMBER
                      // ═══════════════════════════════

                      Center(
                        child: GestureDetector(
                          onTap: _loading ||
                                  _resending
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },

                          child: const Row(
                            mainAxisSize:
                                MainAxisSize.min,

                            children: [
                              Icon(
                                Icons.edit_rounded,

                                size: 14,

                                color:
                                    Color(0xFF7B8494),
                              ),

                              SizedBox(width: 6),

                              Text(
                                'Change mobile number',

                                style: TextStyle(
                                  fontSize: 12,

                                  fontWeight:
                                      FontWeight.w700,

                                  color:
                                      Color(0xFF697386),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ═══════════════════════════════
                      // SECURITY NOTE
                      // ═══════════════════════════════

                      Center(
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [
                            Container(
                              width: 27,
                              height: 27,

                              decoration: BoxDecoration(
                                color:
                                    const Color(
                                  0xFFE9FAF5,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                  9,
                                ),
                              ),

                              child: const Icon(
                                Icons.lock_outline_rounded,

                                size: 14,

                                color:
                                    Color(0xFF16A89A),
                              ),
                            ),

                            const SizedBox(width: 8),

                            const Text(
                              'Your verification is secure & private',

                              style: TextStyle(
                                fontSize: 10.5,

                                fontWeight:
                                    FontWeight.w600,

                                color:
                                    Color(0xFF9299A7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Center(
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [
                            Container(
                              width: 6,
                              height: 6,

                              decoration:
                                  const BoxDecoration(
                                color:
                                    Color(0xFF35B86B),

                                shape:
                                    BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 7),

                            const Text(
                              'Your health, your journey.',

                              style: TextStyle(
                                fontSize: 10.5,

                                fontWeight:
                                    FontWeight.w600,

                                color:
                                    Color(0xFFA0A6B2),
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
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// BRAND MARK
// ═══════════════════════════════════════════════════════

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,

          decoration: BoxDecoration(
            gradient:
                const LinearGradient(
              colors: [
                Color(0xFF4358F5),
                Color(0xFF24B9A7),
              ],
            ),

            borderRadius:
                BorderRadius.circular(12),
          ),

          child: const Icon(
            Icons.accessibility_new_rounded,

            color: Colors.white,

            size: 20,
          ),
        ),

        const SizedBox(width: 9),

        const Text(
          'Physio',

          style: TextStyle(
            fontSize: 15,

            fontWeight:
                FontWeight.w800,

            color:
                Color(0xFF182033),
          ),
        ),

        const Text(
          'AtHome',

          style: TextStyle(
            fontSize: 15,

            fontWeight:
                FontWeight.w500,

            color:
                Color(0xFF7A8292),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// GLASS BUTTON
// ═══════════════════════════════════════════════════════

class _GlassIconButton extends StatelessWidget {
  final IconData icon;

  const _GlassIconButton({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(16),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),

        child: Container(
          width: 48,
          height: 48,

          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(.70),

            borderRadius:
                BorderRadius.circular(16),

            border: Border.all(
              color:
                  Colors.white.withOpacity(.9),
            ),
          ),

          child: Icon(
            icon,

            color:
                const Color(0xFF4B5563),

            size: 21,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// GLASS CONTAINER
// ═══════════════════════════════════════════════════════

class _GlassContainer extends StatelessWidget {
  final Widget child;

  const _GlassContainer({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(25),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),

        child: Container(
          width: double.infinity,

          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(.63),

            borderRadius:
                BorderRadius.circular(25),

            border: Border.all(
              color:
                  Colors.white.withOpacity(.92),
            ),

            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFF29355C)
                        .withOpacity(.07),

                blurRadius: 30,

                offset:
                    const Offset(0, 15),
              ),
            ],
          ),

          child: child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// GLOW ORB
// ═══════════════════════════════════════════════════════

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: 65,
          sigmaY: 65,
        ),

        child: Container(
          width: size,
          height: size,

          decoration: BoxDecoration(
            color:
                color.withOpacity(.10),

            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}