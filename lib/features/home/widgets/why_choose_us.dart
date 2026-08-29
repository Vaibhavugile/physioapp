import 'package:flutter/material.dart';

class WhyChooseUs extends StatelessWidget {
  const WhyChooseUs({super.key});

  static const List<_TrustPoint> _items = [
    _TrustPoint(
      icon: Icons.verified_user_rounded,
      title: 'Verified Physios',
      subtitle: 'Qualified professionals',
    ),
    _TrustPoint(
      icon: Icons.home_rounded,
      title: 'Care at Home',
      subtitle: 'Treatment at your doorstep',
    ),
    _TrustPoint(
      icon: Icons.favorite_rounded,
      title: 'Personalized Care',
      subtitle: 'Plans made for you',
    ),
    _TrustPoint(
      icon: Icons.lock_rounded,
      title: 'Secure Booking',
      subtitle: 'Safe & simple experience',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Why choose us?',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF121A3A),
            fontWeight: FontWeight.w800,
            letterSpacing: -.3,
          ),
        ),

        const SizedBox(height: 10),

        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 9,
            mainAxisSpacing: 9,
            mainAxisExtent: 76,
          ),
          itemBuilder: (context, index) {
            return _TrustCard(
              item: _items[index],
            );
          },
        ),
      ],
    );
  }
}

class _TrustPoint {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustPoint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _TrustCard extends StatelessWidget {
  final _TrustPoint item;

  const _TrustCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE7EAF2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28345C)
                .withOpacity(.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0F0FF),
                  Color(0xFFE9F8F5),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              size: 19,
              color: const Color(0xFF5365D9),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF151D3D),
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Color(0xFF737C99),
                    fontWeight: FontWeight.w500,
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