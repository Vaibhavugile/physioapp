import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';

import 'widgets/home_header.dart';
import 'widgets/hero_banner.dart';
import 'widgets/home_search.dart';
import 'widgets/whats_bothering_you.dart';
import 'widgets/upcoming_appointment.dart';
import 'widgets/recommended_for_you.dart';
import 'widgets/home_offer.dart';
import 'widgets/why_choose_us.dart';
import 'widgets/need_help.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // SERVICES
  // ============================================================

  final AuthService _authService = AuthService();

  // ============================================================
  // USER DATA
  // ============================================================

  UserModel? _user;

  bool _isLoading = true;

  String? _error;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadHomeData();
  }

  // ============================================================
  // LOAD HOME DATA
  // ============================================================

  Future<void> _loadHomeData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user =
          await _authService.getCurrentUserProfile();

      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Home user loading error: $e',
      );

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // REFRESH HOME
  // ============================================================

  Future<void> _refreshHome() async {
    await _loadHomeData();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FC),

      // ==========================================================
      // HOME CONTENT
      // ==========================================================

      body: SafeArea(
        bottom: false,

        child: RefreshIndicator(
          onRefresh: _refreshHome,

          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),

            padding:
                const EdgeInsets.fromLTRB(
              22,
              18,
              22,
              28,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ==================================================
                // HOME HEADER
                // ==================================================

                HomeHeader(
                  userName: _user?.name,

                  profileImageUrl:
                      _user?.profileImageUrl,

                  // Notifications will be connected
                  // with Firestore later.
                  unreadNotificationCount: 0,

                  onMenuTap: () {
                    debugPrint(
                      'Menu tapped',
                    );
                  },

                  onNotificationTap: () {
                    debugPrint(
                      'Notifications tapped',
                    );
                  },

                  onMessagesTap: () {
                    debugPrint(
                      'Messages tapped',
                    );
                  },

                  onProfileTap: () {
                    debugPrint(
                      'Profile tapped',
                    );
                  },
                ),

                // ==================================================
                // LOADING INDICATOR
                // ==================================================

                if (_isLoading) ...[
                  const SizedBox(height: 8),

                  const LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor:
                        Colors.transparent,
                  ),
                ],

                // ==================================================
                // ERROR STATE
                // ==================================================

                if (_error != null &&
                    !_isLoading) ...[
                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: _loadHomeData,

                    child: Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),

                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFFFF1F1),

                        borderRadius:
                            BorderRadius.circular(14),

                        border: Border.all(
                          color:
                              const Color(0xFFFFD5D5),
                        ),
                      ),

                      child: Row(
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            size: 18,
                            color:
                                Color(0xFFE05252),
                          ),

                          const SizedBox(width: 9),

                          const Expanded(
                            child: Text(
                              'Unable to refresh your profile. Tap to try again.',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Color(0xFF9B3D3D),
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color:
                                Color(0xFFE05252),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // ==================================================
                // SEARCH
                // ==================================================

                HomeSearch(
                  onFilterTap: () {
                    debugPrint(
                      'Filter tapped',
                    );
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // HERO BANNER
                // ==================================================

                HeroBanner(
                  onBookNow: () {
                    debugPrint(
                      'Book now tapped',
                    );

                    // Booking flow later.
                  },
                ),

                const SizedBox(height: 24),

                // ==================================================
                // WHAT'S BOTHERING YOU
                // ==================================================

                WhatsBotheringYou(
                  onAreaSelected: (areaId) {
                    debugPrint(
                      'Selected pain area: $areaId',
                    );

                    // Later:
                    // Navigate to filtered physiotherapists.
                  },

                  onAssessmentTap: () {
                    debugPrint(
                      'Assessment tapped',
                    );

                    // Assessment screen later.
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // UPCOMING APPOINTMENT
                // ==================================================

                UpcomingAppointment(
  onTap: () {
    // Open appointment details later.
  },
),

                const SizedBox(height: 20),

                // ==================================================
                // RECOMMENDED FOR YOU
                // ==================================================
                RecommendedForYou(
  onViewAll: () {
    // Recovery programs screen later.
  },
  onProgramTap: (program) {
    debugPrint(
      'Selected program: ${program.title}',
    );

    // Program details screen later.
  },
),


                const SizedBox(height: 18),

                // ==================================================
                // FIRST SESSION OFFER
                // ==================================================

                HomeOffer(
                  onBookNow: () {
                    debugPrint(
                      'First session offer tapped',
                    );

                    // Booking flow later.
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // WHY CHOOSE US
                // ==================================================

                const WhyChooseUs(),

                const SizedBox(height: 20),

                // ==================================================
                // NEED HELP
                // ==================================================

                NeedHelp(
                  onChatTap: () {
                    debugPrint(
                      'Support chat tapped',
                    );

                    // Support/chat later.
                  },
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}