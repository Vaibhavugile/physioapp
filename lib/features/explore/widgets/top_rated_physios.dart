import 'package:flutter/material.dart';

import '../physio_profile_screen.dart';

class TopRatedPhysios extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const TopRatedPhysios({
    super.key,
    this.onSeeAll,
  });

  // ===============================================================
  // HARD-CODED PHYSIOTHERAPISTS
  // ===============================================================

  static const List<_Physio> _physios = [
    _Physio(
      id: 'arjun',
      name: 'Dr. Arjun Mehta',
      specialty: 'Pain Management',
      distance: '2.4 km',
      price: '₹549',
      rating: '4.9',
      reviews: '230',
      image: 'assets/images/doctor_1.png',
      experience: 8,
    ),
    _Physio(
      id: 'priya',
      name: 'Dr. Priya Kapoor',
      specialty: 'Neuro Physiotherapy',
      distance: '2.7 km',
      price: '₹599',
      rating: '4.8',
      reviews: '184',
      image: 'assets/images/doctor_1.png',
      experience: 7,
    ),
    _Physio(
      id: 'rohan',
      name: 'Dr. Rohan Verma',
      specialty: 'Sports Physiotherapy',
      distance: '3.1 km',
      price: '₹549',
      rating: '4.8',
      reviews: '156',
      image: 'assets/images/doctor_1.png',
      experience: 6,
    ),
    _Physio(
      id: 'ananya',
      name: 'Dr. Ananya Rao',
      specialty: 'Orthopedic Physiotherapy',
      distance: '3.6 km',
      price: '₹599',
      rating: '4.9',
      reviews: '211',
      image: 'assets/images/doctor_1.png',
      experience: 9,
    ),
    _Physio(
      id: 'karan',
      name: 'Dr. Karan Shah',
      specialty: 'Sports Rehabilitation',
      distance: '4.1 km',
      price: '₹549',
      rating: '4.7',
      reviews: '143',
      image: 'assets/images/doctor_1.png',
      experience: 6,
    ),
    _Physio(
      id: 'meera',
      name: 'Dr. Meera Joshi',
      specialty: 'Women’s Physiotherapy',
      distance: '4.5 km',
      price: '₹649',
      rating: '4.9',
      reviews: '198',
      image: 'assets/images/doctor_1.png',
      experience: 10,
    ),
    _Physio(
      id: 'aditya',
      name: 'Dr. Aditya Nair',
      specialty: 'Spine & Back Care',
      distance: '4.8 km',
      price: '₹599',
      rating: '4.8',
      reviews: '172',
      image: 'assets/images/doctor_1.png',
      experience: 8,
    ),
    _Physio(
      id: 'isha',
      name: 'Dr. Isha Malhotra',
      specialty: 'Neuro Rehabilitation',
      distance: '5.2 km',
      price: '₹649',
      rating: '4.9',
      reviews: '205',
      image: 'assets/images/doctor_1.png',
      experience: 9,
    ),
    _Physio(
      id: 'vivek',
      name: 'Dr. Vivek Patil',
      specialty: 'Joint & Mobility Care',
      distance: '5.6 km',
      price: '₹549',
      rating: '4.7',
      reviews: '129',
      image: 'assets/images/doctor_1.png',
      experience: 5,
    ),
    _Physio(
      id: 'neha',
      name: 'Dr. Neha Sharma',
      specialty: 'Orthopedic & Sports',
      distance: '6.1 km',
      price: '₹599',
      rating: '4.9',
      reviews: '230',
      image: 'assets/images/doctor_1.png',
      experience: 8,
    ),
    _Physio(
      id: 'rahul',
      name: 'Dr. Rahul Desai',
      specialty: 'Pain & Rehabilitation',
      distance: '6.5 km',
      price: '₹549',
      rating: '4.8',
      reviews: '167',
      image: 'assets/images/doctor_1.png',
      experience: 7,
    ),
    _Physio(
      id: 'simran',
      name: 'Dr. Simran Kaur',
      specialty: 'Posture & Recovery',
      distance: '7.1 km',
      price: '₹599',
      rating: '4.8',
      reviews: '151',
      image: 'assets/images/doctor_1.png',
      experience: 6,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        // =========================================================
        // HEADER
        // =========================================================

        Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [

            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top rated near you',
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.1,
                      color:
                          Color(0xFF111A3D),
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing: -.5,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Trusted physiotherapists around you',
                    style: TextStyle(
                      fontSize: 9,
                      height: 1.1,
                      color:
                          Color(0xFF7B849C),
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            GestureDetector(
              onTap: onSeeAll,
              behavior:
                  HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    begin:
                        Alignment.topLeft,
                    end:
                        Alignment.bottomRight,
                    colors: [
                      Color(0xFFF3F1FF),
                      Color(0xFFEEF8F7),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        const Color(0xFFE1E0F4),
                  ),
                ),
                child: const Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 9,
                        color:
                            Color(0xFF5146D9),
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons
                          .arrow_forward_rounded,
                      size: 13,
                      color:
                          Color(0xFF5146D9),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // =========================================================
        // 2 COLUMN DOCTOR GRID
        // =========================================================

        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _physios.length,

          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 11,
            mainAxisSpacing: 13,
            mainAxisExtent: 286,
          ),

          itemBuilder: (context, index) {
            final physio =
                _physios[index];

            return _PhysioCard(
              physio: physio,

              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        PhysioProfileScreen(
                      doctorName:
                          physio.name,
                      doctorImage:
                          physio.image,
                      specialty:
                          physio.specialty,
                      rating:
                          double.tryParse(
                                physio.rating,
                              ) ??
                              4.8,
                      reviews:
                          int.tryParse(
                                physio.reviews,
                              ) ??
                              0,
                      experience:
                          physio.experience,
                      distance:
                          physio.distance,
                    ),
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


// ===================================================================
// PHYSIO CARD
// ===================================================================

class _PhysioCard
    extends StatelessWidget {
  final _Physio physio;
  final VoidCallback? onTap;

  const _PhysioCard({
    required this.physio,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(22),

        splashColor:
            const Color(0xFF5146D9)
                .withOpacity(.06),

        highlightColor:
            const Color(0xFF5146D9)
                .withOpacity(.025),

        child: Container(
          width: double.infinity,

          decoration:
              BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(22),

            border: Border.all(
              color:
                  const Color(0xFFE3E6EF),
              width: .9,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFF26345C)
                        .withOpacity(.075),
                blurRadius: 22,
                spreadRadius: -5,
                offset:
                    const Offset(0, 9),
              ),
            ],
          ),

          clipBehavior:
              Clip.antiAlias,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // =====================================================
              // DOCTOR IMAGE
              // =====================================================

              SizedBox(
                width: double.infinity,
                height: 137,

                child: Stack(
                  fit: StackFit.expand,
                  children: [

                    Container(
                      decoration:
                          const BoxDecoration(
                        gradient:
                            LinearGradient(
                          begin:
                              Alignment.topLeft,
                          end:
                              Alignment.bottomRight,
                          colors: [
                            Color(0xFFF0F2FF),
                            Color(0xFFE8F9F5),
                          ],
                        ),
                      ),
                    ),

                    Image.asset(
                      physio.image,
                      fit: BoxFit.cover,
                      alignment:
                          Alignment.topCenter,

                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Center(
                          child: Icon(
                            Icons
                                .person_rounded,
                            size: 52,
                            color:
                                Color(0xFF5B64D9),
                          ),
                        );
                      },
                    ),

                    // IMAGE FADE

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 45,

                      child:
                          DecoratedBox(
                        decoration:
                            BoxDecoration(
                          gradient:
                              LinearGradient(
                            begin:
                                Alignment.topCenter,
                            end:
                                Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black
                                  .withOpacity(.13),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // VERIFIED

                    Positioned(
                      left: 9,
                      bottom: 9,

                      child: Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),

                        decoration:
                            BoxDecoration(
                          color: Colors.white
                              .withOpacity(.97),
                          borderRadius:
                              BorderRadius
                                  .circular(9),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(.10),
                              blurRadius: 8,
                              offset:
                                  const Offset(
                                0,
                                3,
                              ),
                            ),
                          ],
                        ),

                        child: const Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              Icons
                                  .verified_rounded,
                              size: 11,
                              color:
                                  Color(0xFF079F87),
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Verified',
                              style:
                                  TextStyle(
                                fontSize: 7,
                                color:
                                    Color(
                                  0xFF087F75,
                                ),
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // FAVORITE

                    Positioned(
                      top: 9,
                      right: 9,

                      child: Container(
                        width: 32,
                        height: 32,

                        decoration:
                            BoxDecoration(
                          color: Colors.white
                              .withOpacity(.96),
                          shape:
                              BoxShape.circle,

                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(
                                0xFF26345C,
                              ).withOpacity(.13),
                              blurRadius: 9,
                              offset:
                                  const Offset(
                                0,
                                3,
                              ),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons
                              .favorite_border_rounded,
                          size: 17,
                          color:
                              Color(0xFF26345C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =====================================================
              // DETAILS
              // =====================================================

              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    11,
                    11,
                    11,
                    10,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // NAME

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              physio.name,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,

                              style:
                                  const TextStyle(
                                fontSize: 11.2,
                                height: 1.1,
                                color:
                                    Color(0xFF111A3D),
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing:
                                    -.25,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 3,
                          ),

                          const Icon(
                            Icons
                                .verified_rounded,
                            size: 13,
                            color:
                                Color(0xFF079F87),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // SPECIALTY

                      Text(
                        physio.specialty,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            const TextStyle(
                          fontSize: 7.8,
                          height: 1.25,
                          color:
                              Color(0xFF68728B),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // RATING

                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color:
                                Color(0xFFFFB21A),
                          ),

                          const SizedBox(
                            width: 3,
                          ),

                          Text(
                            physio.rating,
                            style:
                                const TextStyle(
                              fontSize: 9,
                              color:
                                  Color(0xFF202744),
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),

                          const SizedBox(
                            width: 3,
                          ),

                          Flexible(
                            child: Text(
                              '(${physio.reviews})',
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,

                              style:
                                  const TextStyle(
                                fontSize: 7,
                                color:
                                    Color(0xFF8A92A8),
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      // LOCATION

                      Row(
                        children: [
                          const Icon(
                            Icons
                                .location_on_rounded,
                            size: 14,
                            color:
                                Color(0xFF079F87),
                          ),

                          const SizedBox(
                            width: 3,
                          ),

                          Expanded(
                            child: Text(
                              physio.distance,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,

                              style:
                                  const TextStyle(
                                fontSize: 7.5,
                                color:
                                    Color(0xFF69728D),
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Container(
                        width:
                            double.infinity,
                        height: 1,
                        color:
                            const Color(
                          0xFFEDEFF4,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // PRICE

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        children: [

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  'FROM',
                                  style:
                                      TextStyle(
                                    fontSize: 6,
                                    color:
                                        Color(
                                      0xFF98A0B4,
                                    ),
                                    fontWeight:
                                        FontWeight.w900,
                                    letterSpacing:
                                        .4,
                                  ),
                                ),

                                const SizedBox(
                                  height: 2,
                                ),

                                Text(
                                  physio.price,
                                  style:
                                      const TextStyle(
                                    fontSize: 14,
                                    height: 1,
                                    color:
                                        Color(
                                      0xFF079F87,
                                    ),
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),

                                const SizedBox(
                                  height: 2,
                                ),

                                const Text(
                                  'per session',
                                  style:
                                      TextStyle(
                                    fontSize: 6.5,
                                    color:
                                        Color(
                                      0xFF8A92A8,
                                    ),
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            width: 33,
                            height: 33,

                            decoration:
                                BoxDecoration(
                              gradient:
                                  const LinearGradient(
                                begin:
                                    Alignment.topLeft,
                                end:
                                    Alignment.bottomRight,
                                colors: [
                                  Color(
                                    0xFF6C59EA,
                                  ),
                                  Color(
                                    0xFF5146D9,
                                  ),
                                ],
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(11),

                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(
                                    0xFF5146D9,
                                  ).withOpacity(.20),
                                  blurRadius: 9,
                                  offset:
                                      const Offset(
                                    0,
                                    4,
                                  ),
                                ),
                              ],
                            ),

                            child:
                                const Icon(
                              Icons
                                  .arrow_forward_rounded,
                              size: 15,
                              color:
                                  Colors.white,
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
      ),
    );
  }
}


// ===================================================================
// MODEL
// ===================================================================

class _Physio {
  final String id;
  final String name;
  final String specialty;
  final String distance;
  final String price;
  final String rating;
  final String reviews;
  final String image;
  final int experience;

  const _Physio({
    required this.id,
    required this.name,
    required this.specialty,
    required this.distance,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.image,
    required this.experience,
  });
}