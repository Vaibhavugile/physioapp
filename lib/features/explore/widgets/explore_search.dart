import 'package:flutter/material.dart';

import '../../../models/user_location_model.dart';

class ExploreSearch extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onLocationTap;

  // =============================================================
  // SELECTED LOCATION
  // =============================================================

  final UserLocationModel? selectedLocation;

  const ExploreSearch({
    super.key,
    this.onFilterTap,
    this.onSearchChanged,
    this.onLocationTap,
    this.selectedLocation,
  });

  // =============================================================
  // LOCATION DISPLAY HELPERS
  // =============================================================

  String get _locationTitle {
    if (selectedLocation == null) {
      return 'Select your location';
    }

    if (selectedLocation!.isCurrentLocation) {
      return 'Current location';
    }

    return selectedLocation!.shortDisplayName;
  }

  String get _locationSubtitle {
    if (selectedLocation == null) {
      return 'Choose an area to find physiotherapists near you';
    }

    if (selectedLocation!.isCurrentLocation) {
      return selectedLocation!.displayName;
    }

    return selectedLocation!.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =========================================================
        // PREMIUM SEARCH BAR
        // =========================================================

        Container(
          width: double.infinity,
          height: 60,

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(20),

            border: Border.all(
              color: const Color(0xFFE4E7F0),
            ),

            boxShadow: [
              BoxShadow(
                color: const Color(0xFF202B50)
                    .withOpacity(.055),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Row(
            children: [
              const SizedBox(width: 12),

              // ===================================================
              // SEARCH ICON
              // ===================================================

              Container(
                width: 38,
                height: 38,

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF1EFFF),
                      Color(0xFFF3F8FF),
                    ],
                  ),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.search_rounded,
                  size: 21,
                  color: Color(0xFF5146D9),
                ),
              ),

              const SizedBox(width: 10),

              // ===================================================
              // SEARCH FIELD
              // ===================================================

              Expanded(
                child: TextField(
                  onChanged: onSearchChanged,

                  textInputAction: TextInputAction.search,

                  textCapitalization:
                      TextCapitalization.sentences,

                  cursorColor: const Color(0xFF5146D9),

                  decoration: const InputDecoration(
                    border: InputBorder.none,

                    enabledBorder: InputBorder.none,

                    focusedBorder: InputBorder.none,

                    isDense: true,

                    contentPadding: EdgeInsets.zero,

                    hintText:
                        'Search physios, conditions...',

                    hintStyle: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF9299AE),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF151D3D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // ===================================================
              // DIVIDER
              // ===================================================

              Container(
                width: 1,
                height: 28,
                color: const Color(0xFFE8EAF1),
              ),

              const SizedBox(width: 7),

              // ===================================================
              // FILTER BUTTON
              // ===================================================

              GestureDetector(
                onTap: onFilterTap,

                behavior: HitTestBehavior.opaque,

                child: Container(
                  width: 44,
                  height: 44,

                  margin: const EdgeInsets.only(
                    right: 6,
                  ),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6D58EA),
                        Color(0xFF5146D9),
                      ],
                    ),

                    borderRadius: BorderRadius.circular(14),

                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5146D9)
                            .withOpacity(.22),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // =========================================================
        // LOCATION CARD
        // =========================================================

        GestureDetector(
          onTap: onLocationTap,

          behavior: HitTestBehavior.opaque,

          child: Container(
            width: double.infinity,

            padding: const EdgeInsets.fromLTRB(
              12,
              11,
              12,
              11,
            ),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(18),

              border: Border.all(
                color: selectedLocation == null
                    ? const Color(0xFFE5E8F0)
                    : const Color(0xFFDCD8FF),
              ),

              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF202B50)
                      .withOpacity(.04),
                  blurRadius: 17,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: Row(
              children: [
                // =================================================
                // LOCATION ICON
                // =================================================

                Container(
                  width: 42,
                  height: 42,

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: selectedLocation == null
                          ? const [
                              Color(0xFFF3F4F8),
                              Color(0xFFE9ECF3),
                            ]
                          : const [
                              Color(0xFFF0EDFF),
                              Color(0xFFE6F0FF),
                            ],
                    ),

                    borderRadius: BorderRadius.circular(13),
                  ),

                  child: Icon(
                    selectedLocation?.isCurrentLocation == true
                        ? Icons.my_location_rounded
                        : Icons.location_on_rounded,

                    size: 21,

                    color: selectedLocation == null
                        ? const Color(0xFF7E879C)
                        : const Color(0xFF5146D9),
                  ),
                ),

                const SizedBox(width: 12),

                // =================================================
                // LOCATION TEXT
                // =================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          Text(
                            selectedLocation?.isCurrentLocation ==
                                    true
                                ? 'YOUR CURRENT LOCATION'
                                : selectedLocation == null
                                    ? 'LOCATION'
                                    : 'SELECTED LOCATION',

                            style: const TextStyle(
                              fontSize: 9.5,
                              letterSpacing: .7,
                              color: Color(0xFF9299AE),
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          if (selectedLocation
                                  ?.isCurrentLocation ==
                              true) ...[
                            const SizedBox(width: 6),

                            Container(
                              width: 6,
                              height: 6,

                              decoration: const BoxDecoration(
                                color: Color(0xFF1DBF73),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 3),

                      Text(
                        _locationTitle,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF151D3D),
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        _locationSubtitle,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF7C8498),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // =================================================
                // CHANGE BUTTON
                // =================================================

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EFFF),

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedLocation == null
                            ? 'Choose'
                            : 'Change',

                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF5146D9),
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(width: 3),

                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Color(0xFF5146D9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}