import 'package:cloud_firestore/cloud_firestore.dart';

class RecoveryProgramModel {
  // ==============================================================
  // BASIC INFORMATION
  // ==============================================================

  final String id;

  final String title;

  final String category;

  final String description;

  // ==============================================================
  // DISPLAY
  // ==============================================================

  final String imageUrl;

  final String imagePath;

  final int programCount;

  final int displayOrder;

  // ==============================================================
  // STATUS
  // ==============================================================

  final bool isActive;

  final bool isFeatured;

  // ==============================================================
  // PROGRAM DETAILS
  // ==============================================================

  final List<String> conditions;

  final List<String> benefits;

  final String difficultyLevel;

  final int estimatedDays;

  // ==============================================================
  // TIMESTAMPS
  // ==============================================================

  final DateTime? createdAt;

  final DateTime? updatedAt;

  // ==============================================================
  // CONSTRUCTOR
  // ==============================================================

  const RecoveryProgramModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.imagePath,
    required this.programCount,
    required this.displayOrder,
    required this.isActive,
    required this.isFeatured,
    required this.conditions,
    required this.benefits,
    required this.difficultyLevel,
    required this.estimatedDays,
    this.createdAt,
    this.updatedAt,
  });

  // ==============================================================
  // EMPTY MODEL
  // ==============================================================

  factory RecoveryProgramModel.empty() {
    return const RecoveryProgramModel(
      id: '',
      title: '',
      category: '',
      description: '',
      imageUrl: '',
      imagePath: '',
      programCount: 0,
      displayOrder: 0,
      isActive: true,
      isFeatured: false,
      conditions: [],
      benefits: [],
      difficultyLevel: '',
      estimatedDays: 0,
    );
  }

  // ==============================================================
  // FROM FIRESTORE
  // ==============================================================

  factory RecoveryProgramModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return RecoveryProgramModel(
      id: document.id,

      title: (data['title'] ?? '').toString(),

      category: (data['category'] ?? 'Physio Program')
          .toString(),

      description: (data['description'] ?? '')
          .toString(),

      // ----------------------------------------------------------
      // IMAGE
      // ----------------------------------------------------------

      imageUrl: (data['imageUrl'] ?? '')
          .toString(),

      imagePath: (data['imagePath'] ?? '')
          .toString(),

      // ----------------------------------------------------------
      // PROGRAM DATA
      // ----------------------------------------------------------

      programCount:
          _parseInt(data['programCount']),

      displayOrder:
          _parseInt(data['displayOrder']),

      // ----------------------------------------------------------
      // STATUS
      // ----------------------------------------------------------

      isActive:
          data['isActive'] ?? true,

      isFeatured:
          data['isFeatured'] ?? false,

      // ----------------------------------------------------------
      // LISTS
      // ----------------------------------------------------------

      conditions:
          _parseStringList(data['conditions']),

      benefits:
          _parseStringList(data['benefits']),

      // ----------------------------------------------------------
      // DETAILS
      // ----------------------------------------------------------

      difficultyLevel:
          (data['difficultyLevel'] ?? '')
              .toString(),

      estimatedDays:
          _parseInt(data['estimatedDays']),

      // ----------------------------------------------------------
      // TIMESTAMPS
      // ----------------------------------------------------------

      createdAt:
          _parseTimestamp(data['createdAt']),

      updatedAt:
          _parseTimestamp(data['updatedAt']),
    );
  }

  // ==============================================================
  // FROM MAP
  // ==============================================================

  factory RecoveryProgramModel.fromMap(
    Map<String, dynamic> data, {
    String id = '',
  }) {
    return RecoveryProgramModel(
      id: id.isNotEmpty
          ? id
          : (data['id'] ?? '').toString(),

      title:
          (data['title'] ?? '').toString(),

      category:
          (data['category'] ?? 'Physio Program')
              .toString(),

      description:
          (data['description'] ?? '').toString(),

      imageUrl:
          (data['imageUrl'] ?? '').toString(),

      imagePath:
          (data['imagePath'] ?? '').toString(),

      programCount:
          _parseInt(data['programCount']),

      displayOrder:
          _parseInt(data['displayOrder']),

      isActive:
          data['isActive'] ?? true,

      isFeatured:
          data['isFeatured'] ?? false,

      conditions:
          _parseStringList(data['conditions']),

      benefits:
          _parseStringList(data['benefits']),

      difficultyLevel:
          (data['difficultyLevel'] ?? '')
              .toString(),

      estimatedDays:
          _parseInt(data['estimatedDays']),

      createdAt:
          _parseTimestamp(data['createdAt']),

      updatedAt:
          _parseTimestamp(data['updatedAt']),
    );
  }

  // ==============================================================
  // TO MAP
  // ==============================================================

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'description': description,

      'imageUrl': imageUrl,
      'imagePath': imagePath,

      'programCount': programCount,
      'displayOrder': displayOrder,

      'isActive': isActive,
      'isFeatured': isFeatured,

      'conditions': conditions,
      'benefits': benefits,

      'difficultyLevel': difficultyLevel,
      'estimatedDays': estimatedDays,

      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : null,

      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : null,
    };
  }

  // ==============================================================
  // COPY WITH
  // ==============================================================

  RecoveryProgramModel copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? imageUrl,
    String? imagePath,
    int? programCount,
    int? displayOrder,
    bool? isActive,
    bool? isFeatured,
    List<String>? conditions,
    List<String>? benefits,
    String? difficultyLevel,
    int? estimatedDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecoveryProgramModel(
      id: id ?? this.id,

      title: title ?? this.title,

      category: category ?? this.category,

      description:
          description ?? this.description,

      imageUrl:
          imageUrl ?? this.imageUrl,

      imagePath:
          imagePath ?? this.imagePath,

      programCount:
          programCount ?? this.programCount,

      displayOrder:
          displayOrder ?? this.displayOrder,

      isActive:
          isActive ?? this.isActive,

      isFeatured:
          isFeatured ?? this.isFeatured,

      conditions:
          conditions ?? this.conditions,

      benefits:
          benefits ?? this.benefits,

      difficultyLevel:
          difficultyLevel ?? this.difficultyLevel,

      estimatedDays:
          estimatedDays ?? this.estimatedDays,

      createdAt:
          createdAt ?? this.createdAt,

      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  // ==============================================================
  // HELPER METHODS
  // ==============================================================

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static List<String> _parseStringList(
    dynamic value,
  ) {
    if (value is List) {
      return value
          .map(
            (item) => item.toString(),
          )
          .toList();
    }

    return [];
  }

  static DateTime? _parseTimestamp(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  // ==============================================================
  // DISPLAY HELPERS
  // ==============================================================

  bool get hasNetworkImage =>
      imageUrl.trim().isNotEmpty;

  bool get hasAssetImage =>
      imagePath.trim().isNotEmpty;

  bool get hasImage =>
      hasNetworkImage || hasAssetImage;

  String get displayCategory {
    if (category.trim().isEmpty) {
      return 'PHYSIO PROGRAM';
    }

    return category.toUpperCase();
  }

  String get displayProgramCount {
    if (programCount <= 0) {
      return 'Programs available';
    }

    if (programCount == 1) {
      return '1 Program';
    }

    return '$programCount Programs';
  }

  String get displayDifficulty {
    if (difficultyLevel.trim().isEmpty) {
      return 'All levels';
    }

    return difficultyLevel;
  }

  bool get hasConditions =>
      conditions.isNotEmpty;

  bool get hasBenefits =>
      benefits.isNotEmpty;
}