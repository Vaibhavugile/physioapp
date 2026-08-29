import 'package:flutter/material.dart';

import '../../models/user_location_model.dart';

import 'models/physio_match_model.dart';
import 'services/explore_physio_service.dart';
import 'services/physio_matching_service.dart';

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
  State<ExploreScreen> createState() =>
      _ExploreScreenState();
}

class _ExploreScreenState
    extends State<ExploreScreen> {
  // ==============================================================
  // SERVICES
  // ==============================================================

  final ExplorePhysioService _physioService =
      const ExplorePhysioService();

  final PhysioMatchingService _matchingService =
      const PhysioMatchingService();

  // ==============================================================
  // USER LOCATION
  // ==============================================================

  UserLocationModel? _selectedLocation;

  // ==============================================================
  // SELECTED CONDITION
  // ==============================================================

  String? _selectedCondition;

  // ==============================================================
  // SEARCH
  // ==============================================================

  String _searchQuery = '';

  // ==============================================================
  // PHYSIOTHERAPIST DATA
  // ==============================================================

  List<dynamic> _physiotherapists = [];

  List<PhysioMatchModel> _matches = [];

  // ==============================================================
  // UI STATES
  // ==============================================================

  bool _isLoading = true;

  String? _errorMessage;

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    _loadPhysiotherapists();
  }

  // ==============================================================
  // LOAD PHYSIOTHERAPISTS FROM FIREBASE
  // ==============================================================

  Future<void> _loadPhysiotherapists() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final physiotherapists =
          await _physioService
              .getAvailablePhysiotherapists();

      if (!mounted) {
        return;
      }

      setState(() {
        _physiotherapists = physiotherapists;
        _isLoading = false;
      });

      _calculateMatches();
    } catch (error, stackTrace) {
      debugPrint(
        'Explore loading error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        _errorMessage =
            'Unable to load physiotherapists.';
      });
    }
  }

  // ==============================================================
  // CALCULATE MATCHES
  // ==============================================================

  void _calculateMatches() {
    if (!mounted) {
      return;
    }

    // ------------------------------------------------------------
    // LOCATION REQUIRED FOR DISTANCE-BASED MATCHING
    // ------------------------------------------------------------

    if (_selectedLocation == null) {
      setState(() {
        _matches = [];
      });

      return;
    }

    try {
      final matches =
          _matchingService.getMatches(
        physiotherapists: _physiotherapists,
        userLocation: _selectedLocation!,
        selectedCondition:
            _selectedCondition,
        searchQuery:
            _searchQuery,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _matches = matches;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Physio matching error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _matches = [];

        _errorMessage =
            'Unable to find matching physiotherapists.';
      });
    }
  }

  // ==============================================================
  // REFRESH
  // ==============================================================

  Future<void> _refreshMatches() async {
    await _loadPhysiotherapists();
  }

  // ==============================================================
  // SEARCH CHANGED
  // ==============================================================

  void _handleSearchChanged(
    String value,
  ) {
    final query = value.trim();

    setState(() {
      _searchQuery = query;
    });

    // No Firebase request needed.
    // Just recalculate cached physiotherapists.

    _calculateMatches();
  }

  // ==============================================================
  // CONDITION SELECTED
  // ==============================================================

  void _handleConditionSelected(
    String condition,
  ) {
    setState(() {
      // ----------------------------------------------------------
      // TAP SAME CONDITION AGAIN = CLEAR CONDITION
      // ----------------------------------------------------------

      if (_selectedCondition == condition) {
        _selectedCondition = null;
      } else {
        _selectedCondition = condition;
      }
    });

    _calculateMatches();
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FC),

      body: SafeArea(
        bottom: false,

        child: RefreshIndicator(
          onRefresh: _refreshMatches,

          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(
              parent:
                  BouncingScrollPhysics(),
            ),

            padding:
                const EdgeInsets.fromLTRB(
              22,
              18,
              22,
              30,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ================================================
                // HEADER
                // ================================================

                ExploreHeader(
                  onNotificationTap: () {
                    _showComingSoon(
                      'Notifications',
                    );
                  },

                  onProfileTap: () {
                    _showComingSoon(
                      'Profile',
                    );
                  },
                ),

                const SizedBox(height: 18),

                // ================================================
                // SEARCH + LOCATION
                // ================================================

                ExploreSearch(
                  selectedLocation:
                      _selectedLocation,

                  onFilterTap:
                      _showFilterComingSoon,

                  onSearchChanged:
                      _handleSearchChanged,

                  onLocationTap:
                      _openLocationSelection,
                ),

                const SizedBox(height: 26),

                // ================================================
                // POPULAR CONDITIONS
                // ================================================

                PopularConditions(
                  onSelected:
                      _handleConditionSelected,

                  onSeeAll:
                      _showConditionsComingSoon,
                ),

                const SizedBox(height: 28),

                // ================================================
                // RECOMMENDED TITLE
                // ================================================

                const Text(
                  'Recommended for you',
                  style: TextStyle(
                    fontSize: 19,
                    color:
                        Color(0xFF111A3D),
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _getRecommendationSubtitle(),
                  style: const TextStyle(
                    fontSize: 13,
                    color:
                        Color(0xFF7B849C),
                    fontWeight:
                        FontWeight.w600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 14),

                // ================================================
                // PHYSIOTHERAPIST CONTENT
                // ================================================

                _buildPhysioContent(),

                const SizedBox(height: 28),

                // ================================================
                // TRUST STATS
                // ================================================

                const ExploreTrustStats(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // PHYSIO CONTENT
  // ==============================================================

  Widget _buildPhysioContent() {
    // ------------------------------------------------------------
    // LOADING
    // ------------------------------------------------------------

    if (_isLoading) {
      return const Padding(
        padding:
            EdgeInsets.symmetric(
          vertical: 40,
        ),

        child: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    // ------------------------------------------------------------
    // ERROR
    // ------------------------------------------------------------

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // ------------------------------------------------------------
    // LOCATION REQUIRED
    // ------------------------------------------------------------

    if (_selectedLocation == null) {
      return _buildLocationRequiredState();
    }

    // ------------------------------------------------------------
    // NO RESULTS
    // ------------------------------------------------------------

    if (_matches.isEmpty) {
      return _buildNoPhysiosState();
    }

    // ------------------------------------------------------------
    // BEST MATCH
    // ------------------------------------------------------------

    final bestMatch =
        _matches.first;

    // ------------------------------------------------------------
    // TOP RATED
    // ------------------------------------------------------------

    final topRated =
        List<PhysioMatchModel>.from(
      _matches,
    )
          ..sort(
            (a, b) =>
                b.physiotherapist.rating
                    .compareTo(
              a.physiotherapist.rating,
            ),
          );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        // ========================================================
        // BEST MATCH
        // ========================================================

        BestMatchCard(
          match: bestMatch,

          onViewProfile: () {
            _showComingSoon(
              'Physiotherapist profile',
            );
          },

          onBookSession: () {
            _showComingSoon(
              'Booking',
            );
          },
        ),

        const SizedBox(height: 30),

        // ========================================================
        // TOP RATED
        // ========================================================

        TopRatedPhysios(
          matches: topRated,

          onSeeAll: () {
            _showAllPhysios(
              topRated,
            );
          },
        ),
      ],
    );
  }

  // ==============================================================
  // LOCATION REQUIRED STATE
  // ==============================================================

  Widget _buildLocationRequiredState() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color:
              const Color(0xFFE3E8F2),
        ),
      ),

      child: Column(
        children: [
          const Icon(
            Icons.location_on_rounded,
            size: 46,
            color:
                Color(0xFF2457F5),
          ),

          const SizedBox(height: 14),

          const Text(
            'Choose your location',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF111A3D),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Select your current location to find the best physiotherapists near you.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color:
                  Color(0xFF7B849C),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed:
                _openLocationSelection,

            icon: const Icon(
              Icons.my_location_rounded,
            ),

            label: const Text(
              'Choose location',
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // NO PHYSIOS STATE
  // ==============================================================

  Widget _buildNoPhysiosState() {
    String message;

    if (_searchQuery.isNotEmpty) {
      message =
          'Try changing your search or location.';
    } else if (_selectedCondition != null) {
      message =
          'Try another condition or location.';
    } else {
      message =
          'Try changing your location.';
    }

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(28),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color:
              const Color(0xFFE3E8F2),
        ),
      ),

      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 46,
            color:
                Color(0xFF7B849C),
          ),

          const SizedBox(height: 14),

          const Text(
            'No physiotherapists found',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF111A3D),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            message,
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color:
                  Color(0xFF7B849C),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton(
            onPressed:
                _openLocationSelection,

            child: const Text(
              'Change location',
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // ERROR STATE
  // ==============================================================

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color:
              const Color(0xFFE3E8F2),
        ),
      ),

      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 42,
            color:
                Color(0xFFE85D5D),
          ),

          const SizedBox(height: 14),

          const Text(
            'Unable to load physiotherapists',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF111A3D),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _errorMessage ??
                'Please try again.',
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color:
                  Color(0xFF7B849C),
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed:
                _loadPhysiotherapists,

            child: const Text(
              'Try again',
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // LOCATION SELECTION
  // ==============================================================

  Future<void>
      _openLocationSelection() async {
    final location =
        await showModalBottomSheet<
            UserLocationModel>(
      context: context,

      isScrollControlled: true,

      backgroundColor:
          Colors.transparent,

      builder: (context) {
        return LocationSelectionSheet(
          selectedLocation:
              _selectedLocation,
        );
      },
    );

    if (location == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedLocation = location;
      _errorMessage = null;
    });

    _calculateMatches();

    _showLocationUpdatedMessage(
      location,
    );
  }

  // ==============================================================
  // LOCATION UPDATED MESSAGE
  // ==============================================================

  void _showLocationUpdatedMessage(
    UserLocationModel location,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,

        content: Text(
          'Location updated to '
          '${location.shortDisplayName}',
        ),
      ),
    );
  }

  // ==============================================================
  // RECOMMENDATION SUBTITLE
  // ==============================================================

  String _getRecommendationSubtitle() {
    if (_selectedCondition != null &&
        _selectedLocation != null) {
      return 'Best physiotherapists near you for '
          '$_selectedCondition';
    }

    if (_selectedCondition != null) {
      return 'Physiotherapists recommended for '
          '$_selectedCondition';
    }

    if (_selectedLocation != null) {
      return 'Top physiotherapists near '
          '${_selectedLocation!.shortDisplayName}';
    }

    return 'Choose your location to find the best '
        'physiotherapists near you';
  }

  // ==============================================================
  // SHOW ALL PHYSIOS
  // ==============================================================

  void _showAllPhysios(
    List<PhysioMatchModel> physios,
  ) {
    _showComingSoon(
      'All physiotherapists',
    );
  }

  // ==============================================================
  // FILTER
  // ==============================================================

  void _showFilterComingSoon() {
    _showComingSoon(
      'Advanced filters',
    );
  }

  // ==============================================================
  // ALL CONDITIONS
  // ==============================================================

  void _showConditionsComingSoon() {
    _showComingSoon(
      'All conditions',
    );
  }

  // ==============================================================
  // GENERIC SNACKBAR
  // ==============================================================

  void _showComingSoon(
    String feature,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,

        content: Text(
          '$feature will be available soon.',
        ),
      ),
    );
  }
}