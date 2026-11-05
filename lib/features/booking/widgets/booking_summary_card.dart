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
  final int? originalPrice;
  final int? savings;
  final double? discountPercent;
  final double? sessionPrice;

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
    this.originalPrice,
    this.savings,
    this.discountPercent,
    this.sessionPrice,
  });

  static const _ink = Color(0xFF111A3D);
  static const _muted = Color(0xFF7A839A);
  static const _line = Color(0xFFE8EBF2);
  static const _primary = Color(0xFF5146D9);
  static const _green = Color(0xFF159B7A);

  ImageProvider<Object>? _imageProvider() {
    final value = doctorImage.trim();
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      return NetworkImage(value);
    }
    return AssetImage(value);
  }

  @override
  Widget build(BuildContext context) {
    final image = _imageProvider();
    final base = originalPrice ?? price;
    final discount = savings ?? (base - price).clamp(0, base);
    final hasDiscount = discount > 0 && base > price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review your booking',
          style: TextStyle(
            color: _ink,
            fontSize: 19,
            fontWeight: FontWeight.w900,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Make sure the appointment and recovery plan look right.',
          style: TextStyle(
            color: _muted,
            fontSize: 10.5,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _line),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D2A54).withOpacity(.055),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEDEBFF), Color(0xFFE7F8F3)],
                      ),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: image == null
                        ? const Icon(Icons.person_rounded, size: 31, color: _primary)
                        : Image(
                            image: image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person_rounded,
                              size: 31,
                              color: _primary,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          specialty,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 10,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Row(
                          children: [
                            Icon(Icons.verified_rounded, color: _green, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'Verified physiotherapist',
                              style: TextStyle(
                                color: _green,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              const Divider(height: 1, color: _line),
              const SizedBox(height: 15),
              const _SummarySectionLabel(
                icon: Icons.calendar_month_rounded,
                label: 'APPOINTMENT DETAILS',
              ),
              const SizedBox(height: 11),
              _SummaryRow(
                icon: Icons.event_rounded,
                label: 'Date',
                value: date,
              ),
              const SizedBox(height: 10),
              _SummaryRow(
                icon: Icons.schedule_rounded,
                label: 'Time',
                value: time,
              ),
              const SizedBox(height: 10),
              _SummaryRow(
                icon: visitType == 'Home Visit'
                    ? Icons.home_rounded
                    : Icons.local_hospital_rounded,
                label: 'Care format',
                value: visitType,
              ),
              const SizedBox(height: 17),
              const Divider(height: 1, color: _line),
              const SizedBox(height: 15),
              const _SummarySectionLabel(
                icon: Icons.auto_awesome_rounded,
                label: 'RECOVERY PLAN',
              ),
              const SizedBox(height: 11),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF2F0FF), Color(0xFFEAF8F4)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E5F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        color: _primary,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            packageTitle,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$visits ${visits == 1 ? 'session' : 'sessions'} included'
                            '${sessionPrice == null ? '' : ' • ₹${sessionPrice!.toStringAsFixed(0)} per session before package discount'}',
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 9,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, color: _green, size: 19),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              const Divider(height: 1, color: _line),
              const SizedBox(height: 15),
              const _SummarySectionLabel(
                icon: Icons.receipt_long_rounded,
                label: 'PRICE BREAKDOWN',
              ),
              const SizedBox(height: 13),
              _PriceLine(
                label: 'Package subtotal',
                value: '₹${base.toStringAsFixed(0)}',
              ),
              if (hasDiscount) ...[
                const SizedBox(height: 9),
                _PriceLine(
                  label: discountPercent == null
                      ? 'Package savings'
                      : 'Package discount (${discountPercent!.toStringAsFixed(0)}%)',
                  value: '−₹${discount.toStringAsFixed(0)}',
                  valueColor: _green,
                ),
              ],
              const SizedBox(height: 9),
              const _PriceLine(
                label: 'Platform fee',
                value: '₹0',
                valueColor: _green,
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 1,
                color: _line,
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking total',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Final amount from your selected package',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: _green,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.7,
                    ),
                  ),
                ],
              ),
              if (hasDiscount) ...[
                const SizedBox(height: 11),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.savings_rounded, color: _green, size: 15),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'You save ₹${discount.toStringAsFixed(0)} with this package.',
                          style: const TextStyle(
                            color: Color(0xFF087F68),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SummarySectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummarySectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF5146D9)),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7A839A),
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: .9,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
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
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F0FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 15, color: const Color(0xFF5146D9)),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF858DA2),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF151D3D),
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _PriceLine({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF151D3D),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF737C94),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
