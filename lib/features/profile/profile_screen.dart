import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Premium customer profile screen for PhysioHomey.
///
/// Navigation ownership:
/// MainNavigation owns the app's bottom navigation. This screen deliberately
/// does not add a second bottom navigation bar.
///
/// Firestore structure used by this screen:
/// users/{uid}
///   name, email, phone, profileImageUrl, updatedAt
/// users/{uid}/saved_addresses/{addressId}
///   label, addressLine, landmark, area, city, state, postalCode,
///   formattedAddress, isDefault, createdAt, updatedAt
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _background = Color(0xFFF6F8FD);
  static const Color _ink = Color(0xFF111936);
  static const Color _muted = Color(0xFF77809A);
  static const Color _primary = Color(0xFF5146D9);
  static const Color _violet = Color(0xFF756CF0);
  static const Color _line = Color(0xFFE7EAF3);
  static const Color _green = Color(0xFF159B75);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = true;
  bool _savingProfile = false;
  bool _signingOut = false;
  String? _loadError;
  Map<String, dynamic> _profile = <String, dynamic>{};
  List<_SavedAddress> _addresses = <_SavedAddress>[];

  String get _uid => _auth.currentUser?.uid ?? '';
  User? get _firebaseUser => _auth.currentUser;

  DocumentReference<Map<String, dynamic>> get _userRef =>
      _firestore.collection('users').doc(_uid);

  CollectionReference<Map<String, dynamic>> get _addressRef =>
      _userRef.collection('saved_addresses');

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile({bool showLoader = true}) async {
    if (_uid.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    if (showLoader && mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }

    try {
      final results = await Future.wait([
        _userRef.get(),
        _addressRef.get(),
      ]);
      final userSnapshot = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final addressSnapshot = results[1] as QuerySnapshot<Map<String, dynamic>>;
      final data = userSnapshot.data() ?? <String, dynamic>{};
      final authUser = _firebaseUser;

      final resolvedName = _firstString([
        data['name'],
        data['fullName'],
        data['displayName'],
        authUser?.displayName,
      ]);
      final resolvedEmail = _firstString([data['email'], authUser?.email]);
      final resolvedPhone = _firstString([
        data['phone'],
        data['phoneNumber'],
        authUser?.phoneNumber,
      ]);
      final resolvedPhoto = _firstString([
        data['profileImageUrl'],
        data['photoURL'],
        data['photoUrl'],
        authUser?.photoURL,
      ]);

      if (!mounted) return;
      setState(() {
        _profile = <String, dynamic>{
          ...data,
          'name': resolvedName,
          'email': resolvedEmail,
          'phone': resolvedPhone,
          'profileImageUrl': resolvedPhoto,
        };
        _addresses = addressSnapshot.docs
            .map((doc) => _SavedAddress.fromFirestore(doc.id, doc.data()))
            .toList();
        _loading = false;
        _loadError = null;
      });
    } catch (error, stackTrace) {
      debugPrint('Profile load failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'We could not load your profile. Please try again.';
      });
    }
  }

  String _firstString(List<Object?> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  String get _displayName {
    final name = (_profile['name'] ?? '').toString().trim();
    return name.isEmpty ? 'Welcome to PhysioHomey' : name;
  }

  String get _initials {
    final name = (_profile['name'] ?? '').toString().trim();
    if (name.isEmpty) return 'P';
    final parts = name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  int get _completion {
    final fields = [
      _profile['name'],
      _profile['email'],
      _profile['phone'],
    ];
    final completed = fields.where((e) => e is String && e.trim().isNotEmpty).length;
    return ((completed / fields.length) * 100).round();
  }

  void _message(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? const Color(0xFFB83E50) : _ink,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: (_profile['name'] ?? '').toString());
    final emailController = TextEditingController(text: (_profile['email'] ?? '').toString());
    final phoneController = TextEditingController(text: (_profile['phone'] ?? '').toString());
    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EditProfileSheet(
        formKey: formKey,
        nameController: nameController,
        emailController: emailController,
        phoneController: phoneController,
      ),
    );

    if (result == true && mounted) {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();
      await _saveProfile(name: name, email: email, phone: phone);
    }
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  Future<void> _saveProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    if (_uid.isEmpty) return;
    setState(() => _savingProfile = true);
    try {
      await _userRef.set({
        'name': name,
        'displayName': name,
        'email': email,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final user = _firebaseUser;
      if (user != null && user.displayName != name) {
        await user.updateDisplayName(name);
      }
      if (!mounted) return;
      setState(() {
        _profile = {
          ..._profile,
          'name': name,
          'email': email,
          'phone': phone,
        };
        _savingProfile = false;
      });
      _message('Your profile has been updated.');
    } catch (error, stackTrace) {
      debugPrint('Profile update failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _savingProfile = false);
      _message('Unable to save your profile. Please try again.', error: true);
    }
  }

  Future<void> _addAddress() async => _openAddressEditor();

  Future<void> _editAddress(_SavedAddress address) async =>
      _openAddressEditor(address: address);

  Future<void> _openAddressEditor({_SavedAddress? address}) async {
    final result = await showModalBottomSheet<_AddressDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressEditorSheet(address: address),
    );
    if (result == null || !mounted || _uid.isEmpty) return;

    try {
      final doc = address == null ? _addressRef.doc() : _addressRef.doc(address.id);
      final batch = _firestore.batch();
      if (result.isDefault) {
        for (final existing in _addresses) {
          if (existing.id != doc.id && existing.isDefault) {
            batch.set(_addressRef.doc(existing.id), {
              'isDefault': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }
      }
      batch.set(doc, {
        'label': result.label,
        'addressLine': result.addressLine,
        'landmark': result.landmark,
        'area': result.area,
        'city': result.city,
        'state': result.state,
        'postalCode': result.postalCode,
        'formattedAddress': result.formattedAddress,
        'isDefault': result.isDefault,
        'updatedAt': FieldValue.serverTimestamp(),
        if (address == null) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await batch.commit();
      await _loadProfile(showLoader: false);
      _message(address == null ? 'Address saved.' : 'Address updated.');
    } catch (error, stackTrace) {
      debugPrint('Address save failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _message('Unable to save this address. Please try again.', error: true);
    }
  }

  Future<void> _setDefaultAddress(_SavedAddress address) async {
    try {
      final batch = _firestore.batch();
      for (final item in _addresses) {
        batch.set(_addressRef.doc(item.id), {
          'isDefault': item.id == address.id,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await batch.commit();
      await _loadProfile(showLoader: false);
      _message('Default address updated.');
    } catch (error) {
      debugPrint('Default address update failed: $error');
      _message('Could not update the default address.', error: true);
    }
  }

  Future<void> _deleteAddress(_SavedAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Delete this address?', style: TextStyle(fontWeight: FontWeight.w900, color: _ink)),
        content: const Text('This saved address will be removed from your account.', style: TextStyle(color: _muted, height: 1.45)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Keep address')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE05262)),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _addressRef.doc(address.id).delete();
      await _loadProfile(showLoader: false);
      _message('Address deleted.');
    } catch (error) {
      _message('Unable to delete this address.', error: true);
    }
  }

  Future<void> _showAddressActions(_SavedAddress address) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AddressActionsSheet(
        address: address,
        onEdit: () {
          Navigator.pop(sheetContext);
          _editAddress(address);
        },
        onDefault: () {
          Navigator.pop(sheetContext);
          _setDefaultAddress(address);
        },
        onDelete: () {
          Navigator.pop(sheetContext);
          _deleteAddress(address);
        },
      ),
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        title: const Text('Sign out?', style: TextStyle(color: _ink, fontWeight: FontWeight.w900)),
        content: const Text(
          'You can sign back in anytime to continue your recovery journey.',
          style: TextStyle(color: _muted, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE05262)),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _signingOut = true);
    try {
      await _auth.signOut();
      // The root auth-state listener should now show the login screen.
    } catch (error, stackTrace) {
      debugPrint('Sign out failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _signingOut = false);
      _message('Unable to sign out. Please try again.', error: true);
    }
  }

  void _comingSoon(String feature) {
    _message('$feature will be available here soon.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const _ProfileLoadingView()
            : RefreshIndicator(
                color: _primary,
                backgroundColor: Colors.white,
                onRefresh: () => _loadProfile(showLoader: false),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 34),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _topBar(),
                          const SizedBox(height: 18),
                          if (_loadError != null) ...[
                            _InlineError(message: _loadError!, onRetry: _loadProfile),
                            const SizedBox(height: 14),
                          ],
                          _profileHero(),
                          const SizedBox(height: 18),
                          _completionCard(),
                          const SizedBox(height: 25),
                          _sectionHeading('PERSONAL DETAILS', 'Keep your information up to date'),
                          const SizedBox(height: 12),
                          _personalDetailsCard(),
                          const SizedBox(height: 25),
                          _sectionHeading('SAVED ADDRESSES', 'Choose where you receive care'),
                          const SizedBox(height: 12),
                          _addressesSection(),
                          const SizedBox(height: 25),
                          _sectionHeading('YOUR ACCOUNT', 'Manage your PhysioHomey experience'),
                          const SizedBox(height: 12),
                          _accountMenu(),
                          const SizedBox(height: 24),
                          _signOutButton(),
                          const SizedBox(height: 18),
                          const _FooterNote(),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _topBar() => Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _line)),
            child: const Icon(Icons.person_outline_rounded, color: _primary, size: 21),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MY ACCOUNT', style: TextStyle(color: _primary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
              SizedBox(height: 3),
              Text('Your profile', style: TextStyle(color: _ink, fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: -.6)),
            ]),
          ),
          if (_savingProfile)
            const SizedBox(width: 19, height: 19, child: CircularProgressIndicator(strokeWidth: 2, color: _primary))
          else
            IconButton(
              tooltip: 'Refresh profile',
              onPressed: () => _loadProfile(showLoader: false),
              icon: const Icon(Icons.refresh_rounded, color: _muted),
            ),
        ],
      );

  Widget _profileHero() {
    final photo = (_profile['profileImageUrl'] ?? '').toString().trim();
    final email = (_profile['email'] ?? '').toString().trim();
    final phone = (_profile['phone'] ?? '').toString().trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF302A86), Color(0xFF5146D9), Color(0xFF8178F5)]),
        boxShadow: [BoxShadow(color: _primary.withOpacity(.22), blurRadius: 25, offset: const Offset(0, 12))],
      ),
      child: Stack(children: [
        Positioned(right: -28, top: -42, child: Container(width: 145, height: 145, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.07)))),
        Positioned(right: 35, bottom: -70, child: Container(width: 155, height: 155, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(.10), width: 22)))),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(.7), width: 1.5)),
              child: ClipOval(
                child: photo.isNotEmpty
                    ? Image.network(photo, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _avatarFallback())
                    : _avatarFallback(),
              ),
            ),
            const Spacer(),
            Material(
              color: Colors.white.withOpacity(.14),
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: _editProfile,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.edit_rounded, color: Colors.white, size: 13), SizedBox(width: 6), Text('EDIT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .7))]),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 17),
          Text(_displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: -.6)),
          const SizedBox(height: 9),
          if (phone.isNotEmpty) _heroContact(Icons.phone_rounded, phone),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 6),
            _heroContact(Icons.mail_outline_rounded, email),
          ],
          if (phone.isEmpty && email.isEmpty)
            Text('Add your contact details to complete your profile.', style: TextStyle(color: Colors.white.withOpacity(.78), fontSize: 11, height: 1.4)),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withOpacity(.18)),
          const SizedBox(height: 13),
          Row(children: [
            const Icon(Icons.verified_user_rounded, color: Color(0xFFBFF7E5), size: 15),
            const SizedBox(width: 7),
            Text('Your care journey, all in one place', style: TextStyle(color: Colors.white.withOpacity(.88), fontSize: 10, fontWeight: FontWeight.w700)),
          ]),
        ]),
      ]),
    );
  }

  Widget _avatarFallback() => Container(
        color: const Color(0xFFE8E7FF),
        alignment: Alignment.center,
        child: Text(_initials, style: const TextStyle(color: _primary, fontSize: 25, fontWeight: FontWeight.w900)),
      );

  Widget _heroContact(IconData icon, String value) => Row(children: [
        Icon(icon, color: Colors.white.withOpacity(.78), size: 13),
        const SizedBox(width: 7),
        Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(.88), fontSize: 11, fontWeight: FontWeight.w600))),
      ]);

  Widget _completionCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(21), border: Border.all(color: _line), boxShadow: [BoxShadow(color: const Color(0xFF27345D).withOpacity(.035), blurRadius: 16, offset: const Offset(0, 6))]),
        child: Column(children: [
          Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFEDEBFF), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.auto_awesome_rounded, color: _primary, size: 18)),
            const SizedBox(width: 10),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Profile completeness', style: TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('A complete profile helps us personalise your care.', style: TextStyle(color: _muted, fontSize: 9.5, fontWeight: FontWeight.w500))])),
            Text('$_completion%', style: const TextStyle(color: _primary, fontSize: 17, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 13),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: _completion / 100, minHeight: 7, backgroundColor: const Color(0xFFEEEFFD), valueColor: const AlwaysStoppedAnimation(_primary))),
        ]),
      );

  Widget _sectionHeading(String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .8)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w500)),
      ]);

  Widget _personalDetailsCard() => Container(
        padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
        decoration: _cardDecoration(),
        child: Column(children: [
          _detailRow(Icons.person_outline_rounded, 'Full name', _value('name'), isFirst: true),
          _detailRow(Icons.phone_outlined, 'Mobile number', _value('phone')),
          _detailRow(Icons.mail_outline_rounded, 'Email address', _value('email')),
          Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 10), child: SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_outlined, size: 15),
            label: const Text('Edit personal details'),
            style: OutlinedButton.styleFrom(foregroundColor: _primary, side: const BorderSide(color: Color(0xFFDCD9FF)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)), padding: const EdgeInsets.symmetric(vertical: 12), textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ))),
        ]),
      );

  String _value(String key) {
    final value = (_profile[key] ?? '').toString().trim();
    return value.isEmpty ? 'Not added yet' : value;
  }

  Widget _detailRow(IconData icon, String label, String value, {bool isFirst = false}) => Container(
        padding: EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(border: isFirst ? null : const Border(top: BorderSide(color: _line))),
        child: Row(children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: _primary, size: 16)),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: value == 'Not added yet' ? const Color(0xFFA1A7B8) : _ink, fontSize: 11, fontWeight: FontWeight.w800))])),
        ]),
      );

  Widget _addressesSection() => Column(children: [
        if (_addresses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 23, 20, 20),
            decoration: _cardDecoration(),
            child: Column(children: [
              Container(width: 55, height: 55, decoration: BoxDecoration(color: const Color(0xFFEDEBFF), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.location_on_outlined, color: _primary, size: 25)),
              const SizedBox(height: 12),
              const Text('No saved addresses yet', style: TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              const Text('Save your home or work address for quicker bookings.', textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 10, height: 1.45)),
              const SizedBox(height: 14),
              _addAddressButton(),
            ]),
          )
        else ...[
          ..._addresses.map((address) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _AddressCard(address: address, onTap: () => _showAddressActions(address)))),
          _addAddressButton(),
        ],
      ]);

  Widget _addAddressButton() => SizedBox(width: double.infinity, child: OutlinedButton.icon(
        onPressed: _addAddress,
        icon: const Icon(Icons.add_location_alt_outlined, size: 16),
        label: const Text('Add a new address'),
        style: OutlinedButton.styleFrom(foregroundColor: _primary, side: const BorderSide(color: Color(0xFFDCD9FF)), backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 14), textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
      ));

  Widget _accountMenu() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: _cardDecoration(),
        child: Column(children: [
          _menuRow(Icons.people_alt_outlined, 'Family members', 'Manage profiles for your family', () => _comingSoon('Family members')),
          _menuRow(Icons.receipt_long_outlined, 'Payments & invoices', 'View your payment history', () => _comingSoon('Payments & invoices')),
          _menuRow(Icons.notifications_none_rounded, 'Notifications', 'Your reminders and updates', () => _comingSoon('Notifications')),
          _menuRow(Icons.description_outlined, 'My documents', 'Reports and shared documents', () => _comingSoon('My documents')),
          _menuRow(Icons.help_outline_rounded, 'Help & support', 'We are here when you need us', () => _comingSoon('Help & support')),
          _menuRow(Icons.privacy_tip_outlined, 'Privacy & terms', 'How your information is used', () => _comingSoon('Privacy & terms'), isLast: true),
        ]),
      );

  Widget _menuRow(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isLast = false}) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: _line))),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: _primary, size: 17)),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _ink, fontSize: 11, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w500))])),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFA0A6B7), size: 19),
          ]),
        ),
      );

  Widget _signOutButton() => SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _signingOut ? null : _signOut,
          icon: _signingOut ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD84F60))) : const Icon(Icons.logout_rounded, size: 17),
          label: Text(_signingOut ? 'Signing out...' : 'Sign out'),
          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD84F60), side: const BorderSide(color: Color(0xFFF2D6DA)), backgroundColor: const Color(0xFFFFF9FA), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 15), textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
        ),
      );

  BoxDecoration _cardDecoration() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(21), border: Border.all(color: _line), boxShadow: [BoxShadow(color: const Color(0xFF27345D).withOpacity(.03), blurRadius: 15, offset: const Offset(0, 5))]);
}

