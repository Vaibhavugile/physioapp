import 'package:flutter/material.dart';

class ExploreSearch extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onLocationTap;

  const ExploreSearch({
    super.key,
    this.onFilterTap,
    this.onSearchChanged,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =========================================================
        // PREMIUM SEARCH BAR
        // =========================================================

        Container(
          width: double.infinity,
          height: 60,

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(20),

            border: Border.all(
              color: const Color(0xFFE4E7F0),
            ),

            boxShadow: [
              BoxShadow(
                color: const Color(0xFF202B50)
                    .withOpacity(.055),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Row(
            children: [
              const SizedBox(width: 12),

              // ===================================================
              // SEARCH ICON CONTAINER
              // ===================================================

              Container(
                width: 38,
                height: 38,

                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF1EFFF),
                      Color(0xFFF3F8FF),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.search_rounded,
                  size: 21,
                  color: Color(0xFF5146D9),
                ),
              ),

              const SizedBox(width: 10),

              // ===================================================
              // TEXT FIELD
              // ===================================================

              Expanded(
                child: TextField(
                  onChanged: onSearchChanged,

                  textInputAction:
                      TextInputAction.search,

                  textCapitalization:
                      TextCapitalization.sentences,

                  cursorColor:
                      const Color(0xFF5146D9),

                  decoration:
                      const InputDecoration(
                    border: InputBorder.none,

                    enabledBorder:
                        InputBorder.none,

                    focusedBorder:
                        InputBorder.none,

                    isDense: true,

                    contentPadding:
                        EdgeInsets.zero,

                    hintText:
                        'Search physios, conditions...',

                    hintStyle: TextStyle(
                      fontSize: 11.5,
                      color:
                          Color(0xFF9299AE),
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),

                  style: const TextStyle(
                    fontSize: 11.5,
                    color:
                        Color(0xFF151D3D),
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              // ===================================================
              // DIVIDER
              // ===================================================

              Container(
                width: 1,
                height: 28,

                color:
                    const Color(0xFFE8EAF1),
              ),

              const SizedBox(width: 7),

              // ===================================================
              // FILTER BUTTON
              // ===================================================

              GestureDetector(
                onTap: onFilterTap,

                behavior:
                    HitTestBehavior.opaque,

                child: Container(
                  width: 44,
                  height: 44,

                  margin:
                      const EdgeInsets.only(
                    right: 6,
                  ),

                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                      begin:
                          Alignment.topLeft,
                      end:
                          Alignment.bottomRight,
                      colors: [
                        Color(0xFF6D58EA),
                        Color(0xFF5146D9),
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(14),

                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(
                          0xFF5146D9,
                        ).withOpacity(.22),

                        blurRadius: 12,

                        offset:
                            const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // =========================================================
        // LOCATION CARD
        // =========================================================

        GestureDetector(
          onTap: onLocationTap,

          behavior:
              HitTestBehavior.opaque,

          child: Container(
            width: double.infinity,

            padding:
                const EdgeInsets.fromLTRB(
              12,
              11,
              12,
              11,
            ),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(18),

              border: Border.all(
                color:
                    const Color(0xFFE5E8F0),
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      const Color(0xFF202B50)
                          .withOpacity(.04),

                  blurRadius: 17,

                  offset:
                      const Offset(0, 6),
                ),
              ],
            ),

            child: Row(
              children: [
                // =================================================
                // LOCATION ICON
                // =================================================

                Container(
                  width: 38,
                  height: 38,

                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                      begin:
                          Alignment.topLeft,
                      end:
                          Alignment.bottomRight,
                      colors: [
                        Color(0xFFE6F9F4),
                        Color(0xFFEAF5FF),
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(12),
                  ),

                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 19,
                    color:
                        Color(0xFF079F87),
                  ),
                ),

                const SizedBox(width: 10),

                // =================================================
                // LOCATION DETAILS
                // =================================================

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'YOUR LOCATION',
                            style: TextStyle(
                              fontSize: 7,
                              color:
                                  Color(0xFF9299AE),
                              fontWeight:
                                  FontWeight.w800,
                              letterSpacing: .6,
                            ),
                          ),

                          SizedBox(width: 5),

                          // LIVE DOT
                          _LiveDot(),
                        ],
                      ),

                      SizedBox(height: 3),

                      Text(
                        'Pune, Maharashtra',
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              Color(0xFF151D3D),
                          fontWeight:
                              FontWeight.w800,
                          letterSpacing: -.1,
                        ),
                      ),
                    ],
                  ),
                ),

                // =================================================
                // CHANGE BUTTON
                // =================================================

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFF3F1FF),

                    borderRadius:
                        BorderRadius.circular(11),
                  ),

                  child: const Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        'Change',
                        style: TextStyle(
                          fontSize: 8,
                          color:
                              Color(0xFF5146D9),
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      SizedBox(width: 2),

                      Icon(
                        Icons
                            .chevron_right_rounded,
                        size: 15,
                        color:
                            Color(0xFF5146D9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


// ===============================================================
// LIVE LOCATION DOT
// ===============================================================

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,

      decoration:
          const BoxDecoration(
        color: Color(0xFF079F87),
        shape: BoxShape.circle,
      ),
    );
  }
}