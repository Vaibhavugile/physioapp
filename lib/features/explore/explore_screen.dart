import 'package:flutter/material.dart';

import '../../models/user_location_model.dart';
import '../../models/physiotherapist_model.dart';
import '../../services/user_location_service.dart';
import '../booking/booking_details_screen.dart';
import '../booking/instant_booking_screen.dart';
import '../core/config/pricing_config.dart';

import 'models/physio_match_model.dart';
import 'physio_profile_screen.dart';
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
  final UserLocationModel? initialLocation;
  final String? initialCondition;

  const ExploreScreen({
    super.key,
    this.initialLocation,
    this.initialCondition,
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

  final UserLocationService _locationService =
      const UserLocationService();

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

  /// IMPORTANT:
  /// This must NOT be List<dynamic>.
  ///
  /// PhysioMatchingService expects:
  /// List<PhysiotherapistModel>
  ///
  List<PhysiotherapistModel> _physiotherapists =
      <PhysiotherapistModel>[];

  List<PhysioMatchModel> _matches =
      <PhysioMatchModel>[];

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

    // HomeScreen can pass its already-detected location and selected body area.
    // When Explore is opened independently, reuse the device's current location.
    _selectedLocation = widget.initialLocation;
    _selectedCondition = widget.initialCondition;

    _initializeExplore();
  }

  Future<void> _initializeExplore() async {
    if (_selectedLocation == null) {
      try {
        final location = await _locationService.getCurrentLocation();
        if (!mounted) return;

        setState(() {
          _selectedLocation = location;
        });
      } catch (error) {
        // Keep Explore usable when location permission is unavailable.
        // The location-required state offers manual selection.
        debugPrint('Explore automatic location detection failed: $error');
      }
    }

    if (!mounted) return;
    await _loadPhysiotherapists();
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
      final List<PhysiotherapistModel>
          physiotherapists =
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
        _matches = <PhysioMatchModel>[];
      });

      return;
    }

    try {
      final List<PhysioMatchModel> matches =
          _matchingService.getMatches(
        physiotherapists: _physiotherapists,
        userLocation: _selectedLocation!,
        selectedCondition: _selectedCondition,
        searchQuery: _searchQuery,
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
        _matches = <PhysioMatchModel>[];

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
    final String query = value.trim();

    setState(() {
      _searchQuery = query;
    });

    _calculateMatches();
  }

  // ==============================================================
  // CONDITION SELECTED
  // ==============================================================

  void _handleConditionSelected(
    String condition,
  ) {
    setState(() {
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
      backgroundColor: const Color(0xFFF6F7FC),

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

            padding: const EdgeInsets.fromLTRB(18, 14, 18, 34),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ==================================================
                // HEADER
                // ==================================================

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

                const SizedBox(height: 16),

                // ==================================================
                // SEARCH + LOCATION
                // ==================================================

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

                const SizedBox(height: 16),

                _buildBookingMarketplaceCard(),

                const SizedBox(height: 22),

                if (_selectedCondition != null) ...[
                  _SelectedConditionBanner(
                    condition: _formatConditionLabel(_selectedCondition!),
                    onClear: () {
                      setState(() {
                        _selectedCondition = null;
                      });
                      _calculateMatches();
                    },
                  ),
                  const SizedBox(height: 22),
                ],

                // ==================================================
                // POPULAR CONDITIONS
                // ==================================================

                PopularConditions(
                  onSelected:
                      _handleConditionSelected,

                  onSeeAll:
                      _showConditionsComingSoon,
                ),

                const SizedBox(height: 28),

                // ==================================================
                // RECOMMENDED TITLE
                // ==================================================

                const Text(
                  'CURATED FOR YOUR RECOVERY',
                  style: TextStyle(
                    fontSize: 8,
                    color: Color(0xFF7771D9),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Recommended for you',
                  style: TextStyle(
                    fontSize: 21,
                    height: 1.1,
                    color: Color(0xFF111A3D),
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.7,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _getRecommendationSubtitle(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7B849C),
                    fontWeight:
                        FontWeight.w600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // PHYSIOTHERAPIST CONTENT
                // ==================================================

                _buildPhysioContent(),

                const SizedBox(height: 24),

                // ==================================================
                // TRUST STATS
                // ==================================================

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
  // PREMIUM BOOKING MARKETPLACE
  // ==============================================================

  Widget _buildBookingMarketplaceCard() {
    return InkWell(
      onTap: _openOnDemandBooking,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF171B4B), Color(0xFF39318C), Color(0xFF5146D9)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5146D9).withOpacity(.17),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.13),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.bolt_rounded, color: Color(0xFFFFD88A), size: 25),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ON-DEMAND PHYSIOTHERAPY', style: TextStyle(color: Color(0xFFBFC4FF), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                  SizedBox(height: 4),
                  Text('Book a physiotherapist instantly', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                  SizedBox(height: 3),
                  Text('Choose your time, location and care type', style: TextStyle(color: Color(0xFFD9DBF5), fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 21),
          ],
        ),
      ),
    );
  }

  Future<void> _openOnDemandBooking() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InstantBookingScreen(
          initialLocation: _selectedLocation,
          initialCondition: _selectedCondition,
        ),
      ),
    );
  }

  Future<void> _openPhysioProfile(PhysioMatchModel match) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PhysioProfileScreen(match: match),
      ),
    );
  }

  Future<void> _openBooking(
    PhysioMatchModel match,
    String careMode,
    int packageVisits,
  ) async {
    final p = match.physiotherapist;
    if (_priceForMode(p, careMode) <= 0) {
      _showNoProviderFeedback('This physiotherapist has not completed pricing for this service.');
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingDetailsScreen(
          physiotherapistId: p.uid,
          doctorName: p.fullName,
          doctorImage: p.profileImageUrl ?? '',
          specialty: p.primarySpecialization,
          rating: p.rating,
          physiotherapistPhone: p.phone,
          experienceYears: p.experienceYears,
          initialCareMode: careMode,
          initialPackageVisits: packageVisits,
          workingDays: p.workingDays,
        ),
      ),
    );
  }

  String _defaultCareMode(PhysiotherapistModel p) {
    if (p.homeVisitEnabled && p.homeVisitPrice > 0) return PricingConfig.home;
    if (p.clinicVisitEnabled && p.clinicVisitPrice > 0) return PricingConfig.clinic;
    if (p.onlineConsultationEnabled && p.onlineConsultationPrice > 0) return PricingConfig.online;
    return PricingConfig.home;
  }

  double _priceForMode(PhysiotherapistModel p, String mode) {
    if (mode == PricingConfig.clinic) return p.clinicVisitPrice;
    if (mode == PricingConfig.online) return p.onlineConsultationPrice;
    return p.homeVisitPrice;
  }

  void _showNoProviderFeedback([String message = 'No eligible physiotherapists are available for this service in your selected area yet.']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
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

    final PhysioMatchModel bestMatch =
        _matches.first;

    // ------------------------------------------------------------
    // TOP RATED
    // ------------------------------------------------------------

    final List<PhysioMatchModel> topRated =
        List<PhysioMatchModel>.from(
      _matches,
    )..sort(
            (
              PhysioMatchModel a,
              PhysioMatchModel b,
            ) =>
                b.physiotherapist.rating.compareTo(
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

          onViewProfile: () => _openPhysioProfile(bestMatch),

          onBookSession: () => _openBooking(
            bestMatch,
            _defaultCareMode(bestMatch.physiotherapist),
            1,
          ),
        ),

        const SizedBox(height: 30),

        // ========================================================
        // TOP RATED
        // ========================================================

        TopRatedPhysios(
          matches: topRated,
          onPhysioTap: _openPhysioProfile,
          onSeeAll: () => _showAllPhysios(topRated),
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
    final UserLocationModel? location =
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

  String _formatConditionLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  // ==============================================================
  // RECOMMENDATION SUBTITLE
  // ==============================================================

  String _getRecommendationSubtitle() {
    if (_selectedCondition != null &&
        _selectedLocation != null) {
      return 'Best physiotherapists near you for '
          '${_formatConditionLabel(_selectedCondition!)}';
    }

    if (_selectedCondition != null) {
      return 'Physiotherapists recommended for '
          '${_formatConditionLabel(_selectedCondition!)}';
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

  void _showAllPhysios(List<PhysioMatchModel> physios) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(sheetContext).size.height * .78,
        decoration: const BoxDecoration(color: Color(0xFFF7F8FC), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFD8DCE8), borderRadius: BorderRadius.circular(4))),
          Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 12), child: Row(children: [const Expanded(child: Text('Physiotherapists near you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF171D3B))),), Text('${physios.length} found', style: const TextStyle(fontSize: 11, color: Color(0xFF77809A), fontWeight: FontWeight.w700))])),
          Expanded(child: ListView.separated(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), itemCount: physios.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, index) {
            final match = physios[index];
            final p = match.physiotherapist;
            final mode = _defaultCareMode(p);
            final price = _priceForMode(p, mode);
            final currency = _currencySymbol(p.currency);
            return _ProviderOfferTile(match: match, priceText: price > 0 ? '$currency${price.toStringAsFixed(0)} / session' : 'Price unavailable', onTap: () { Navigator.pop(sheetContext); _openPhysioProfile(match); });
          })),
        ]),
      ),
    );
  }

  String _currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'INR': return '₹';
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      default: return '$currency ';
    }
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