class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator(color: Color(0xFF5146D9), strokeWidth: 2.5));
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFF5D4D8))),
        child: Row(children: [const Icon(Icons.info_outline_rounded, color: Color(0xFFC54C5C), size: 18), const SizedBox(width: 9), Expanded(child: Text(message, style: const TextStyle(color: Color(0xFF9D3D4B), fontSize: 10, fontWeight: FontWeight.w600))), TextButton(onPressed: onRetry, child: const Text('Retry'))]),
      );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.formKey, required this.nameController, required this.emailController, required this.phoneController});
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  static const Color _ink = Color(0xFF111936);
  static const Color _primary = Color(0xFF5146D9);
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: SingleChildScrollView(child: Form(key: widget.formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDE0EA), borderRadius: BorderRadius.circular(5)))),
            const SizedBox(height: 20),
            const Text('Edit personal details', style: TextStyle(color: _ink, fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            const Text('Keep your account information current.', style: TextStyle(color: Color(0xFF77809A), fontSize: 11)),
            const SizedBox(height: 19),
            _FormField(label: 'Full name', hint: 'Enter your full name', controller: widget.nameController, icon: Icons.person_outline_rounded, validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null),
            const SizedBox(height: 13),
            _FormField(label: 'Email address', hint: 'Enter your email', controller: widget.emailController, icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress, validator: (v) { final value = v?.trim() ?? ''; if (value.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) return 'Enter a valid email address'; return null; }),
            const SizedBox(height: 13),
            _FormField(label: 'Mobile number', hint: 'Enter your phone number', controller: widget.phoneController, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () { if (widget.formKey.currentState?.validate() ?? false) Navigator.pop(context, true); },
              style: FilledButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.symmetric(vertical: 15)),
              child: const Text('Save changes', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            )),
          ]))),
        ),
      );
}

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.hint, required this.controller, required this.icon, this.keyboardType, this.validator});
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Color(0xFF303957), fontSize: 10, fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Color(0xFF111936), fontSize: 12, fontWeight: FontWeight.w600),
          decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Color(0xFFA0A6B8), fontSize: 11), prefixIcon: Icon(icon, color: const Color(0xFF7771D9), size: 18), filled: true, fillColor: const Color(0xFFF8F9FD), contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8EAF2))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8EAF2))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF8178F5), width: 1.4)), errorStyle: const TextStyle(fontSize: 9)),
        ),
      ]);
}

