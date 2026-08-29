import 'package:flutter/material.dart';

import '../../models/user_location_model.dart';

import 'widgets/explore_header.dart';
import 'widgets/explore_search.dart';
import 'widgets/popular_conditions.dart';
import 'widgets/best_match_card.dart';
import 'widgets/top_rated_physios.dart';
import 'widgets/explore_trust_stats.dart';
import 'widgets/location_selection_sheet.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // ==============================================================
  // SELECTED LOCATION
  // ==============================================================

  UserLocationModel? _selectedLocation;

  // ==============================================================
  // SELECTED CONDITION
  // ==============================================================

  String? _selectedCondition;

  // ==============================================================
  // SEARCH QUERY
  // ==============================================================

  String _searchQuery = '';

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      body: SafeArea(
        bottom: false,

        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(
            22,
            18,
            22,
            30,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // PREMIUM EXPLORE HEADER
              // ==================================================

              ExploreHeader(
                onNotificationTap: () {
                  // TODO:
                  // Navigate to notifications screen.
                },

                onProfileTap: () {
                  // TODO:
                  // Navigate to profile screen.
                },
              ),

              const SizedBox(height: 18),

              // ==================================================
              // SEARCH + LOCATION
              // ==================================================

              ExploreSearch(
                // ----------------------------------------------
                // SELECTED LOCATION
                // ----------------------------------------------

                selectedLocation: _selectedLocation,

                // ----------------------------------------------
                // FILTER
                // ----------------------------------------------

                onFilterTap: () {
                  _showFilterComingSoon();
                },

                // ----------------------------------------------
                // SEARCH
                // ----------------------------------------------

                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });

                  debugPrint(
                    'Explore search: $_searchQuery',
                  );

                  // Future:
                  // Use _searchQuery to filter physiotherapists.
                },

                // ----------------------------------------------
                // LOCATION
                // ----------------------------------------------

                onLocationTap: _openLocationSelection,
              ),

              const SizedBox(height: 26),

              // ==================================================
              // POPULAR CONDITIONS
              // ==================================================

              PopularConditions(
                onSelected: (condition) {
                  setState(() {
                    _selectedCondition = condition;
                  });

                  debugPrint(
                    'Selected condition: $_selectedCondition',
                  );

                  // Future:
                  //
                  // Use _selectedCondition +
                  // _selectedLocation
                  //
                  // to calculate the best physiotherapist match.
                },

                onSeeAll: () {
                  _showConditionsComingSoon();
                },
              ),

              const SizedBox(height: 28),

              // ==================================================
              // RECOMMENDED FOR YOU
              // ==================================================

              const Text(
                'Recommended for you',
                style: TextStyle(
                  fontSize: 19,
                  color: Color(0xFF111A3D),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                _getRecommendationSubtitle(),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7B849C),
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // BEST MATCH
              // ==================================================

              BestMatchCard(
                onViewProfile: () {
                  // TODO:
                  // Navigate to physiotherapist profile.
                },

                onBookSession: () {
                  // TODO:
                  // Open booking flow.
                },
              ),

              const SizedBox(height: 30),

              // ==================================================
              // TOP RATED PHYSIOS
              // ==================================================

              TopRatedPhysios(
                onSeeAll: () {
                  // TODO:
                  // Navigate to all physiotherapists screen.
                },
              ),

              const SizedBox(height: 28),

              // ==================================================
              // TRUST STATS
              // ==================================================

              const ExploreTrustStats(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // OPEN LOCATION SELECTION
  // ==============================================================

  Future<void> _openLocationSelection() async {
    final location =
        await showModalBottomSheet<UserLocationModel>(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return LocationSelectionSheet(
          selectedLocation: _selectedLocation,
        );
      },
    );

    // ------------------------------------------------------------
    // USER CLOSED SHEET WITHOUT SELECTING
    // ------------------------------------------------------------

    if (location == null) {
      return;
    }

    // ------------------------------------------------------------
    // UPDATE LOCATION
    // ------------------------------------------------------------

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedLocation = location;
    });

    debugPrint(
      'Selected location: ${location.toString()}',
    );

    // ------------------------------------------------------------
    // FUTURE:
    //
    // Reload physiotherapists based on:
    //
    // location.latitude
    // location.longitude
    // location.city
    //
    // ------------------------------------------------------------

    _showLocationUpdatedMessage(location);
  }

  // ==============================================================
  // LOCATION UPDATED MESSAGE
  // ==============================================================

  void _showLocationUpdatedMessage(
    UserLocationModel location,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,

        margin: const EdgeInsets.all(16),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        content: Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                'Location updated to ${location.shortDisplayName}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // RECOMMENDATION SUBTITLE
  // ==============================================================

  String _getRecommendationSubtitle() {
    // ------------------------------------------------------------
    // CONDITION + LOCATION
    // ------------------------------------------------------------

    if (_selectedCondition != null &&
        _selectedLocation != null) {
      return 'Best physiotherapists near you for $_selectedCondition';
    }

    // ------------------------------------------------------------
    // CONDITION ONLY
    // ------------------------------------------------------------

    if (_selectedCondition != null) {
      return 'Physiotherapists recommended for $_selectedCondition';
    }

    // ------------------------------------------------------------
    // LOCATION ONLY
    // ------------------------------------------------------------

    if (_selectedLocation != null) {
      return 'Top physiotherapists near ${_selectedLocation!.shortDisplayName}';
    }

    // ------------------------------------------------------------
    // DEFAULT
    // ------------------------------------------------------------

    return 'Choose your location to find the best physiotherapists near you';
  }

  // ==============================================================
  // FILTER
  // ==============================================================

  void _showFilterComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Advanced filters will be available soon.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==============================================================
  // ALL CONDITIONS
  // ==============================================================

  void _showConditionsComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'All conditions will be available soon.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}