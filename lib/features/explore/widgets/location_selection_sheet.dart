import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../../config/google_maps_config.dart';
import '../../../models/user_location_model.dart';
import '../../../services/user_location_service.dart';

class LocationSelectionSheet extends StatefulWidget {
  final UserLocationModel? selectedLocation;

  const LocationSelectionSheet({
    super.key,
    this.selectedLocation,
  });

  @override
  State<LocationSelectionSheet> createState() =>
      _LocationSelectionSheetState();
}

class _LocationSelectionSheetState
    extends State<LocationSelectionSheet> {
  // ==============================================================
  // SERVICES
  // ==============================================================

  final UserLocationService _locationService =
      const UserLocationService();

  // ==============================================================
  // CONTROLLERS
  // ==============================================================

  final TextEditingController _searchController =
      TextEditingController();

  // ==============================================================
  // STATE
  // ==============================================================

  bool _isGettingCurrentLocation = false;

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==============================================================
  // GET CURRENT LOCATION
  // ==============================================================

  Future<void> _useCurrentLocation() async {
    if (_isGettingCurrentLocation) return;

    setState(() {
      _isGettingCurrentLocation = true;
    });

    try {
      final location =
          await _locationService.getCurrentLocation();

      if (!mounted) return;

      Navigator.pop(
        context,
        location,
      );
    } on LocationServiceDisabledException {
      if (!mounted) return;

      _showLocationServiceDialog();
    } on LocationPermissionDeniedForeverException {
      if (!mounted) return;

      _showPermissionSettingsDialog();
    } on LocationPermissionDeniedException {
      if (!mounted) return;

      _showMessage(
        'Location permission was denied. Please allow permission to find physiotherapists near you.',
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Unable to get your current location. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGettingCurrentLocation = false;
        });
      }
    }
  }

  // ==============================================================
  // LOCATION SERVICE DISABLED
  // ==============================================================

  Future<void> _showLocationServiceDialog() async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Turn on location',
          ),
          content: const Text(
            'Please enable your device location to find the best physiotherapists near you.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await _locationService
                    .openLocationSettings();
              },
              child: const Text(
                'Open settings',
              ),
            ),
          ],
        );
      },
    );
  }

  // ==============================================================
  // PERMISSION DENIED FOREVER
  // ==============================================================

  Future<void> _showPermissionSettingsDialog() async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Location permission needed',
          ),
          content: const Text(
            'Location permission is disabled permanently. Please enable it from app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await _locationService
                    .openAppSettings();
              },
              child: const Text(
                'Open settings',
              ),
            ),
          ],
        );
      },
    );
  }

  // ==============================================================
  // SHOW MESSAGE
  // ==============================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.only(
          bottom: bottomInset,
        ),
        decoration: const BoxDecoration(
          color: const Color(0xFFFCFCFF),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ====================================================
            // HANDLE
            // ====================================================

            const SizedBox(height: 12),

            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD8DDEA),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 18),

            // ====================================================
            // HEADER
            // ====================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose your location',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111A3D),
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Find the best physiotherapists near you',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7B849C),
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // GOOGLE LOCATION SEARCH
            // ====================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child:
                  GooglePlaceAutoCompleteTextField(
                textEditingController:
                    _searchController,

                googleAPIKey:
                    GoogleMapsConfig.apiKey,

                debounceTime: 700,

                countries: const [
                  'in',
                ],

                isCrossBtnShown: true,

                inputDecoration: InputDecoration(
                  hintText:
                      'Search area, locality or city',

                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF5146D9),
                  ),

                  filled: true,

                  fillColor: const Color(0xFFF4F5FB),

                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),

                    borderSide: BorderSide.none,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),

                    borderSide:
                        const BorderSide(
                      color: Color(0xFFE7EAF2),
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),

                    borderSide:
                        const BorderSide(
                      color: Color(0xFF5146D9),
                      width: 1.6,
                    ),
                  ),
                ),

                itemClick: (
                  Prediction prediction,
                ) async {
                  if (prediction.lat == null ||
                      prediction.lng == null) {
                    _showMessage(
                      'Unable to get coordinates for this location.',
                    );
                    return;
                  }

                  final latitude =
                      double.tryParse(
                    prediction.lat!,
                  );

                  final longitude =
                      double.tryParse(
                    prediction.lng!,
                  );

                  if (latitude == null ||
                      longitude == null) {
                    _showMessage(
                      'Invalid location coordinates.',
                    );
                    return;
                  }

                  final location =
                      await _locationService
                          .getLocationFromCoordinates(
                    latitude: latitude,
                    longitude: longitude,
                  );

                  if (!mounted) return;

                  Navigator.pop(
                    context,
                    location,
                  );
                },

                itemBuilder: (
                  BuildContext context,
                  int index,
                  Prediction prediction,
                ) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFEAF0FF),
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color:
                                Color(0xFF2457F5),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            prediction.description ??
                                'Unknown location',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  Color(0xFF111A3D),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },

                seperatedBuilder:
                    const Divider(
                  height: 1,
                  color: Color(0xFFE9ECF3),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ====================================================
            // CURRENT LOCATION BUTTON
            // ====================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: InkWell(
                onTap: _isGettingCurrentLocation
                    ? null
                    : _useCurrentLocation,

                borderRadius:
                    BorderRadius.circular(18),

                child: Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),

                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFEAF0FF),

                    borderRadius:
                        BorderRadius.circular(18),
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,

                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF2457F5),

                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),

                        child:
                            _isGettingCurrentLocation
                                ? const Padding(
                                    padding:
                                        EdgeInsets.all(
                                      13,
                                    ),
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .my_location_rounded,
                                    color: Colors.white,
                                  ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Use my current location',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.w800,
                                color:
                                    Color(0xFF111A3D),
                              ),
                            ),

                            SizedBox(height: 3),

                            Text(
                              'Find physiotherapists closest to you',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w600,
                                color:
                                    Color(0xFF65708B),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons
                            .arrow_forward_ios_rounded,
                        size: 16,
                        color: Color(0xFF5146D9),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ====================================================
            // CURRENTLY SELECTED LOCATION
            // ====================================================

            if (widget.selectedLocation != null)
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  22,
                  0,
                  22,
                  22,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Color(0xFF7B849C),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Current: ${widget.selectedLocation!.displayName}',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w600,
                          color: Color(0xFF7B849C),
                        ),
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