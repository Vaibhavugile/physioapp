import 'package:flutter/material.dart';
import '../pricing_config.dart';

/// Read-only pricing overview. No fee controllers or editable price fields.
class FeesPricingStep extends StatelessWidget {
  final int experienceYears;
  final String? city;
  final String? locality;

  const FeesPricingStep({
    super.key,
    required this.experienceYears,
    this.city,
    this.locality,
  });

  @override
  Widget build(BuildContext context) => PricingLocationSummary(
        city: city,
        locality: locality,
        experienceYears: experienceYears,
      );
}
