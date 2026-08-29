import 'package:flutter/material.dart';

class BookingSummaryCard extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String doctorImage;

  final String visitType;
  final String date;
  final String time;

  final String packageTitle;
  final int visits;
  final int price;

  const BookingSummaryCard({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.doctorImage,
    required this.visitType,
    required this.date,
    required this.time,
    required this.packageTitle,
    required this.visits,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // =========================================================
        // SECTION HEADER
        // =========================================================

        const Text(
          'Booking summary',
          style: TextStyle(
            fontSize: 15.5,
            color: Color(0xFF111A3D),
            fontWeight: FontWeight.w900,
            letterSpacing: -.3,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Review your appointment before continuing',
          style: TextStyle(
            fontSize: 10.5,
            color: Color(0xFF7A839A),
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        // =========================================================
        // MAIN SUMMARY CARD
        // =========================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color:
                  const Color(0xFFE3E6EF),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFF26345C)
                        .withOpacity(.05),
                blurRadius: 18,
                offset:
                    const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            children: [
              // ===================================================
              // DOCTOR
              // ===================================================

              Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(0xFFEDEBFF),
                          Color(0xFFE9F9F5),
                        ],
                      ),
                    ),
                    clipBehavior:
                        Clip.antiAlias,
                    child: Image.asset(
                      doctorImage,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons
                              .person_rounded,
                          size: 28,
                          color:
                              Color(0xFF5146D9),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 12.5,
                            color:
                                Color(0xFF111A3D),
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          specialty,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 9.5,
                            height: 1.25,
                            color:
                                Color(0xFF737C94),
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 5,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFEAF9F5,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        9,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .verified_rounded,
                          size: 12,
                          color:
                              Color(0xFF079F87),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Verified',
                          style:
                              TextStyle(
                            fontSize: 7.5,
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

              const SizedBox(height: 15),

              // ===================================================
              // DIVIDER
              // ===================================================

              const Divider(
                height: 1,
                color:
                    Color(0xFFE9EBF1),
              ),

              const SizedBox(height: 13),

              // ===================================================
              // APPOINTMENT DETAILS
              // ===================================================

              _SummaryRow(
                icon:
                    Icons.calendar_month_rounded,
                label: 'Date',
                value: date,
              ),

              const SizedBox(height: 11),

              _SummaryRow(
                icon:
                    Icons.access_time_rounded,
                label: 'Time',
                value: time,
              ),

              const SizedBox(height: 11),

              _SummaryRow(
                icon:
                    visitType ==
                            'Home Visit'
                        ? Icons.home_rounded
                        : Icons
                            .local_hospital_rounded,
                label: 'Care type',
                value: visitType,
              ),

              const SizedBox(height: 11),

              _SummaryRow(
                icon:
                    Icons
                        .auto_awesome_rounded,
                label: 'Recovery plan',
                value: packageTitle,
              ),

              const SizedBox(height: 15),

              // ===================================================
              // PACKAGE INFO
              // ===================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 10,
                ),
                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    begin:
                        Alignment.centerLeft,
                    end:
                        Alignment.centerRight,
                    colors: [
                      Color(0xFFF2F0FF),
                      Color(0xFFEAF9F6),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                  border: Border.all(
                    color:
                        const Color(
                      0xFFE1E3F0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 29,
                      height: 29,
                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withOpacity(.85),
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
                            Color(0xFF5146D9),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            '$visits ${visits == 1 ? 'session' : 'sessions'} included',
                            style:
                                const TextStyle(
                              fontSize: 9.5,
                              color:
                                  Color(
                                0xFF151D3D,
                              ),
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 2),

                          const Text(
                            'You can choose any physiotherapist for each visit',
                            maxLines: 2,
                            style:
                                TextStyle(
                              fontSize: 8.5,
                              height: 1.25,
                              color:
                                  Color(
                                0xFF737C94,
                              ),
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ===================================================
              // PRICE BREAKDOWN
              // ===================================================

              const Divider(
                height: 1,
                color:
                    Color(0xFFE9EBF1),
              ),

              const SizedBox(height: 13),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Consultation',
                      style:
                          TextStyle(
                        fontSize: 10,
                        color:
                            Color(0xFF737C94),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),

                  Text(
                    '₹$price',
                    style:
                        const TextStyle(
                      fontSize: 10.5,
                      color:
                          Color(0xFF151D3D),
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 9),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Platform fee',
                      style:
                          TextStyle(
                        fontSize: 10,
                        color:
                            Color(0xFF737C94),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),

                  const Text(
                    '₹0',
                    style:
                        TextStyle(
                      fontSize: 10.5,
                      color:
                          Color(0xFF079F87),
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Divider(
                height: 1,
                color:
                    Color(0xFFE9EBF1),
              ),

              const SizedBox(height: 12),

              // ===================================================
              // TOTAL
              // ===================================================

              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Total payable',
                          style:
                              TextStyle(
                            fontSize: 11.5,
                            color:
                                Color(
                              0xFF151D3D,
                            ),
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        SizedBox(height: 3),

                        Text(
                          'Inclusive of all applicable fees',
                          style:
                              TextStyle(
                            fontSize: 8.5,
                            color:
                                Color(
                              0xFF858DA2,
                            ),
                            fontWeight:
                                FontWeight.w600,
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
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}


// ====================================================================
// SUMMARY ROW
// ====================================================================

class _SummaryRow
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration:
              BoxDecoration(
            color:
                const Color(0xFFF2F1FF),
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

        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              color:
                  Color(0xFF858DA2),
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        Flexible(
          child: Text(
            value,
            textAlign:
                TextAlign.right,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color:
                  Color(0xFF151D3D),
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}