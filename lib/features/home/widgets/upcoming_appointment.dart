import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/appointment_model.dart';
import '../../../services/appointment_service.dart';

class UpcomingAppointment extends StatelessWidget {
  const UpcomingAppointment({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  // ==============================================================
  // SERVICES
  // ==============================================================

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static final AppointmentService _appointmentService =
      AppointmentService();

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    // ------------------------------------------------------------
    // USER NOT LOGGED IN
    // ------------------------------------------------------------

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<AppointmentModel?>(
      stream: _appointmentService
          .streamNextUpcomingAppointment(
        userId: user.uid,
      ),

      builder: (
        context,
        snapshot,
      ) {
        // --------------------------------------------------------
        // LOADING
        // --------------------------------------------------------

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const _UpcomingAppointmentLoading();
        }

        // --------------------------------------------------------
        // ERROR
        // --------------------------------------------------------

        if (snapshot.hasError) {
          debugPrint(
            'Upcoming appointment error: '
            '${snapshot.error}',
          );

          return const SizedBox.shrink();
        }

        // --------------------------------------------------------
        // NO APPOINTMENT
        // --------------------------------------------------------

        final appointment = snapshot.data;

        if (appointment == null) {
          return _NoUpcomingAppointment(
            onTap: onTap,
          );
        }

        // --------------------------------------------------------
        // APPOINTMENT FOUND
        // --------------------------------------------------------

        return _UpcomingAppointmentCard(
          appointment: appointment,
          onTap: onTap,
        );
      },
    );
  }
}

// =================================================================
// PREMIUM APPOINTMENT CARD
// =================================================================

class _UpcomingAppointmentCard extends StatelessWidget {
  const _UpcomingAppointmentCard({
    required this.appointment,
    this.onTap,
  });

  final AppointmentModel appointment;

  final VoidCallback? onTap;

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final date =
        appointment.appointmentDate;

    final doctorName =
        _getDoctorName();

    final specialization =
        _getSpecialization();

    final imageUrl =
        _getImageUrl();

    final visitType =
        _getVisitType();

    final status =
        _getStatus();

