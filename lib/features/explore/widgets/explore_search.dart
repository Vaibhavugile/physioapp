import 'package:flutter/material.dart';
import '../../../models/user_location_model.dart';

class ExploreSearch extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onLocationTap;
  final UserLocationModel? selectedLocation;

  const ExploreSearch({
    super.key,
    this.onFilterTap,
    this.onSearchChanged,
    this.onLocationTap,
    this.selectedLocation,
  });

  String get _locationTitle {
    if (selectedLocation == null) return 'Choose your location';
    if (selectedLocation!.isCurrentLocation) return 'Current location';
    return selectedLocation!.shortDisplayName;
  }

  String get _locationSubtitle {
    if (selectedLocation == null) return 'Set your area to discover nearby care';
    return selectedLocation!.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 59,
          padding: const EdgeInsets.only(left: 13, right: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFE7E9F2)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF202B50).withOpacity(.055),
                blurRadius: 20,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF0EEFF), Color(0xFFEAF8F6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.search_rounded, color: Color(0xFF5146D9), size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  onChanged: onSearchChanged,
                  textInputAction: TextInputAction.search,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: const Color(0xFF5146D9),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Search physios, conditions...',
                    hintStyle: TextStyle(
                      color: Color(0xFF969DB0),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF151D3D),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onFilterTap,
                  borderRadius: BorderRadius.circular(14),
                  child: Ink(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF7064E8), Color(0xFF5146D9)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5146D9).withOpacity(.22),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 19),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onLocationTap,
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFF7FAFF)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5EAF2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on_rounded, color: Color(0xFF079F87), size: 19),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YOUR AREA',
                          style: TextStyle(
                            color: Color(0xFF9AA1B2),
                            fontSize: 8,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _locationTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF17203E),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _locationSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8790A6),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EEFF),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Change', style: TextStyle(color: Color(0xFF5146D9), fontSize: 9, fontWeight: FontWeight.w900)),
                        SizedBox(width: 3),
                        Icon(Icons.chevron_right_rounded, color: Color(0xFF5146D9), size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
