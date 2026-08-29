import 'package:flutter/material.dart';

class PhysiotherapistCard extends StatelessWidget {
  final String name;
  final String specialization;
  final String imagePath;
  final double rating;
  final int experience;
  final double distance;
  final int price;
  final bool available;
  final VoidCallback? onTap;
  final VoidCallback? onBookTap;

  const PhysiotherapistCard({
    super.key,
    required this.name,
    required this.specialization,
    required this.imagePath,
    required this.rating,
    required this.experience,
    required this.distance,
    required this.price,
    this.available = true,
    this.onTap,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: const Color(0xFFE6E9F1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF26345C)
                  .withOpacity(.055),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ==================================================
                // DOCTOR IMAGE
                // ==================================================

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(17),
                  child: SizedBox(
                    width: 82,
                    height: 94,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          color:
                              const Color(0xFFF0F3FF),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 36,
                            color:
                                Color(0xFF6974D6),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 11),

                // ==================================================
                // DOCTOR INFORMATION
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color:
                                    Color(0xFF121A3A),
                                fontWeight:
                                    FontWeight.w800,
                                letterSpacing: -.25,
                              ),
                            ),
                          ),

                          const SizedBox(width: 4),

                          const Icon(
                            Icons.verified_rounded,
                            size: 15,
                            color:
                                Color(0xFF079F87),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        specialization,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color:
                              Color(0xFF737C99),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 9),

                      // Rating + Experience
                      Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFFFFF7E5,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(7),
                            ),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 12,
                                  color:
                                      Color(0xFFF5A623),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  rating
                                      .toStringAsFixed(
                                    1,
                                  ),
                                  style:
                                      const TextStyle(
                                    fontSize: 8.5,
                                    color:
                                        Color(
                                      0xFF765800,
                                    ),
                                    fontWeight:
                                        FontWeight
                                            .w800,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 7),

                          Text(
                            '$experience yrs exp.',
                            style:
                                const TextStyle(
                              fontSize: 9,
                              color:
                                  Color(0xFF737C99),
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Distance + Home visit
                      Row(
                        children: [
                          const Icon(
                            Icons
                                .location_on_outlined,
                            size: 13,
                            color:
                                Color(0xFF66718D),
                          ),

                          const SizedBox(width: 3),

                          Text(
                            '${distance.toStringAsFixed(1)} km',
                            style:
                                const TextStyle(
                              fontSize: 9,
                              color:
                                  Color(0xFF66718D),
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(width: 9),

                          const Icon(
                            Icons.home_outlined,
                            size: 13,
                            color:
                                Color(0xFF079F87),
                          ),

                          const SizedBox(width: 3),

                          const Text(
                            'Home visit',
                            style: TextStyle(
                              fontSize: 9,
                              color:
                                  Color(0xFF079F87),
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ======================================================
            // BOTTOM ACTION AREA
            // ======================================================

            Container(
              padding:
                  const EdgeInsets.fromLTRB(
                10,
                8,
                8,
                8,
              ),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFF8F9FC),
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  // ------------------------------------------------
                  // PRICE
                  // ------------------------------------------------

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SESSION FROM',
                          style: TextStyle(
                            fontSize: 7,
                            color:
                                Color(0xFF9299AB),
                            fontWeight:
                                FontWeight.w800,
                            letterSpacing: .5,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .baseline,
                          textBaseline:
                              TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹$price',
                              style:
                                  const TextStyle(
                                fontSize: 15,
                                color:
                                    Color(
                                  0xFF121A3A,
                                ),
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: -.3,
                              ),
                            ),

                            const SizedBox(width: 3),

                            const Text(
                              '/ session',
                              style: TextStyle(
                                fontSize: 8,
                                color:
                                    Color(
                                  0xFF737C99,
                                ),
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ------------------------------------------------
                  // AVAILABILITY
                  // ------------------------------------------------

                  if (available)
                    Container(
                      margin:
                          const EdgeInsets.only(
                        right: 7,
                      ),
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 7,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFE9F8F3,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          9,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 5,
                            color:
                                Color(0xFF08A789),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 8,
                              color:
                                  Color(
                                0xFF078B74,
                              ),
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ------------------------------------------------
                  // BOOK BUTTON
                  // ------------------------------------------------

                  GestureDetector(
                    onTap: onBookTap,
                    child: Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(
                          begin:
                              Alignment.topLeft,
                          end:
                              Alignment.bottomRight,
                          colors: [
                            Color(0xFF5E68E8),
                            Color(0xFF5146D9),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          11,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(
                              0xFF5146D9,
                            ).withOpacity(.18),
                            blurRadius: 8,
                            offset:
                                const Offset(0, 3),
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
                              fontSize: 9.5,
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons
                                .arrow_forward_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
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