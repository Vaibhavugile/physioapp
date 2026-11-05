import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../models/user_location_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_location_service.dart';
import '../explore/widgets/location_selection_sheet.dart';
import 'widgets/hero_banner.dart';
import 'widgets/home_header.dart';
import 'widgets/home_offer.dart';
import 'widgets/home_search.dart';
import 'widgets/need_help.dart';
import 'widgets/recommended_for_you.dart';
import 'widgets/upcoming_appointment.dart';
import 'widgets/whats_bothering_you.dart';
import 'widgets/why_choose_us.dart';

/// Premium patient home screen.
///
/// This screen composes the reusable home widgets from `widgets/`.
/// The five-tab navigation is intentionally owned by MainNavigation;
/// do not add a second bottom navigation bar here.
class HomeScreen extends StatefulWidget {
  final void Function(UserLocationModel? location, String? condition)?
      onExploreRequested;

  const HomeScreen({super.key, this.onExploreRequested});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _background = Color(0xFFF6F8FD);
  static const Color _ink = Color(0xFF111936);
  static const Color _muted = Color(0xFF77809A);
  static const Color _primary = Color(0xFF5146D9);
  static const Color _line = Color(0xFFE8EBF3);

  final AuthService _authService = AuthService();
  final UserLocationService _locationService =
      const UserLocationService();
  final TextEditingController _searchController = TextEditingController();

  UserModel? _user;
  bool _loadingUser = true;
  String? _userError;

  UserLocationModel? _currentLocation;
  bool _isDetectingLocation = false;
  String? _locationError;
  Future<void>? _locationFuture;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _locationFuture = _detectLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    if (!mounted) return;

    setState(() {
      _loadingUser = true;
      _userError = null;
    });

