import 'package:flutter/material.dart';

class NeedHelp extends StatelessWidget {
  final VoidCallback? onChatTap;

  const NeedHelp({
    super.key,
    this.onChatTap,
  });

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
            Color(0xFFF0F5FF),
            Color(0xFFF7F4FF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE1E5F5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF33416D)
                .withOpacity(.035),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ======================================================
          // SUPPORT ICON
          // ======================================================

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5B6DED),
                  Color(0xFF7259E8),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B62E8)
                      .withOpacity(.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.headset_mic_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 10),

          // ======================================================
          // TEXT
          // ======================================================

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help?',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF151D3D),
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'We’re here to help with your recovery',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.8,
                    color: Color(0xFF737C99),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ======================================================
          // CHAT BUTTON
          // ======================================================

          GestureDetector(
            onTap: onChatTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFFE0E3F2),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF5146D9),
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: Color(0xFF5146D9),
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