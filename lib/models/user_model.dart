import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // ==============================================================
  // BASIC USER INFORMATION
  // ==============================================================

  final String uid;

  final String name;

  final String email;

  final String phone;

  final String? profileImageUrl;


  // ==============================================================
  // USER STATUS
  // ==============================================================

  final bool isActive;

  final bool isProfileCompleted;


  // ==============================================================
  // TIMESTAMPS
  // ==============================================================

  final DateTime? createdAt;

  final DateTime? updatedAt;


  // ==============================================================
  // CONSTRUCTOR
  // ==============================================================

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    this.isActive = true,
    this.isProfileCompleted = false,
    this.createdAt,
    this.updatedAt,
  });


  // ==============================================================
  // CREATE EMPTY / DEFAULT USER
  // ==============================================================

  factory UserModel.empty({
    required String uid,
  }) {
    return UserModel(
      uid: uid,
      name: '',
      email: '',
      phone: '',
      profileImageUrl: null,
      isActive: true,
      isProfileCompleted: false,
      createdAt: null,
      updatedAt: null,
    );
  }


  // ==============================================================
  // FIRESTORE → USER MODEL
  // ==============================================================

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return UserModel(
      uid: document.id,

      name: data['name'] as String? ?? '',

      email: data['email'] as String? ?? '',

      phone: data['phone'] as String? ?? '',

      profileImageUrl:
          data['profileImageUrl'] as String?,

      isActive:
          data['isActive'] as bool? ?? true,

      isProfileCompleted:
          data['isProfileCompleted'] as bool? ?? false,

      createdAt:
          (data['createdAt'] as Timestamp?)
              ?.toDate(),

      updatedAt:
          (data['updatedAt'] as Timestamp?)
              ?.toDate(),
    );
  }


  // ==============================================================
  // USER MODEL → FIRESTORE
  // ==============================================================

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,

      'profileImageUrl': profileImageUrl,

      'isActive': isActive,

      'isProfileCompleted':
          isProfileCompleted,

      // Only include these if available.
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),

      'updatedAt':
          FieldValue.serverTimestamp(),
    };
  }


  // ==============================================================
  // COPY WITH
  // ==============================================================

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    bool? isActive,
    bool? isProfileCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,

      name: name ?? this.name,

      email: email ?? this.email,

      phone: phone ?? this.phone,

      profileImageUrl:
          profileImageUrl ??
              this.profileImageUrl,

      isActive:
          isActive ?? this.isActive,

      isProfileCompleted:
          isProfileCompleted ??
              this.isProfileCompleted,

      createdAt:
          createdAt ?? this.createdAt,

      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }


  // ==============================================================
  // HELPFUL DISPLAY VALUES
  // ==============================================================

  String get firstName {
    if (name.trim().isEmpty) {
      return '';
    }

    return name
        .trim()
        .split(' ')
        .first;
  }


  String get displayName {
    if (name.trim().isNotEmpty) {
      return name.trim();
    }

    if (email.trim().isNotEmpty) {
      return email
          .trim()
          .split('@')
          .first;
    }

    return 'User';
  }


  String get initials {
    if (name.trim().isEmpty) {
      return 'U';
    }

    final parts = name
        .trim()
        .split(' ')
        .where(
          (part) => part.isNotEmpty,
        )
        .toList();

    if (parts.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts.first[0]
          .toUpperCase();
    }

    return '${parts.first[0]}'
            '${parts.last[0]}'
        .toUpperCase();
  }
}