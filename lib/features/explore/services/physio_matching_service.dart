import 'dart:math';

import '../../../models/physiotherapist_model.dart';
import '../../../models/user_location_model.dart';
import '../models/physio_match_model.dart';

// ================================================================
// PHYSIO MATCHING SERVICE
// ================================================================
//
// Calculates:
//
// ✓ Distance from user
// ✓ Home visit availability
// ✓ Specialization match
// ✓ Condition match
// ✓ Experience score
// ✓ Rating score placeholder
// ✓ Final match score
//
// ================================================================

class PhysioMatchingService {
  const PhysioMatchingService();

  // ==============================================================
  // MAIN MATCHING METHOD
  // ==============================================================

  List<PhysioMatchModel> getMatches({
    required List<PhysiotherapistModel> physiotherapists,
    required UserLocationModel userLocation,
    String? selectedCondition,
    String searchQuery = '',
  }) {
    final matches = <PhysioMatchModel>[];

    for (final physio in physiotherapists) {
      // ----------------------------------------------------------
      // ONLY ACTIVE PHYSIOTHERAPISTS
      // ----------------------------------------------------------

      if (!physio.isActive) {
        continue;
      }

      // ----------------------------------------------------------
      // CALCULATE DISTANCE
      // ----------------------------------------------------------

      final distanceKm = _calculateDistanceKm(
        userLatitude: userLocation.latitude,
        userLongitude: userLocation.longitude,
        physioLatitude: physio.latitude,
        physioLongitude: physio.longitude,
      );

      // ----------------------------------------------------------
      // HOME VISIT AVAILABILITY
      // ----------------------------------------------------------

      final withinHomeVisitRange =
          physio.homeVisitEnabled &&
              distanceKm <= physio.homeVisitRadiusKm;

      // ----------------------------------------------------------
      // SEARCH FILTER
      // ----------------------------------------------------------

      if (!_matchesSearch(
        physio: physio,
        query: searchQuery,
      )) {
        continue;
      }

      // ----------------------------------------------------------
      // SPECIALIZATION MATCH
      // ----------------------------------------------------------

      final specializationMatched =
          _matchesConditionOrSpecialization(
        physio: physio,
        condition: selectedCondition,
      );

      // ----------------------------------------------------------
      // CONDITION MATCH
      // ----------------------------------------------------------

      final conditionMatched =
          specializationMatched;

      // ----------------------------------------------------------
      // SCORES
      // ----------------------------------------------------------

      final distanceScore =
          _calculateDistanceScore(distanceKm);

      final specializationScore =
          specializationMatched ? 25.0 : 0.0;

      final conditionScore =
          conditionMatched ? 25.0 : 0.0;

      final experienceScore =
          _calculateExperienceScore(
        physio.experienceYears,
      );

      // ----------------------------------------------------------
      // RATING SCORE
      //
      // Rating will be connected when reviews are implemented.
      // ----------------------------------------------------------

      const ratingScore = 10.0;

      // ----------------------------------------------------------
      // HOME VISIT BONUS
      // ----------------------------------------------------------

      final homeVisitScore =
          withinHomeVisitRange ? 10.0 : 0.0;

      // ----------------------------------------------------------
      // FINAL SCORE
      // ----------------------------------------------------------

      final matchScore =
          distanceScore +
              specializationScore +
              conditionScore +
              experienceScore +
              ratingScore +
              homeVisitScore;

      matches.add(
        PhysioMatchModel(
          physiotherapist: physio,

          distanceKm: distanceKm,

          specializationMatched:
              specializationMatched,

          conditionMatched:
              conditionMatched,

          withinHomeVisitRange:
              withinHomeVisitRange,

          distanceScore:
              distanceScore,

          specializationScore:
              specializationScore,

          conditionScore:
              conditionScore,

          experienceScore:
              experienceScore,

          ratingScore:
              ratingScore,

          matchScore:
              matchScore.clamp(0.0, 100.0),
        ),
      );
    }

    // ============================================================
    // SORT BEST MATCH FIRST
    // ============================================================

    matches.sort(
      (a, b) {
        final scoreComparison =
            b.matchScore.compareTo(a.matchScore);

        if (scoreComparison != 0) {
          return scoreComparison;
        }

        return a.distanceKm.compareTo(
          b.distanceKm,
        );
      },
    );

    return matches;
  }

  // ==============================================================
  // HAVERSINE DISTANCE
  // ==============================================================

