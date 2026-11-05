
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models/booking_model.dart';
import 'services/booking_service.dart';

const Color _bookingBg = Color(0xFFF5F7FC);
const Color _bookingInk = Color(0xFF111936);
const Color _bookingMuted = Color(0xFF737C99);
const Color _bookingPrimary = Color(0xFF5146D9);
const Color _bookingViolet = Color(0xFF7067F0);
const Color _bookingCyan = Color(0xFF35C6D9);
const Color _bookingGreen = Color(0xFF22A06B);
const Color _bookingOrange = Color(0xFFF08A3C);
const Color _bookingRed = Color(0xFFE45867);

/// My Bookings
///
/// Premium 2026-style booking hub for the patient app.
/// Data source: `bookings` collection through BookingService.
///
/// Designed to be dropped into the main bottom navigation:
///   const MyBookingsScreen()
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  static const _bookingBg = Color(0xFFF5F7FC);
  static const _bookingInk = Color(0xFF111936);
  static const BookingService _bookingService = BookingService();

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BookingModel> _filterBookings(List<BookingModel> bookings) {
    final valid = bookings.where((booking) {
      final status = booking.bookingStatus.trim().toLowerCase();
      return status != 'rejected';
    }).toList();

    valid.sort(
      (a, b) => _bookingDateTime(b).compareTo(_bookingDateTime(a)),
    );

    return valid;
  }

  List<BookingModel> _upcoming(List<BookingModel> bookings) {
    final now = DateTime.now();

    return bookings.where((booking) {
      final status = booking.bookingStatus.trim().toLowerCase();

      if (status == 'cancelled' || status == 'rejected' || status == 'completed') {
        return false;
      }

      return !_bookingDateTime(booking).isBefore(now);
    }).toList()
      ..sort(
        (a, b) => _bookingDateTime(a).compareTo(_bookingDateTime(b)),
      );
  }

  List<BookingModel> _completed(List<BookingModel> bookings) {
    return bookings.where((booking) {
      final status = booking.bookingStatus.trim().toLowerCase();
      return status == 'completed';
    }).toList()
      ..sort(
        (a, b) => _bookingDateTime(b).compareTo(_bookingDateTime(a)),
      );
  }

  List<BookingModel> _cancelled(List<BookingModel> bookings) {
    return bookings.where((booking) {
      final status = booking.bookingStatus.trim().toLowerCase();
      return status == 'cancelled' || status == 'rejected';
    }).toList()
      ..sort(
        (a, b) => _bookingDateTime(b).compareTo(_bookingDateTime(a)),
      );
  }

  DateTime _bookingDateTime(BookingModel booking) {
    final date = booking.appointmentDate;
    final raw = booking.appointmentTime.trim();

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$',
      caseSensitive: false,
    ).firstMatch(raw);

    if (match == null) {
      return DateTime(date.year, date.month, date.day);
    }

    var hour = int.tryParse(match.group(1)!) ?? 0;
    final minute = int.tryParse(match.group(2)!) ?? 0;
    final period = match.group(3)?.toUpperCase();

    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _firstName(User user) {
    final display = user.displayName?.trim() ?? '';
    if (display.isNotEmpty) {
      return display.split(' ').first;
    }
    return 'there';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const _SignedOutState();
    }

    return Scaffold(
      backgroundColor: _bookingBg,
      body: StreamBuilder<List<BookingModel>>(
        stream: _bookingService.streamUserBookings(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorState(
              onRetry: () => setState(() {}),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const _BookingsLoading();
          }

          final bookings = _filterBookings(
            snapshot.data ?? const <BookingModel>[],
          );

          final upcoming = _upcoming(bookings);
          final completed = _completed(bookings);
          final cancelled = _cancelled(bookings);

          return RefreshIndicator(
            color: _bookingPrimary,
            backgroundColor: Colors.white,
            onRefresh: () async {
              setState(() {});
              await Future<void>.delayed(
                const Duration(milliseconds: 350),
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: _PremiumHeader(
                    greeting: _greeting(),
                    firstName: _firstName(user),
                    totalBookings: bookings.length,
                    upcomingCount: upcoming.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _JourneySummary(
                    upcomingCount: upcoming.length,
                    completedCount: completed.length,
                    totalCount: bookings.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _PremiumTabBar(
                    controller: _tabController,
                    upcomingCount: upcoming.length,
                    completedCount: completed.length,
                    cancelledCount: cancelled.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      final index = _tabController.index;
                      final items = index == 0
                          ? upcoming
                          : index == 1
                              ? completed
                              : cancelled;

                      if (items.isEmpty) {
                        return _EmptyBookings(
                          type: index == 0
                              ? 'upcoming'
                              : index == 1
                                  ? 'completed'
                                  : 'cancelled',
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                        child: Column(
                          children: [
                            for (int i = 0; i < items.length; i++) ...[
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: Duration(milliseconds: 260 + (i % 5) * 55),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 14 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _BookingCard(
                                  booking: items[i],
                                  onTap: () => _showBookingDetails(
                                    context,
                                    items[i],
                                  ),
                                ),
                              ),
                              if (i != items.length - 1)
                                const SizedBox(height: 14),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBookingDetails(
    BuildContext context,
    BookingModel booking,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: _bookingInk.withOpacity(.55),
      builder: (_) => _BookingDetailsSheet(booking: booking),
    );
  }
}

// ============================================================================
// PREMIUM HEADER
// ============================================================================

class _PremiumHeader extends StatelessWidget {
  final String greeting;
  final String firstName;
  final int totalBookings;
  final int upcomingCount;

  const _PremiumHeader({
    required this.greeting,
    required this.firstName,
    required this.totalBookings,
    required this.upcomingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF171E4A),
            Color(0xFF35319A),
            Color(0xFF5146D9),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -48,
            top: -70,
            child: _GlowOrb(
              size: 180,
              color: const Color(0xFF8C83FF).withOpacity(.26),
            ),
          ),
          Positioned(
            left: -60,
            bottom: -90,
            child: _GlowOrb(
              size: 170,
              color: const Color(0xFF43D9E8).withOpacity(.10),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _MiniBrandMark(),
                      const Spacer(),
                      _HeaderIconButton(
                        icon: Icons.support_agent_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      _HeaderIconButton(
                        icon: Icons.more_horiz_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    greeting,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(.66),
                      letterSpacing: .15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your care journey, $firstName.',
                    style: const TextStyle(
                      fontSize: 25,
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -.55,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    upcomingCount > 0
                        ? 'Everything you need for your next session.'
                        : 'Your appointments and recovery history live here.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: Colors.white.withOpacity(.67),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      _HeaderStat(
                        value: '$upcomingCount',
                        label: 'Upcoming',
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withOpacity(.14),
                      ),
                      _HeaderStat(
                        value: '$totalBookings',
                        label: 'Total bookings',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39,
      height: 39,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.11),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.white.withOpacity(.15),
        ),
      ),
      child: const Icon(
        Icons.spa_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.09),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 39,
          height: 39,
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(.56),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// JOURNEY SUMMARY
// ============================================================================

class _JourneySummary extends StatelessWidget {
  final int upcomingCount;
  final int completedCount;
  final int totalCount;

  const _JourneySummary({
    required this.upcomingCount,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.event_available_rounded,
              value: '$upcomingCount',
              label: 'Upcoming',
              accent: const Color(0xFF5146D9),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              icon: Icons.verified_rounded,
              value: '$completedCount',
              label: 'Completed',
              accent: const Color(0xFF22A06B),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              icon: Icons.receipt_long_rounded,
              value: '$totalCount',
              label: 'All sessions',
              accent: const Color(0xFF35AFC4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 12, 10, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8EBF4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF182044).withOpacity(.035),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              color: accent.withOpacity(.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111936),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF7A829B),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TABS
// ============================================================================

class _PremiumTabBar extends StatelessWidget {
  final TabController controller;
  final int upcomingCount;
  final int completedCount;
  final int cancelledCount;

  const _PremiumTabBar({
    required this.controller,
    required this.upcomingCount,
    required this.completedCount,
    required this.cancelledCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Container(
        height: 52,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEFF7),
          borderRadius: BorderRadius.circular(17),
        ),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Row(
              children: [
                _TabPill(
                  label: 'Upcoming',
                  count: upcomingCount,
                  selected: controller.index == 0,
                  onTap: () => controller.animateTo(0),
                ),
                _TabPill(
                  label: 'Completed',
                  count: completedCount,
                  selected: controller.index == 1,
                  onTap: () => controller.animateTo(1),
                ),
                _TabPill(
                  label: 'Cancelled',
                  count: cancelledCount,
                  selected: controller.index == 2,
                  onTap: () => controller.animateTo(2),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF171E4A).withOpacity(.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF111936)
                        : const Color(0xFF7A829B),
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF5146D9).withOpacity(.10)
                      : const Color(0xFF7A829B).withOpacity(.08),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF5146D9)
                        : const Color(0xFF7A829B),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
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

// ============================================================================
// BOOKING CARD
// ============================================================================

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = booking.appointmentDate;
    final status = booking.bookingStatus.trim().toLowerCase();
    final isConfirmed = status == 'confirmed';
    final isPendingPayment = status == 'pendingpayment' ||
        status == 'pending payment';
    final isPendingAcceptance = status == 'pendingacceptance' ||
        status == 'pending acceptance' ||
        status == 'pending';

    final mode = _modeLabel(booking.serviceType);
    final modeIcon = _modeIcon(booking.serviceType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(27),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(27),
            border: Border.all(
              color: const Color(0xFFE6E9F2),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF192044).withOpacity(.055),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 13),
                child: Row(
                  children: [
                    _PhysioAvatar(
                      imageUrl: booking.physiotherapistPhotoUrl,
                      name: booking.physiotherapistName,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.physiotherapistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _bookingInk,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Physiotherapy Specialist',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _bookingMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _BookingStatus(status: booking.bookingStatus),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  height: 1,
                  color: const Color(0xFFF0F1F6),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _InfoChip(
                            icon: Icons.calendar_today_rounded,
                            title: _dateLabel(date),
                            subtitle: _relativeDate(
                              _bookingDateTime(booking),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _InfoChip(
                            icon: Icons.schedule_rounded,
                            title: booking.appointmentTime.isEmpty
                                ? 'Time pending'
                                : booking.appointmentTime,
                            subtitle: '1 hour session',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: _ModeChip(
                            icon: modeIcon,
                            label: mode,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _ModeChip(
                            icon: Icons.layers_rounded,
                            label: (booking.packageName?.trim().isNotEmpty ?? false)
                                ? booking.packageName!.trim()
                                : 'Single session',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(15, 11, 12, 11),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFBFE),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(27),
                    bottomRight: Radius.circular(27),
                  ),
                ),
                child: Row(
                  children: [
                    _SessionProgress(booking: booking),
                    const Spacer(),
                    Text(
                      '₹${booking.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: _bookingInk,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Container(
                      width: 31,
                      height: 31,
                      decoration: BoxDecoration(
                        color: _bookingPrimary.withOpacity(.09),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: _bookingPrimary,
                        size: 17,
                      ),
                    ),
                  ],
                ),
              ),
              if (isConfirmed || isPendingPayment || isPendingAcceptance)
                _ActionHint(
                  isConfirmed: isConfirmed,
                  isPendingPayment: isPendingPayment,
                  isPendingAcceptance: isPendingAcceptance,
                ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _bookingDateTime(BookingModel booking) {
    final date = booking.appointmentDate;
    final raw = booking.appointmentTime.trim();
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$',
      caseSensitive: false,
    ).firstMatch(raw);

    if (match == null) return DateTime(date.year, date.month, date.day);

    var hour = int.tryParse(match.group(1)!) ?? 0;
    final minute = int.tryParse(match.group(2)!) ?? 0;
    final period = match.group(3)?.toUpperCase();

    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _dateLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _relativeDate(DateTime date) {
    final today = DateTime.now();
    final a = DateTime(today.year, today.month, today.day);
    final b = DateTime(date.year, date.month, date.day);
    final days = b.difference(a).inDays;

    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days == -1) return 'Yesterday';
    if (days > 1 && days < 7) return 'In $days days';
    return '';
  }

  String _modeLabel(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('clinic')) return 'Clinic visit';
    if (value.contains('online')) return 'Online session';
    return 'Home visit';
  }

  IconData _modeIcon(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('clinic')) return Icons.local_hospital_rounded;
    if (value.contains('online')) return Icons.videocam_rounded;
    return Icons.home_work_rounded;
  }
}

class _PhysioAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;

  const _PhysioAvatar({
    required this.imageUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'P' : name.trim()[0].toUpperCase();

    return Container(
      width: 55,
      height: 55,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B84F5),
            Color(0xFF35C6D9),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageUrl != null && imageUrl!.trim().isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(initial),
              )
            : _fallback(initial),
      ),
    );
  }

  Widget _fallback(String initial) {
    return Container(
      color: const Color(0xFFECEAFF),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF5146D9),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BookingStatus extends StatelessWidget {
  final String status;

  const _BookingStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    final key = status.trim().toLowerCase().replaceAll('_', '');

    late final String label;
    late final Color color;
    late final IconData icon;

    if (key == 'confirmed') {
      label = 'Confirmed';
      color = const Color(0xFF22A06B);
      icon = Icons.verified_rounded;
    } else if (key == 'pendingpayment' || key == 'pending payment') {
      label = 'Payment pending';
      color = const Color(0xFFF08A3C);
      icon = Icons.payments_rounded;
    } else if (key == 'pendingacceptance' ||
        key == 'pending acceptance' ||
        key == 'pending') {
      label = 'Awaiting confirmation';
      color = const Color(0xFF7067F0);
      icon = Icons.hourglass_top_rounded;
    } else if (key == 'completed') {
      label = 'Completed';
      color = const Color(0xFF2C9D70);
      icon = Icons.check_circle_rounded;
    } else if (key == 'cancelled' || key == 'canceled') {
      label = 'Cancelled';
      color = const Color(0xFFE45867);
      icon = Icons.cancel_rounded;
    } else if (key == 'rejected') {
      label = 'Declined';
      color = const Color(0xFFE45867);
      icon = Icons.block_rounded;
    } else {
      label = status.isEmpty ? 'Processing' : status;
      color = const Color(0xFF7A829B);
      icon = Icons.more_time_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.085),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(.13),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoChip({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              color: const Color(0xFF5146D9).withOpacity(.075),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 14,
              color: const Color(0xFF5146D9),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF202845),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8990A5),
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
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

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ModeChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFE),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFEEF0F6),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13,
            color: const Color(0xFF6B65D8),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF5D6682),
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionProgress extends StatelessWidget {
  final BookingModel booking;

  const _SessionProgress({required this.booking});

  @override
  Widget build(BuildContext context) {
    final total = booking.totalSessions <= 0 ? 1 : booking.totalSessions;
    final completed = booking.completedSessions.clamp(0, total);
    final progress = completed / total;

    return SizedBox(
      width: 126,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                minHeight: 5,
                value: progress,
                backgroundColor: const Color(0xFFE7E9F2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF5146D9),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$completed/$total sessions',
            style: const TextStyle(
              color: Color(0xFF7A829B),
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionHint extends StatelessWidget {
  final bool isConfirmed;
  final bool isPendingPayment;
  final bool isPendingAcceptance;

  const _ActionHint({
    required this.isConfirmed,
    required this.isPendingPayment,
    required this.isPendingAcceptance,
  });

  @override
  Widget build(BuildContext context) {
    final String text;
    final IconData icon;

    if (isPendingPayment) {
      text = 'Complete payment to confirm this booking';
      icon = Icons.lock_outline_rounded;
    } else if (isPendingAcceptance) {
      text = 'Your physiotherapist will confirm this request';
      icon = Icons.notifications_none_rounded;
    } else {
      text = 'Your session is scheduled — tap to view details';
      icon = Icons.auto_awesome_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 9, 15, 10),
      decoration: BoxDecoration(
        color: isConfirmed
            ? const Color(0xFFF2FBF7)
            : const Color(0xFFF7F5FF),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(27),
          bottomRight: Radius.circular(27),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 12,
            color: isConfirmed
                ? const Color(0xFF22A06B)
                : const Color(0xFF5146D9),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isConfirmed
                    ? const Color(0xFF25815E)
                    : const Color(0xFF625AAE),
                fontSize: 8.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DETAILS SHEET
// ============================================================================

class _BookingDetailsSheet extends StatelessWidget {
  final BookingModel booking;

  const _BookingDetailsSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking.bookingStatus.trim().toLowerCase();

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .88,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F8FC),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8DCE8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 19),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Booking details',
                      style: TextStyle(
                        color: Color(0xFF111936),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.3,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF707890),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _DetailsHero(booking: booking),
              const SizedBox(height: 14),
              _DetailsSection(
                title: 'Appointment',
                icon: Icons.event_note_rounded,
                children: [
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: _formatDate(booking.appointmentDate),
                  ),
                  _DetailRow(
                    icon: Icons.schedule_rounded,
                    label: 'Time',
                    value: booking.appointmentTime,
                  ),
                  _DetailRow(
                    icon: _modeIcon(booking.serviceType),
                    label: 'Care mode',
                    value: _modeLabel(booking.serviceType),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DetailsSection(
                title: 'Plan',
                icon: Icons.auto_graph_rounded,
                children: [
                  _DetailRow(
                    icon: Icons.layers_rounded,
                    label: 'Package',
                    value: (booking.packageName?.trim().isNotEmpty ?? false)
                        ? booking.packageName!.trim()
                        : 'Single session',
                  ),
                  _DetailRow(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Sessions',
                    value:
                        '${booking.totalSessions} sessions · ${booking.remainingSessions} remaining',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DetailsSection(
                title: 'Payment',
                icon: Icons.receipt_long_rounded,
                children: [
                  _DetailRow(
                    icon: Icons.currency_rupee_rounded,
                    label: 'Total',
                    value: '₹${booking.totalAmount.toStringAsFixed(0)}',
                    emphasize: true,
                  ),
                  _DetailRow(
                    icon: Icons.payments_outlined,
                    label: 'Payment status',
                    value: _prettyStatus(booking.paymentStatus),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DetailsSection(
                title: 'Booking status',
                icon: Icons.track_changes_rounded,
                children: [
                  _DetailRow(
                    icon: Icons.flag_rounded,
                    label: 'Current status',
                    value: _prettyStatus(status),
                    emphasize: true,
                  ),
                  if (booking.id.isNotEmpty)
                    _DetailRow(
                      icon: Icons.tag_rounded,
                      label: 'Booking ID',
                      value: _shortId(booking.id),
                    ),
                ],
              ),
              if (status == 'pendingpayment' ||
                  status == 'pending payment') ...[
                const SizedBox(height: 14),
                _NoticeCard(
                  icon: Icons.lock_outline_rounded,
                  title: 'Payment is still pending',
                  message:
                      'This booking request has been created, but payment still needs to be completed.',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _shortId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 6)}…${id.substring(id.length - 4)}';
  }

  static String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _prettyStatus(String value) {
    if (value.trim().isEmpty) return 'Not available';

    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  static String _modeLabel(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('clinic')) return 'Clinic visit';
    if (value.contains('online')) return 'Online session';
    return 'Home visit';
  }

  static IconData _modeIcon(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('clinic')) return Icons.local_hospital_rounded;
    if (value.contains('online')) return Icons.videocam_rounded;
    return Icons.home_work_rounded;
  }
}

class _DetailsHero extends StatelessWidget {
  final BookingModel booking;

  const _DetailsHero({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF191F4B),
            Color(0xFF5146D9),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5146D9).withOpacity(.18),
            blurRadius: 25,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Row(
        children: [
          _PhysioAvatar(
            imageUrl: booking.physiotherapistPhotoUrl,
            name: booking.physiotherapistName,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.physiotherapistName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Physiotherapy Specialist',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.62),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 9),
                _BookingStatus(status: booking.bookingStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFE8EAF2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF5146D9).withOpacity(.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: const Color(0xFF5146D9),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A2140),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFF858CA2),
          ),
          const SizedBox(width: 9),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF81889E),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: const Color(0xFF202845),
                fontSize: 10.5,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _NoticeCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF7067F0).withOpacity(.13),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF5146D9),
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF3B357E),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF6F6A9D),
                    fontSize: 9.5,
                    height: 1.35,
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

// ============================================================================
// EMPTY / ERROR / LOADING
// ============================================================================

class _EmptyBookings extends StatelessWidget {
  final String type;

  const _EmptyBookings({required this.type});

  @override
  Widget build(BuildContext context) {
    final bool upcoming = type == 'upcoming';
    final bool completed = type == 'completed';

    final title = upcoming
        ? 'Your next chapter starts here'
        : completed
            ? 'No completed sessions yet'
            : 'Nothing cancelled';

    final message = upcoming
        ? 'Find the right physiotherapist and book your first session when you’re ready.'
        : completed
            ? 'Once you complete a session, your recovery history will appear here.'
            : 'Cancelled or declined bookings will appear here.';

    final icon = upcoming
        ? Icons.calendar_month_rounded
        : completed
            ? Icons.verified_rounded
            : Icons.event_busy_rounded;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 45, 22, 40),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7067F0),
                  Color(0xFF35C6D9),
                ],
              ),
              borderRadius: BorderRadius.circular(27),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5146D9).withOpacity(.18),
                  blurRadius: 25,
                  offset: const Offset(0, 11),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(height: 19),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF151C3A),
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -.2,
            ),
          ),
          const SizedBox(height: 7),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 310),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF7A829B),
                fontSize: 10.5,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingsLoading extends StatelessWidget {
  const _BookingsLoading();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 270,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF171E4A),
                  Color(0xFF5146D9),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(34),
                bottomRight: Radius.circular(34),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ShimmerBox(height: 112),
                const SizedBox(height: 18),
                _ShimmerBox(height: 52),
                const SizedBox(height: 14),
                _ShimmerBox(height: 250),
                const SizedBox(height: 14),
                _ShimmerBox(height: 250),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;

  const _ShimmerBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEF0),
                borderRadius: BorderRadius.circular(21),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xFFE45867),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Couldn’t load your bookings',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF171E3E),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7A829B),
                fontSize: 10.5,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5146D9),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'Try again',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedOutState extends StatelessWidget {
  const _SignedOutState();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F7FC),
      body: Center(
        child: Text(
          'Please sign in to view your bookings.',
          style: TextStyle(
            color: Color(0xFF737C99),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MICRO VISUALS
// ============================================================================

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 22,
        sigmaY: 22,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