class _AddressEditorSheet extends StatefulWidget {
  const _AddressEditorSheet({this.address});
  final _SavedAddress? address;
  @override
  State<_AddressEditorSheet> createState() => _AddressEditorSheetState();
}

class _AddressEditorSheetState extends State<_AddressEditorSheet> {
  static const Color _ink = Color(0xFF111936);
  static const Color _primary = Color(0xFF5146D9);
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _line = TextEditingController(text: widget.address?.addressLine ?? '');
  late final TextEditingController _landmark = TextEditingController(text: widget.address?.landmark ?? '');
  late final TextEditingController _area = TextEditingController(text: widget.address?.area ?? '');
  late final TextEditingController _city = TextEditingController(text: widget.address?.city ?? '');
  late final TextEditingController _state = TextEditingController(text: widget.address?.state ?? '');
  late final TextEditingController _postal = TextEditingController(text: widget.address?.postalCode ?? '');
  late String _label = widget.address?.label ?? 'Home';
  late bool _default = widget.address?.isDefault ?? false;

  @override
  void dispose() {
    _line.dispose(); _landmark.dispose(); _area.dispose(); _city.dispose(); _state.dispose(); _postal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .88),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDE0EA), borderRadius: BorderRadius.circular(5)))),
            const SizedBox(height: 18),
            Text(widget.address == null ? 'Add a saved address' : 'Edit saved address', style: const TextStyle(color: _ink, fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            const Text('Save a location for a smoother booking experience.', style: TextStyle(color: Color(0xFF77809A), fontSize: 10)),
            const SizedBox(height: 15),
            Row(children: ['Home', 'Work', 'Other'].map((label) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 7), child: ChoiceChip(label: Center(child: Text(label)), selected: _label == label, onSelected: (_) => setState(() => _label = label), selectedColor: const Color(0xFFECEBFF), backgroundColor: const Color(0xFFF7F8FC), labelStyle: TextStyle(color: _label == label ? _primary : const Color(0xFF69718B), fontSize: 10, fontWeight: FontWeight.w800), side: BorderSide(color: _label == label ? const Color(0xFFD5D1FF) : const Color(0xFFE8EAF2)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))).toList()),
            const SizedBox(height: 13),
            Flexible(child: SingleChildScrollView(child: Column(children: [
              _AddressInput(label: 'Flat, house no. and street', controller: _line, requiredField: true),
              _AddressInput(label: 'Landmark (optional)', controller: _landmark),
              _AddressInput(label: 'Area / locality', controller: _area, requiredField: true),
              Row(children: [Expanded(child: _AddressInput(label: 'City', controller: _city, requiredField: true)), const SizedBox(width: 10), Expanded(child: _AddressInput(label: 'State', controller: _state, requiredField: true))]),
              _AddressInput(label: 'PIN code', controller: _postal, requiredField: true, keyboardType: TextInputType.number),
            ]))),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _default,
              activeColor: _primary,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Set as my default address', style: TextStyle(color: _ink, fontSize: 11, fontWeight: FontWeight.w800)),
              onChanged: (value) => setState(() => _default = value ?? false),
            ),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                if (!(_formKey.currentState?.validate() ?? false)) return;
                final parts = [_line.text.trim(), _landmark.text.trim(), _area.text.trim(), _city.text.trim(), _state.text.trim(), _postal.text.trim()].where((e) => e.isNotEmpty).toList();
                Navigator.pop(context, _AddressDraft(label: _label, addressLine: _line.text.trim(), landmark: _landmark.text.trim(), area: _area.text.trim(), city: _city.text.trim(), state: _state.text.trim(), postalCode: _postal.text.trim(), formattedAddress: parts.join(', '), isDefault: _default));
              },
              style: FilledButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.symmetric(vertical: 15)),
              child: Text(widget.address == null ? 'Save address' : 'Update address', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            )),
          ]),
        ),
      );
}

