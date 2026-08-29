import 'package:flutter/material.dart';

class BasicInformationStep extends StatefulWidget {
  final String? initialFullName;
  final String? initialGender;
  final DateTime? initialDateOfBirth;
  final String? initialEmail;
  final String? initialCity;
  final String? initialState;
  final String? phoneNumber;

  final ValueChanged<BasicInformationData> onChanged;

  const BasicInformationStep({
    super.key,
    this.initialFullName,
    this.initialGender,
    this.initialDateOfBirth,
    this.initialEmail,
    this.initialCity,
    this.initialState,
    this.phoneNumber,
    required this.onChanged,
  });

  @override
  State<BasicInformationStep> createState() =>
      _BasicInformationStepState();
}

// ================================================================
// DATA MODEL
// ================================================================

class BasicInformationData {
  final String fullName;
  final String gender;
  final DateTime? dateOfBirth;
  final String email;
  final String city;
  final String state;

  const BasicInformationData({
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.email,
    required this.city,
    required this.state,
  });
}

class _BasicInformationStepState
    extends State<BasicInformationStep> {
  // ==============================================================
  // FORM KEY
  // ==============================================================

  final _formKey = GlobalKey<FormState>();

  // ==============================================================
  // CONTROLLERS
  // ==============================================================

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;

  // ==============================================================
  // STATE
  // ==============================================================

  String? _selectedGender;

  DateTime? _selectedDateOfBirth;

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    _fullNameController =
        TextEditingController(
      text: widget.initialFullName ?? '',
    );

    _emailController =
        TextEditingController(
      text: widget.initialEmail ?? '',
    );

    _cityController =
        TextEditingController(
      text: widget.initialCity ?? '',
    );

    _stateController =
        TextEditingController(
      text: widget.initialState ?? '',
    );

    _selectedGender =
        widget.initialGender;

    _selectedDateOfBirth =
        widget.initialDateOfBirth;

    _fullNameController.addListener(_notifyChanged);
    _emailController.addListener(_notifyChanged);
    _cityController.addListener(_notifyChanged);
    _stateController.addListener(_notifyChanged);
  }

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _stateController.dispose();

    super.dispose();
  }

  // ==============================================================
  // NOTIFY PARENT
  // ==============================================================

  void _notifyChanged() {
    widget.onChanged(
      BasicInformationData(
        fullName:
            _fullNameController.text.trim(),
        gender:
            _selectedGender ?? '',
        dateOfBirth:
            _selectedDateOfBirth,
        email:
            _emailController.text.trim(),
        city:
            _cityController.text.trim(),
        state:
            _stateController.text.trim(),
      ),
    );
  }

  // ==============================================================
  // VALIDATE
  // ==============================================================

  bool validate() {
    final formValid =
        _formKey.currentState?.validate() ?? false;

    if (_selectedGender == null ||
        _selectedGender!.isEmpty) {
      _showError(
        'Please select your gender.',
      );

      return false;
    }

    if (_selectedDateOfBirth == null) {
      _showError(
        'Please select your date of birth.',
      );

      return false;
    }

    return formValid;
  }

  // ==============================================================
  // ERROR
  // ==============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // ==============================================================
  // DATE PICKER
  // ==============================================================

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();

    final initialDate =
        _selectedDateOfBirth ??
            DateTime(
              now.year - 25,
              now.month,
              now.day,
            );

    final selectedDate =
        await showDatePicker(
      context: context,

      initialDate: initialDate,

      firstDate:
          DateTime(now.year - 80),

      lastDate:
          DateTime(
        now.year - 18,
        now.month,
        now.day,
      ),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _selectedDateOfBirth =
          selectedDate;
    });

    _notifyChanged();
  }

  // ==============================================================
  // DATE FORMAT
  // ==============================================================

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ======================================================
          // PROFILE PHOTO
          // ======================================================

          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,

                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFEAF0FF),

                        shape: BoxShape.circle,

                        border: Border.all(
                          color:
                              const Color(0xFFD9E3FF),
                          width: 2,
                        ),
                      ),

                      child: const Icon(
                        Icons.person_rounded,
                        size: 46,
                        color:
                            Color(0xFF2457F5),
                      ),
                    ),

                    Positioned(
                      right: 0,
                      bottom: 0,

                      child: Container(
                        width: 34,
                        height: 34,

                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF2457F5),

                          shape: BoxShape.circle,

                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),

                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  'Profile photo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF2457F5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ======================================================
          // FULL NAME
          // ======================================================

          _buildLabel('Full name'),

          const SizedBox(height: 8),

          TextFormField(
            controller: _fullNameController,

            textCapitalization:
                TextCapitalization.words,

            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Please enter your full name.';
              }

              if (value.trim().length < 3) {
                return 'Please enter a valid name.';
              }

              return null;
            },

            decoration: _inputDecoration(
              hint: 'Enter your full name',
              icon:
                  Icons.person_outline_rounded,
            ),
          ),

          const SizedBox(height: 20),

          // ======================================================
          // GENDER
          // ======================================================

          _buildLabel('Gender'),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildGenderOption(
                  label: 'Male',
                  icon: Icons.male_rounded,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildGenderOption(
                  label: 'Female',
                  icon: Icons.female_rounded,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildGenderOption(
                  label: 'Other',
                  icon: Icons.person_outline_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ======================================================
          // DATE OF BIRTH
          // ======================================================

          _buildLabel('Date of birth'),

          const SizedBox(height: 8),

          InkWell(
            onTap: _selectDateOfBirth,

            borderRadius:
                BorderRadius.circular(16),

            child: Container(
              height: 56,

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color:
                      const Color(0xFFE1E6EF),
                ),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color:
                        Color(0xFF7B849C),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      _selectedDateOfBirth == null
                          ? 'Select your date of birth'
                          : _formatDate(
                              _selectedDateOfBirth!,
                            ),

                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,

                        color:
                            _selectedDateOfBirth ==
                                    null
                                ? const Color(
                                    0xFF98A1B5,
                                  )
                                : const Color(
                                    0xFF111A3D,
                                  ),
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color:
                        Color(0xFF7B849C),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ======================================================
          // EMAIL
          // ======================================================

          _buildLabel(
            'Email address',
            optional: true,
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: _emailController,

            keyboardType:
                TextInputType.emailAddress,

            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return null;
              }

              final email =
                  value.trim();

              if (!email.contains('@') ||
                  !email.contains('.')) {
                return 'Please enter a valid email.';
              }

              return null;
            },

            decoration: _inputDecoration(
              hint: 'Enter your email address',
              icon:
                  Icons.email_outlined,
            ),
          ),

          const SizedBox(height: 20),

          // ======================================================
          // PHONE NUMBER
          // ======================================================

          _buildLabel('Mobile number'),

          const SizedBox(height: 8),

          Container(
            height: 56,

            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            decoration: BoxDecoration(
              color:
                  const Color(0xFFF0F3F8),

              borderRadius:
                  BorderRadius.circular(16),

              border: Border.all(
                color:
                    const Color(0xFFE1E6EF),
              ),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 20,
                  color:
                      Color(0xFF7B849C),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    widget.phoneNumber ??
                        'Mobile number',

                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Color(0xFF4B556D),
                    ),
                  ),
                ),

                const Icon(
                  Icons.verified_rounded,
                  size: 19,
                  color:
                      Color(0xFF1DAA61),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Verified through your OTP login and cannot be changed here.',
            style: TextStyle(
              fontSize: 9.5,
              color:
                  Color(0xFF98A1B5),
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // ======================================================
          // CITY
          // ======================================================

          _buildLabel('City'),

          const SizedBox(height: 8),

          TextFormField(
            controller: _cityController,

            textCapitalization:
                TextCapitalization.words,

            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Please enter your city.';
              }

              return null;
            },

            decoration: _inputDecoration(
              hint: 'Enter your city',
              icon:
                  Icons.location_city_outlined,
            ),
          ),

          const SizedBox(height: 20),

          // ======================================================
          // STATE
          // ======================================================

          _buildLabel('State'),

          const SizedBox(height: 8),

          TextFormField(
            controller: _stateController,

            textCapitalization:
                TextCapitalization.words,

            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Please enter your state.';
              }

              return null;
            },

            decoration: _inputDecoration(
              hint: 'Enter your state',
              icon:
                  Icons.map_outlined,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Your profile details will be reviewed before your account is activated.',
            style: TextStyle(
              fontSize: 10,
              height: 1.5,
              color:
                  Color(0xFF98A1B5),
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==============================================================
  // LABEL
  // ==============================================================

  Widget _buildLabel(
    String label, {
    bool optional = false,
  }) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF111A3D),
            ),
          ),

          if (optional)
            const TextSpan(
              text: '  Optional',
              style: TextStyle(
                fontSize: 9,
                fontWeight:
                    FontWeight.w600,
                color:
                    Color(0xFF98A1B5),
              ),
            ),
        ],
      ),
    );
  }

  // ==============================================================
  // GENDER OPTION
  // ==============================================================

  Widget _buildGenderOption({
    required String label,
    required IconData icon,
  }) {
    final isSelected =
        _selectedGender == label;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = label;
        });

        _notifyChanged();
      },

      borderRadius:
          BorderRadius.circular(14),

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),

        height: 50,

        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEEF3FF)
              : Colors.white,

          borderRadius:
              BorderRadius.circular(14),

          border: Border.all(
            color: isSelected
                ? const Color(0xFF2457F5)
                : const Color(0xFFE1E6EF),

            width: isSelected ? 1.5 : 1,
          ),
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected
                  ? const Color(0xFF2457F5)
                  : const Color(0xFF7B849C),
            ),

            const SizedBox(width: 5),

            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w700,

                color: isSelected
                    ? const Color(0xFF2457F5)
                    : const Color(0xFF7B849C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // INPUT DECORATION
  // ==============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        fontSize: 12,
        color:
            Color(0xFF98A1B5),
        fontWeight:
            FontWeight.w500,
      ),

      prefixIcon: Icon(
        icon,
        size: 20,
        color:
            const Color(0xFF7B849C),
      ),

      filled: true,

      fillColor: Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),

        borderSide:
            const BorderSide(
          color:
              Color(0xFFE1E6EF),
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),

        borderSide:
            const BorderSide(
          color:
              Color(0xFFE1E6EF),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),

        borderSide:
            const BorderSide(
          color:
              Color(0xFF2457F5),
          width: 1.5,
        ),
      ),

      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),

        borderSide:
            const BorderSide(
          color:
              Color(0xFFE05252),
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),

        borderSide:
            const BorderSide(
          color:
              Color(0xFFE05252),
          width: 1.5,
        ),
      ),
    );
  }
}