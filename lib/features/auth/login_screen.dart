import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../navigation/main_navigation.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ==============================================================
  // CONTROLLERS
  // ==============================================================

  final TextEditingController _phoneController =
      TextEditingController();

  final FocusNode _phoneFocusNode = FocusNode();

  // ==============================================================
  // SERVICES
  // ==============================================================

  final AuthService _authService = AuthService();

  // ==============================================================
  // ANIMATION
  // ==============================================================

  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;

  late Animation<Offset> _slideAnimation;

  // ==============================================================
  // STATE
  // ==============================================================

  bool _loading = false;

  String? _error;

  int? _resendToken;

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _phoneFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _animationController.forward();
  }

  // ==============================================================
  // SEND OTP
  // ==============================================================

  Future<void> _sendOtp() async {
  if (_loading) return;

  FocusScope.of(context).unfocus();

  final phone = _phoneController.text
      .replaceAll(' ', '')
      .trim();

  // ============================================================
  // VALIDATE MOBILE NUMBER
  // ============================================================

  if (phone.length != 10 ||
      !RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
    setState(() {
      _error =
          'Please enter a valid 10-digit mobile number.';
    });

    return;
  }

  // ============================================================
  // START LOADING
  // ============================================================

  setState(() {
    _loading = true;
    _error = null;
  });

  final fullPhoneNumber = '+91$phone';

  try {
    await _authService.sendOtp(
      phoneNumber: fullPhoneNumber,

      // ========================================================
      // AUTO VERIFICATION
      // ========================================================

      verificationCompleted:
          (PhoneAuthCredential credential) async {
        if (!mounted) return;

        try {
          await _authService.signInWithCredential(
            credential: credential,
          );

          // Create Firestore user profile if needed.
          await _authService
              .createUserProfileIfNeeded();

          if (!mounted) return;

          setState(() {
            _loading = false;
          });

          // ======================================================
          // USER IS ALREADY VERIFIED
          // GO DIRECTLY TO MAIN APP
          // ======================================================

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) =>
                  const MainNavigation(),
            ),
            (route) => false,
          );
        } on FirebaseAuthException catch (e) {
          if (!mounted) return;

          setState(() {
            _loading = false;
            _error =
                _firebaseErrorMessage(e);
          });
        } catch (_) {
          if (!mounted) return;

          setState(() {
            _loading = false;

            _error =
                'Unable to verify your mobile number automatically.';
          });
        }
      },

      // ========================================================
      // VERIFICATION FAILED
      // ========================================================

      verificationFailed:
          (FirebaseAuthException exception) {
        if (!mounted) return;

        setState(() {
          _loading = false;

          _error =
              _firebaseErrorMessage(exception);
        });
      },

      // ========================================================
      // OTP SENT SUCCESSFULLY
      // ========================================================

      onCodeSent: (
        String verificationId,
        int? resendToken,
      ) {
        if (!mounted) return;

        setState(() {
          _loading = false;
          _resendToken = resendToken;
        });

        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (
              context,
              animation,
              secondaryAnimation,
            ) {
              return OtpScreen(
                verificationId: verificationId,
                phoneNumber: fullPhoneNumber,
              );
            },

            transitionDuration:
                const Duration(
              milliseconds: 450,
            ),

            reverseTransitionDuration:
                const Duration(
              milliseconds: 350,
            ),

            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              final curvedAnimation =
                  CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );

              return FadeTransition(
                opacity: curvedAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(
                      0.04,
                      0,
                    ),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                ),
              );
            },
          ),
        );
      },

      // ========================================================
      // AUTO RETRIEVAL TIMEOUT
      // ========================================================

      codeAutoRetrievalTimeout:
          (String verificationId) {
        // We don't stop the user from entering the OTP.
        // The verificationId is still valid for manual OTP entry.
      },
    );
  } on FirebaseAuthException catch (error) {
    if (!mounted) return;

    setState(() {
      _loading = false;

      _error =
          _firebaseErrorMessage(error);
    });
  } catch (_) {
    if (!mounted) return;

    setState(() {
      _loading = false;

      _error =
          'Something went wrong. Please try again.';
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
      case 'invalid-phone-number':
        return 'Please enter a valid mobile number.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'quota-exceeded':
        return 'OTP limit reached. Please try again later.';

      case 'network-request-failed':
        return 'Check your internet connection and try again.';

      case 'operation-not-allowed':
        return 'Phone login is not enabled in Firebase.';

      case 'app-not-authorized':
        return 'This app is not authorized for phone authentication.';

      case 'captcha-check-failed':
        return 'Security verification failed. Please try again.';

      default:
        return error.message ??
            'Unable to send OTP. Please try again.';
    }
  }

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    _phoneController.dispose();

    _phoneFocusNode.dispose();

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
      backgroundColor: const Color(0xFFF5F7FB),
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          // ======================================================
          // PREMIUM BACKGROUND
          // ======================================================

          const Positioned(
            top: -120,
            right: -100,
            child: _GlowOrb(
              size: 320,
              color: Color(0xFF6375FF),
            ),
          ),

          const Positioned(
            top: 250,
            left: -170,
            child: _GlowOrb(
              size: 290,
              color: Color(0xFF36C9B5),
            ),
          ),

          const Positioned(
            bottom: -180,
            right: -120,
            child: _GlowOrb(
              size: 360,
              color: Color(0xFFA494FF),
            ),
          ),

          // ======================================================
          // CONTENT
          // ======================================================

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
                    32 + bottomInset,
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
                              Navigator.pop(context);
                            },
                            child: const _GlassIconButton(
                              icon:
                                  Icons.arrow_back_rounded,
                            ),
                          ),

                          const Spacer(),

                          const _BrandMark(),
                        ],
                      ),

                      const SizedBox(height: 54),

                      // ==================================================
                      // EYEBROW
                      // ==================================================

                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 2,

                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF4358F5),

                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                          ),

                          const SizedBox(width: 9),

                          const Text(
                            'WELCOME BACK',

                            style: TextStyle(
                              fontSize: 10,

                              fontWeight:
                                  FontWeight.w800,

                              letterSpacing: 1.8,

                              color:
                                  Color(0xFF4358F5),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // ==================================================
                      // TITLE
                      // ==================================================

                      const Text(
                        'Your recovery\nstarts here.',

                        style: TextStyle(
                          fontSize: 40,
                          height: 1.03,
                          letterSpacing: -1.8,

                          fontWeight:
                              FontWeight.w800,

                          color:
                              Color(0xFF121827),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Sign in with your mobile number to book care, manage appointments and continue your recovery journey.',

                        style: TextStyle(
                          fontSize: 15,
                          height: 1.55,

                          color:
                              Color(0xFF697386),

                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 38),

                      // ==================================================
                      // PHONE CARD
                      // ==================================================

                      _GlassContainer(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(18),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'Mobile number',

                                style: TextStyle(
                                  fontSize: 13,

                                  fontWeight:
                                      FontWeight.w700,

                                  color:
                                      Color(0xFF263047),
                                ),
                              ),

                              const SizedBox(height: 11),

                              AnimatedContainer(
                                duration:
                                    const Duration(
                                  milliseconds: 200,
                                ),

                                height: 60,

                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(.85),

                                  borderRadius:
                                      BorderRadius.circular(17),

                                  border: Border.all(
                                    color: _error != null
                                        ? const Color(
                                            0xFFE5484D,
                                          )
                                        : _phoneFocusNode
                                                .hasFocus
                                            ? const Color(
                                                0xFF4358F5,
                                              )
                                            : Colors.white,

                                    width: 1.3,
                                  ),
                                ),

                                child: Row(
                                  children: [
                                    const SizedBox(width: 16),

                                    // COUNTRY CODE

                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),

                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFF3F5FA,
                                        ),

                                        borderRadius:
                                            BorderRadius.circular(
                                          11,
                                        ),
                                      ),

                                      child: const Row(
                                        children: [
                                          Text(
                                            '🇮🇳',

                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),

                                          SizedBox(width: 6),

                                          Text(
                                            '+91',

                                            style: TextStyle(
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
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Container(
                                      width: 1,
                                      height: 26,

                                      color:
                                          const Color(
                                        0xFFE3E6ED,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: TextField(
                                        controller:
                                            _phoneController,

                                        focusNode:
                                            _phoneFocusNode,

                                        keyboardType:
                                            TextInputType.phone,

                                        maxLength: 10,

                                        enabled: !_loading,

                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],

                                        onChanged: (_) {
                                          if (_error != null) {
                                            setState(() {
                                              _error = null;
                                            });
                                          }
                                        },

                                        onSubmitted: (_) {
                                          if (!_loading) {
                                            _sendOtp();
                                          }
                                        },

                                        decoration:
                                            const InputDecoration(
                                          hintText:
                                              '98765 43210',

                                          hintStyle:
                                              TextStyle(
                                            color:
                                                Color(0xFFB1B6C2),

                                            fontSize: 16,

                                            fontWeight:
                                                FontWeight.w600,
                                          ),

                                          border:
                                              InputBorder.none,

                                          enabledBorder:
                                              InputBorder.none,

                                          focusedBorder:
                                              InputBorder.none,

                                          counterText: '',

                                          contentPadding:
                                              EdgeInsets.zero,
                                        ),

                                        style:
                                            const TextStyle(
                                          fontSize: 17,

                                          fontWeight:
                                              FontWeight.w700,

                                          letterSpacing: .3,

                                          color:
                                              Color(0xFF182033),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (_error != null) ...[
                                const SizedBox(height: 12),

                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [
                                    const Icon(
                                      Icons
                                          .error_outline_rounded,

                                      size: 17,

                                      color:
                                          Color(0xFFE5484D),
                                    ),

                                    const SizedBox(width: 7),

                                    Expanded(
                                      child: Text(
                                        _error!,

                                        style:
                                            const TextStyle(
                                          fontSize: 12,
                                          height: 1.35,

                                          fontWeight:
                                              FontWeight.w600,

                                          color:
                                              Color(0xFFE5484D),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ==================================================
                      // CONTINUE BUTTON
                      // ==================================================

                      GestureDetector(
                        onTap:
                            _loading ? null : _sendOtp,

                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 200),

                          height: 58,
                          width: double.infinity,

                          decoration: BoxDecoration(
                            gradient:
                                const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,

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

                                blurRadius: 24,

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
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,

                                    children: [
                                      Text(
                                        'Continue securely',

                                        style: TextStyle(
                                          color: Colors.white,

                                          fontSize: 15,

                                          fontWeight:
                                              FontWeight.w800,
                                        ),
                                      ),

                                      SizedBox(width: 10),

                                      Icon(
                                        Icons
                                            .arrow_forward_rounded,

                                        color: Colors.white,

                                        size: 19,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // TRUST
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: const [
                          _TrustItem(
                            icon:
                                Icons.lock_outline_rounded,
                            text: 'Secure',
                          ),

                          _TrustDivider(),

                          _TrustItem(
                            icon: Icons
                                .verified_user_outlined,
                            text: 'Verified',
                          ),

                          _TrustDivider(),

                          _TrustItem(
                            icon:
                                Icons.privacy_tip_outlined,
                            text: 'Private',
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // TERMS
                      // ==================================================

                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,

                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.5,

                              color:
                                  Color(0xFF8A92A2),
                            ),

                            children: [
                              TextSpan(
                                text:
                                    'By continuing, you agree to our ',
                              ),

                              TextSpan(
                                text: 'Terms',

                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w700,

                                  color:
                                      Color(0xFF596275),
                                ),
                              ),

                              TextSpan(
                                text: ' and ',
                              ),

                              TextSpan(
                                text: 'Privacy Policy',

                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w700,

                                  color:
                                      Color(0xFF596275),
                                ),
                              ),

                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ==================================================
                      // BRAND FOOTER
                      // ==================================================

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

                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 7),

                            const Text(
                              'Your health, your journey.',

                              style: TextStyle(
                                fontSize: 11,

                                fontWeight:
                                    FontWeight.w600,

                                color:
                                    Color(0xFF9AA1AF),
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

// ================================================================
// BRAND MARK
// ================================================================

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
            gradient: const LinearGradient(
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
            fontWeight: FontWeight.w800,
            color: Color(0xFF182033),
          ),
        ),

        const Text(
          'AtHome',

          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7A8292),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// GLASS ICON BUTTON
// ================================================================

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

// ================================================================
// GLASS CONTAINER
// ================================================================

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
                Colors.white.withOpacity(.62),

            borderRadius:
                BorderRadius.circular(25),

            border: Border.all(
              color:
                  Colors.white.withOpacity(.90),
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

// ================================================================
// TRUST ITEM
// ================================================================

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TrustItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color:
              const Color(0xFF35B86B),
        ),

        const SizedBox(width: 5),

        Text(
          text,

          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF697386),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// TRUST DIVIDER
// ================================================================

class _TrustDivider extends StatelessWidget {
  const _TrustDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 15,

      margin:
          const EdgeInsets.symmetric(
        horizontal: 13,
      ),

      color: const Color(0xFFDDE1E9),
    );
  }
}

// ================================================================
// GLOW ORB
// ================================================================

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