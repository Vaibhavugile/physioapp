import 'package:flutter/material.dart';

import 'widgets/explore_header.dart';
import 'widgets/explore_search.dart';
import 'widgets/popular_conditions.dart';
import 'widgets/best_match_card.dart';
import 'widgets/top_rated_physios.dart';
import 'widgets/explore_trust_stats.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      body: SafeArea(
        bottom: false,

        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(
            22,
            18,
            22,
            30,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ==================================================
              // PREMIUM EXPLORE HEADER
              // ==================================================

              ExploreHeader(
                onNotificationTap: () {
                  // Notifications screen later.
                },

                onProfileTap: () {
                  // Profile screen later.
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // SEARCH + LOCATION
              // ==================================================

              ExploreSearch(
                onFilterTap: () {
                  // Filter screen later.
                },

                onSearchChanged: (value) {
                  debugPrint(
                    'Explore search: $value',
                  );
                },

                onLocationTap: () {
                  // Location selection later.
                },
              ),

              const SizedBox(height: 24),

              // ==================================================
              // POPULAR CONDITIONS
              // ==================================================

              PopularConditions(
                onSelected: (condition) {
                  debugPrint(
                    'Selected condition: $condition',
                  );

                  // Later:
                  // Filter physiotherapists
                  // according to selected condition.
                },

                onSeeAll: () {
                  // All conditions screen later.
                },
              ),

              const SizedBox(height: 24),

              // ==================================================
              // RECOMMENDED FOR YOU
              // ==================================================

              const Text(
                'Recommended for you',

                style: TextStyle(
                  fontSize: 15,
                  color:
                      Color(0xFF111A3D),
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: -.35,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'A physiotherapist picked for your needs',
                style: TextStyle(
                  fontSize: 8.5,
                  color:
                      Color(0xFF7B849C),
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 11),

              // ==================================================
              // BEST MATCH
              // ==================================================

              BestMatchCard(
                onViewProfile: () {
                  // Doctor profile later.
                },

                onBookSession: () {
                  // Booking flow later.
                },
              ),

              const SizedBox(height: 26),

              // ==================================================
              // TOP RATED PHYSIOS
              // ==================================================

              TopRatedPhysios(
                onSeeAll: () {
                  // All physiotherapists screen later.
                },
              ),

              const SizedBox(height: 24),

              // ==================================================
              // TRUST STATS
              // ==================================================

              const ExploreTrustStats(),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}