import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../../../config/google_maps_config.dart';
import '../pricing_config.dart';

class PhysioLocationData {
  final String clinicName, address, locality, city, state, pincode;
  final double latitude, longitude;
  final int homeVisitRadiusKm;

  const PhysioLocationData({
    this.clinicName = '',
    this.address = '',
    this.locality = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.latitude = 0,
    this.longitude = 0,
    this.homeVisitRadiusKm = 10,
  });
}

class PhysioLocationStep extends StatefulWidget {
  final PhysioLocationData initialData;
  final bool homeVisitsEnabled;
  final int experienceYears;
  final ValueChanged<PhysioLocationData> onChanged;

  const PhysioLocationStep({
    super.key,
    required this.initialData,
    required this.homeVisitsEnabled,
    required this.experienceYears,
    required this.onChanged,
  });

  @override
  State<PhysioLocationStep> createState() => _PhysioLocationStepState();
}

class _PhysioLocationStepState extends State<PhysioLocationStep>
    with TickerProviderStateMixin {
  static const _ink = Color(0xFF173B38);
  static const _muted = Color(0xFF748985);
  static const _green = Color(0xFF078F80);
  static const _line = Color(0xFFE3EEEB);
  static const _surface = Color(0xFFF3F8F6);

  late final TextEditingController _search;
  late final TextEditingController _clinic;
  late final TextEditingController _locality;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _pincode;
  late final TextEditingController _radius;

  late final AnimationController _entranceController;
  double _lat = 0, _lng = 0;
  String _selectedDescription = '';
  String _resolvedDescription = '';
  bool _settingSearchFromSelection = false;

  bool get _placeSelected =>
      _selectedDescription.isNotEmpty &&
      _resolvedDescription == _selectedDescription &&
      _lat != 0 &&
      _lng != 0;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _search = TextEditingController(text: d.address);
    _clinic = TextEditingController(text: d.clinicName);
    _locality = TextEditingController(text: d.locality);
    _city = TextEditingController(text: d.city);
    _state = TextEditingController(text: d.state);
    _pincode = TextEditingController(text: d.pincode);
    _radius = TextEditingController(text: d.homeVisitRadiusKm.toString());
    _lat = d.latitude;
    _lng = d.longitude;
    _selectedDescription = d.address;
    _resolvedDescription =
        (d.latitude != 0 && d.longitude != 0) ? d.address : '';
    _search.addListener(_handleSearchChanged);
    for (final c in [_clinic, _locality, _city, _state, _pincode, _radius]) {
      c.addListener(_emit);
    }
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant PhysioLocationStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialData != widget.initialData) {
      // Parent-driven updates are intentionally not pushed into active controllers;
      // this avoids overwriting text while the user is editing the form.
    }
  }

  void _handleSearchChanged() {
    if (_settingSearchFromSelection) return;
    if (_search.text.trim() != _selectedDescription.trim()) {
      _selectedDescription = '';
      _resolvedDescription = '';
      _lat = 0;
      _lng = 0;
      _emit();
      if (mounted) setState(() {});
    }
  }

  void _emit() {
    widget.onChanged(
      PhysioLocationData(
        clinicName: _clinic.text.trim(),
        address: _search.text.trim(),
        locality: _locality.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        pincode: _pincode.text.trim(),
        latitude: _lat,
        longitude: _lng,
        homeVisitRadiusKm: int.tryParse(_radius.text.trim()) ?? 0,
      ),
    );
  }

  @override
  void dispose() {
    _search.removeListener(_handleSearchChanged);
    for (final c in [
      _search,
      _clinic,
      _locality,
      _city,
      _state,
      _pincode,
      _radius,
    ]) {
      c.dispose();
    }
    _entranceController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFA1B2AE),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: _green, size: 19),
      suffixIcon: suffix,
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _green, width: 1.5),
      ),
    );
  }

  Widget _label(String text, {String? helper}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: .15,
            ),
          ),
          if (helper != null) ...[
            const SizedBox(width: 6),
            Text(
              helper,
              style: const TextStyle(
                color: _muted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    String? helper,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label, helper: helper),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
              color: _ink,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: _decoration(hint, icon),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String number,
    required String title,
    required String subtitle,
    required Widget child,
    required int index,
    IconData? icon,
  }) {
    final start = (index * .12).clamp(0.0, .65);
    final end = (start + .35).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(
          ((_entranceController.value - start) / (end - start))
              .clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - t)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: _line),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF163F39).withOpacity(.045),
                    blurRadius: 22,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4F0),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          number,
                          style: const TextStyle(
                            color: _green,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: _ink,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                letterSpacing: -.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 11,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (icon != null)
                        Icon(icon, color: const Color(0xFF9AB5AF), size: 19),
                    ],
                  ),
                  const SizedBox(height: 17),
                  child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _locationSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GooglePlaceAutoCompleteTextField(
          textEditingController: _search,
          googleAPIKey: GoogleMapsConfig.apiKey,
          debounceTime: 600,
          countries: const ['in'],
          isLatLngRequired: true,
          isCrossBtnShown: true,
          getPlaceDetailWithLatLng: (Prediction prediction) {
            final lat = double.tryParse(prediction.lat ?? '');
            final lng = double.tryParse(prediction.lng ?? '');
            if (lat == null || lng == null) return;
            final resolved =
                (prediction.description ?? _selectedDescription).trim();
            setState(() {
              _lat = lat;
              _lng = lng;
              _resolvedDescription = resolved;
            });
            _emit();
          },
          inputDecoration: _decoration(
            'Search clinic, building, area or landmark',
            Icons.search_rounded,
          ),
          itemClick: (Prediction prediction) {
            final description = prediction.description ?? '';
            setState(() {
              _settingSearchFromSelection = true;
              _search.text = description;
              _search.selection = TextSelection.collapsed(
                offset: _search.text.length,
              );
              _settingSearchFromSelection = false;
              _selectedDescription = description;
              if (_resolvedDescription != description) {
                _lat = 0;
                _lng = 0;
              }
            });
            _emit();
          },
          itemBuilder: (context, index, Prediction prediction) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: _green,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      prediction.description ?? 'Location',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          seperatedBuilder: const Divider(height: 1, color: _line),
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: _placeSelected
                ? const Color(0xFFECF8F1)
                : const Color(0xFFFFF8EC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _placeSelected
                  ? const Color(0xFFCDEBD9)
                  : const Color(0xFFF2E4C7),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _placeSelected
                    ? Icons.verified_rounded
                    : Icons.touch_app_rounded,
                color: _placeSelected
                    ? const Color(0xFF279461)
                    : const Color(0xFFB78331),
                size: 17,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _placeSelected
                      ? 'Exact map location selected'
                          '  ·  ${_lat.toStringAsFixed(5)}, ${_lng.toStringAsFixed(5)}'
                      : 'Choose one of the Google suggestions to confirm the exact map pin and coordinates.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: _placeSelected
                        ? const Color(0xFF267B54)
                        : const Color(0xFF98723A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _locationSnapshot(String city, String locality) {
    final hasPlace = city.isNotEmpty || locality.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C766D), Color(0xFF0B9D8B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.near_me_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR PRACTICE AREA',
                  style: TextStyle(
                    color: Color(0xFFD0F1E9),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasPlace
                      ? [locality, city].where((e) => e.isNotEmpty).join(', ')
                      : 'Add your city and locality below',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_outward_rounded,
            color: Color(0xFFC9F1E8),
            size: 18,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final city = _city.text.trim();
    final locality = _locality.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(19, 20, 19, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE6F4F0), Color(0xFFF6FBF9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFDDEFE9)),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -8,
                top: -14,
                child: Icon(
                  Icons.location_on_rounded,
                  size: 92,
                  color: const Color(0xFF0B927F).withOpacity(.07),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.85),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.explore_rounded, color: _green, size: 13),
                        SizedBox(width: 5),
                        Text(
                          'PRACTICE PROFILE',
                          style: TextStyle(
                            color: _green,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    'Set your practice\nlocation',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 25,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tell patients where they can find you and define the area you cover for home visits.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _locationSnapshot(city, locality),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        _section(
          number: '01',
          title: 'Pin your location',
          subtitle: 'Search and select the exact address on Google Maps',
          icon: Icons.map_outlined,
          index: 0,
          child: _locationSearch(),
        ),
        _section(
          number: '02',
          title: 'Practice details',
          subtitle: 'Add the clinic name and registered operating area',
          icon: Icons.medical_services_outlined,
          index: 1,
          child: Column(
            children: [
              _field(
                'Clinic / practice name',
                _clinic,
                'Example: Active Physio Clinic',
                Icons.local_hospital_outlined,
                helper: 'OPTIONAL',
              ),
              _field(
                'Locality / neighbourhood',
                _locality,
                'Example: Baner, Andheri West',
                Icons.location_city_outlined,
              ),
              _field(
                'City',
                _city,
                'Example: Pune or Mumbai',
                Icons.location_city_rounded,
              ),
              _field(
                'State',
                _state,
                'Example: Maharashtra',
                Icons.map_outlined,
              ),
              _field(
                'PIN code',
                _pincode,
                '6-digit PIN code',
                Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
            ],
          ),
        ),
        if (widget.homeVisitsEnabled)
          _section(
            number: '03',
            title: 'Home-visit coverage',
            subtitle: 'Choose how far you are comfortable travelling',
            icon: Icons.radar_rounded,
            index: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8F6),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: _green, size: 18),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'This radius is measured from your selected practice location. Patients within this area can discover your home-visit service.',
                          style: TextStyle(
                            color: Color(0xFF55716B),
                            fontSize: 11,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                _label('Travel radius', helper: 'IN KILOMETRES'),
                TextField(
                  controller: _radius,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: _decoration(
                    'Enter radius, e.g. 15',
                    Icons.radar_rounded,
                    suffix: const Padding(
                      padding: EdgeInsets.only(right: 14),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          'KM',
                          style: TextStyle(
                            color: _green,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 2),
        PricingLocationSummary(
          city: city,
          locality: locality,
          experienceYears: widget.experienceYears,
        ),
      ],
    );
  }
}