  double _calculateDistanceKm({
    required double userLatitude,
    required double userLongitude,
    required double physioLatitude,
    required double physioLongitude,
  }) {
    const earthRadiusKm = 6371.0;

    final latDistance =
        _degreesToRadians(
      physioLatitude - userLatitude,
    );

    final lonDistance =
        _degreesToRadians(
      physioLongitude - userLongitude,
    );

    final a =
        sin(latDistance / 2) *
                sin(latDistance / 2) +
            cos(
                  _degreesToRadians(
                    userLatitude,
                  ),
                ) *
                cos(
                  _degreesToRadians(
                    physioLatitude,
                  ),
                ) *
                sin(lonDistance / 2) *
                sin(lonDistance / 2);

    final c =
        2 *
            atan2(
              sqrt(a),
              sqrt(1 - a),
            );

    return earthRadiusKm * c;
  }

  // ==============================================================
  // DEGREES → RADIANS
  // ==============================================================

  double _degreesToRadians(
    double degrees,
  ) {
    return degrees * pi / 180;
  }

  // ==============================================================
  // DISTANCE SCORE
  // ==============================================================

  double _calculateDistanceScore(
    double distanceKm,
  ) {
    if (distanceKm <= 2) {
      return 20.0;
    }

    if (distanceKm <= 5) {
      return 17.0;
    }

    if (distanceKm <= 10) {
      return 13.0;
    }

    if (distanceKm <= 20) {
      return 8.0;
    }

    if (distanceKm <= 50) {
      return 4.0;
    }

    return 1.0;
  }

  // ==============================================================
  // EXPERIENCE SCORE
  // ==============================================================

  double _calculateExperienceScore(
    int experienceYears,
  ) {
    if (experienceYears >= 15) {
      return 10.0;
    }

    if (experienceYears >= 10) {
      return 8.0;
    }

    if (experienceYears >= 5) {
      return 6.0;
    }

    if (experienceYears >= 2) {
      return 4.0;
    }

    return 2.0;
  }

  // ==============================================================
  // SEARCH MATCH
  // ==============================================================

  bool _matchesSearch({
    required PhysiotherapistModel physio,
    required String query,
  }) {
    final normalizedQuery =
        query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return true;
    }

    final searchableText = [
      physio.fullName,
      physio.primarySpecialization,
      ...physio.specializations,
      physio.city,
      physio.state,
    ].join(' ').toLowerCase();

    return searchableText.contains(
      normalizedQuery,
    );
  }

  // ==============================================================
  // CONDITION / SPECIALIZATION MATCH
  // ==============================================================

  bool _matchesConditionOrSpecialization({
    required PhysiotherapistModel physio,
    required String? condition,
  }) {
    if (condition == null ||
        condition.trim().isEmpty) {
      return false;
    }

    final normalizedCondition =
        condition.toLowerCase().trim();

    final specializations = [
      physio.primarySpecialization,
      ...physio.specializations,
    ].map(
      (value) => value.toLowerCase(),
    );

    // ------------------------------------------------------------
    // DIRECT MATCH
    // ------------------------------------------------------------

    if (specializations.any(
      (specialization) =>
          specialization.contains(
            normalizedCondition,
          ) ||
          normalizedCondition.contains(
            specialization,
          ),
    )) {
      return true;
    }

    // ------------------------------------------------------------
    // CONDITION → SPECIALIZATION MAPPING
    // ------------------------------------------------------------

    final conditionMap =
        <String, List<String>>{
      'back pain': [
        'orthopedic',
        'musculoskeletal',
        'sports',
      ],

      'neck pain': [
        'orthopedic',
        'musculoskeletal',
      ],

      'knee pain': [
        'orthopedic',
        'sports',
        'musculoskeletal',
      ],

      'shoulder pain': [
        'orthopedic',
        'sports',
        'musculoskeletal',
      ],

      'sports injury': [
        'sports',
        'orthopedic',
      ],

      'stroke rehabilitation': [
        'neurological',
        'neuro',
      ],

      'parkinson': [
        'neurological',
        'neuro',
      ],

      'post surgery': [
        'orthopedic',
        'rehabilitation',
      ],

      'arthritis': [
        'orthopedic',
        'musculoskeletal',
      ],

      'elderly care': [
        'geriatric',
        'rehabilitation',
      ],

      'child physiotherapy': [
        'pediatric',
        'paediatric',
      ],
    };

    final keywords =
        conditionMap[normalizedCondition];

    if (keywords == null) {
      return false;
    }

    return specializations.any(
      (specialization) {
        return keywords.any(
          (keyword) =>
              specialization.contains(keyword),
        );
      },
    );
  }
}