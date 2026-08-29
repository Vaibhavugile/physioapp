import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String? userName;
  final String? profileImageUrl;
  final int unreadNotificationCount;

  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMessagesTap;
  final VoidCallback? onProfileTap;

  const HomeHeader({
    super.key,
    this.userName,
    this.profileImageUrl,
    this.unreadNotificationCount = 0,
    this.onMenuTap,
    this.onNotificationTap,
    this.onMessagesTap,
    this.onProfileTap,
  });

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 17) {
      return 'Good afternoon';
    }

    if (hour < 21) {
      return 'Good evening';
    }

    return 'Good night';
  }

  String _displayGreeting() {
    final name = userName?.trim();

    if (name == null || name.isEmpty) {
      return '${_greeting()} 👋';
    }

    final firstName = name.split(' ').first;

    return '${_greeting()}, $firstName 👋';
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: 1,
      ),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (
        context,
        value,
        child,
      ) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              12 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          // =====================================================
          // MENU
          // =====================================================

          _HeaderActionButton(
            icon: Icons.menu_rounded,
            onTap: onMenuTap,
          ),

          const SizedBox(width: 14),

          // =====================================================
          // GREETING
          // =====================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _displayGreeting(),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.15,
                    color: Color(0xFF727B90),
                    fontWeight:
                        FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'How can we help you today?',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.5,
                    height: 1.05,
                    color: Color(0xFF121B3A),
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing: -0.75,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 9),

          // =====================================================
          // NOTIFICATIONS
          // =====================================================

          _NotificationButton(
            count: unreadNotificationCount,
            onTap: onNotificationTap,
          ),

          const SizedBox(width: 8),

          // =====================================================
          // MESSAGES
          // =====================================================

          _HeaderActionButton(
            icon:
                Icons.chat_bubble_outline_rounded,
            onTap: onMessagesTap,
          ),

          const SizedBox(width: 9),

          // =====================================================
          // PROFILE
          // =====================================================

          _ProfileAvatar(
            imageUrl: profileImageUrl,
            onTap: onProfileTap,
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// HEADER ACTION BUTTON
// ===============================================================

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderActionButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(17),
        child: Ink(
          width: 47,
          height: 47,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(17),

            border: Border.all(
              color: Colors.white,
              width: 1,
            ),

            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF24345F,
                ).withOpacity(.055),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Center(
            child: Icon(
              icon,
              size: 23,
              color:
                  const Color(0xFF17203E),
            ),
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// NOTIFICATION BUTTON
// ===============================================================

class _NotificationButton
    extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _NotificationButton({
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _HeaderActionButton(
          icon:
              Icons.notifications_none_rounded,
          onTap: onTap,
        ),

        if (count > 0)
          Positioned(
            top: -5,
            right: -4,
            child: Container(
              constraints:
                  const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 5,
              ),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFFF4656),
                shape: count < 10
                    ? BoxShape.circle
                    : BoxShape.rectangle,
                borderRadius: count >= 10
                    ? BorderRadius.circular(
                        10,
                      )
                    : null,
                border: Border.all(
                  color:
                      const Color(0xFFF5F7FC),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(
                      0xFFFF4656,
                    ).withOpacity(.28),
                    blurRadius: 9,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  count > 99
                      ? '99+'
                      : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ===============================================================
// PROFILE AVATAR
// ===============================================================

class _ProfileAvatar
    extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onTap;

  const _ProfileAvatar({
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(30),
        child: Container(
          width: 49,
          height: 49,
          padding:
              const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,

            gradient:
                const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFC9D5FF),
                Color(0xFFBFECE2),
              ],
            ),

            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF4358F5,
                ).withOpacity(.13),
                blurRadius: 17,
                offset:
                    const Offset(0, 7),
              ),
            ],
          ),

          child: ClipOval(
            child: imageUrl != null &&
                    imageUrl!.trim().isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return _fallback();
                    },
                  )
                : _fallback(),
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFE9EDFF),
      child: const Icon(
        Icons.person_rounded,
        color: Color(0xFF5869D8),
        size: 27,
      ),
    );
  }
}