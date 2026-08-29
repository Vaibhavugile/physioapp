import 'package:flutter/material.dart';

class HomeOffer extends StatelessWidget {
  final VoidCallback? onBookNow;

  const HomeOffer({
    super.key,
    this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 142,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5146D8),
            Color(0xFF6D5BE7),
            Color(0xFF8067EA),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5146D8)
                .withOpacity(.18),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ======================================================
          // DECORATIVE GLOW
          // ======================================================

          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
                    .withOpacity(.08),
              ),
            ),
          ),

          Positioned(
            right: 25,
            bottom: -65,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
                    .withOpacity(.055),
              ),
            ),
          ),

          // ======================================================
          // CONTENT
          // ======================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              14,
              14,
              13,
            ),
            child: Row(
              children: [
                // ------------------------------------------------
                // OFFER ICON
                // ------------------------------------------------

                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(.14),
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white
                          .withOpacity(.16),
                    ),
                  ),
                  child: const Icon(
                    Icons.local_offer_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 12),

                // ------------------------------------------------
                // TEXT
                // ------------------------------------------------

                const Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR FIRST SESSION',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white70,
                          fontWeight:
                              FontWeight.w800,
                          letterSpacing: .8,
                        ),
                      ),

                      SizedBox(height: 3),

                      Text(
                        'Get 20% OFF',
                        style: TextStyle(
                          fontSize: 21,
                          height: 1,
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: -.5,
                        ),
                      ),

                      SizedBox(height: 5),
  Text(
  'on your first physiotherapy session',
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(
    fontSize: 9.5,
    color: Color(0xD1FFFFFF),
    fontWeight: FontWeight.w500,
  ),
),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ------------------------------------------------
                // BOOK BUTTON
                // ------------------------------------------------

                GestureDetector(
                  onTap: onBookNow,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(.10),
                          blurRadius: 10,
                          offset:
                              const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Text(
                          'Book',
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                Color(0xFF5146D8),
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(
                          Icons
                              .arrow_forward_rounded,
                          size: 14,
                          color:
                              Color(0xFF5146D8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // CODE
          // ======================================================

          Positioned(
            left: 16,
            bottom: 11,
            child: Row(
              children: [
                Text(
                  'Use code',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white
                        .withOpacity(.65),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(width: 5),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(.12),
                    borderRadius:
                        BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'FIRST20',
                    style: TextStyle(
                      fontSize: 7.5,
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: .5,
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