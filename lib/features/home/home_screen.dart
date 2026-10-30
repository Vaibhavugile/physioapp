
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/config/pricing_config.dart';
import '../booking/models/booking_model.dart';
import '../../models/recovery_program_model.dart';
import '../../models/user_model.dart';
import '../../models/physiotherapist_model.dart';
import '../../services/auth_service.dart';
import '../booking/services/booking_service.dart';
import '../../services/physiotherapist_service.dart';
import '../../services/recovery_program_service.dart';
import '../booking/booking_details_screen.dart';

/// ================================================================
/// PREMIUM HOME — SINGLE FILE
/// ================================================================
///
/// Everything used by the patient Home screen intentionally lives in
/// this file:
///
/// HomeScreen
/// HomeHeader
/// HeroBanner
/// HomeSearch
/// WhatsBotheringYou
/// UpcomingAppointment
/// RecommendedForYou
/// HomeOffer
/// WhyChooseUs
/// NeedHelp
/// HomeBottomNav
///
/// DATA POLICY
/// ----------------------------------------------------------------
/// No doctor, offer, condition, banner, booking or recovery content
/// is hardcoded as application data.
///
/// Firebase sources:
///   users                -> patient profile/location
///   physiotherapists     -> featured physiotherapists
///   bookings             -> upcoming appointment
///   recovery_programs    -> recovery programs
///   home_hero_banners    -> hero content
///   home_conditions     -> condition content
///   home_offers          -> offers
///   home_trust_points    -> trust content
///
/// If an admin-managed collection is empty, the UI shows a clean
/// empty state rather than inventing content.
/// ================================================================

const Color _homeBg = Color(0xFFF5F7FC);
const Color _homeInk = Color(0xFF111936);
const Color _homeMuted = Color(0xFF737C99);
const Color _homePrimary = Color(0xFF5146D9);
const Color _homeViolet = Color(0xFF7067F0);
const Color _homeCyan = Color(0xFF35C6D9);
const Color _homeGreen = Color(0xFF22A06B);
const Color _homeOrange = Color(0xFFF08A3C);
const Color _homeRed = Color(0xFFE45867);
const Color _homeBorder = Color(0xFFE5E8F1);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _loadingUser = true;
  String? _userError;
  String _locationLabel = 'Set your location';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (!mounted) return;

    setState(() {
      _loadingUser = true;
      _userError = null;
    });

    try {
      final user = await _authService.getCurrentUserProfile();

      if (!mounted) return;

      _user = user;

      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        final data = snap.data() ?? <String, dynamic>{};

        final locality = _stringValue(
          data['locality'] ??
              data['area'] ??
              data['location'] ??
              data['address'],
        );

        final city = _stringValue(data['city']);

        if (locality.isNotEmpty && city.isNotEmpty) {
          _locationLabel = '$locality, $city';
        } else if (city.isNotEmpty) {
          _locationLabel = city;
        } else if (locality.isNotEmpty) {
          _locationLabel = locality;
        }
      }

      if (mounted) {
        setState(() {
          _loadingUser = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingUser = false;
        _userError = e.toString();
      });
    }
  }

  Future<void> _refreshHome() async {
    await _loadUser();
  }

  void _openSearch() {
    _showMessage('Search is ready in Explore.');
  }

  void _openExplore() {
    _showMessage('Explore is available from the bottom navigation.');
  }

  void _openBookings() {
    _showMessage('Open My Bookings from the bottom navigation.');
  }

  void _openRecovery() {
    _showMessage('Open Recovery from the bottom navigation.');
  }

  void _openProfile() {
    _showMessage('Open Profile from the bottom navigation.');
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _homeInk,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _homeBg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: _homePrimary,
          backgroundColor: Colors.white,
          onRefresh: _refreshHome,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      HomeHeader(
                        userName: _user?.name,
                        profileImageUrl: _user?.profileImageUrl,
                        location: _locationLabel,
                        isLoading: _loadingUser,
                        onMenuTap: () => _showMessage(
                          'Menu will be connected to your account actions.',
                        ),
                        onNotificationTap: () => _showMessage(
                          'Notifications will appear here.',
                        ),
                        onMessagesTap: () => _showMessage(
                          'Messages will appear here.',
                        ),
                        onProfileTap: _openProfile,
                      ),
                      const SizedBox(height: 18),

                      if (_userError != null)
                        _InlineError(
                          message: 'Unable to load your profile.',
                          onRetry: _loadUser,
                        ),

                      HeroBanner(
                        onBookNow: _openExplore,
                      ),
                      const SizedBox(height: 18),

                      HomeSearch(
                        onTap: _openSearch,
                        onFilterTap: _openExplore,
                      ),
                      const SizedBox(height: 28),

                      WhatsBotheringYou(
                        onConditionTap: (condition) {
                          _showMessage(
                            'Finding care for ${condition.title}.',
                          );
                          _openExplore();
                        },
                        onAssessmentTap: _openExplore,
                      ),
                      const SizedBox(height: 30),

                      UpcomingAppointment(
                        onTap: _openBookings,
                        onViewAll: _openBookings,
                      ),
                      const SizedBox(height: 30),

                      HomeFeaturedPhysios(
                        onViewAll: _openExplore,
                        onBook: (physio) {
                          _openBookingForPhysio(context, physio);
                        },
                      ),
                      const SizedBox(height: 30),

                      RecommendedForYou(
                        onViewAll: _openRecovery,
                        onProgramTap: (_) => _openRecovery(),
                      ),
                      const SizedBox(height: 30),

                      HomeOffer(
                        onTap: _openExplore,
                      ),
                      const SizedBox(height: 30),

                      WhyChooseUs(),
                      const SizedBox(height: 30),

                      NeedHelp(
                        onChatTap: () => _showMessage(
                          'Support will be connected here.',
                        ),
                      ),
                      const SizedBox(height: 36),
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

  void _openBookingForPhysio(
    BuildContext context,
    PhysiotherapistModel physio,
  ) {
    if (physio.uid.trim().isEmpty) {
      _showMessage('This physiotherapist profile is unavailable.');
      return;
    }

    final careMode = _resolveCareMode(physio);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingDetailsScreen(
          physiotherapistId: physio.uid,
          doctorName: physio.fullName,
          doctorImage: physio.profileImageUrl ?? '',
          specialty: physio.primarySpecialization.trim().isNotEmpty
              ? physio.primarySpecialization
              : physio.professionalTitle,
          rating: physio.rating,
          physiotherapistPhone: physio.phone,
          experienceYears: physio.experienceYears,
          initialCareMode: careMode,
        ),
      ),
    );
  }

  String _resolveCareMode(PhysiotherapistModel physio) {
    if (physio.homeVisitEnabled) {
      return PricingConfig.home;
    }

    if (physio.clinicVisitEnabled) {
      return PricingConfig.clinic;
    }

    if (physio.onlineConsultationEnabled) {
      return PricingConfig.online;
    }

    return PricingConfig.home;
  }
}