class _AddressInput extends StatelessWidget {
  const _AddressInput({required this.label, required this.controller, this.requiredField = false, this.keyboardType});
  final String label;
  final TextEditingController controller;
  final bool requiredField;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: requiredField ? (value) => (value == null || value.trim().isEmpty) ? 'Required' : null : null,
          style: const TextStyle(color: Color(0xFF111936), fontSize: 11, fontWeight: FontWeight.w600),
          decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Color(0xFF838AA0), fontSize: 10), filled: true, fillColor: const Color(0xFFF8F9FD), contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xFFE8EAF2))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xFFE8EAF2))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xFF8178F5), width: 1.3)), errorStyle: const TextStyle(fontSize: 9)),
        ),
      );
}

class _AddressActionsSheet extends StatelessWidget {
  const _AddressActionsSheet({required this.address, required this.onEdit, required this.onDefault, required this.onDelete});
  final _SavedAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDefault;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 38, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDE0EA), borderRadius: BorderRadius.circular(5))),
          const SizedBox(height: 16),
          Text(address.label, style: const TextStyle(color: Color(0xFF111936), fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(address.formattedAddress, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF77809A), fontSize: 10, height: 1.4)),
          const SizedBox(height: 14),
          _ActionTile(icon: Icons.edit_outlined, title: 'Edit address', onTap: onEdit),
          if (!address.isDefault) _ActionTile(icon: Icons.check_circle_outline_rounded, title: 'Make default address', onTap: onDefault),
          _ActionTile(icon: Icons.delete_outline_rounded, title: 'Delete address', color: const Color(0xFFD84F60), onTap: onDelete),
        ]),
      );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.onTap, this.color = const Color(0xFF5146D9)});
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 4), leading: Icon(icon, color: color, size: 20), title: Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)), onTap: onTap, dense: true);
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onTap});
  final _SavedAddress address;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final icon = address.label == 'Work' ? Icons.work_outline_rounded : address.label == 'Other' ? Icons.place_outlined : Icons.home_outlined;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: _line), boxShadow: [BoxShadow(color: const Color(0xFF27345D).withOpacity(.025), blurRadius: 14, offset: const Offset(0, 4))]),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 39, height: 39, decoration: BoxDecoration(color: const Color(0xFFEDEBFF), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: const Color(0xFF5146D9), size: 19)),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text(address.label, style: const TextStyle(color: Color(0xFF111936), fontSize: 12, fontWeight: FontWeight.w900)), const SizedBox(width: 7), if (address.isDefault) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFE8F8F2), borderRadius: BorderRadius.circular(7)), child: const Text('DEFAULT', style: TextStyle(color: Color(0xFF168B6B), fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: .4))]),
              const SizedBox(height: 6),
              Text(address.formattedAddress, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF77809A), fontSize: 10, height: 1.45, fontWeight: FontWeight.w500)),
            ])),
            const SizedBox(width: 5),
            const Icon(Icons.more_horiz_rounded, color: Color(0xFF9299AD), size: 21),
          ]),
        ),
      ),
    );
  }
}

