class UserLocationModel {
  final String name;
  final String? locality;
  final String? city;
  final String? state;
  final String? country;

  final double latitude;
  final double longitude;

  final bool isCurrentLocation;

  const UserLocationModel({
    required this.name,
    this.locality,
    this.city,
    this.state,
    this.country,
    required this.latitude,
    required this.longitude,
    this.isCurrentLocation = false,
  });

  // ==============================================================
  // DISPLAY LOCATION
  // ==============================================================

  String get displayName {
    final parts = <String>[];

    if (locality != null && locality!.trim().isNotEmpty) {
      parts.add(locality!.trim());
    }

    if (city != null && city!.trim().isNotEmpty) {
      if (!parts.contains(city!.trim())) {
        parts.add(city!.trim());
      }
    }

    if (state != null && state!.trim().isNotEmpty) {
      if (!parts.contains(state!.trim())) {
        parts.add(state!.trim());
      }
    }

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    return name;
  }

  // ==============================================================
  // SHORT DISPLAY NAME
  // ==============================================================

  String get shortDisplayName {
    if (locality != null && locality!.trim().isNotEmpty) {
      return locality!.trim();
    }

    if (city != null && city!.trim().isNotEmpty) {
      return city!.trim();
    }

    return name;
  }

  // ==============================================================
  // COPY WITH
  // ==============================================================

  UserLocationModel copyWith({
    String? name,
    String? locality,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    bool? isCurrentLocation,
  }) {
    return UserLocationModel(
      name: name ?? this.name,
      locality: locality ?? this.locality,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isCurrentLocation:
          isCurrentLocation ?? this.isCurrentLocation,
    );
  }

  // ==============================================================
  // FIRESTORE / MAP
  // ==============================================================

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'locality': locality,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'isCurrentLocation': isCurrentLocation,
    };
  }

  // ==============================================================
  // FROM MAP
  // ==============================================================

  factory UserLocationModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return UserLocationModel(
      name: (map['name'] ?? '').toString(),

      locality: map['locality']?.toString(),

      city: map['city']?.toString(),

      state: map['state']?.toString(),

      country: map['country']?.toString(),

      latitude: _parseDouble(
        map['latitude'],
      ),

      longitude: _parseDouble(
        map['longitude'],
      ),

      isCurrentLocation:
          map['isCurrentLocation'] == true,
    );
  }

  // ==============================================================
  // JSON ALIAS
  // ==============================================================

  Map<String, dynamic> toJson() {
    return toMap();
  }

  factory UserLocationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserLocationModel.fromMap(json);
  }

  // ==============================================================
  // HELPERS
  // ==============================================================

  static double _parseDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  // ==============================================================
  // DEBUG
  // ==============================================================

  @override
  String toString() {
    return '''
UserLocationModel(
  name: $name,
  locality: $locality,
  city: $city,
  state: $state,
  latitude: $latitude,
  longitude: $longitude,
  isCurrentLocation: $isCurrentLocation,
)
''';
  }
}