import 'package:flutter/material.dart';

class FeesPricingStep extends StatefulWidget {
  final String currency;

  final double homeVisitFee;
  final double clinicVisitFee;
  final double onlineConsultationFee;
  final double followUpFee;

  final bool travelChargesEnabled;
  final double travelCharges;

  final bool discountAvailable;
  final double discountPercentage;

  final ValueChanged<String> onCurrencyChanged;

  final ValueChanged<double> onHomeVisitFeeChanged;
  final ValueChanged<double> onClinicVisitFeeChanged;
  final ValueChanged<double> onOnlineConsultationFeeChanged;
  final ValueChanged<double> onFollowUpFeeChanged;

  final ValueChanged<bool> onTravelChargesEnabledChanged;
  final ValueChanged<double> onTravelChargesChanged;

  final ValueChanged<bool> onDiscountAvailableChanged;
  final ValueChanged<double> onDiscountPercentageChanged;

  const FeesPricingStep({
    super.key,
    required this.currency,
    required this.homeVisitFee,
    required this.clinicVisitFee,
    required this.onlineConsultationFee,
    required this.followUpFee,
    required this.travelChargesEnabled,
    required this.travelCharges,
    required this.discountAvailable,
    required this.discountPercentage,
    required this.onCurrencyChanged,
    required this.onHomeVisitFeeChanged,
    required this.onClinicVisitFeeChanged,
    required this.onOnlineConsultationFeeChanged,
    required this.onFollowUpFeeChanged,
    required this.onTravelChargesEnabledChanged,
    required this.onTravelChargesChanged,
    required this.onDiscountAvailableChanged,
    required this.onDiscountPercentageChanged,
  });

  @override
  State<FeesPricingStep> createState() => _FeesPricingStepState();
}

class _FeesPricingStepState extends State<FeesPricingStep> {
  late TextEditingController _homeVisitController;
  late TextEditingController _clinicVisitController;
  late TextEditingController _onlineController;
  late TextEditingController _followUpController;
  late TextEditingController _travelController;
  late TextEditingController _discountController;

  @override
  void initState() {
    super.initState();

    _homeVisitController = TextEditingController(
      text: _formatNumber(widget.homeVisitFee),
    );

    _clinicVisitController = TextEditingController(
      text: _formatNumber(widget.clinicVisitFee),
    );

    _onlineController = TextEditingController(
      text: _formatNumber(widget.onlineConsultationFee),
    );

    _followUpController = TextEditingController(
      text: _formatNumber(widget.followUpFee),
    );

    _travelController = TextEditingController(
      text: _formatNumber(widget.travelCharges),
    );

    _discountController = TextEditingController(
      text: _formatNumber(widget.discountPercentage),
    );
  }

