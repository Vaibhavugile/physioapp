import 'package:flutter/material.dart';

/// Personal identity only. Practice location is collected once in
/// PhysioLocationStep so city/locality are never requested twice.
class BasicInformationStep extends StatefulWidget {
  final String? initialFullName;
  final String? initialGender;
  final DateTime? initialDateOfBirth;
  final String? initialEmail;
  final String? phoneNumber;
  final ValueChanged<BasicInformationData> onChanged;

  const BasicInformationStep({
    super.key,
    this.initialFullName,
    this.initialGender,
    this.initialDateOfBirth,
    this.initialEmail,
    this.phoneNumber,
    required this.onChanged,
  });

  @override
  State<BasicInformationStep> createState() => _BasicInformationStepState();
}

class BasicInformationData {
  final String fullName;
  final String gender;
  final DateTime? dateOfBirth;
  final String email;

  const BasicInformationData({
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.email,
  });
}

class _BasicInformationStepState extends State<BasicInformationStep>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  String _gender = '';
  DateTime? _dob;
  late final AnimationController _animation;

  static const _ink = Color(0xFF183D39);
  static const _green = Color(0xFF078F83);
  static const _muted = Color(0xFF7A918C);
  static const _line = Color(0xFFE3ECE9);
  static const _pale = Color(0xFFF4F9F7);

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialFullName ?? '');
    _email = TextEditingController(text: widget.initialEmail ?? '');
    _gender = widget.initialGender ?? '';
    _dob = widget.initialDateOfBirth;
    _name.addListener(_emit);
    _email.addListener(_emit);
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();
  }

  void _emit() {
    widget.onChanged(BasicInformationData(
      fullName: _name.text.trim(),
      gender: _gender,
      dateOfBirth: _dob,
      email: _email.text.trim(),
    ));
  }

  @override
  void dispose() {
    _name.removeListener(_emit);
    _email.removeListener(_emit);
    _name.dispose();
    _email.dispose();
    _animation.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 19, color: const Color(0xFF829A94)),
      filled: true,
      fillColor: const Color(0xFFFAFCFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      hintStyle: const TextStyle(
        color: Color(0xFFA0B1AD),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _green, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE07878)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE07878), width: 1.4),
      ),
    );
  }

  Widget _label(String value, {bool required = false, String? helper}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _ink,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (helper != null)
            Text(
              helper,
              style: const TextStyle(
                color: _muted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (required)
            const Padding(
              padding: EdgeInsets.only(left: 3),
              child: Text(
                '*',
                style: TextStyle(
                  color: Color(0xFFE07878),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5F2),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 17, color: _green),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formattedDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: 'SELECT YOUR DATE OF BIRTH',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _green,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _ink,
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dob = picked);
      _emit();
    }
  }

  Widget _genderOption(String value) {
    final selected = _gender == value;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => _gender = value);
          _emit();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F5F1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _green : _line,
              width: selected ? 1.3 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected) ...[
                const Icon(Icons.check_circle_rounded, color: _green, size: 14),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? _green : const Color(0xFF617873),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Gender', required: true),
        Row(
          children: [
            _genderOption('Male'),
            const SizedBox(width: 7),
            _genderOption('Female'),
            const SizedBox(width: 7),
            _genderOption('Other'),
          ],
        ),
        if (_gender.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              'Choose one option',
              style: TextStyle(color: _muted, fontSize: 10),
            ),
          ),
      ],
    );
  }

  Widget _dobField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Date of birth', required: true),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _selectDate,
            child: InputDecorator(
              decoration: _inputDecoration(
                hint: 'DD / MM / YYYY',
                icon: Icons.calendar_today_rounded,
              ).copyWith(
                suffixIcon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _muted,
                ),
              ),
              child: Text(
                _dob == null ? 'Select date' : _formattedDate(_dob!),
                style: TextStyle(
                  color: _dob == null ? const Color(0xFFA0B1AD) : _ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'You must be at least 18 years old.',
          style: TextStyle(color: _muted, fontSize: 10),
        ),
      ],
    );
  }

  Widget _phoneCard() {
    final phone = widget.phoneNumber ?? '';
    if (phone.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFDDECE6)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.phone_iphone_rounded, color: _green, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VERIFIED MOBILE NUMBER',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  phone,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded, color: _green, size: 17),
          const SizedBox(width: 4),
          const Text(
            'Verified',
            style: TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _animation, curve: Curves.easeOut),
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 620;
            final gap = wide ? 18.0 : 14.0;

            final nameField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Full name', required: true, helper: 'As per documents'),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w700),
                  decoration: _inputDecoration(
                    hint: 'Enter your full name',
                    icon: Icons.badge_outlined,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please enter your full name'
                      : null,
                ),
              ],
            );

            final emailField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Email address', required: true, helper: 'For account updates'),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  style: const TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w700),
                  decoration: _inputDecoration(
                    hint: 'you@example.com',
                    icon: Icons.alternate_email_rounded,
                  ),
                  validator: (value) {
                    final email = (value ?? '').trim();
                    if (email.isEmpty) return 'Please enter your email address';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
              ],
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                  decoration: BoxDecoration(
                    color: _pale,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: const Color(0xFFE5EFEB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0EA896), Color(0xFF08776F)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your personal profile',
                              style: TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Use the details shown on your official documents.',
                              style: TextStyle(color: _muted, fontSize: 10, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.lock_outline_rounded, color: _green, size: 17),
                    ],
                  ),
                ),
                SizedBox(height: gap),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: nameField),
                      const SizedBox(width: 16),
                      Expanded(child: emailField),
                    ],
                  )
                else ...[
                  nameField,
                  SizedBox(height: gap),
                  emailField,
                ],
                SizedBox(height: gap + 2),
                _sectionTitle(
                  Icons.tune_rounded,
                  'Personal details',
                  'A couple of details to complete your identity.',
                ),
                const SizedBox(height: 14),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _genderSelector()),
                      const SizedBox(width: 16),
                      Expanded(child: _dobField()),
                    ],
                  )
                else ...[
                  _genderSelector(),
                  SizedBox(height: gap),
                  _dobField(),
                ],
                if ((widget.phoneNumber ?? '').isNotEmpty) ...[
                  SizedBox(height: gap + 3),
                  _phoneCard(),
                ],
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: _green, size: 15),
                    const SizedBox(width: 7),
                    const Expanded(
                      child: Text(
                        'Your practice address and locality will be collected once in the Practice Location step.',
                        style: TextStyle(color: _muted, fontSize: 10, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