/// ================================================================
/// HEADER
/// ================================================================

class HomeHeader extends StatelessWidget {
  final String? userName;
  final String? profileImageUrl;
  final String location;
  final bool isLoading;

  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMessagesTap;
  final VoidCallback? onProfileTap;

  const HomeHeader({
    super.key,
    this.userName,
    this.profileImageUrl,
    this.location = 'Set your location',
    this.isLoading = false,
    this.onMenuTap,
    this.onNotificationTap,
    this.onMessagesTap,
    this.onProfileTap,
  });

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  String _firstName() {
    final name = userName?.trim() ?? '';

    if (name.isEmpty) return 'there';

    return name.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 450),
      opacity: isLoading ? .65 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _HomeCircleButton(
            icon: Icons.menu_rounded,
            onTap: onMenuTap,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}, ${_firstName()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _homeMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: _homePrimary,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _homeInk,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          _HomeCircleButton(
            icon: Icons.notifications_none_rounded,
            onTap: onNotificationTap,
            badge: 0,
          ),
          const SizedBox(width: 7),

          _HomeCircleButton(
            icon: Icons.chat_bubble_outline_rounded,
            onTap: onMessagesTap,
          ),
          const SizedBox(width: 7),

          _ProfileAvatar(
            imageUrl: profileImageUrl,
            onTap: onProfileTap,
          ),
        ],
      ),
    );
  }
}

/// ================================================================
/// HERO BANNER — FIREBASE
/// ================================================================

class HeroBanner extends StatefulWidget {
  final VoidCallback? onBookNow;