    try {
      final profile = await _authService.getCurrentUserProfile();
      if (!mounted) return;

      setState(() {
        _user = profile;
        _loadingUser = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Home profile load failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;

      setState(() {
        _loadingUser = false;
        _userError = 'We could not load your profile details.';
      });
    }
  }

  Future<void> _refreshHome() async {
    await Future.wait([
      _loadUser(),
      _detectLocation(),
    ]);
  }

  /// Gets the device location once when the authenticated home opens.
  /// The resulting model is reused when navigating to ExploreScreen.
  Future<void> _detectLocation({bool showFeedback = false}) async {
    if (_isDetectingLocation) return;

    if (mounted) {
      setState(() {
        _isDetectingLocation = true;
        _locationError = null;
      });
    }

    try {
      final location = await _locationService.getCurrentLocation();
      if (!mounted) return;

      setState(() {
        _currentLocation = location;
        _isDetectingLocation = false;
        _locationError = null;
      });

      if (showFeedback) {
        _showMessage('Location updated to ${location.shortDisplayName}.');
      }
    } catch (error, stackTrace) {
      debugPrint('Home location detection failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;

      setState(() {
        _isDetectingLocation = false;
        _locationError = 'Location unavailable';
      });

      if (showFeedback) {
        _showMessage(
          'Unable to detect your location. You can search for your city instead.',
        );
      }
    }
  }

  Future<void> _chooseLocation() async {
    final selected = await showModalBottomSheet<UserLocationModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationSelectionSheet(
        selectedLocation: _currentLocation,
      ),
    );

    if (!mounted || selected == null) return;

    setState(() {
      _currentLocation = selected;
      _locationError = null;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        ),
      );
  }

  Future<void> _openExplore([String? query]) async {
    final value = query?.trim();

    // If location has not been obtained yet, try once before opening Explore.
    if (_currentLocation == null) {
      if (_isDetectingLocation && _locationFuture != null) {
        await _locationFuture;
      } else {
        _locationFuture = _detectLocation();
        await _locationFuture;
      }
    }

    if (!mounted) return;

    // Ask the parent navigation shell to select its existing Explore tab.
    // This keeps the shared bottom navigation visible and forwards the
    // already-detected location plus the selected body area.
    widget.onExploreRequested?.call(
      _currentLocation,
      value == null || value.isEmpty ? null : value,
    );
  }

  void _openBookings() {
    _showMessage('Your appointments are available in the Bookings tab.');
  }

  void _openRecovery() {
    _showMessage('Your recovery programmes are available in the Recovery tab.');
  }

  void _openProfile() {
    _showMessage('Your account details are available in the Profile tab.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: _primary,
          backgroundColor: Colors.white,
          onRefresh: _refreshHome,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 15, 18, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      HomeHeader(
                        userName: _user?.name,
                        profileImageUrl: _user?.profileImageUrl,
                        unreadNotificationCount: 0,
                        onMenuTap: () => _showMessage(
                          'Account options will be available here.',
                        ),
                        onNotificationTap: () => _showMessage(
                          'You are all caught up on notifications.',
                        ),
                        onMessagesTap: () => _showMessage(
                          'Your support conversations will appear here.',
                        ),
                        onProfileTap: _openProfile,
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: _HomeLocationChip(
                          locationName: _currentLocation?.shortDisplayName,
                          isLoading: _isDetectingLocation,
                          hasError: _locationError != null,
                          onTap: _chooseLocation,
                          onRetry: () { _locationFuture = _detectLocation(showFeedback: true); },
                        ),
                      ),

                      const SizedBox(height: 14),

                      if (_loadingUser) const _ProfileLoadingLine(),
                      if (_userError != null) ...[
                        _HomeInlineNotice(
                          message: _userError!,
                          onRetry: _loadUser,
                        ),
                        const SizedBox(height: 14),
                      ],

                      const _SectionEyebrow(
                        label: 'PERSONALISED PHYSIOTHERAPY',
                        icon: Icons.health_and_safety_rounded,
                      ),
                      const SizedBox(height: 12),

                      HeroBanner(
                        onBookNow: () => _openExplore(),
                      ),

                      const SizedBox(height: 24),

                      HomeSearch(
                        controller: _searchController,
                        onChanged: (value) {
                          // Keep the field responsive; search navigation
                          // is triggered when the field is tapped/submitted.
                        },
                        onTap: () => _openExplore(_searchController.text),
                        onFilterTap: () => _openExplore(),
                      ),

                      const SizedBox(height: 27),

                      const _SectionIntro(
                        eyebrow: 'START WITH HOW YOU FEEL',
                        title: 'Let’s find the right care',
                        subtitle:
                            'Choose the area that needs attention and explore suitable care.',
                      ),
                      const SizedBox(height: 14),

                      WhatsBotheringYou(
                        onAreaSelected: (areaId) => _openExplore(areaId),
                        onAssessmentTap: () => _openExplore(),
                      ),

                      const SizedBox(height: 27),

                      const _SectionIntro(
                        eyebrow: 'YOUR SCHEDULE',
                        title: 'Stay on track',
                        subtitle:
                            'Keep your next physiotherapy session close at hand.',
                      ),
                      const SizedBox(height: 13),

                      UpcomingAppointment(
                        onTap: _openBookings,
                      ),

                      const SizedBox(height: 28),

                      RecommendedForYou(
                        onViewAll: _openRecovery,
                        onProgramTap: (_) => _openRecovery(),
                      ),

                      const SizedBox(height: 27),

                      HomeOffer(
                        onBookNow: () => _openExplore(),
                      ),

                      const SizedBox(height: 27),

                      const WhyChooseUs(),

                      const SizedBox(height: 25),

                      NeedHelp(
                        onChatTap: () => _showMessage(
                          'Support chat will be available here.',
                        ),
                      ),

                      const SizedBox(height: 10),
                      const _HomeFooterNote(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeLocationChip extends StatelessWidget {
  const _HomeLocationChip({
    required this.locationName,
    required this.isLoading,
    required this.hasError,
    required this.onTap,
    required this.onRetry,
  });

  final String? locationName;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final name = locationName?.trim();
    final hasLocation = name != null && name.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasError ? onRetry : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7EAF3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF26345F).withOpacity(.045),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 29,
                height: 29,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(7),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF5146D9),
                        ),
                      )
                    : Icon(
                        hasLocation
                            ? Icons.location_on_rounded
                            : Icons.my_location_rounded,
                        size: 17,
                        color: const Color(0xFF5146D9),
                      ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'YOUR LOCATION',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                        color: Color(0xFF9299AD),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLoading
                          ? 'Detecting...'
                          : hasLocation
                              ? name
                              : hasError
                                  ? 'Tap to retry'
                                  : 'Select your city',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF17203E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 17,
                color: Color(0xFF8189A0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 27,
          height: 27,
          decoration: BoxDecoration(
            color: const Color(0xFFECEBFF),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: const Color(0xFF5146D9)),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6F7691),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.05,
          ),
        ),
      ],
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: Color(0xFF7771D9),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF111936),
            fontSize: 19,
            height: 1.15,
            fontWeight: FontWeight.w900,
            letterSpacing: -.55,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF77809A),
            fontSize: 11,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ProfileLoadingLine extends StatelessWidget {
  const _ProfileLoadingLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF35A995),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          const Text(
            'Preparing your personal home',
            style: TextStyle(
              color: Color(0xFF8991A8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeInlineNotice extends StatelessWidget {
  const _HomeInlineNotice({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF4E3C2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFB47A27),
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF765A31),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Color(0xFF765A31),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeFooterNote extends StatelessWidget {
  const _HomeFooterNote();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Small steps today. Stronger movement tomorrow.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFA0A6B8),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: .1,
          ),
        ),
      ),
    );
  }
}
