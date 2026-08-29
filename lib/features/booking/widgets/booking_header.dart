import 'package:flutter/material.dart';

class BookingHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackTap;
  final VoidCallback? onHelpTap;

  const BookingHeader({
    super.key,
    this.title = 'Confirm appointment',
    this.subtitle = 'Your care, your way',
    this.onBackTap,
    this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        // =========================================================
        // BACK BUTTON
        // =========================================================

        GestureDetector(
          onTap: onBackTap ??
              () {
                Navigator.of(context).pop();
              },
          behavior: HitTestBehavior.opaque,
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
                          .withOpacity(.055),
                  blurRadius: 14,
                  offset:
                      const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color:
                  Color(0xFF151D3D),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // =========================================================
        // TITLE
        // =========================================================

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  color:
                      Color(0xFF111A3D),
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: -.45,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
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

        const SizedBox(width: 10),

        // =========================================================
        // HELP BUTTON
        // =========================================================

        GestureDetector(
          onTap: onHelpTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 43,
            height: 43,
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
                  BorderRadius.circular(14),
              border: Border.all(
                color:
                    const Color(0xFFE0E2F0),
              ),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              size: 20,
              color:
                  Color(0xFF5146D9),
            ),
          ),
        ),
      ],
    );
  }
}