    return GestureDetector(
      onTap: onTap,

      child: Container(
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
            // =====================================================
            // HEADER
            // =====================================================

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Upcoming Appointment',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF087F75),
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: -.2,
                    ),
                  ),
                ),

                _StatusBadge(
                  status: status,
                ),

                const SizedBox(width: 3),

                const Icon(
                  Icons.more_vert_rounded,
                  size: 19,
                  color: Color(0xFF59647E),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =====================================================
            // MAIN CONTENT
            // =====================================================

            Row(
              children: [
                // DATE

                _DateCard(
                  date: date,
                ),

                const SizedBox(width: 10),

                // DOCTOR IMAGE

                _DoctorAvatar(
                  imageUrl: imageUrl,
                ),

                const SizedBox(width: 9),

                // DETAILS

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              doctorName,

                              maxLines: 1,

                              overflow:
                                  TextOverflow
                                      .ellipsis,

                              style:
                                  const TextStyle(
                                fontSize: 14,
                                color:
                                    Color(
                                  0xFF151D3D,
                                ),
                                fontWeight:
                                    FontWeight
                                        .w800,
                                letterSpacing:
                                    -.25,
                              ),
                            ),
                          ),

                          const SizedBox(width: 4),

                          const Icon(
                            Icons
                                .verified_rounded,
                            color:
                                Color(
                              0xFF08A78B,
                            ),
                            size: 15,
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      Text(
                        specialization,

                        maxLines: 1,

                        overflow:
                            TextOverflow
                                .ellipsis,

                        style:
                            const TextStyle(
                          fontSize: 10.5,
                          color:
                              Color(
                            0xFF697394,
                          ),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 9,
                        runSpacing: 5,

                        children: [
                          _InfoItem(
                            icon: Icons
                                .access_time_rounded,

                            text:
                                appointment.startTime,
                          ),

                          _InfoItem(
                            icon: _getVisitIcon(),

                            text: visitType,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 7),

                // ACTION BUTTON

                Container(
                  width: 34,
                  height: 34,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    gradient:
                        const LinearGradient(
                      begin:
                          Alignment.topLeft,

                      end:
                          Alignment.bottomRight,

                      colors: [
                        Color(0xFF0CB49A),
                        Color(0xFF078D7A),
                      ],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(
                          0xFF079F87,
                        ).withOpacity(.18),

                        blurRadius: 8,

                        offset:
                            const Offset(
                          0,
                          3,
                        ),
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

            // =====================================================
            // PACKAGE INFORMATION
            // =====================================================

            if (_hasPackage()) ...[
              const SizedBox(height: 13),

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(.72),

                  borderRadius:
                      BorderRadius.circular(12),

                  border: Border.all(
                    color: const Color(
                      0xFFDDECEA,
                    ),
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 29,
                      height: 29,

                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFE6F8F3,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          9,
                        ),
                      ),

                      child: const Icon(
                        Icons
                            .confirmation_number_rounded,
                        size: 15,
                        color:
                            Color(
                          0xFF078D7A,
                        ),
                      ),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          const Text(
                            'Your Care Package',
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  Color(
                                0xFF697394,
                              ),
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            _packageText(),

                            style:
                                const TextStyle(
                              fontSize: 12,
                              color:
                                  Color(
                                0xFF182142,
                              ),
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons
                          .chevron_right_rounded,
                      color:
                          Color(0xFF7B879E),
                      size: 19,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // DATA HELPERS
  // ==============================================================

  String _getDoctorName() {
    final name =
        appointment.physiotherapistName;

    if (name.trim().isNotEmpty) {
      return name;
    }

    return 'Physiotherapist';
  }

  String _getSpecialization() {
    final specialization =
        appointment.physiotherapistSpecialization;

    if (specialization.trim().isNotEmpty) {
      return specialization;
    }

    return 'Physiotherapy Specialist';
  }

  String? _getImageUrl() {
    final image =
        appointment.physiotherapistImageUrl;

    if (image == null ||
        image.trim().isEmpty) {
      return null;
    }

    return image;
  }

  String _getVisitType() {
    // IMPORTANT:
    // Change these values only if your model
    // uses different visit type names.

    final type =
        appointment.appointmentType
    .toString()
    .toLowerCase();

    if (type.contains('clinic')) {
      return 'Clinic Visit';
    }

    if (type.contains('online')) {
      return 'Online';
    }

    return 'At Home';
  }

  IconData _getVisitIcon() {
    final type =
        appointment.appointmentType
    .toString()
    .toLowerCase();

    if (type.contains('clinic')) {
      return Icons
          .local_hospital_outlined;
    }

    if (type.contains('online')) {
      return Icons
          .videocam_outlined;
    }

    return Icons
        .home_work_outlined;
  }

  String _getStatus() {
    final status =
        appointment.status
            .trim()
            .toLowerCase();

    if (status.isEmpty) {
      return 'Confirmed';
    }

    switch (status) {
      case 'pending':
        return 'Pending';

      case 'confirmed':
        return 'Confirmed';

      case 'assigned':
        return 'Assigned';

      case 'checkedin':
        return 'Checked In';

      case 'inprogress':
        return 'In Progress';

      case 'rescheduled':
        return 'Rescheduled';

      default:
        return _capitalize(status);
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }

  bool _hasPackage() {
    return appointment.isPackageBooking;
  }

  String _packageText() {
    final total =
        appointment.totalSessions ?? 0;

    final remaining =
        appointment.remainingSessions ?? 0;

    if (total <= 0) {
      return 'Package session';
    }

    return '$remaining of $total visits remaining';
  }
}

// =================================================================
// STATUS BADGE
// =================================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor =
            const Color(0xFFFFF6E4);

        borderColor =
            const Color(0xFFF8DEAA);

        textColor =
            const Color(0xFFC58A14);

        icon =
            Icons.access_time_rounded;

        break;

      case 'assigned':
        backgroundColor =
            const Color(0xFFEAF2FF);

        borderColor =
            const Color(0xFFD3E2FF);

        textColor =
            const Color(0xFF3973C8);

        icon =
            Icons.person_rounded;

        break;

      case 'rescheduled':
        backgroundColor =
            const Color(0xFFF2EEFF);

        borderColor =
            const Color(0xFFE0D8FF);

        textColor =
            const Color(0xFF7656B8);

        icon =
            Icons.event_repeat_rounded;

        break;

      case 'in progress':
        backgroundColor =
            const Color(0xFFE9F7FF);

        borderColor =
            const Color(0xFFCFEAF8);

        textColor =
            const Color(0xFF2580AA);

        icon =
            Icons.play_circle_rounded;

        break;

      default:
        backgroundColor =
            const Color(0xFFE7F8F3);

        borderColor =
            const Color(0xFFC9EDE3);

        textColor =
            const Color(0xFF008F78);

        icon =
            Icons.check_circle_rounded;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: backgroundColor,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: borderColor,
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            icon,
            size: 11,
            color: textColor,
          ),

          const SizedBox(width: 4),

          Text(
            status,

            style: TextStyle(
              fontSize: 9,
              color: textColor,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// DATE CARD
// =================================================================

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.date,
  });

  final DateTime date;

  static const List<String> _weekdays = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  static const List<String> _months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  @override
  Widget build(BuildContext context) {
    final weekday =
        _weekdays[date.weekday - 1];

    final month =
        _months[date.month - 1];

    return Container(
      width: 52,
      height: 68,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(15),

        border: Border.all(
          color:
              const Color(0xFFE1E8E8),
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF30415E,
            ).withOpacity(.045),

            blurRadius: 10,

            offset:
                const Offset(0, 4),
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
              color:
                  Color(0xFF0C967E),
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            '${date.day}',

            style: const TextStyle(
              fontSize: 23,
              height: 1,
              color:
                  Color(0xFF087F75),
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            month,

            style: const TextStyle(
              fontSize: 7.5,
              color:
                  Color(0xFF6D7690),
              fontWeight:
                  FontWeight.w700,
              letterSpacing: .4,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// DOCTOR AVATAR
// =================================================================

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({
    this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,

      padding:
          const EdgeInsets.all(2.5),

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: Colors.white,

        border: Border.all(
          color:
              const Color(0xFFDCE6EA),
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF31546A,
            ).withOpacity(.06),

            blurRadius: 10,

            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
                imageUrl!,

                fit: BoxFit.cover,

                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return _fallback();
                },
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color:
          const Color(0xFFEAF3F4),

      child: const Icon(
        Icons.person_rounded,
        color:
            Color(0xFF6B8490),
        size: 30,
      ),
    );
  }
}

// =================================================================
// INFO ITEM
// =================================================================

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,

      children: [
        Icon(
          icon,
          size: 13,
          color:
              const Color(0xFF53628A),
        ),

        const SizedBox(width: 4),

        Text(
          text,

          style: const TextStyle(
            fontSize: 10,
            color:
                Color(0xFF465274),
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// LOADING STATE
// =================================================================

class _UpcomingAppointmentLoading
    extends StatelessWidget {
  const _UpcomingAppointmentLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 125,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              const Color(0xFFE2E8F0),
        ),
      ),

      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,

          child:
              CircularProgressIndicator(
            strokeWidth: 2.5,
            color:
                Color(0xFF079F87),
          ),
        ),
      ),
    );
  }
}

// =================================================================
// NO UPCOMING APPOINTMENT
// =================================================================

class _NoUpcomingAppointment
    extends StatelessWidget {
  const _NoUpcomingAppointment({
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding:
            const EdgeInsets.all(18),

        decoration: BoxDecoration(
          gradient:
              const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF4FBFA),
              Color(0xFFF9FCFF),
            ],
          ),

          borderRadius:
              BorderRadius.circular(20),

          border: Border.all(
            color:
                const Color(0xFFDCEFED),
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color:
                    const Color(0xFFE4F7F3),

                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),

              child: const Icon(
                Icons
                    .calendar_month_rounded,
                color:
                    Color(0xFF079F87),
                size: 24,
              ),
            ),

            const SizedBox(width: 13),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    'No upcoming appointment',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          Color(
                        0xFF172040,
                      ),
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Book a physiotherapy session and start your recovery journey.',
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.4,
                      color:
                          Color(
                        0xFF697394,
                      ),
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons
                  .arrow_forward_ios_rounded,
              size: 16,
              color:
                  Color(0xFF079F87),
            ),
          ],
        ),
      ),
    );
  }
}