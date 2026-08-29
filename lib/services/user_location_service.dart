import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/user_location_model.dart';

class UserLocationService {
  const UserLocationService();

  // ==============================================================
  // GET CURRENT USER LOCATION
  // ==============================================================

  Future<UserLocationModel> getCurrentLocation() async {
    // ------------------------------------------------------------
    // CHECK WHETHER LOCATION SERVICE IS ENABLED
    // ------------------------------------------------------------

    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    // ------------------------------------------------------------
    // CHECK PERMISSION
    // ------------------------------------------------------------

    LocationPermission permission =
        await Geolocator.checkPermission();

    // ------------------------------------------------------------
    // REQUEST PERMISSION IF DENIED
    // ------------------------------------------------------------

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    // ------------------------------------------------------------
    // PERMISSION STILL DENIED
    // ------------------------------------------------------------

    if (permission == LocationPermission.denied) {
      throw const LocationPermissionDeniedException();
    }

    // ------------------------------------------------------------
    // PERMISSION DENIED FOREVER
    // ------------------------------------------------------------

    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionDeniedForeverException();
    }

    // ------------------------------------------------------------
    // GET GPS POSITION
    // ------------------------------------------------------------

    final position =
        await Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    // ------------------------------------------------------------
    // CONVERT GPS → ADDRESS
    // ------------------------------------------------------------

    return _locationFromCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
      isCurrentLocation: true,
    );
  }

  // ==============================================================
  // CREATE LOCATION FROM COORDINATES
  // ==============================================================

  Future<UserLocationModel> getLocationFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    return _locationFromCoordinates(
      latitude: latitude,
      longitude: longitude,
      isCurrentLocation: false,
    );
  }

  // ==============================================================
  // REVERSE GEOCODING
  // ==============================================================

  Future<UserLocationModel> _locationFromCoordinates({
    required double latitude,
    required double longitude,
    required bool isCurrentLocation,
  }) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return UserLocationModel(
          name: 'Selected location',
          latitude: latitude,
          longitude: longitude,
          isCurrentLocation: isCurrentLocation,
        );
      }

      final place = placemarks.first;

      // ----------------------------------------------------------
      // EXTRACT LOCATION DETAILS
      // ----------------------------------------------------------

      final locality = _clean(
        place.subLocality,
      );

      final city = _firstNonEmpty([
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
      ]);

      final state = _clean(
        place.administrativeArea,
      );

      final country = _clean(
        place.country,
      );

      final name = _buildLocationName(
        locality: locality,
        city: city,
        state: state,
      );

      return UserLocationModel(
        name: name,
        locality: locality,
        city: city,
        state: state,
        country: country,
        latitude: latitude,
        longitude: longitude,
        isCurrentLocation: isCurrentLocation,
      );
    } catch (_) {
      // ----------------------------------------------------------
      // FALLBACK IF REVERSE GEOCODING FAILS
      // ----------------------------------------------------------

      return UserLocationModel(
        name: 'Current location',
        latitude: latitude,
        longitude: longitude,
        isCurrentLocation: isCurrentLocation,
      );
    }
  }

  // ==============================================================
  // BUILD LOCATION NAME
  // ==============================================================

  String _buildLocationName({
    String? locality,
    String? city,
    String? state,
  }) {
    final parts = <String>[];

    if (locality != null &&
        locality.isNotEmpty) {
      parts.add(locality);
    }

    if (city != null &&
        city.isNotEmpty &&
        !parts.contains(city)) {
      parts.add(city);
    }

    if (state != null &&
        state.isNotEmpty &&
        !parts.contains(state)) {
      parts.add(state);
    }

    if (parts.isEmpty) {
      return 'Selected location';
    }

    return parts.join(', ');
  }

  // ==============================================================
  // FIRST NON EMPTY VALUE
  // ==============================================================

  String? _firstNonEmpty(
    List<String?> values,
  ) {
    for (final value in values) {
      final cleaned = _clean(value);

      if (cleaned != null) {
        return cleaned;
      }
    }

    return null;
  }

  // ==============================================================
  // CLEAN STRING
  // ==============================================================

  String? _clean(
    String? value,
  ) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  // ==============================================================
  // OPEN LOCATION SETTINGS
  // ==============================================================

  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  // ==============================================================
  // OPEN APP SETTINGS
  // ==============================================================

  Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }
}

// ================================================================
// CUSTOM EXCEPTIONS
// ================================================================

class LocationServiceDisabledException
    implements Exception {
  const LocationServiceDisabledException();

  @override
  String toString() {
    return 'Location services are disabled.';
  }
}

class LocationPermissionDeniedException
    implements Exception {
  const LocationPermissionDeniedException();

  @override
  String toString() {
    return 'Location permission was denied.';
  }
}

class LocationPermissionDeniedForeverException
    implements Exception {
  const LocationPermissionDeniedForeverException();

  @override
  String toString() {
    return 'Location permission is permanently denied.';
  }
}