class _MarketplaceAction extends StatelessWidget {
  const _MarketplaceAction({required this.icon, required this.title, required this.subtitle, required this.primary, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? Colors.white : Colors.white.withOpacity(.10),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: primary ? Colors.white : Colors.white.withOpacity(.20))),
          child: Row(children: [
            Icon(icon, color: primary ? const Color(0xFF5146D9) : Colors.white, size: 21),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: primary ? const Color(0xFF1A2040) : Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: primary ? const Color(0xFF8189A0) : Colors.white.withOpacity(.70), fontSize: 8, fontWeight: FontWeight.w600)),
            ])),
          ]),
        ),
      ),
    );
  }
}

class _OnDemandSelection {
  const _OnDemandSelection(this.match, this.careMode, this.packageVisits);
  final PhysioMatchModel match;
  final String careMode;
  final int packageVisits;
}

class _OnDemandBookingSheet extends StatefulWidget {
  const _OnDemandBookingSheet({required this.matches, this.initialCondition});
  final List<PhysioMatchModel> matches;
  final String? initialCondition;

  @override
  State<_OnDemandBookingSheet> createState() => _OnDemandBookingSheetState();
}

class _OnDemandBookingSheetState extends State<_OnDemandBookingSheet> {
  String _careMode = PricingConfig.home;
  int _visits = 1;

