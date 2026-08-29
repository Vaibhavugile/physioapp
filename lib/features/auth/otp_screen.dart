import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home/home_screen.dart';
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
  final TextEditingController _otpController =
      TextEditingController();

  final FocusNode _otpFocusNode = FocusNode();

  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // IMPORTANT:
  // This must NOT be final because Firebase gives
  // us a new verification ID when OTP is resent.
  late String _verificationId;

  Timer? _resendTimer;

  bool _loading = false;
  bool _resending = false;
  bool _canResend = false;

  int _resendSeconds = 30;

  String? _error;

  @override
  void initState() {
    super.initState();

    _verificationId = widget.verificationId;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _otpFocusNode.requestFocus();
    });
  }

  // ==========================================================
  // RESEND TIMER
  // ==========================================================

  void _startResendTimer() {
    _resendTimer?.cancel();

    setState(() {
      _resendSeconds = 30;
      _canResend = false;
    });

    _resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_resendSeconds <= 1) {
          timer.cancel();

          setState(() {
            _resendSeconds = 0;
            _canResend = true;
          });

          return;
        }

        setState(() {
          _resendSeconds--;
        });
      },
    );
  }

  // ==========================================================
  // MASK PHONE
  // ==========================================================

  String get _maskedPhone {
    final phone = widget.phoneNumber;

    if (phone.length < 7) {
      return phone;
    }

    return '${phone.substring(0, 3)} •••• ${phone.substring(phone.length - 4)}';
  }

  // ==========================================================
  // VERIFY OTP
  // ==========================================================

  Future<void> _verifyOtp() async {
    if (_loading) return;

    final otp = _otpController.text.trim();

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
      final credential =
          PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (!mounted) return;

      // ======================================================
      // OTP SUCCESS
      //
      // IMPORTANT:
      // User goes directly to HOME.
      // Profile is NOT required.
      // ======================================================

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              const MainNavigation(),

          transitionDuration:
              const Duration(milliseconds: 550),

          transitionsBuilder:
              (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.985,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
        ),

        // Remove login + OTP from back stack.
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = _firebaseErrorMessage(e);
      });

      _shakeError();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            'Unable to verify the code. Please try again.';
      });

      _shakeError();
    }
  }

  // ==========================================================
  // FIREBASE ERROR
  // ==========================================================

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

      default:
        return error.message ??
            'Unable to verify the OTP.';
    }
  }

  // ==========================================================
  // ERROR ANIMATION
  // ==========================================================

  void _shakeError() {
    _animationController
      ..reset()
      ..forward();
  }

  // ==========================================================
  // RESEND OTP
  // ==========================================================

  Future<void> _resendOtp() async {
    if (!_canResend || _loading || _resending) {
      return;
    }

    setState(() {
      _resending = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,

        verificationCompleted:
            (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance
                .signInWithCredential(
              credential,
            );

            if (!mounted) return;

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const MainNavigation(),
              ),
              (route) => false,
            );
          } catch (_) {}
        },

        verificationFailed:
            (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() {
            _resending = false;
            _canResend = true;
            _error = _firebaseErrorMessage(e);
          });
        },

        codeSent: (
          String newVerificationId,
          int? resendToken,
        ) {
          if (!mounted) return;

          // VERY IMPORTANT
          // Firebase has issued a new verification ID.
          _verificationId = newVerificationId;

          _otpController.clear();

          setState(() {
            _resending = false;
            _error = null;
          });

          _startResendTimer();

          _otpFocusNode.requestFocus();

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              behavior:
                  SnackBarBehavior.floating,
              margin: const EdgeInsets.all(18),
              shape: RoundedRectangleBorder(
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

        codeAutoRetrievalTimeout:
            (String newVerificationId) {
          // Save the latest verification ID.
          _verificationId = newVerificationId;
        },
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _resending = false;
        _canResend = true;
        _error =
            'Unable to resend the OTP. Please try again.';
      });
    }
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _resendTimer?.cancel();

    _otpController.dispose();
    _otpFocusNode.dispose();
    _animationController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

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
          // ==================================================
          // BACKGROUND
          // ==================================================

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
                      // ==================================================
                      // HEADER
                      // ==================================================

                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(
                                context,
                              );
                            },
                            child:
                                const _GlassIconButton(
                              icon: Icons
                                  .arrow_back_rounded,
                            ),
                          ),

                          const Spacer(),

                          const _BrandMark(),
                        ],
                      ),

                      const SizedBox(height: 45),

                      // ==================================================
                      // ICON
                      // ==================================================

                      Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient:
                                const LinearGradient(
                              begin:
                                  Alignment.topLeft,
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
                                    const Color(
                                  0xFF4358F5,
                                ).withOpacity(.22),
                                blurRadius: 30,
                                offset:
                                    const Offset(
                                  0,
                                  15,
                                ),
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
                                  color: Colors
                                      .white
                                      .withOpacity(
                                    .12,
                                  ),
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

                      // ==================================================
                      // TITLE
                      // ==================================================

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

                      // ==================================================
                      // PHONE
                      // ==================================================

                      Center(
                        child: Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors.white
                                .withOpacity(.70),
                            borderRadius:
                                BorderRadius
                                    .circular(30),
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
                              const SizedBox(
                                width: 7,
                              ),
                              Text(
                                _maskedPhone,
                                style:
                                    const TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  color:
                                      Color(
                                    0xFF263047,
                                  ),
                                  letterSpacing: .4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      // ==================================================
                      // OTP CARD
                      // ==================================================

                      _GlassContainer(
                        child: Padding(
                          padding:
                              const EdgeInsets
                                  .fromLTRB(
                            18,
                            20,
                            18,
                            18,
                          ),
                          child: Column(
                            children: [
                              const Align(
                                alignment:
                                    Alignment
                                        .centerLeft,
                                child: Text(
                                  'Enter 6-digit code',
                                  style:
                                      TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight
                                            .w800,
                                    color:
                                        Color(
                                      0xFF263047,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              // ==================================================
                              // HIDDEN INPUT
                              // ==================================================

                              SizedBox(
                                height: 1,
                                width: 1,
                                child: TextField(
                                  controller:
                                      _otpController,
                                  focusNode:
                                      _otpFocusNode,
                                  keyboardType:
                                      TextInputType
                                          .number,
                                  maxLength: 6,
                                  autofocus: true,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly,
                                  ],
                                  onChanged:
                                      (value) {
                                    setState(() {
                                      _error =
                                          null;
                                    });

                                    if (value
                                            .length ==
                                        6) {
                                      _verifyOtp();
                                    }
                                  },
                                  decoration:
                                      const InputDecoration(
                                    border:
                                        InputBorder
                                            .none,
                                    counterText:
                                        '',
                                  ),
                                ),
                              ),

                              // ==================================================
                              // OTP BOXES
                              // ==================================================

                              GestureDetector(
                                onTap: () {
                                  _otpFocusNode
                                      .requestFocus();
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children:
                                      List.generate(
                                    6,
                                    (index) {
                                      final otp =
                                          _otpController
                                              .text;

                                      final hasValue =
                                          index <
                                              otp.length;

                                      final char =
                                          hasValue
                                              ? otp[
                                                  index]
                                              : '';

                                      return AnimatedContainer(
                                        duration:
                                            const Duration(
                                          milliseconds:
                                              180,
                                        ),
                                        width: 45,
                                        height: 56,
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              hasValue
                                                  ? const Color(
                                                      0xFFEEF0FF,
                                                    )
                                                  : Colors
                                                      .white
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
                                            color:
                                                _error !=
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
                                            width:
                                                hasValue
                                                    ? 1.5
                                                    : 1,
                                          ),
                                        ),
                                        child:
                                            Center(
                                          child:
                                              hasValue
                                                  ? Text(
                                                      char,
                                                      style:
                                                          const TextStyle(
                                                        fontSize:
                                                            22,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color:
                                                            Color(0xFF263047),
                                                      ),
                                                    )
                                                  : Container(
                                                      width:
                                                          6,
                                                      height:
                                                          6,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Color(0xFFD6DAE3),
                                                        shape:
                                                            BoxShape.circle,
                                                      ),
                                                    ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              // ==================================================
                              // ERROR
                              // ==================================================

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
                                        child:
                                            Text(
                                          _error!,
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                12,
                                            height:
                                                1.35,
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

                      // ==================================================
                      // VERIFY BUTTON
                      // ==================================================

                      GestureDetector(
                        onTap:
                            _loading
                                ? null
                                : _verifyOtp,
                        child: Container(
                          height: 58,
                          width:
                              double.infinity,
                          decoration:
                              BoxDecoration(
                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(0xFF4358F5),
                                Color(0xFF6375FF),
                              ],
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              18,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(
                                  0xFF4358F5,
                                ).withOpacity(.24),
                                blurRadius: 25,
                                offset:
                                    const Offset(
                                  0,
                                  12,
                                ),
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
                                      strokeWidth:
                                          2.5,
                                      color:
                                          Colors
                                              .white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Text(
                                        'Verify & continue',
                                        style:
                                            TextStyle(
                                          color:
                                              Colors
                                                  .white,
                                          fontSize:
                                              15,
                                          fontWeight:
                                              FontWeight
                                                  .w800,
                                        ),
                                      ),
                                      SizedBox(
                                          width: 10),
                                      Icon(
                                        Icons
                                            .arrow_forward_rounded,
                                        color:
                                            Colors
                                                .white,
                                        size: 19,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // RESEND
                      // ==================================================

                      Center(
                        child:
                            AnimatedSwitcher(
                          duration:
                              const Duration(
                            milliseconds: 250,
                          ),
                          child: _resending
                              ? const SizedBox(
                                  key: ValueKey(
                                    'resending',
                                  ),
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        Color(
                                      0xFF4358F5,
                                    ),
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
                                      child:
                                          Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal:
                                              16,
                                          vertical:
                                              10,
                                        ),
                                        decoration:
                                            BoxDecoration(
                                          color: Colors
                                              .white
                                              .withOpacity(
                                            .72,
                                          ),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            30,
                                          ),
                                          border:
                                              Border.all(
                                            color: Colors
                                                .white,
                                          ),
                                        ),
                                        child:
                                            const Row(
                                          mainAxisSize:
                                              MainAxisSize
                                                  .min,
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
                                            SizedBox(
                                              width: 7,
                                            ),
                                            Text(
                                              'Resend OTP',
                                              style:
                                                  TextStyle(
                                                fontSize:
                                                    12,
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
                                      text:
                                          TextSpan(
                                        style:
                                            const TextStyle(
                                          fontSize:
                                              12,
                                          color:
                                              Color(
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

                      // ==================================================
                      // CHANGE NUMBER
                      // ==================================================

                      Center(
                        child:
                            GestureDetector(
                          onTap: () {
                            Navigator.pop(
                              context,
                            );
                          },
                          child: const Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color:
                                    Color(
                                  0xFF7B8494,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Change mobile number',
                                style:
                                    TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                  color:
                                      Color(
                                    0xFF697386,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ==================================================
                      // SECURITY
                      // ==================================================

                      Center(
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Container(
                              width: 27,
                              height: 27,
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFE9FAF5,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  9,
                                ),
                              ),
                              child: const Icon(
                                Icons
                                    .lock_outline_rounded,
                                size: 14,
                                color:
                                    Color(
                                  0xFF16A89A,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Text(
                              'Your verification is secure & private',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight:
                                    FontWeight.w600,
                                color:
                                    Color(
                                  0xFF9299A7,
                                ),
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
                                    Color(
                                  0xFF35B86B,
                                ),
                                shape:
                                    BoxShape.circle,
                              ),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            const Text(
                              'Your health, your journey.',
                              style:
                                  TextStyle(
                                fontSize: 10.5,
                                fontWeight:
                                    FontWeight.w600,
                                color:
                                    Color(
                                  0xFFA0A6B2,
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
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// BRAND MARK
// ==========================================================

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

// ==========================================================
// GLASS BUTTON
// ==========================================================

class _GlassIconButton
    extends StatelessWidget {
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
          decoration:
              BoxDecoration(
            color: Colors.white
                .withOpacity(.70),
            borderRadius:
                BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color: Colors.white
                  .withOpacity(.9),
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

// ==========================================================
// GLASS CONTAINER
// ==========================================================

class _GlassContainer
    extends StatelessWidget {
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
          width:
              double.infinity,
          decoration:
              BoxDecoration(
            color: Colors.white
                .withOpacity(.63),
            borderRadius:
                BorderRadius.circular(
              25,
            ),
            border: Border.all(
              color: Colors.white
                  .withOpacity(.92),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF29355C,
                ).withOpacity(.07),
                blurRadius: 30,
                offset:
                    const Offset(
                  0,
                  15,
                ),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ==========================================================
// GLOW ORB
// ==========================================================

class _GlowOrb
    extends StatelessWidget {
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
        imageFilter:
            ImageFilter.blur(
          sigmaX: 65,
          sigmaY: 65,
        ),
        child: Container(
          width: size,
          height: size,
          decoration:
              BoxDecoration(
            color:
                color.withOpacity(.10),
            shape:
                BoxShape.circle,
          ),
        ),
      ),
    );
  }
}