class _SavedAddress {
  const _SavedAddress({required this.id, required this.label, required this.addressLine, required this.landmark, required this.area, required this.city, required this.state, required this.postalCode, required this.formattedAddress, required this.isDefault});
  final String id;
  final String label;
  final String addressLine;
  final String landmark;
  final String area;
  final String city;
  final String state;
  final String postalCode;
  final String formattedAddress;
  final bool isDefault;
  factory _SavedAddress.fromFirestore(String id, Map<String, dynamic> data) {
    String s(String key) => (data[key] ?? '').toString();
    final formatted = s('formattedAddress').trim();
    final fallback = [s('addressLine'), s('landmark'), s('area'), s('city'), s('state'), s('postalCode')].where((e) => e.trim().isNotEmpty).join(', ');
    return _SavedAddress(id: id, label: s('label').isEmpty ? 'Other' : s('label'), addressLine: s('addressLine'), landmark: s('landmark'), area: s('area'), city: s('city'), state: s('state'), postalCode: s('postalCode'), formattedAddress: formatted.isEmpty ? fallback : formatted, isDefault: data['isDefault'] == true);
  }
}

class _AddressDraft {
  const _AddressDraft({required this.label, required this.addressLine, required this.landmark, required this.area, required this.city, required this.state, required this.postalCode, required this.formattedAddress, required this.isDefault});
  final String label;
  final String addressLine;
  final String landmark;
  final String area;
  final String city;
  final String state;
  final String postalCode;
  final String formattedAddress;
  final bool isDefault;
}

class _FooterNote extends StatelessWidget {
  const _FooterNote();
  @override
  Widget build(BuildContext context) => const Column(children: [
        Text('PHYSIOHOMEY', style: TextStyle(color: Color(0xFF9BA2B5), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.8)),
        SizedBox(height: 5),
        Text('Move better. Feel stronger.', style: TextStyle(color: Color(0xFFADB3C2), fontSize: 9, fontWeight: FontWeight.w600)),
      ]);
}
