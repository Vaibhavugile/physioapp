import 'package:flutter/material.dart';

class RecoveryPackageCard extends StatelessWidget {
  final int visits;
  final String title;
  final String description;
  final int price;
  final int? savings;
  final bool selected;
  final bool popular;
  final bool bestValue;
  final VoidCallback? onTap;

  const RecoveryPackageCard({
    super.key,
    required this.visits,
    required this.title,
    required this.description,
    required this.price,
    this.savings,
    this.selected = false,
    this.popular = false,
    this.bestValue = false,
    this.onTap,
  });

  String get pricePerVisit {
    final value = price / visits;
    return '₹${value.round()} / visit';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF1EFFF),
                    Color(0xFFEAF9F6),
                  ],
                )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? const Color(0xFF6657E8)
                : const Color(0xFFE2E6EF),
            width: selected ? 1.4 : .9,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF5146D9)
                      .withOpacity(.11)
                  : const Color(0xFF26345C)
                      .withOpacity(.045),
              blurRadius: selected ? 20 : 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // TOP ROW
            // ======================================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PACKAGE ICON
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFEDEAFF),
                        Color(0xFFE7F9F5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    visits == 1
                        ? Icons
                            .calendar_today_rounded
                        : Icons
                            .auto_awesome_rounded,
                    size: 21,
                    color: selected
                        ? const Color(0xFF5146D9)
                        : const Color(0xFF5D64B7),
                  ),
                ),

                const SizedBox(width: 11),

                // TITLE
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color:
                                    Color(0xFF111A3D),
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: -.25,
                              ),
                            ),
                          ),

                          if (popular) ...[
                            const SizedBox(width: 6),
                            _Badge(
                              text: 'POPULAR',
                            ),
                          ],

                          if (bestValue) ...[
                            const SizedBox(width: 6),
                            _Badge(
                              text: 'BEST VALUE',
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        description,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.5,
                          height: 1.3,
                          color:
                              Color(0xFF6E7791),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // CHECK
                AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 180),
                  width: 23,
                  height: 23,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? const Color(0xFF079F87)
                        : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF079F87)
                          : const Color(0xFFD5D9E4),
                      width: selected ? 0 : 1.3,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ======================================================
            // PRICE
            // ======================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  '₹$price',
                  style: const TextStyle(
                    fontSize: 22,
                    color:
                        Color(0xFF111A3D),
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -.6,
                  ),
                ),

                const SizedBox(width: 6),

                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 2),
                  child: Text(
                    'total',
                    style: const TextStyle(
                      fontSize: 9.5,
                      color:
                          Color(0xFF7D859B),
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                const Spacer(),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(.82),
                    borderRadius:
                        BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          const Color(0xFFE0E3ED),
                    ),
                  ),
                  child: Text(
                    pricePerVisit,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color:
                          Color(0xFF079F87),
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            // ======================================================
            // SAVINGS
            // ======================================================

            if (savings != null && savings! > 0)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF9F5),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons
                          .local_offer_rounded,
                      size: 14,
                      color:
                          Color(0xFF079F87),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      'Save ₹$savings with this package',
                      style: const TextStyle(
                        fontSize: 9.5,
                        color:
                            Color(0xFF087F75),
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

            if (savings != null && savings! > 0)
              const SizedBox(height: 13),

            // ======================================================
            // BENEFITS
            // ======================================================

            _BenefitRow(
              icon: Icons
                  .person_search_rounded,
              text:
                  'Choose any physiotherapist',
            ),

            const SizedBox(height: 7),

            _BenefitRow(
              icon:
                  Icons.swap_horiz_rounded,
              text:
                  'Home or clinic for each visit',
            ),

            if (visits > 1) ...[
              const SizedBox(height: 7),

              _BenefitRow(
                icon:
                    Icons.calendar_month_rounded,
                text:
                    'Flexible appointment scheduling',
              ),
            ],

            const SizedBox(height: 14),

            // ======================================================
            // VISIT COUNT
            // ======================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(.65)
                    : const Color(0xFFF7F8FC),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons
                        .confirmation_number_outlined,
                    size: 15,
                    color: selected
                        ? const Color(0xFF5146D9)
                        : const Color(0xFF69728D),
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      visits == 1
                          ? '1 physiotherapy session'
                          : '$visits physiotherapy sessions',
                      style: const TextStyle(
                        fontSize: 9.5,
                        color:
                            Color(0xFF59627E),
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),

                  Text(
                    selected
                        ? 'Selected'
                        : 'Select plan',
                    style: TextStyle(
                      fontSize: 9,
                      color: selected
                          ? const Color(0xFF079F87)
                          : const Color(0xFF5146D9),
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ====================================================================
// BADGE
// ====================================================================

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6657E8),
            Color(0xFF5146D9),
          ],
        ),
        borderRadius:
            BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 6.5,
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: .25,
        ),
      ),
    );
  }
}


// ====================================================================
// BENEFIT ROW
// ====================================================================

class _BenefitRow
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color:
                const Color(0xFFF0F1FF),
            borderRadius:
                BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color:
                const Color(0xFF5146D9),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 9.5,
              color:
                  Color(0xFF626C86),
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),

        const Icon(
          Icons.check_rounded,
          size: 15,
          color:
              Color(0xFF079F87),
        ),
      ],
    );
  }
}