  @override
  void dispose() {
    _homeVisitController.dispose();
    _clinicVisitController.dispose();
    _onlineController.dispose();
    _followUpController.dispose();
    _travelController.dispose();
    _discountController.dispose();

    super.dispose();
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  double _parseValue(String value) {
    return double.tryParse(value.trim()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = _getCurrencySymbol(widget.currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =========================================================
        // HEADER
        // =========================================================

        const Text(
          'Fees & pricing',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111A3D),
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Set your consultation fees for different types of physiotherapy sessions.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF7B849C),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 26),

        // =========================================================
        // CURRENCY
        // =========================================================

        const _SectionHeader(
          title: 'Currency',
          subtitle: 'Select the currency used for your consultation fees.',
        ),

        const SizedBox(height: 14),

        DropdownButtonFormField<String>(
          value: widget.currency,
          decoration: _inputDecoration(
            hintText: 'Select currency',
            icon: Icons.currency_exchange_rounded,
          ),
          items: const [
            DropdownMenuItem(
              value: 'INR',
              child: Text('INR — Indian Rupee (₹)'),
            ),
            DropdownMenuItem(
              value: 'USD',
              child: Text('USD — US Dollar (\$)'),
            ),
            DropdownMenuItem(
              value: 'AED',
              child: Text('AED — UAE Dirham'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              widget.onCurrencyChanged(value);
            }
          },
        ),

        const SizedBox(height: 30),

        // =========================================================
        // CONSULTATION FEES
        // =========================================================

        const _SectionHeader(
          title: 'Consultation fees',
          subtitle: 'Set separate pricing for each service you offer.',
        ),

        const SizedBox(height: 16),

        _FeeInputCard(
          title: 'Home visit',
          subtitle: 'Physiotherapy session at the patient’s location',
          icon: Icons.home_outlined,
          controller: _homeVisitController,
          currencySymbol: currencySymbol,
          onChanged: (value) {
            widget.onHomeVisitFeeChanged(
              _parseValue(value),
            );
          },
        ),

        const SizedBox(height: 12),

        _FeeInputCard(
          title: 'Clinic appointment',
          subtitle: 'Session at your clinic or practice location',
          icon: Icons.local_hospital_outlined,
          controller: _clinicVisitController,
          currencySymbol: currencySymbol,
          onChanged: (value) {
            widget.onClinicVisitFeeChanged(
              _parseValue(value),
            );
          },
        ),

        const SizedBox(height: 12),

        _FeeInputCard(
          title: 'Online consultation',
          subtitle: 'Video consultation or virtual follow-up',
          icon: Icons.video_call_outlined,
          controller: _onlineController,
          currencySymbol: currencySymbol,
          onChanged: (value) {
            widget.onOnlineConsultationFeeChanged(
              _parseValue(value),
            );
          },
        ),

        const SizedBox(height: 12),

        _FeeInputCard(
          title: 'Follow-up session',
          subtitle: 'Follow-up treatment session for existing patients',
          icon: Icons.refresh_rounded,
          controller: _followUpController,
          currencySymbol: currencySymbol,
          onChanged: (value) {
            widget.onFollowUpFeeChanged(
              _parseValue(value),
            );
          },
        ),

        const SizedBox(height: 30),

        // =========================================================
        // TRAVEL CHARGES
        // =========================================================

        const _SectionHeader(
          title: 'Travel charges',
          subtitle: 'Optionally add extra charges for home visits.',
        ),

        const SizedBox(height: 15),

        _ToggleCard(
          icon: Icons.directions_car_outlined,
          title: 'Add travel charges',
          subtitle:
              'Charge an additional amount for travelling to the patient.',
          value: widget.travelChargesEnabled,
          onChanged: widget.onTravelChargesEnabledChanged,
        ),

        if (widget.travelChargesEnabled) ...[
          const SizedBox(height: 14),

          TextField(
            controller: _travelController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (value) {
              widget.onTravelChargesChanged(
                _parseValue(value),
              );
            },
            decoration: _inputDecoration(
              hintText: 'Enter travel charge',
              icon: Icons.directions_car_filled_outlined,
              prefixText: '$currencySymbol ',
            ),
          ),
        ],

        const SizedBox(height: 30),

        // =========================================================
        // DISCOUNT
        // =========================================================

        const _SectionHeader(
          title: 'Discounts',
          subtitle:
              'Offer an optional introductory discount to attract new patients.',
        ),

        const SizedBox(height: 15),

        _ToggleCard(
          icon: Icons.local_offer_outlined,
          title: 'Offer a discount',
          subtitle:
              'Enable a promotional discount for your services.',
          value: widget.discountAvailable,
          onChanged: widget.onDiscountAvailableChanged,
          activeColor: const Color(0xFF22A864),
        ),

        if (widget.discountAvailable) ...[
          const SizedBox(height: 14),

          TextField(
            controller: _discountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (value) {
              final discount = _parseValue(value);

              widget.onDiscountPercentageChanged(
                discount > 100 ? 100 : discount,
              );
            },
            decoration: _inputDecoration(
              hintText: 'Enter discount percentage',
              icon: Icons.percent_rounded,
              suffixText: '%',
            ),
          ),
        ],

        const SizedBox(height: 28),

        // =========================================================
        // PRICING SUMMARY
        // =========================================================

        _PricingSummary(
          currencySymbol: currencySymbol,
          homeVisitFee: widget.homeVisitFee,
          clinicVisitFee: widget.clinicVisitFee,
          onlineConsultationFee:
              widget.onlineConsultationFee,
          followUpFee: widget.followUpFee,
          travelChargesEnabled:
              widget.travelChargesEnabled,
          travelCharges: widget.travelCharges,
          discountAvailable:
              widget.discountAvailable,
          discountPercentage:
              widget.discountPercentage,
        ),

        const SizedBox(height: 22),

        // =========================================================
        // INFORMATION
        // =========================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFD5E4FF),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF246BFD),
              ),

              SizedBox(width: 11),

              Expanded(
                child: Text(
                  'You can update your fees later from your professional dashboard. Any future booking will use your latest published pricing.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF4B5B78),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';

      case 'AED':
        return 'AED';

      case 'INR':
      default:
        return '₹';
    }
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    String? prefixText,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      suffixText: suffixText,

      prefixIcon: Icon(
        icon,
        color: const Color(0xFF667085),
      ),

      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFF9AA3B5),
        fontWeight: FontWeight.w500,
      ),

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE1E6EF),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE1E6EF),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF246BFD),
          width: 1.5,
        ),
      ),
    );
  }
}