  @override
  void initState() {
    super.initState();
    final hasHome = widget.matches.any((m) => m.physiotherapist.homeVisitEnabled && m.physiotherapist.homeVisitPrice > 0);
    final hasClinic = widget.matches.any((m) => m.physiotherapist.clinicVisitEnabled && m.physiotherapist.clinicVisitPrice > 0);
    final hasOnline = widget.matches.any((m) => m.physiotherapist.onlineConsultationEnabled && m.physiotherapist.onlineConsultationPrice > 0);
    if (!hasHome && hasClinic) {
      _careMode = PricingConfig.clinic;
    } else if (!hasHome && !hasClinic && hasOnline) {
      _careMode = PricingConfig.online;
    }
  }

  bool _enabled(PhysiotherapistModel p, String mode) {
    final flagAndPrice = mode == PricingConfig.home
        ? p.homeVisitEnabled && p.homeVisitPrice > 0
        : mode == PricingConfig.clinic
            ? p.clinicVisitEnabled && p.clinicVisitPrice > 0
            : p.onlineConsultationEnabled && p.onlineConsultationPrice > 0;
    if (!flagAndPrice) return false;
    final key = mode == PricingConfig.home ? 'home' : mode == PricingConfig.clinic ? 'clinic' : 'online';
    final schedule = p.serviceSchedules[key];
    if (schedule is Map && schedule['enabled'] == false) return false;
    return true;
  }

