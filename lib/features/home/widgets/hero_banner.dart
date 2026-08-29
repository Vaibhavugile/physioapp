import 'package:flutter/material.dart';

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
  late final PageController _pageController;

  int _currentPage = 0;

  final List<String> _banners = const [
    'assets/images/hero_physio_1.png',
    'assets/images/hero_physio_2.png',
    'assets/images/hero_physio_3.png',
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleBannerTap() {
    widget.onBookNow?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =========================================================
        // HERO BANNER
        // =========================================================

        ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: AspectRatio(
            // IMPORTANT:
            // This is closer to the actual banner composition.
            aspectRatio: 1.72,

            child: PageView.builder(
              controller: _pageController,

              itemCount: _banners.length,

              physics:
                  const BouncingScrollPhysics(),

              onPageChanged: (index) {
                if (!mounted) return;

                setState(() {
                  _currentPage = index;
                });
              },

              itemBuilder: (
                context,
                index,
              ) {
                return _BannerImage(
                  imagePath: _banners[index],
                  onTap: _handleBannerTap,
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 10),

        // =========================================================
        // INDICATORS
        // =========================================================

        _BannerIndicators(
          count: _banners.length,
          currentIndex: _currentPage,
        ),
      ],
    );
  }
}


// ===============================================================
// BANNER IMAGE
// ===============================================================

class _BannerImage extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;

  const _BannerImage({
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,

      child: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(26),

          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4358F5)
                  .withOpacity(.14),

              blurRadius: 26,

              offset:
                  const Offset(0, 12),
            ),
          ],
        ),

        clipBehavior:
            Clip.antiAlias,

        child: Image.asset(
          imagePath,

          width: double.infinity,
          height: double.infinity,

          // IMPORTANT
          // Do NOT use BoxFit.cover here.
          //
          // contain ensures the complete banner
          // composition remains visible.
          fit: BoxFit.contain,

          alignment: Alignment.center,

          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return const _BannerError();
          },
        ),
      ),
    );
  }
}


// ===============================================================
// ERROR STATE
// ===============================================================

class _BannerError
    extends StatelessWidget {
  const _BannerError();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3449E8),
            Color(0xFF705CF0),
          ],
        ),
      ),

      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }
}


// ===============================================================
// INDICATORS
// ===============================================================

class _BannerIndicators
    extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _BannerIndicators({
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: List.generate(
        count,
        (index) {
          final active =
              index == currentIndex;

          return AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 280,
            ),

            curve:
                Curves.easeOutCubic,

            margin:
                const EdgeInsets.symmetric(
              horizontal: 3,
            ),

            width: active ? 24 : 7,
            height: 7,

            decoration:
                BoxDecoration(
              color: active
                  ? const Color(
                      0xFF4358F5,
                    )
                  : const Color(
                      0xFFD5DAE8,
                    ),

              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
          );
        },
      ),
    );
  }
}