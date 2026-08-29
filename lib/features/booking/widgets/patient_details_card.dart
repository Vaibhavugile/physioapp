import 'package:flutter/material.dart';

class PatientDetailsCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  final bool isHomeVisit;

  const PatientDetailsCard({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.isHomeVisit,
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
          'Patient details',
          style: TextStyle(
            fontSize: 15.5,
            color: Color(0xFF111A3D),
            fontWeight: FontWeight.w900,
            letterSpacing: -.3,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Tell us who the appointment is for',
          style: TextStyle(
            fontSize: 10.5,
            color: Color(0xFF7A839A),
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        // =========================================================
        // CARD
        // =========================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
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
                        .withOpacity(.045),
                blurRadius: 17,
                offset:
                    const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // ===================================================
              // NAME
              // ===================================================

              _BookingTextField(
                controller: nameController,
                label: 'Full name',
                hint: 'Enter patient name',
                icon: Icons.person_outline_rounded,
                keyboardType:
                    TextInputType.name,
                textCapitalization:
                    TextCapitalization.words,
              ),

              const SizedBox(height: 11),

              // ===================================================
              // PHONE
              // ===================================================

              _BookingTextField(
                controller: phoneController,
                label: 'Mobile number',
                hint: 'Enter 10-digit mobile number',
                icon: Icons.phone_outlined,
                keyboardType:
                    TextInputType.phone,
              ),

              // ===================================================
              // HOME ADDRESS
              // ===================================================

              if (isHomeVisit) ...[
                const SizedBox(height: 11),

                _BookingTextField(
                  controller:
                      addressController,
                  label: 'Home address',
                  hint:
                      'Enter your complete address',
                  icon:
                      Icons.location_on_outlined,
                  keyboardType:
                      TextInputType.streetAddress,
                  maxLines: 3,
                ),
              ],

              const SizedBox(height: 12),

              // ===================================================
              // PRIVACY NOTE
              // ===================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFF7F8FC),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons
                          .lock_outline_rounded,
                      size: 15,
                      color:
                          Color(0xFF69728D),
                    ),

                    const SizedBox(width: 7),

                    const Expanded(
                      child: Text(
                        'Your information is kept secure and is only used for your appointment.',
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.3,
                          color:
                              Color(0xFF747D94),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
// BOOKING TEXT FIELD
// ====================================================================

class _BookingTextField
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  final TextInputType? keyboardType;
  final TextCapitalization
      textCapitalization;

  final int maxLines;

  const _BookingTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textCapitalization =
        TextCapitalization.none,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // =========================================================
        // LABEL
        // =========================================================

        Padding(
          padding:
              const EdgeInsets.only(
            left: 2,
            bottom: 6,
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color:
                  Color(0xFF59627E),
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),

        // =========================================================
        // FIELD
        // =========================================================

        Container(
          decoration: BoxDecoration(
            color:
                const Color(0xFFF9FAFC),
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color:
                  const Color(0xFFE4E7EF),
            ),
          ),

          child: TextField(
            controller: controller,

            keyboardType:
                keyboardType,

            textCapitalization:
                textCapitalization,

            maxLines: maxLines,

            style: const TextStyle(
              fontSize: 11,
              color:
                  Color(0xFF151D3D),
              fontWeight:
                  FontWeight.w700,
            ),

            decoration:
                InputDecoration(
              border:
                  InputBorder.none,

              enabledBorder:
                  InputBorder.none,

              focusedBorder:
                  InputBorder.none,

              contentPadding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 12,
                vertical: 12,
              ),

              prefixIcon: Padding(
                padding:
                    const EdgeInsets.only(
                  left: 11,
                  right: 3,
                ),

                child: Icon(
                  icon,
                  size: 18,
                  color:
                      const Color(
                    0xFF68718C,
                  ),
                ),
              ),

              prefixIconConstraints:
                  const BoxConstraints(
                minWidth: 35,
              ),

              hintText: hint,

              hintStyle:
                  const TextStyle(
                fontSize: 10,
                color:
                    Color(0xFF9AA1B2),
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}