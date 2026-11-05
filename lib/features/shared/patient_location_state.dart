import 'package:flutter/foundation.dart';

import '../../models/user_location_model.dart';

/// Shared patient location and condition hand-off between Home and Explore.
///
/// Keeps the selected location alive while the patient moves between tabs
/// or pushes Explore from the Home condition cards.
class PatientLocationState {
  PatientLocationState._();

  static final ValueNotifier<UserLocationModel?> location =
      ValueNotifier<UserLocationModel?>(null);

  static String? pendingCondition;

  static void setLocation(UserLocationModel value) {
    location.value = value;
  }

  static void openCondition(String? conditionId) {
    pendingCondition = conditionId;
  }

  static String? consumeCondition() {
    final value = pendingCondition;
    pendingCondition = null;
    return value;
  }
}