  const HeroBanner({
    super.key,
    this.onBookNow,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _controller = PageController(
    viewportFraction: .93,
  );

  int _page = 0;

  Stream<List<Map<String, dynamic>>> get _stream {
    return FirebaseFirestore.instance
        .collection('home_hero_banners')
        .where('isActive', isEqualTo: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => <String, dynamic>{
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      items.sort(
        (a, b) => _intValue(a['order'])
            .compareTo(_intValue(b['order'])),
      );

      return items;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _HeroLoading();
        }

        if (snapshot.hasError) {
          return _HeroEmpty(
            onBookNow: widget.onBookNow,
          );
        }

        final banners = snapshot.data ?? const [];

        if (banners.isEmpty) {
          return _HeroEmpty(
            onBookNow: widget.onBookNow,
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 224,
              child: PageView.builder(
                controller: _controller,
                itemCount: banners.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  if (mounted) {
                    setState(() => _page = index);
                  }
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _HeroCard(
                      data: banners[index],
                      onTap: widget.onBookNow,
                    ),
                  );
                },
              ),
            ),
            if (banners.length > 1) ...[
              const SizedBox(height: 11),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == _page ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: index == _page
                          ? _homePrimary
                          : const Color(0xFFD9DDE9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const _HeroCard({
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = _stringValue(
      data['title'] ?? data['headline'],
    );
    final subtitle = _stringValue(
      data['subtitle'] ?? data['description'],
    );
    final button = _stringValue(
      data['buttonText'] ?? data['ctaText'],
    );
    final imageUrl = _stringValue(
      data['imageUrl'] ?? data['image'],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF171E4A),
            Color(0xFF5146D9),
            Color(0xFF7067F0),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _homePrimary.withOpacity(.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -38,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.08),
              ),
            ),
          ),
          Positioned(
            right: 45,
            bottom: -70,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _homeCyan.withOpacity(.10),
              ),
            ),
          ),
          if (imageUrl.isNotEmpty)
            Positioned(
              right: 0,
              bottom: 0,
              top: 0,
              width: 142,
              child: Opacity(
                opacity: .94,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 130, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniPill(
                  icon: Icons.auto_awesome_rounded,
                  text: _stringValue(
                    data['eyebrow'],
                    fallback: 'PERSONALISED CARE',
                  ),
                  color: Colors.white.withOpacity(.15),
                ),
                const Spacer(),
                Text(
                  title.isEmpty
                      ? 'Personalised physiotherapy care'
                      : title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.8,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.78),
                      fontSize: 11,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),
                if (button.isNotEmpty)
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(
                        button,
                        style: const TextStyle(
                          color: _homePrimary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroEmpty extends StatelessWidget {
  final VoidCallback? onBookNow;

  const _HeroEmpty({
    this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 224,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF171E4A),
            Color(0xFF5146D9),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniPill(
            icon: Icons.health_and_safety_rounded,
            text: 'PHYSIOTHERAPY CARE',
            color: Colors.white.withOpacity(.15),
          ),
          const Spacer(),
          const Text(
            'Care that moves\nwith you.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              height: 1.02,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find verified physiotherapists and book the care you need.',
            style: TextStyle(
              color: Colors.white.withOpacity(.78),
              fontSize: 11,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onBookNow,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Find a physiotherapist',
                style: TextStyle(
                  color: _homePrimary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroLoading extends StatelessWidget {
  const _HeroLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 224,
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECF5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _homePrimary,
        ),
      ),
    );
  }
}

/// ================================================================
/// SEARCH
/// ================================================================

class HomeSearch extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  const HomeSearch({
    super.key,
    this.onTap,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: _homeBorder),
                boxShadow: [
                  BoxShadow(
                    color: _homeInk.withOpacity(.035),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: _homePrimary,
                    size: 23,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search physios, conditions or care',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _homeMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_homePrimary, _homeViolet],
              ),
              borderRadius: BorderRadius.circular(19),
              boxShadow: [
                BoxShadow(
                  color: _homePrimary.withOpacity(.20),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

/// ================================================================
/// CONDITIONS — FIREBASE
/// ================================================================

class HomeCondition {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final IconData icon;

  const HomeCondition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.icon,
  });
}

class WhatsBotheringYou extends StatelessWidget {
  final void Function(HomeCondition condition)? onConditionTap;
  final VoidCallback? onAssessmentTap;

  const WhatsBotheringYou({
    super.key,
    this.onConditionTap,
    this.onAssessmentTap,
  });

  Stream<List<HomeCondition>> get _stream {
    return FirebaseFirestore.instance
        .collection('home_conditions')
        .where('isActive', isEqualTo: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();

        return HomeCondition(
          id: doc.id,
          title: _stringValue(data['title']),
          subtitle: _stringValue(
            data['subtitle'] ?? data['description'],
          ),
          imageUrl: _stringValue(
            data['imageUrl'] ?? data['image'],
          ),
          icon: _conditionIcon(
            _stringValue(data['icon']),
          ),
        );
      }).where((item) => item.title.isNotEmpty).toList();

      return list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          eyebrow: 'START WITH HOW YOU FEEL',
          title: 'What’s bothering you?',
          subtitle: 'Tell us what you want help with.',
          trailing: GestureDetector(
            onTap: onAssessmentTap,
            child: const _TextArrow(text: 'Assessment'),
          ),
        ),
        const SizedBox(height: 14),

        StreamBuilder<List<HomeCondition>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                !snapshot.hasData) {
              return const _ConditionLoading();
            }

            if (snapshot.hasError) {
              return const _FirebaseEmptyCard(
                icon: Icons.medical_information_outlined,
                title: 'Conditions are being prepared',
                subtitle:
                    'Your care catalogue will appear here once published.',
              );
            }

            final conditions = snapshot.data ?? const [];

            if (conditions.isEmpty) {
              return const _FirebaseEmptyCard(
                icon: Icons.medical_information_outlined,
                title: 'Care categories are coming soon',
                subtitle:
                    'No condition categories have been published yet.',
              );
            }

            final visible = conditions.take(8).toList();

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visible.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 9,
                mainAxisSpacing: 10,
                childAspectRatio: .82,
              ),
              itemBuilder: (context, index) {
                final condition = visible[index];

                return GestureDetector(
                  onTap: () => onConditionTap?.call(condition),
                  child: _ConditionCard(
                    condition: condition,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ConditionCard extends StatelessWidget {
  final HomeCondition condition;

  const _ConditionCard({
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _homeBorder),
        boxShadow: [
          BoxShadow(
            color: _homeInk.withOpacity(.035),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EEFF),
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: condition.imageUrl.isNotEmpty
                  ? Image.network(
                      condition.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(
                        condition.icon,
                        color: _homePrimary,
                        size: 28,
                      ),
                    )
                  : Icon(
                      condition.icon,
                      color: _homePrimary,
                      size: 28,
                    ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            condition.title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _homeInk,
              fontSize: 9.5,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConditionLoading extends StatelessWidget {
  const _ConditionLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125,
      child: Row(
        children: List.generate(
          4,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index == 3 ? 0 : 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EBF4),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ================================================================
/// UPCOMING APPOINTMENT — REAL BOOKINGS
/// ================================================================

class UpcomingAppointment extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onViewAll;

  const UpcomingAppointment({
    super.key,
    this.onTap,
    this.onViewAll,
  });

  static final BookingService _bookingService =
      const BookingService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<BookingModel>>(
      stream: _bookingService.streamUserBookings(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _AppointmentLoading();
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final bookings = snapshot.data ?? const [];
        final upcoming = _findUpcoming(bookings);

        if (upcoming == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeading(
              eyebrow: 'YOUR CARE',
              title: 'Next appointment',
              subtitle: 'Stay on track with your recovery.',
              trailing: GestureDetector(
                onTap: onViewAll,
                child: const _TextArrow(text: 'All bookings'),
              ),
            ),
            const SizedBox(height: 13),
            GestureDetector(
              onTap: onTap,
              child: _UpcomingCard(
                booking: upcoming,
              ),
            ),
          ],
        );
      },
    );
  }

  BookingModel? _findUpcoming(List<BookingModel> bookings) {
    final now = DateTime.now();

    final candidates = bookings.where((booking) {
      final status =
          booking.bookingStatus.trim().toLowerCase();

      if (status == 'cancelled' ||
          status == 'rejected' ||
          status == 'completed') {
        return false;
      }

      final dateTime = _bookingDateTime(booking);

      return !dateTime.isBefore(now);
    }).toList();

    candidates.sort(
      (a, b) =>
          _bookingDateTime(a).compareTo(_bookingDateTime(b)),
    );

    return candidates.isEmpty ? null : candidates.first;
  }

  DateTime _bookingDateTime(BookingModel booking) {
    final date = booking.appointmentDate;
    final raw = booking.appointmentTime.trim();

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$',
      caseSensitive: false,
    ).firstMatch(raw);

    if (match == null) {
      return DateTime(
        date.year,
        date.month,
        date.day,
      );
    }

    var hour = int.tryParse(match.group(1)!) ?? 0;
    final minute = int.tryParse(match.group(2)!) ?? 0;
    final period = match.group(3)?.toUpperCase();

    if (period == 'PM' && hour < 12) {
      hour += 12;
    }

    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final BookingModel booking;

  const _UpcomingCard({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final status = booking.bookingStatus.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _homeBorder),
        boxShadow: [
          BoxShadow(
            color: _homeInk.withOpacity(.055),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 74,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_homePrimary, _homeViolet],
              ),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _month(booking.appointmentDate.month),
                  style: TextStyle(
                    color: Colors.white.withOpacity(.72),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${booking.appointmentDate.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _weekday(booking.appointmentDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _doctorName(booking.physiotherapistName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _homeInk,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _StatusPill(
                      text: status.isEmpty ? 'Upcoming' : status,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
  (booking.packageName ?? '').trim().isEmpty
      ? 'Physiotherapy session'
      : booking.packageName!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _homeMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: _homePrimary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      booking.appointmentTime,
                      style: const TextStyle(
                        color: _homeInk,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.home_work_outlined,
                      size: 15,
                      color: _homeGreen,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _serviceLabel(booking.serviceType),
                      style: const TextStyle(
                        color: _homeMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentLoading extends StatelessWidget {
  const _AppointmentLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECF4),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _homePrimary,
        ),
      ),
    );
  }
}

/// ================================================================
/// FEATURED PHYSIOTHERAPISTS — REAL FIREBASE
/// ================================================================

class HomeFeaturedPhysios extends StatelessWidget {
  final VoidCallback? onViewAll;
  final void Function(PhysiotherapistModel physio)? onBook;

  const HomeFeaturedPhysios({
    super.key,
    this.onViewAll,
    this.onBook,
  });

  static final PhysiotherapistService _service =
      PhysiotherapistService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PhysiotherapistModel>>(
      stream: _service.streamFeaturedPhysiotherapists(
        limit: 10,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _PhysioLoading();
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final physios = snapshot.data ?? const [];

        if (physios.isEmpty) {
          return const _FirebaseEmptyCard(
            icon: Icons.people_alt_outlined,
            title: 'Verified care is coming soon',
            subtitle:
                'No featured physiotherapists have been published yet.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeading(
              eyebrow: 'VERIFIED CARE TEAM',
              title: 'Featured physiotherapists',
              subtitle: 'Real professionals available on the platform.',
              trailing: GestureDetector(
                onTap: onViewAll,
                child: const _TextArrow(text: 'View all'),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 286,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: physios.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final physio = physios[index];

                  return _HomePhysioCard(
                    physio: physio,
                    onTap: () => onBook?.call(physio),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HomePhysioCard extends StatelessWidget {
  final PhysiotherapistModel physio;
  final VoidCallback? onTap;

  const _HomePhysioCard({
    required this.physio,
    this.onTap,
  });

  String get _name {
    final name = physio.fullName.trim();

    if (name.isEmpty) return 'Physiotherapist';

    if (name.toLowerCase().startsWith('dr.')) {
      return name;
    }

    return 'Dr. $name';
  }

  String get _specialization {
    if (physio.primarySpecialization.trim().isNotEmpty) {
      return physio.primarySpecialization.trim();
    }

    if (physio.specializations.isNotEmpty) {
      return physio.specializations.first;
    }

    return physio.professionalTitle.trim().isNotEmpty
        ? physio.professionalTitle
        : 'Physiotherapist';
  }

  String get _price {
    final mode = physio.homeVisitEnabled
        ? PricingConfig.home
        : physio.clinicVisitEnabled
            ? PricingConfig.clinic
            : physio.onlineConsultationEnabled
                ? PricingConfig.online
                : null;

    if (mode == null) return 'Price unavailable';

    final price = PricingConfig.getSessionPrice(
      experienceYears:
          physio.experienceYears < 0 ? 0 : physio.experienceYears,
      careMode: mode,
    );

    return '₹${price.toStringAsFixed(0)} / session';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = (physio.profileImageUrl ?? '').trim();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 235,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: _homeBorder),
          boxShadow: [
            BoxShadow(
              color: _homeInk.withOpacity(.055),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 135,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: const Color(0xFFEDEFFF),
                    child: imageUrl.isEmpty
                        ? const Icon(
                            Icons.person_rounded,
                            size: 64,
                            color: _homePrimary,
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(
                              Icons.person_rounded,
                              size: 64,
                              color: _homePrimary,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _GlassPill(
                      icon: Icons.verified_rounded,
                      text: physio.isVerified
                          ? 'Verified'
                          : 'Professional',
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _GlassPill(
                      icon: Icons.star_rounded,
                      text: physio.rating > 0
                          ? physio.rating.toStringAsFixed(1)
                          : 'New',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _homeInk,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _specialization,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _homeMuted,
                        fontSize: 9.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          size: 15,
                          color: _homePrimary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${physio.experienceYears}+ yrs',
                          style: const TextStyle(
                            color: _homeInk,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.reviews_rounded,
                          size: 15,
                          color: _homeCyan,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${physio.totalReviews}',
                          style: const TextStyle(
                            color: _homeMuted,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _price,
                            style: const TextStyle(
                              color: _homeGreen,
                              fontSize: 9.8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _homePrimary,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhysioLoading extends StatelessWidget {
  const _PhysioLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          eyebrow: 'VERIFIED CARE TEAM',
          title: 'Featured physiotherapists',
          subtitle: 'Loading real professionals...',
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 286,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 12),
            itemBuilder: (_, __) => Container(
              width: 235,
              decoration: BoxDecoration(
                color: const Color(0xFFE9ECF4),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ================================================================
/// RECOVERY PROGRAMS — EXISTING FIREBASE SERVICE
/// ================================================================

class RecommendedForYou extends StatelessWidget {
  final VoidCallback? onViewAll;
  final void Function(RecoveryProgramModel program)? onProgramTap;

  const RecommendedForYou({
    super.key,
    this.onViewAll,
    this.onProgramTap,
  });

  static final RecoveryProgramService _service =
      RecoveryProgramService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RecoveryProgramModel>>(
      stream: _service.streamFeaturedPrograms(
        limit: 10,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _RecoveryLoading();
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final programs = snapshot.data ?? const [];

        if (programs.isEmpty) {
          return const _FirebaseEmptyCard(
            icon: Icons.self_improvement_rounded,
            title: 'Recovery programs are coming soon',
            subtitle:
                'No featured recovery programs have been published yet.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeading(
              eyebrow: 'RECOVERY',
              title: 'Recommended for you',
              subtitle: 'Keep your recovery moving between sessions.',
              trailing: GestureDetector(
                onTap: onViewAll,
                child: const _TextArrow(text: 'View all'),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 164,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: programs.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final program = programs[index];

                  return _RecoveryCard(
                    program: program,
                    onTap: () =>
                        onProgramTap?.call(program),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  final RecoveryProgramModel program;
  final VoidCallback? onTap;

  const _RecoveryCard({
    required this.program,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dynamic item = program;

    final title = _dynamicString(
      () => item.title,
      fallback: 'Recovery program',
    );
    final description = _dynamicString(
      () => item.description,
    );
    final imageUrl = _dynamicString(
      () => item.imageUrl,
    );
    final category = _dynamicString(
      () => item.category,
    );
    final duration = _dynamicString(
      () => item.duration,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 270,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _homeBorder),
          boxShadow: [
            BoxShadow(
              color: _homeInk.withOpacity(.045),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 105,
              height: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEFFF),
                borderRadius: BorderRadius.circular(17),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl.isEmpty
                  ? const Icon(
                      Icons.self_improvement_rounded,
                      color: _homePrimary,
                      size: 35,
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(
                        Icons.self_improvement_rounded,
                        color: _homePrimary,
                        size: 35,
                      ),
                    ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.isNotEmpty)
                    _SmallLabel(text: category),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _homeInk,
                      fontSize: 13,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _homeMuted,
                        fontSize: 9,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (duration.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: _homePrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: const TextStyle(
                            color: _homeMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryLoading extends StatelessWidget {
  const _RecoveryLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164,
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECF4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _homePrimary,
        ),
      ),
    );
  }
}

/// ================================================================
/// OFFERS — FIREBASE
/// ================================================================

class HomeOffer extends StatelessWidget {
  final VoidCallback? onTap;

  const HomeOffer({
    super.key,
    this.onTap,
  });

  Stream<List<Map<String, dynamic>>> get _stream {
    return FirebaseFirestore.instance
        .collection('home_offers')
        .where('isActive', isEqualTo: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map(
            (doc) => <String, dynamic>{
              'id': doc.id,
              ...doc.data(),
            },
          )
          .toList();

      list.sort(
        (a, b) => _intValue(a['order'])
            .compareTo(_intValue(b['order'])),
      );

      return list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SizedBox(
            height: 128,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _homePrimary,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final offers = snapshot.data ?? const [];

        if (offers.isEmpty) {
          return const SizedBox.shrink();
        }

        final offer = offers.first;

        final title = _stringValue(offer['title']);
        final subtitle = _stringValue(
          offer['subtitle'] ?? offer['description'],
        );
        final code = _stringValue(
          offer['code'],
        );
        final cta = _stringValue(
          offer['buttonText'] ?? offer['ctaText'],
          fallback: 'Explore',
        );

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF10183E),
                  Color(0xFF252C65),
                ],
              ),
              borderRadius: BorderRadius.circular(27),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _MiniPill(
                        icon: Icons.local_offer_rounded,
                        text: 'MEMBER OFFER',
                        color: Colors.white.withOpacity(.12),
                      ),
                      const SizedBox(height: 11),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.4,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.66),
                            fontSize: 9.5,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (code.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _homeCyan,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        cta,
                        style: const TextStyle(
                          color: _homeInk,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ================================================================
/// TRUST — FIREBASE
/// ================================================================

class WhyChooseUs extends StatelessWidget {
  const WhyChooseUs({super.key});

  Stream<List<Map<String, dynamic>>> get _stream {
    return FirebaseFirestore.instance
        .collection('home_trust_points')
        .where('isActive', isEqualTo: true)
        .limit(8)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map(
            (doc) => <String, dynamic>{
              'id': doc.id,
              ...doc.data(),
            },
          )
          .toList();

      list.sort(
        (a, b) => _intValue(a['order'])
            .compareTo(_intValue(b['order'])),
      );

      return list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final points = snapshot.data ?? const [];

        if (points.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeading(
              eyebrow: 'WHY PEOPLE TRUST US',
              title: 'Care, designed around you.',
              subtitle:
                  'Everything important stays simple and transparent.',
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: points.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.25,
              ),
              itemBuilder: (context, index) {
                final data = points[index];

                return _TrustCard(
                  title: _stringValue(data['title']),
                  subtitle: _stringValue(
                    data['subtitle'] ?? data['description'],
                  ),
                  icon: _trustIcon(
                    _stringValue(data['icon']),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _TrustCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _TrustCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _homeBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EEFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _homePrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _homeInk,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _homeMuted,
                      fontSize: 8.2,
                      height: 1.15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ================================================================
/// SUPPORT
/// ================================================================

class NeedHelp extends StatelessWidget {
  final VoidCallback? onChatTap;

  const NeedHelp({
    super.key,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChatTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: _homeBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_homePrimary, _homeViolet],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need help?',
                    style: TextStyle(
                      color: _homeInk,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Get support with booking, care or your recovery journey.',
                    maxLines: 2,
                    style: TextStyle(
                      color: _homeMuted,
                      fontSize: 9.5,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: _homePrimary,
            ),
          ],
        ),
      ),
    );
  }
}

/// ================================================================
/// BOTTOM NAV — INCLUDED IN THIS FILE
/// ================================================================

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onChanged;

  const HomeBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onChanged,
  });

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
    (Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Bookings'),
    (Icons.favorite_rounded, Icons.favorite_border_rounded, 'Recovery'),
    (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.97),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: _homeBorder),
            boxShadow: [
              BoxShadow(
                color: _homeInk.withOpacity(.09),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: List.generate(
              _items.length,
              (index) {
                final item = _items[index];
                final active = currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged?.call(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      margin: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: active
                            ? const LinearGradient(
                                colors: [
                                  _homePrimary,
                                  _homeViolet,
                                ],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            active ? item.$1 : item.$2,
                            size: 21,
                            color: active
                                ? Colors.white
                                : _homeMuted,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.$3,
                            style: TextStyle(
                              color: active
                                  ? Colors.white
                                  : _homeMuted,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// ================================================================
/// SHARED PREMIUM UI
/// ================================================================

class _SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: _homePrimary,
                  fontSize: 8.5,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  color: _homeInk,
                  fontSize: 18,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _homeMuted,
                  fontSize: 9.5,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

class _TextArrow extends StatelessWidget {
  final String text;

  const _TextArrow({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: _homePrimary,
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 2),
        const Icon(
          Icons.chevron_right_rounded,
          color: _homePrimary,
          size: 17,
        ),
      ],
    );
  }
}

class _HomeCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final int badge;

  const _HomeCircleButton({
    required this.icon,
    this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _homeBorder),
                boxShadow: [
                  BoxShadow(
                    color: _homeInk.withOpacity(.035),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: _homeInk,
                size: 20,
              ),
            ),
          ),
        ),
        if (badge > 0)
          Positioned(
            right: -2,
            top: -3,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 15,
                minHeight: 15,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              decoration: BoxDecoration(
                color: _homeRed,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _homeBg,
                  width: 2,
                ),
              ),
              child: Text(
                '$badge',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onTap;

  const _ProfileAvatar({
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final url = (imageUrl ?? '').trim();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: _homeInk.withOpacity(.10),
              blurRadius: 15,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: url.isEmpty
            ? Container(
                color: const Color(0xFFEDEFFF),
                child: const Icon(
                  Icons.person_rounded,
                  color: _homePrimary,
                  size: 21,
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFEDEFFF),
                  child: const Icon(
                    Icons.person_rounded,
                    color: _homePrimary,
                    size: 21,
                  ),
                ),
              ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MiniPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 7.5,
              letterSpacing: .7,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GlassPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: _homePrimary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: _homeInk,
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  final String text;

  const _SmallLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _homePrimary,
          fontSize: 7,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;

  const _StatusPill({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = text.toLowerCase();

    final Color color = normalized.contains('confirm')
        ? _homeGreen
        : normalized.contains('pending')
            ? _homeOrange
            : _homePrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 7,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FirebaseEmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FirebaseEmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _homeBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EEFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: _homePrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _homeInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _homeMuted,
                    fontSize: 9,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InlineError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _homeRed.withOpacity(.16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: _homeRed,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _homeInk,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                color: _homePrimary,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ================================================================
/// HELPERS
/// ================================================================

String _stringValue(
  dynamic value, {
  String fallback = '',
}) {
  if (value == null) return fallback;

  final text = value.toString().trim();

  return text.isEmpty ? fallback : text;
}

String _dynamicString(
  String Function() getter, {
  String fallback = '',
}) {
  try {
    final value = getter().trim();

    return value.isEmpty ? fallback : value;
  } catch (_) {
    return fallback;
  }
}

int _intValue(dynamic value) {
  if (value is num) return value.toInt();

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

String _doctorName(String value) {
  final name = value.trim();

  if (name.isEmpty) return 'Physiotherapist';

  if (name.toLowerCase().startsWith('dr.')) {
    return name;
  }

  return 'Dr. $name';
}

String _serviceLabel(String serviceType) {
  switch (serviceType.trim().toLowerCase()) {
    case 'homevisit':
    case 'home_visit':
    case 'home':
      return 'Home visit';
    case 'clinicvisit':
    case 'clinic_visit':
    case 'clinic':
      return 'Clinic';
    case 'online':
    case 'onlineconsultation':
    case 'online_consultation':
      return 'Online';
    default:
      return serviceType.trim().isEmpty
          ? 'Physio care'
          : serviceType;
  }
}

String _month(int month) {
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  if (month < 1 || month > 12) return '';

  return months[month - 1];
}

String _weekday(DateTime date) {
  const weekdays = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  return weekdays[date.weekday - 1];
}

IconData _conditionIcon(String value) {
  switch (value.toLowerCase()) {
    case 'neck':
    case 'neck_pain':
      return Icons.accessibility_new_rounded;
    case 'shoulder':
    case 'shoulder_pain':
      return Icons.accessibility_rounded;
    case 'back':
    case 'back_pain':
      return Icons.airline_seat_recline_normal_rounded;
    case 'knee':
    case 'knee_pain':
      return Icons.directions_walk_rounded;
    case 'hip':
      return Icons.directions_run_rounded;
    case 'ankle':
    case 'foot':
      return Icons.directions_walk_rounded;
    case 'sports':
      return Icons.sports_rounded;
    default:
      return Icons.health_and_safety_rounded;
  }
}

IconData _trustIcon(String value) {
  switch (value.toLowerCase()) {
    case 'verified':
      return Icons.verified_rounded;
    case 'home':
      return Icons.home_work_rounded;
    case 'secure':
      return Icons.lock_rounded;
    case 'personalized':
      return Icons.auto_awesome_rounded;
    case 'support':
      return Icons.support_agent_rounded;
    case 'recovery':
      return Icons.monitor_heart_rounded;
    default:
      return Icons.check_circle_rounded;
  }
}
