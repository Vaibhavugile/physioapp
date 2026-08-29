import 'package:flutter/material.dart';

class ClinicDetailsScreen extends StatelessWidget {
  final String clinicName;
  final String address;
  final String imagePath;
  final double rating;
  final double distance;

  const ClinicDetailsScreen({
    super.key,
    this.clinicName = 'PhysioCare Wellness Clinic',
    this.address =
        'Baner Road, Pune, Maharashtra',
    this.imagePath =
        'assets/images/clinic/clinic_1.png',
    this.rating = 4.8,
    this.distance = 2.4,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FC),

      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),

              padding:
                  const EdgeInsets.fromLTRB(
                18,
                15,
                18,
                110,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // HEADER
                  // =================================================

                  Row(
                    children: [
                      _IconButton(
                        icon:
                            Icons.arrow_back_rounded,
                        onTap: () {
                          Navigator.of(context)
                              .pop();
                        },
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clinic details',
                              style: TextStyle(
                                fontSize: 19,
                                color:
                                    Color(0xFF111A3D),
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: -.45,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Everything you need to know',
                              style: TextStyle(
                                fontSize: 10.5,
                                color:
                                    Color(0xFF737C99),
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      _IconButton(
                        icon:
                            Icons.share_rounded,
                        onTap: () {
                          // Share clinic later.
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // CLINIC HERO
                  // =================================================

                  _ClinicHero(
                    clinicName:
                        clinicName,
                    imagePath:
                        imagePath,
                    rating:
                        rating,
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // LOCATION
                  // =================================================

                  _SectionCard(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle(
                          icon:
                              Icons.location_on_rounded,
                          title:
                              'Clinic location',
                        ),

                        const SizedBox(height: 12),

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                address,
                                style:
                                    const TextStyle(
                                  fontSize: 11,
                                  height: 1.4,
                                  color:
                                      Color(0xFF151D3D),
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFEAF9F5,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                              ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons
                                        .near_me_rounded,
                                    size: 12,
                                    color:
                                        Color(
                                      0xFF079F87,
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 3),
                                  Text(
                                    '${distance.toStringAsFixed(1)} km',
                                    style:
                                        const TextStyle(
                                      fontSize: 8.5,
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
                          ],
                        ),

                        const SizedBox(height: 13),

                        // MAP PREVIEW
                        Container(
                          height: 125,
                          width: double.infinity,
                          decoration:
                              BoxDecoration(
                            gradient:
                                const LinearGradient(
                              begin:
                                  Alignment.topLeft,
                              end:
                                  Alignment.bottomRight,
                              colors: [
                                Color(0xFFEFF1FF),
                                Color(0xFFE8F8F5),
                              ],
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                          ),
                          child: Stack(
                            alignment:
                                Alignment.center,
                            children: [
                              const Icon(
                                Icons
                                    .location_on_rounded,
                                size: 42,
                                color:
                                    Color(
                                  0xFF5146D9,
                                ),
                              ),

                              Positioned(
                                bottom: 10,
                                right: 11,
                                child:
                                    Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        Colors.white,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      10,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            const Color(
                                          0xFF26345C,
                                        ).withOpacity(
                                          .08,
                                        ),
                                        blurRadius:
                                            10,
                                        offset:
                                            const Offset(
                                          0,
                                          4,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child:
                                      const Row(
                                    mainAxisSize:
                                        MainAxisSize
                                            .min,
                                    children: [
                                      Icon(
                                        Icons
                                            .directions_rounded,
                                        size: 14,
                                        color:
                                            Color(
                                          0xFF5146D9,
                                        ),
                                      ),
                                      SizedBox(
                                          width: 4),
                                      Text(
                                        'Get directions',
                                        style:
                                            TextStyle(
                                          fontSize:
                                              8.5,
                                          color:
                                              Color(
                                            0xFF5146D9,
                                          ),
                                          fontWeight:
                                              FontWeight
                                                  .w900,
                                        ),
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

                  const SizedBox(height: 16),

                  // =================================================
                  // CLINIC FEATURES
                  // =================================================

                  const _SectionHeading(
                    title: 'Why this clinic',
                    subtitle:
                        'Designed for comfortable recovery',
                  ),

                  const SizedBox(height: 11),

                  const Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          icon:
                              Icons.verified_rounded,
                          title:
                              'Verified',
                          subtitle:
                              'Trusted clinic',
                        ),
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: _FeatureCard(
                          icon:
                              Icons
                                  .medical_services_rounded,
                          title:
                              'Modern care',
                          subtitle:
                              'Quality equipment',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  const Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          icon:
                              Icons
                                  .access_time_rounded,
                          title:
                              'Flexible',
                          subtitle:
                              'Multiple slots',
                        ),
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: _FeatureCard(
                          icon:
                              Icons
                                  .clean_hands_rounded,
                          title:
                              'Hygienic',
                          subtitle:
                              'Clean environment',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // SERVICES
                  // =================================================

                  const _SectionHeading(
                    title: 'Services available',
                    subtitle:
                        'Treatments you can book here',
                  ),

                  const SizedBox(height: 11),

                  const _ServicesCard(),

                  const SizedBox(height: 18),

                  // =================================================
                  // TIMINGS
                  // =================================================

                  const _SectionHeading(
                    title: 'Clinic timings',
                    subtitle:
                        'Plan your visit around these hours',
                  ),

                  const SizedBox(height: 11),

                  const _TimingCard(),

                  const SizedBox(height: 18),

                  // =================================================
                  // PHYSIOS
                  // =================================================

                  const _SectionHeading(
                    title: 'Physiotherapists here',
                    subtitle:
                        'Choose any available physiotherapist',
                  ),

                  const SizedBox(height: 11),

                  const _PhysioMiniCard(
                    name:
                        'Dr. Neha Sharma',
                    specialty:
                        'Orthopedic Physiotherapy',
                    rating: 4.9,
                    imagePath:
                        'assets/images/doctors/doctor_1.png',
                  ),

                  const SizedBox(height: 9),

                  const _PhysioMiniCard(
                    name:
                        'Dr. Arjun Mehta',
                    specialty:
                        'Rehabilitation & Pain Care',
                    rating: 4.8,
                    imagePath:
                        'assets/images/doctors/doctor_2.png',
                  ),
                ],
              ),
            ),

            // =======================================================
            // BOTTOM CTA
            // =======================================================

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child:
                  _BottomActionBar(
                onTap: () {
                  Navigator.of(context)
                      .pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// ICON BUTTON
// ====================================================================

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color:
                const Color(0xFFE3E6EF),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  const Color(0xFF26345C)
                      .withOpacity(.05),
              blurRadius: 13,
              offset:
                  const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 19,
          color:
              const Color(0xFF151D3D),
        ),
      ),
    );
  }
}

// ====================================================================
// CLINIC HERO
// ====================================================================

class _ClinicHero extends StatelessWidget {
  final String clinicName;
  final String imagePath;
  final double rating;

  const _ClinicHero({
    required this.clinicName,
    required this.imagePath,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 225,
      width: double.infinity,
      clipBehavior:
          Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(23),
        border: Border.all(
          color:
              const Color(0xFFE3E6EF),
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF26345C)
                    .withOpacity(.07),
            blurRadius: 20,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) {
              return Container(
                decoration:
                    const BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topLeft,
                    end:
                        Alignment.bottomRight,
                    colors: [
                      Color(0xFFEDEBFF),
                      Color(0xFFE7F8F5),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons
                      .local_hospital_rounded,
                  size: 60,
                  color:
                      Color(0xFF5146D9),
                ),
              );
            },
          ),

          // DARK GRADIENT
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 105,
            child: DecoratedBox(
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
                        .withOpacity(.72),
                  ],
                ),
              ),
            ),
          ),

          // VERIFIED
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.white
                        .withOpacity(.92),
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons
                        .verified_rounded,
                    size: 13,
                    color:
                        Color(0xFF079F87),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Verified clinic',
                    style:
                        TextStyle(
                      fontSize: 8,
                      color:
                          Color(0xFF087F75),
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // RATING
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.white
                        .withOpacity(.92),
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 13,
                    color:
                        Color(0xFFFFB21A),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    rating
                        .toStringAsFixed(1),
                    style:
                        const TextStyle(
                      fontSize: 8.5,
                      color:
                          Color(0xFF151D3D),
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TITLE
          Positioned(
            left: 15,
            right: 15,
            bottom: 14,
            child: Text(
              clinicName,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                height: 1.15,
                color: Colors.white,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: -.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// SECTION CARD
// ====================================================================

class _SectionCard
    extends StatelessWidget {
  final Widget child;

  const _SectionCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFE3E6EF),
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF26345C)
                    .withOpacity(.04),
            blurRadius: 16,
            offset:
                const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ====================================================================
// SECTION TITLE
// ====================================================================

class _SectionTitle
    extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color:
                const Color(0xFFF1F0FF),
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 16,
            color:
                const Color(0xFF5146D9),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12.5,
            color:
                Color(0xFF151D3D),
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// SECTION HEADING
// ====================================================================

class _SectionHeading
    extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15.5,
            color:
                Color(0xFF111A3D),
            fontWeight:
                FontWeight.w900,
            letterSpacing: -.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10.5,
            color:
                Color(0xFF7A839A),
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// FEATURE CARD
// ====================================================================

class _FeatureCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color:
              const Color(0xFFE3E6EF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFEFF0FF),
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 17,
              color:
                  const Color(0xFF5146D9),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 10,
                    color:
                        Color(0xFF151D3D),
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style:
                      const TextStyle(
                    fontSize: 8,
                    color:
                        Color(0xFF7A839A),
                    fontWeight:
                        FontWeight.w600,
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

// ====================================================================
// SERVICES
// ====================================================================

class _ServicesCard
    extends StatelessWidget {
  const _ServicesCard();

  static const services = [
    'Orthopedic physiotherapy',
    'Sports rehabilitation',
    'Pain management',
    'Post-surgery recovery',
    'Neuro rehabilitation',
    'Strength & mobility',
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: services.map(
          (service) {
            return Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFFF7F8FC),
                borderRadius:
                    BorderRadius.circular(
                  11,
                ),
                border: Border.all(
                  color:
                      const Color(
                    0xFFE5E8EF,
                  ),
                ),
              ),
              child: Text(
                service,
                style:
                    const TextStyle(
                  fontSize: 8.5,
                  color:
                      Color(0xFF59627E),
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

// ====================================================================
// TIMING CARD
// ====================================================================

class _TimingCard
    extends StatelessWidget {
  const _TimingCard();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        children: const [
          _TimingRow(
            day: 'Monday - Friday',
            time: '08:00 AM - 08:00 PM',
          ),
          SizedBox(height: 10),
          _TimingRow(
            day: 'Saturday',
            time: '09:00 AM - 06:00 PM',
          ),
          SizedBox(height: 10),
          _TimingRow(
            day: 'Sunday',
            time: '10:00 AM - 04:00 PM',
          ),
        ],
      ),
    );
  }
}

class _TimingRow
    extends StatelessWidget {
  final String day;
  final String time;

  const _TimingRow({
    required this.day,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.schedule_rounded,
          size: 17,
          color:
              Color(0xFF5146D9),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            day,
            style:
                const TextStyle(
              fontSize: 9.5,
              color:
                  Color(0xFF59627E),
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
        Text(
          time,
          style:
              const TextStyle(
            fontSize: 9.5,
            color:
                Color(0xFF151D3D),
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// PHYSIO MINI CARD
// ====================================================================

class _PhysioMiniCard
    extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final String imagePath;

  const _PhysioMiniCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            clipBehavior:
                Clip.antiAlias,
            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xFFEDEBFF),
                  Color(0xFFEAF9F5),
                ],
              ),
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) {
                return const Icon(
                  Icons.person_rounded,
                  size: 27,
                  color:
                      Color(0xFF5146D9),
                );
              },
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style:
                      const TextStyle(
                    fontSize: 11,
                    color:
                        Color(0xFF151D3D),
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  specialty,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 8.5,
                    color:
                        Color(0xFF737C94),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color:
                          Color(0xFFFFB21A),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      rating
                          .toStringAsFixed(1),
                      style:
                          const TextStyle(
                        fontSize: 8.5,
                        color:
                            Color(0xFF151D3D),
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color:
                Color(0xFF7A839A),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// BOTTOM ACTION BAR
// ====================================================================

class _BottomActionBar
    extends StatelessWidget {
  final VoidCallback onTap;

  const _BottomActionBar({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        12,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color:
                Color(0xFFE5E8F0),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF26345C)
                    .withOpacity(.10),
            blurRadius: 22,
            offset:
                const Offset(0, -7),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 49,
          child: ElevatedButton(
            onPressed: onTap,
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(
                0xFF5146D9,
              ),
              elevation: 0,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
            ),
            child: const Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  Icons
                      .check_circle_outline_rounded,
                  size: 17,
                  color: Colors.white,
                ),
                SizedBox(width: 7),
                Text(
                  'Select this clinic',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}