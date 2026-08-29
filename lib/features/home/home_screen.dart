import 'package:flutter/material.dart';

import 'widgets/home_header.dart';
import 'widgets/hero_banner.dart';
import 'widgets/home_search.dart';
import 'widgets/whats_bothering_you.dart';
import 'widgets/upcoming_appointment.dart';
import 'widgets/recommended_for_you.dart';
import 'widgets/home_offer.dart';
import 'widgets/why_choose_us.dart';
import 'widgets/need_help.dart';
import 'widgets/home_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      // ==========================================================
      // HOME CONTENT
      // ==========================================================

      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(
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
                userName: null,
                profileImageUrl: null,
                unreadNotificationCount: 0,

                onMenuTap: () {
                  // Menu screen later.
                },

                onNotificationTap: () {
                  // Notifications screen later.
                },

                onMessagesTap: () {
                  // Messages screen later.
                },

                onProfileTap: () {
                  // Profile screen later.
                },
              ),

              const SizedBox(height: 18),

              // ==================================================
              // SEARCH
              // ==================================================

              HomeSearch(
                onFilterTap: () {
                  // Filter screen later.
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // HERO BANNER
              // ==================================================

              HeroBanner(
                onBookNow: () {
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
                  // Open relevant physiotherapists
                  // or start booking flow.
                },

                onAssessmentTap: () {
                  // Assessment screen later.
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // UPCOMING APPOINTMENT
              // ==================================================

              const UpcomingAppointment(),

              const SizedBox(height: 20),

              // ==================================================
              // RECOMMENDED FOR YOU
              // ==================================================

              const RecommendedForYou(),

              const SizedBox(height: 18),

              // ==================================================
              // FIRST SESSION OFFER
              // ==================================================

              HomeOffer(
                onBookNow: () {
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
                  // Support/chat screen later.
                },
              ),

              // Bottom spacing so content doesn't
              // touch the navigation bar.
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================

      // bottomNavigationBar: HomeBottomNav(
      //   currentIndex: 0,

      //   onChanged: (index) {
      //     debugPrint(
      //       'Selected navigation index: $index',
      //     );

      //     // Navigation will be connected later.
      //     //
      //     // 0 = Home
      //     // 1 = Explore
      //     // 2 = Bookings
      //     // 3 = Recovery
      //     // 4 = Profile
      //   },
      // ),
    );
  }
}