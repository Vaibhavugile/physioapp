import 'package:flutter/material.dart';

class UpcomingAppointment extends StatelessWidget {
  const UpcomingAppointment({super.key});

  // ============================================================
  // TEMPORARY HARDCODED DATA
  // ============================================================

  static const String doctorName =
      'Dr. Neha Sharma';

  static const String specialization =
      'Knee Pain Specialist';

  static const String doctorImage =
      'assets/images/doctors/doctor_1.png';

  static const String day = '21';
  static const String weekday = 'TUE';
  static const String month = 'MAY';

  static const String time = '11:00 AM';
  static const String location = 'At Home';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        14,
        13,
        12,
        13,
      ),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF1FBF9),
            Color(0xFFF8FCFF),
          ],
        ),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFFDCEFED),
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A6B68)
                .withOpacity(.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ========================================================
          // HEADER
          // ========================================================

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Upcoming Appointment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF087F75),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.2,
                  ),
                ),
              ),

              // CONFIRMED
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFE7F8F3),

                  borderRadius:
                      BorderRadius.circular(20),

                  border: Border.all(
                    color: const Color(0xFFC9EDE3),
                  ),
                ),

                child: const Row(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 12,
                      color: Color(0xFF00A889),
                    ),

                    SizedBox(width: 4),

                    Text(
                      'Confirmed',
                      style: TextStyle(
                        fontSize: 8.5,
                        color: Color(0xFF008F78),
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 3),

              const Icon(
                Icons.more_vert_rounded,
                size: 19,
                color: Color(0xFF59647E),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ========================================================
          // MAIN APPOINTMENT ROW
          // ========================================================

          Row(
            children: [
              // ----------------------------------------------------
              // DATE
              // ----------------------------------------------------

              _DateCard(
                weekday: weekday,
                day: day,
                month: month,
              ),

              const SizedBox(width: 10),

              // ----------------------------------------------------
              // DOCTOR
              // ----------------------------------------------------

              _DoctorAvatar(
                imagePath: doctorImage,
              ),

              const SizedBox(width: 9),

              // ----------------------------------------------------
              // DETAILS
              // ----------------------------------------------------

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // Doctor name
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            doctorName,

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontSize: 13.5,
                              color:
                                  Color(0xFF151D3D),
                              fontWeight:
                                  FontWeight.w800,
                              letterSpacing: -.25,
                            ),
                          ),
                        ),

                        const SizedBox(width: 4),

                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF08A78B),
                          size: 15,
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // Specialization
                    Text(
                      specialization,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF697394),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    // Time + Location
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: Color(0xFF53628A),
                        ),

                        const SizedBox(width: 4),

                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color:
                                Color(0xFF465274),
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(width: 9),

                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Color(0xFF53628A),
                        ),

                        const SizedBox(width: 3),

                        Flexible(
                          child: Text(
                            location,

                            overflow:
                                TextOverflow.ellipsis,

                            style:
                                const TextStyle(
                              fontSize: 9.5,
                              color:
                                  Color(0xFF465274),
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 7),

              // ----------------------------------------------------
              // SMALL ACTION BUTTON
              // ----------------------------------------------------

              Container(
                width: 34,
                height: 34,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient:
                      const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0CB49A),
                      Color(0xFF078D7A),
                    ],
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF079F87)
                          .withOpacity(.18),
                      blurRadius: 8,
                      offset:
                          const Offset(0, 3),
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// ================================================================
// DATE CARD
// ================================================================

class _DateCard extends StatelessWidget {
  final String weekday;
  final String day;
  final String month;

  const _DateCard({
    required this.weekday,
    required this.day,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 68,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(15),

        border: Border.all(
          color: const Color(0xFFE1E8E8),
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF30415E)
                .withOpacity(.045),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Text(
            weekday,
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF0C967E),
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            day,
            style: const TextStyle(
              fontSize: 23,
              height: 1,
              color: Color(0xFF087F75),
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            month,
            style: const TextStyle(
              fontSize: 7.5,
              color: Color(0xFF6D7690),
              fontWeight: FontWeight.w700,
              letterSpacing: .4,
            ),
          ),
        ],
      ),
    );
  }
}


// ================================================================
// DOCTOR AVATAR
// ================================================================

class _DoctorAvatar extends StatelessWidget {
  final String imagePath;

  const _DoctorAvatar({
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,

      padding: const EdgeInsets.all(2.5),

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: Colors.white,

        border: Border.all(
          color: const Color(0xFFDCE6EA),
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF31546A)
                .withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: ClipOval(
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
                  const Color(0xFFEAF3F4),

              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF6B8490),
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }
}