  double _price(PhysiotherapistModel p) {
    if (_careMode == PricingConfig.clinic) return p.clinicVisitPrice;
    if (_careMode == PricingConfig.online) return p.onlineConsultationPrice;
    return p.homeVisitPrice;
  }

  String _currency(String value) {
    switch (value.toUpperCase()) {
      case 'INR': return '₹';
      case 'EUR': return '€';
      case 'GBP': return '£';
      default: return '$value ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = widget.matches.where((m) => _enabled(m.physiotherapist, _careMode)).toList()..sort((a,b) => a.distanceKm.compareTo(b.distanceKm));
    return Container(
      height: MediaQuery.of(context).size.height * .86,
      decoration: const BoxDecoration(color: Color(0xFFF7F8FC), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(children: [
        const SizedBox(height: 12),
        Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFD8DCE8), borderRadius: BorderRadius.circular(4))),
        Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 10), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Build your session', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF171D3B))),
            const SizedBox(height: 4),
            Text(widget.initialCondition == null ? 'Choose a service and recovery package.' : 'Care for ${widget.initialCondition!.replaceAll('_', ' ')}', style: const TextStyle(fontSize: 11, color: Color(0xFF7B849C))),
          ])),
          const Icon(Icons.health_and_safety_rounded, color: Color(0xFF5146D9), size: 27),
        ])),
        Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 20), children: [
          const _SheetSectionTitle('1. Choose your service'),
          const SizedBox(height: 9),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _ServiceChoice(label: 'Home visit', icon: Icons.home_rounded, value: PricingConfig.home, selected: _careMode == PricingConfig.home, onTap: () => setState(() => _careMode = PricingConfig.home)),
            _ServiceChoice(label: 'Clinic', icon: Icons.local_hospital_rounded, value: PricingConfig.clinic, selected: _careMode == PricingConfig.clinic, onTap: () => setState(() => _careMode = PricingConfig.clinic)),
            _ServiceChoice(label: 'Online', icon: Icons.videocam_rounded, value: PricingConfig.online, selected: _careMode == PricingConfig.online, onTap: () => setState(() => _careMode = PricingConfig.online)),
          ]),
          const SizedBox(height: 20),
          const _SheetSectionTitle('2. Choose your package'),
          const SizedBox(height: 9),
          Row(children: PricingConfig.packages.map((package) {
            final visits = package.visits;
            final selected = _visits == visits;
            final isLast = visits == PricingConfig.packages.last.visits;
            return Expanded(child: Padding(padding: EdgeInsets.only(right: isLast ? 0 : 7), child: InkWell(onTap: () => setState(() => _visits = visits), borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4), decoration: BoxDecoration(color: selected ? const Color(0xFFEEEDFF) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? const Color(0xFF6257E8) : const Color(0xFFE6E9F1), width: selected ? 1.5 : 1)), child: Column(children: [Text('$visits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: selected ? const Color(0xFF5146D9) : const Color(0xFF1A2040))), Text(visits == 1 ? 'Session' : 'Sessions', style: const TextStyle(fontSize: 8, color: Color(0xFF7B849C), fontWeight: FontWeight.w700))])))));
          }).toList()),
          const SizedBox(height: 20),
          Row(children: [const Expanded(child: _SheetSectionTitle('3. Available physiotherapists')), Text('${available.length} offers', style: const TextStyle(fontSize: 10, color: Color(0xFF7B849C), fontWeight: FontWeight.w800))]),
          const SizedBox(height: 5),
          const Text('Rates below come from each professional’s saved onboarding price card. Final package totals are verified again in booking.', style: TextStyle(fontSize: 9, color: Color(0xFF8790A6), height: 1.4)),
          const SizedBox(height: 10),
          if (available.isEmpty)
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Text('No eligible professionals currently offer this service with an active price in your selected area. Try another service or change location.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Color(0xFF77809A), height: 1.5)))
          else
            ...available.map((match) {
              final p = match.physiotherapist;
              final unit = _price(p);
              final discount = p.discountAvailable ? p.discountPercentage.clamp(0, 100).toDouble() : 0.0;
              final total = unit * _visits * (1 - discount / 100);
              return Padding(padding: const EdgeInsets.only(bottom: 10), child: _ProviderOfferTile(
                match: match,
                priceText: '${_currency(p.currency)}${unit.toStringAsFixed(0)} / session',
                packageText: '${_currency(p.currency)}${total.toStringAsFixed(0)} for $_visits ${_visits == 1 ? 'session' : 'sessions'}',
                onTap: () => Navigator.pop(context, _OnDemandSelection(match, _careMode, _visits)),
              ));
            }),
        ])),
      ]),
    );
  }
}

