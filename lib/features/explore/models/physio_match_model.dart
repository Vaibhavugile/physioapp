import '../../../models/physiotherapist_model.dart';

// ================================================================
// PHYSIO MATCH MODEL
// ================================================================
//
// Combines a PhysiotherapistModel with calculated information:
//
// • Distance
// • Specialization match
// • Condition match
// • Experience
// • Rating
// • Final match score
//
// ================================================================

class PhysioMatchModel {
  final PhysiotherapistModel physiotherapist;

  // ==============================================================
  // DISTANCE
  // ==============================================================

  final double distanceKm;

  // ==============================================================
  // MATCHES
  // ==============================================================

  final bool specializationMatched;

  final bool conditionMatched;

  final bool withinHomeVisitRange;

  // ==============================================================
  // SCORES
  // ==============================================================

  final double distanceScore;

  final double specializationScore;

  final double conditionScore;

  final double experienceScore;

  final double ratingScore;

  // ==============================================================
  // FINAL SCORE
  // ==============================================================

  final double matchScore;

  const PhysioMatchModel({
    required this.physiotherapist,
    required this.distanceKm,
    required this.specializationMatched,
    required this.conditionMatched,
    required this.withinHomeVisitRange,
    required this.distanceScore,
    required this.specializationScore,
    required this.conditionScore,
    required this.experienceScore,
    required this.ratingScore,
    required this.matchScore,
  });

  // ==============================================================
  // CONVENIENCE GETTERS
  // ==============================================================

  String get uid => physiotherapist.uid;

  String get fullName => physiotherapist.fullName;

  String? get profileImageUrl =>
      physiotherapist.profileImageUrl;

  String get primarySpecialization =>
      physiotherapist.primarySpecialization;

  List<String> get specializations =>
      physiotherapist.specializations;

  int get experienceYears =>
      physiotherapist.experienceYears;

  bool get homeVisitEnabled =>
      physiotherapist.homeVisitEnabled;

  String get city => physiotherapist.city;

  String get state => physiotherapist.state;

  // ==============================================================
  // MATCH LABEL
  // ==============================================================

  String get matchLabel {
    if (matchScore >= 90) {
      return 'Perfect match';
    }

    if (matchScore >= 75) {
      return 'Best match';
    }

    if (matchScore >= 60) {
      return 'Good match';
    }

    return 'Available nearby';
  }

  // ==============================================================
  // DISTANCE LABEL
  // ==============================================================

  String get distanceLabel {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m away';
    }

    return '${distanceKm.toStringAsFixed(1)} km away';
  }

  // ==============================================================
  // MATCH PERCENTAGE
  // ==============================================================

  int get matchPercentage {
    return matchScore
        .clamp(0, 100)
        .round();
  }

  // ==============================================================
  // DEBUG
  // ==============================================================

  @override
  String toString() {
    return '''
PhysioMatchModel(
  name: $fullName,
  distance: $distanceKm km,
  specializationMatched: $specializationMatched,
  conditionMatched: $conditionMatched,
  matchScore: $matchScore
)
''';
  }
}