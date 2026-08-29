import 'package:flutter/material.dart';
import '../booking/booking_details_screen.dart';
import '../booking/clinic_details_screen.dart';
class PhysioProfileScreen extends StatefulWidget {
  final String doctorName;
  final String doctorImage;
  final String specialty;
  final double rating;
  final int reviews;
  final int experience;
  final String distance;

  const PhysioProfileScreen({
    super.key,
    this.doctorName = 'Dr. Neha Sharma',
    this.doctorImage = 'assets/images/doctor_1.png',
    this.specialty =
        'Orthopedic & Sports Physiotherapist',
    this.rating = 4.9,
    this.reviews = 230,
    this.experience = 8,
    this.distance = '1.8 km',
  });

  @override
  State<PhysioProfileScreen> createState() =>
      _PhysioProfileScreenState();
}

class _PhysioProfileScreenState
    extends State<PhysioProfileScreen> {
  bool _homeVisitSelected = true;

  final List<String> _timeSlots = const [
    '10:00 AM',
    '11:30 AM',
    '02:00 PM',
    '04:00 PM',
    '05:30 PM',
    '07:00 PM',
  ];

  String? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final int consultationPrice =
        _homeVisitSelected ? 599 : 499;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FC),

      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(
                18,
                14,
                18,
                120,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  _ProfileHeader(
                    onBackTap: () {
                      Navigator.of(context).pop();
                    },
                    onFavoriteTap: () {},
                  ),

                  const SizedBox(height: 16),

                  _DoctorHero(
                    name: widget.doctorName,
                    image: widget.doctorImage,
                    specialty: widget.specialty,
                    rating: widget.rating,
                    reviews: widget.reviews,
                    experience: widget.experience,
                  ),

                  const SizedBox(height: 18),

                  const _SectionTitle(
                    title: 'Choose your care',
                    subtitle:
                        'Select how you want your session',
                  ),

                  const SizedBox(height: 11),

                  Row(
                    children: [
                      Expanded(
                        child: _CareModeCard(
                          icon:
                              Icons.home_rounded,
                          title: 'Home Visit',
                          subtitle:
                              'At your doorstep',
                          price: '₹599',
                          selected:
                              _homeVisitSelected,
                          onTap: () {
                            setState(() {
                              _homeVisitSelected =
                                  true;
                              _selectedTime = null;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 11),

                      Expanded(
                        child: _CareModeCard(
                          icon:
                              Icons.local_hospital_rounded,
                          title: 'Clinic Visit',
                          subtitle:
                              'Visit the clinic',
                          price: '₹499',
                          selected:
                              !_homeVisitSelected,
                          onTap: () {
                            setState(() {
                              _homeVisitSelected =
                                  false;
                              _selectedTime = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (!_homeVisitSelected) ...[
                    const _SectionTitle(
                      title: 'Clinic details',
                      subtitle:
                          'Where your appointment will take place',
                    ),

                    const SizedBox(height: 11),

                    _ClinicCard(
                      onViewDetails: () {
                        // Clinic details screen later.
                        Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => const ClinicDetailsScreen(),
  ),
);
                      },
                    ),

                    const SizedBox(height: 20),
                  ],

                  if (_homeVisitSelected) ...[
                    const _SectionTitle(
                      title: 'Home visit',
                      subtitle:
                          'Personalized care at your location',
                    ),

                    const SizedBox(height: 11),

                    const _HomeVisitCard(),

                    const SizedBox(height: 20),
                  ],

                  const _SectionTitle(
                    title: 'About the physiotherapist',
                    subtitle:
                        'Experience you can trust',
                  ),

                  const SizedBox(height: 11),

                  const _AboutCard(),

                  const SizedBox(height: 20),

                  const _SectionTitle(
                    title: 'Specializations',
                    subtitle:
                        'Conditions this physiotherapist treats',
                  ),

                  const SizedBox(height: 11),

                  const _SpecializationsCard(),

                  const SizedBox(height: 20),

                  if (!_homeVisitSelected) ...[
                    const _SectionTitle(
                      title: 'Clinic facilities',
                      subtitle:
                          'Designed for comfortable recovery',
                    ),

                    const SizedBox(height: 11),

                    const _FacilitiesCard(),

                    const SizedBox(height: 20),
                  ],

                  const _SectionTitle(
                    title: 'Available time',
                    subtitle:
                        'Choose a convenient appointment slot',
                  ),

                  const SizedBox(height: 11),

                  _AvailabilityCard(
                    slots: _timeSlots,
                    selectedTime: _selectedTime,
                    onSelected: (time) {
                      setState(() {
                        _selectedTime = time;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  _PriceCard(
                    isHomeVisit:
                        _homeVisitSelected,
                    price:
                        consultationPrice,
                  ),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,

              child: _BottomBookingBar(
                price: consultationPrice,
                selectedTime:
                    _selectedTime,
                onBookTap: () {
                  _handleBooking();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
void _handleBooking() {
  if (_selectedTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF151D3D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: const Text(
          'Please select an available time.',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    return;
  }

  // ===============================================================
  // OPEN BOOKING DETAILS
  // ===============================================================

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BookingDetailsScreen(
        doctorName: widget.doctorName,
        doctorImage: widget.doctorImage,
        specialty: widget.specialty,
        rating: widget.rating,
      ),
    ),
  );
}
}

// ====================================================================
// PROFILE HEADER
// ====================================================================

class _ProfileHeader extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onFavoriteTap;

  const _ProfileHeader({
    this.onBackTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(
          icon:
              Icons.arrow_back_rounded,
          onTap: onBackTap,
        ),

        const Expanded(
          child: Center(
            child: Text(
              'Physiotherapist',
              style: TextStyle(
                fontSize: 15,
                color:
                    Color(0xFF111A3D),
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),
        ),

        _RoundIconButton(
          icon:
              Icons.favorite_border_rounded,
          onTap: onFavoriteTap,
        ),
      ],
    );
  }
}

// ====================================================================
// ROUND ICON BUTTON
// ====================================================================

class _RoundIconButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 42,
        height: 42,

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
                      .withOpacity(.055),
              blurRadius: 14,
              offset:
                  const Offset(0, 5),
            ),
          ],
        ),

        child: Icon(
          icon,
          size: 20,
          color:
              const Color(0xFF151D3D),
        ),
      ),
    );
  }
}

// ====================================================================
// DOCTOR HERO
// ====================================================================

class _DoctorHero
    extends StatelessWidget {
  final String name;
  final String image;
  final String specialty;
  final double rating;
  final int reviews;
  final int experience;

  const _DoctorHero({
    required this.name,
    required this.image,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.experience,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(26),

        border: Border.all(
          color:
              const Color(0xFFE3E6EF),
        ),

        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF26345C)
                    .withOpacity(.075),
            blurRadius: 25,
            spreadRadius: -4,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        children: [
          Container(
            height: 225,
            width: double.infinity,

            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(21),

              gradient:
                  const LinearGradient(
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

            clipBehavior:
                Clip.antiAlias,

            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  image,
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
                        size: 90,
                        color:
                            Color(0xFF5B64D9),
                      ),
                    );
                  },
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 80,

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
                              .withOpacity(.20),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 12,
                  bottom: 12,

                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withOpacity(.96),

                      borderRadius:
                          BorderRadius.circular(
                        11,
                      ),
                    ),

                    child: const Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .verified_rounded,
                          size: 14,
                          color:
                              Color(0xFF079F87),
                        ),

                        SizedBox(width: 4),

                        Text(
                          'Verified Professional',
                          style:
                              TextStyle(
                            fontSize: 9,
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
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    fontSize: 20,
                    color:
                        Color(0xFF111A3D),
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -.55,
                  ),
                ),
              ),

              const Icon(
                Icons.verified_rounded,
                size: 20,
                color:
                    Color(0xFF079F87),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Align(
            alignment:
                Alignment.centerLeft,

            child: Text(
              specialty,
              style: const TextStyle(
                fontSize: 11.5,
                color:
                    Color(0xFF69728D),
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  icon:
                      Icons.star_rounded,
                  value:
                      rating.toString(),
                  label:
                      '$reviews reviews',
                  iconColor:
                      Color(0xFFFFB21A),
                ),
              ),

              _VerticalDivider(),

              Expanded(
                child: _HeroStat(
                  icon:
                      Icons.workspace_premium_rounded,
                  value:
                      '$experience+',
                  label:
                      'Years experience',
                  iconColor:
                      Color(0xFF5146D9),
                ),
              ),

              _VerticalDivider(),

              Expanded(
                child: _HeroStat(
                  icon:
                      Icons.home_rounded,
                  value:
                      'Home',
                  label:
                      'Visit available',
                  iconColor:
                      Color(0xFF079F87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// HERO STAT
// ====================================================================

class _HeroStat
    extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _HeroStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor,
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color:
                Color(0xFF151D3D),
            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          textAlign:
              TextAlign.center,
          maxLines: 2,

          style: const TextStyle(
            fontSize: 9,
            height: 1.2,
            color:
                Color(0xFF7D859B),
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// VERTICAL DIVIDER
// ====================================================================

class _VerticalDivider
    extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color:
          const Color(0xFFE5E8F0),
    );
  }
}

// ====================================================================
// SECTION TITLE
// ====================================================================

class _SectionTitle
    extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
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
            fontSize: 16,
            color:
                Color(0xFF111A3D),
            fontWeight:
                FontWeight.w900,
            letterSpacing: -.35,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10.5,
            height: 1.3,
            color:
                Color(0xFF7D859B),
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// CARE MODE CARD
// ====================================================================

class _CareModeCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  const _CareModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 220),

        padding:
            const EdgeInsets.all(12),

        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin:
                      Alignment.topLeft,
                  end:
                      Alignment.bottomRight,
                  colors: [
                    Color(0xFFF0EEFF),
                    Color(0xFFEAF9F6),
                  ],
                )
              : null,

          color:
              selected ? null : Colors.white,

          borderRadius:
              BorderRadius.circular(20),

          border: Border.all(
            color: selected
                ? const Color(0xFF8E82EF)
                : const Color(0xFFE3E6EF),

            width:
                selected ? 1.3 : .9,
          ),

          boxShadow: [
            if (selected)
              BoxShadow(
                color:
                    const Color(0xFF5146D9)
                        .withOpacity(.09),
                blurRadius: 18,
                offset:
                    const Offset(0, 7),
              ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  width: 39,
                  height: 39,

                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withOpacity(.80),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),

                  child: Icon(
                    icon,
                    size: 20,
                    color: selected
                        ? const Color(
                            0xFF5146D9,
                          )
                        : const Color(
                            0xFF66708D,
                          ),
                  ),
                ),

                const Spacer(),

                if (selected)
                  const Icon(
                    Icons
                        .check_circle_rounded,
                    size: 19,
                    color:
                        Color(0xFF079F87),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color:
                    Color(0xFF151D3D),
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 9.5,
                height: 1.2,
                color:
                    Color(0xFF737C99),
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '$price / session',
              style: const TextStyle(
                fontSize: 11,
                color:
                    Color(0xFF079F87),
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// CLINIC CARD
// ====================================================================

class _ClinicCard
    extends StatelessWidget {
  final VoidCallback? onViewDetails;

  const _ClinicCard({
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(21),

        border: Border.all(
          color:
              const Color(0xFFE3E6EF),
        ),

        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF26345C)
                    .withOpacity(.055),
            blurRadius: 18,
            offset:
                const Offset(0, 7),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,

                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xFFEDEBFF),
                      Color(0xFFE8F9F5),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: const Icon(
                  Icons
                      .local_hospital_rounded,
                  color:
                      Color(0xFF5146D9),
                  size: 22,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'PhysioCare Rehabilitation Centre',
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Color(0xFF111A3D),
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 13,
                          color:
                              Color(0xFFFFB21A),
                        ),

                        SizedBox(width: 3),

                        Text(
                          '4.8',
                          style:
                              TextStyle(
                            fontSize: 10,
                            color:
                                Color(
                              0xFF202744,
                            ),
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        SizedBox(width: 5),

                        Text(
                          '• Baner, Pune',
                          style:
                              TextStyle(
                            fontSize: 9.5,
                            color:
                                Color(
                              0xFF7B849B,
                            ),
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          const _InfoRow(
            icon:
                Icons.location_on_rounded,
            title:
                'Baner, Pune',
            subtitle:
                '1.8 km from your location',
          ),

          const SizedBox(height: 10),

          const _InfoRow(
            icon:
                Icons.access_time_rounded,
            title:
                '9:00 AM – 8:00 PM',
            subtitle:
                'Monday – Saturday',
          ),

          const SizedBox(height: 12),

          GestureDetector(
            onTap: onViewDetails,

            child: Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.symmetric(
                vertical: 10,
              ),

              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFFF3F1FF),
                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    'View clinic details',
                    style: TextStyle(
                      fontSize: 10,
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
    );
  }
}
// ====================================================================
// HOME VISIT CARD
// ====================================================================

class _HomeVisitCard
    extends StatelessWidget {
  const _HomeVisitCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFFF0EEFF),
            Color(0xFFEAF9F6),
          ],
        ),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              const Color(0xFFE0E1F2),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,

            decoration:
                BoxDecoration(
              color: Colors.white
                  .withOpacity(.85),
              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.home_work_rounded,
              size: 22,
              color:
                  Color(0xFF079F87),
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Care at your doorstep',
                  style: TextStyle(
                    fontSize: 11.5,
                    color:
                        Color(0xFF151D3D),
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Your physiotherapist will visit your selected address.',
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.3,
                    color:
                        Color(0xFF69728D),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle_rounded,
            size: 19,
            color:
                Color(0xFF079F87),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// ABOUT CARD
// ====================================================================

class _AboutCard
    extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(19),

        border: Border.all(
          color:
              const Color(0xFFE4E7EF),
        ),
      ),

      child: const Text(
        'Dr. Neha Sharma is an experienced physiotherapist specializing in orthopedic recovery, sports injuries, pain management and mobility rehabilitation. Her approach focuses on personalized treatment plans designed around each patient’s recovery goals.',
        style: TextStyle(
          fontSize: 11.5,
          height: 1.55,
          color:
              Color(0xFF626C87),
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }
}

// ====================================================================
// SPECIALIZATIONS
// ====================================================================

class _SpecializationsCard
    extends StatelessWidget {
  const _SpecializationsCard();

  static const List<String> items = [
    'Knee Pain',
    'Back Pain',
    'Sports Injury',
    'Shoulder Pain',
    'Neck Pain',
    'Post Surgery',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,

      children:
          items.map((item) {
        return Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),

          decoration: BoxDecoration(
            color:
                const Color(0xFFF7F8FC),

            borderRadius:
                BorderRadius.circular(11),

            border: Border.all(
              color:
                  const Color(0xFFE4E7EF),
            ),
          ),

          child: Text(
            item,
            style:
                const TextStyle(
              fontSize: 10,
              color:
                  Color(0xFF59627E),
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ====================================================================
// FACILITIES
// ====================================================================

class _FacilitiesCard
    extends StatelessWidget {
  const _FacilitiesCard();

  static const List<String> facilities = [
    'Modern equipment',
    'Private treatment rooms',
    'Parking available',
    'Wheelchair accessible',
    'Clean & hygienic',
    'Comfortable waiting area',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(19),

        border: Border.all(
          color:
              const Color(0xFFE4E7EF),
        ),
      ),

      child: Column(
        children:
            facilities.map((facility) {
          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 9,
            ),

            child: Row(
              children: [
                Container(
                  width: 23,
                  height: 23,

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFEAF9F6,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      7,
                    ),
                  ),

                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color:
                        Color(0xFF079F87),
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  facility,
                  style:
                      const TextStyle(
                    fontSize: 10.5,
                    color:
                        Color(0xFF59627E),
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ====================================================================
// AVAILABILITY
// ====================================================================

class _AvailabilityCard
    extends StatelessWidget {
  final List<String> slots;
  final String? selectedTime;
  final ValueChanged<String> onSelected;

  const _AvailabilityCard({
    required this.slots,
    required this.selectedTime,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              const Color(0xFFE3E6EF),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEAF9F6,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),

                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color:
                      Color(0xFF079F87),
                ),
              ),

              const SizedBox(width: 8),

              const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    'Today',
                    style:
                        TextStyle(
                      fontSize: 10.5,
                      color:
                          Color(0xFF151D3D),
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  SizedBox(height: 3),

                  Text(
                    'Available slots',
                    style:
                        TextStyle(
                      fontSize: 9.5,
                      color:
                          Color(0xFF7B849B),
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 13),

          Wrap(
            spacing: 7,
            runSpacing: 7,

            children:
                slots.map((slot) {
              final selected =
                  slot ==
                      selectedTime;

              return GestureDetector(
                onTap: () {
                  onSelected(slot);
                },

                child:
                    AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 180,
                  ),

                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),

                  decoration:
                      BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [
                              Color(
                                0xFF6650E5,
                              ),
                              Color(
                                0xFF5146D9,
                              ),
                            ],
                          )
                        : null,

                    color: selected
                        ? null
                        : const Color(
                            0xFFF7F8FC,
                          ),

                    borderRadius:
                        BorderRadius.circular(
                      11,
                    ),

                    border: Border.all(
                      color: selected
                          ? const Color(
                              0xFF5146D9,
                            )
                          : const Color(
                              0xFFE3E6EF,
                            ),
                    ),
                  ),

                  child: Text(
                    slot,

                    style: TextStyle(
                      fontSize: 10,
                      color: selected
                          ? Colors.white
                          : const Color(
                              0xFF59627E,
                            ),
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// INFO ROW
// ====================================================================

class _InfoRow
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 31,
          height: 31,

          decoration:
              BoxDecoration(
            color:
                const Color(0xFFF1F2FF),
            borderRadius:
                BorderRadius.circular(9),
          ),

          child: Icon(
            icon,
            size: 15,
            color:
                const Color(0xFF5146D9),
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 10.5,
                  color:
                      Color(0xFF151D3D),
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style:
                    const TextStyle(
                  fontSize: 9.5,
                  color:
                      Color(0xFF7B849B),
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// PRICE CARD
// ====================================================================

class _PriceCard
    extends StatelessWidget {
  final bool isHomeVisit;
  final int price;

  const _PriceCard({
    required this.isHomeVisit,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(15),

      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFFF1F0FF),
            Color(0xFFEAF9F6),
          ],
        ),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              const Color(0xFFE0E2F1),
        ),
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'CONSULTATION',
                  style: TextStyle(
                    fontSize: 9,
                    color:
                        Color(0xFF8A92A8),
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  isHomeVisit
                      ? 'Home Visit'
                      : 'Clinic Visit',

                  style:
                      const TextStyle(
                    fontSize: 11,
                    color:
                        Color(0xFF151D3D),
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '₹$price',

            style:
                const TextStyle(
              fontSize: 21,
              color:
                  Color(0xFF079F87),
              fontWeight:
                  FontWeight.w900,
              letterSpacing: -.5,
            ),
          ),

          const SizedBox(width: 4),

          const Text(
            '/ session',
            style: TextStyle(
              fontSize: 9.5,
              color:
                  Color(0xFF7B849B),
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// BOTTOM BOOKING BAR
// ====================================================================

class _BottomBookingBar
    extends StatelessWidget {
  final int price;
  final String? selectedTime;
  final VoidCallback onBookTap;

  const _BottomBookingBar({
    required this.price,
    required this.selectedTime,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        11,
        18,
        13,
      ),

      decoration: BoxDecoration(
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

        child: Row(
          children: [
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 9,
                    color:
                        Color(0xFF9198AA),
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '₹$price',
                  style:
                      const TextStyle(
                    fontSize: 17,
                    color:
                        Color(0xFF079F87),
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            Expanded(
              child: GestureDetector(
                onTap: onBookTap,

                child: Container(
                  height: 49,

                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      begin:
                          Alignment.topLeft,
                      end:
                          Alignment.bottomRight,
                      colors: [
                        Color(0xFF6C59EA),
                        Color(0xFF5146D9),
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(
                          0xFF5146D9,
                        ).withOpacity(.24),

                        blurRadius: 14,

                        offset:
                            const Offset(
                          0,
                          6,
                        ),
                      ),
                    ],
                  ),

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      Text(
                        selectedTime == null
                            ? 'Select Time'
                            : 'Book Appointment',

                        style:
                            const TextStyle(
                          fontSize: 12,
                          color:
                              Colors.white,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),

                      const SizedBox(width: 7),

                      const Icon(
                        Icons
                            .arrow_forward_rounded,
                        size: 16,
                        color:
                            Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}