// ================================================================
// SECTION HEADER
// ================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111A3D),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            height: 1.45,
            color: Color(0xFF7B849C),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// FEE INPUT CARD
// ================================================================

class _FeeInputCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final TextEditingController controller;
  final String currencySymbol;
  final ValueChanged<String> onChanged;

  const _FeeInputCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.controller,
    required this.currencySymbol,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE1E6EF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF246BFD),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF27314D),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: Color(0xFF7B849C),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 105,
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              onChanged: onChanged,
              decoration: InputDecoration(
                prefixText: '$currencySymbol ',

                filled: true,
                fillColor: const Color(0xFFF7F9FC),

                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE1E6EF),
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE1E6EF),
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF246BFD),
                    width: 1.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// TOGGLE CARD
// ================================================================

class _ToggleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _ToggleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xFF246BFD),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: value
            ? activeColor.withValues(alpha: 0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: value
              ? activeColor.withValues(alpha: 0.35)
              : const Color(0xFFE1E6EF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: value
                  ? activeColor.withValues(alpha: 0.12)
                  : const Color(0xFFF3F6FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: value
                  ? activeColor
                  : const Color(0xFF59637A),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF27314D),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: Color(0xFF7B849C),
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: value,
            activeThumbColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// PRICING SUMMARY
// ================================================================

class _PricingSummary extends StatelessWidget {
  final String currencySymbol;

  final double homeVisitFee;
  final double clinicVisitFee;
  final double onlineConsultationFee;
  final double followUpFee;

  final bool travelChargesEnabled;
  final double travelCharges;

  final bool discountAvailable;
  final double discountPercentage;

  const _PricingSummary({
    required this.currencySymbol,
    required this.homeVisitFee,
    required this.clinicVisitFee,
    required this.onlineConsultationFee,
    required this.followUpFee,
    required this.travelChargesEnabled,
    required this.travelCharges,
    required this.discountAvailable,
    required this.discountPercentage,
  });

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    }

    return price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF111A3D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: Colors.white,
                size: 21,
              ),
              SizedBox(width: 9),
              Text(
                'Your pricing summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _SummaryRow(
            label: 'Home visit',
            value:
                '$currencySymbol ${_formatPrice(homeVisitFee)}',
          ),

          _SummaryRow(
            label: 'Clinic appointment',
            value:
                '$currencySymbol ${_formatPrice(clinicVisitFee)}',
          ),

          _SummaryRow(
            label: 'Online consultation',
            value:
                '$currencySymbol ${_formatPrice(onlineConsultationFee)}',
          ),

          _SummaryRow(
            label: 'Follow-up session',
            value:
                '$currencySymbol ${_formatPrice(followUpFee)}',
          ),

          if (travelChargesEnabled)
            _SummaryRow(
              label: 'Travel charge',
              value:
                  '$currencySymbol ${_formatPrice(travelCharges)}',
            ),

          if (discountAvailable)
            _SummaryRow(
              label: 'Discount',
              value:
                  '${discountPercentage.toStringAsFixed(0)}%',
              valueColor: const Color(0xFF74E7AA),
            ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFB8C1D9),
              fontWeight: FontWeight.w500,
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}