class _SheetSectionTitle extends StatelessWidget {
  const _SheetSectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF202747)));
}

class _ServiceChoice extends StatelessWidget {
  const _ServiceChoice({required this.label, required this.icon, required this.value, required this.selected, required this.onTap});
  final String label; final IconData icon; final String value; final bool selected; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(13), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: selected ? const Color(0xFFEEEDFF) : Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: selected ? const Color(0xFF6257E8) : const Color(0xFFE6E9F1))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: selected ? const Color(0xFF5146D9) : const Color(0xFF7B849C)), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: selected ? const Color(0xFF5146D9) : const Color(0xFF59627A))) ])));
}

class _ProviderOfferTile extends StatelessWidget {
  const _ProviderOfferTile({required this.match, required this.priceText, this.packageText, required this.onTap});
  final PhysioMatchModel match; final String priceText; final String? packageText; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = match.physiotherapist;
    final tier = p.pricingTierLabel.trim().isEmpty ? 'Pricing tier unavailable' : p.pricingTierLabel;
    final name = p.fullName.trim().toLowerCase().startsWith('dr.') ? p.fullName.trim() : 'Dr. ${p.fullName.trim()}';
    return Material(color: Colors.white, borderRadius: BorderRadius.circular(18), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE6E9F1))), child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFEFEEFF), borderRadius: BorderRadius.circular(15), image: p.profileImageUrl == null || p.profileImageUrl!.isEmpty ? null : DecorationImage(image: NetworkImage(p.profileImageUrl!), fit: BoxFit.cover)), child: p.profileImageUrl == null || p.profileImageUrl!.isEmpty ? const Icon(Icons.person_rounded, color: Color(0xFF5146D9), size: 25) : null),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1B2241))), const SizedBox(height: 3), Text('$tier • ${p.experienceYears} yrs experience', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Color(0xFF727C96), fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text('${[p.pricingLocality, p.pricingCity].where((v) => v.trim().isNotEmpty).join(', ').isEmpty ? 'Nearby service area' : [p.pricingLocality, p.pricingCity].where((v) => v.trim().isNotEmpty).join(', ')} • ${match.distanceKm.toStringAsFixed(1)} km away', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Color(0xFF8991A5))) ])),
      const SizedBox(width: 7),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(priceText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF1C2444))), if (packageText != null) ...[const SizedBox(height: 3), Text(packageText!, style: const TextStyle(fontSize: 8, color: Color(0xFF079F87), fontWeight: FontWeight.w800))], const SizedBox(height: 5), const Icon(Icons.arrow_forward_rounded, color: Color(0xFF5146D9), size: 16)]),
    ]))));
  }
}

class _SelectedConditionBanner extends StatelessWidget {
  const _SelectedConditionBanner({
    required this.condition,
    required this.onClear,
  });

  final String condition;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 13, 10, 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0EFFF), Color(0xFFEEF8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE2E4FA)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Color(0xFF5146D9),
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CARE FOCUS',
                  style: TextStyle(
                    color: Color(0xFF7771C9),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$condition care',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF182044),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onClear,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF5146D9),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Clear',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
