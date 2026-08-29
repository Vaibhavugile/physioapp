import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recovery_program_model.dart';

class RecoveryProgramService {
  // ==============================================================
  // FIRESTORE
  // ==============================================================

  final FirebaseFirestore _firestore;

  RecoveryProgramService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  // ==============================================================
  // COLLECTION
  // ==============================================================

  static const String _collectionName =
      'recovery_programs';

  CollectionReference<Map<String, dynamic>>
      get _collection =>
          _firestore.collection(
            _collectionName,
          );

  // ==============================================================
  // GET ALL ACTIVE PROGRAMS
  // ==============================================================

  Future<List<RecoveryProgramModel>>
      getActivePrograms() async {
    final snapshot = await _collection
        .where(
          'isActive',
          isEqualTo: true,
        )
        .orderBy(
          'displayOrder',
        )
        .get();

    return snapshot.docs
        .map(
          RecoveryProgramModel.fromFirestore,
        )
        .toList();
  }

  // ==============================================================
  // REAL-TIME ACTIVE PROGRAMS
  // ==============================================================

  Stream<List<RecoveryProgramModel>>
      streamActivePrograms({
    int? limit,
  }) {
    Query<Map<String, dynamic>> query =
        _collection
            .where(
              'isActive',
              isEqualTo: true,
            )
            .orderBy(
              'displayOrder',
            );

    if (limit != null && limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map(
              RecoveryProgramModel.fromFirestore,
            )
            .toList();
      },
    );
  }

  // ==============================================================
  // FEATURED PROGRAMS
  // ==============================================================

  Future<List<RecoveryProgramModel>>
      getFeaturedPrograms() async {
    final snapshot = await _collection
        .where(
          'isActive',
          isEqualTo: true,
        )
        .where(
          'isFeatured',
          isEqualTo: true,
        )
        .orderBy(
          'displayOrder',
        )
        .get();

    return snapshot.docs
        .map(
          RecoveryProgramModel.fromFirestore,
        )
        .toList();
  }

  // ==============================================================
  // REAL-TIME FEATURED PROGRAMS
  // ==============================================================

  Stream<List<RecoveryProgramModel>>
      streamFeaturedPrograms({
    int limit = 10,
  }) {
    return _collection
        .where(
          'isActive',
          isEqualTo: true,
        )
        .where(
          'isFeatured',
          isEqualTo: true,
        )
        .orderBy(
          'displayOrder',
        )
        .limit(limit)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs
            .map(
              RecoveryProgramModel.fromFirestore,
            )
            .toList();
      },
    );
  }

  // ==============================================================
  // GET SINGLE PROGRAM
  // ==============================================================

  Future<RecoveryProgramModel?>
      getProgram(
    String programId,
  ) async {
    if (programId.trim().isEmpty) {
      return null;
    }

    final document = await _collection
        .doc(programId)
        .get();

    if (!document.exists) {
      return null;
    }

    return RecoveryProgramModel
        .fromFirestore(document);
  }

  // ==============================================================
  // REAL-TIME SINGLE PROGRAM
  // ==============================================================

  Stream<RecoveryProgramModel?>
      streamProgram(
    String programId,
  ) {
    if (programId.trim().isEmpty) {
      return Stream.value(null);
    }

    return _collection
        .doc(programId)
        .snapshots()
        .map(
      (document) {
        if (!document.exists) {
          return null;
        }

        return RecoveryProgramModel
            .fromFirestore(document);
      },
    );
  }

  // ==============================================================
  // CREATE PROGRAM
  // ==============================================================

  Future<String> createProgram({
    required RecoveryProgramModel program,
  }) async {
    final now =
        FieldValue.serverTimestamp();

    final document =
        program.id.trim().isNotEmpty
            ? _collection.doc(program.id)
            : _collection.doc();

    await document.set({
      ...program.toMap(),

      'createdAt':
          program.createdAt != null
              ? Timestamp.fromDate(
                  program.createdAt!,
                )
              : now,

      'updatedAt': now,
    });

    return document.id;
  }

  // ==============================================================
  // UPDATE PROGRAM
  // ==============================================================

  Future<void> updateProgram({
    required String programId,
    required Map<String, dynamic> data,
  }) async {
    if (programId.trim().isEmpty) {
      throw Exception(
        'Program ID cannot be empty.',
      );
    }

    await _collection
        .doc(programId)
        .update({
      ...data,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // SAVE / REPLACE PROGRAM
  // ==============================================================

  Future<void> saveProgram({
    required RecoveryProgramModel program,
  }) async {
    if (program.id.trim().isEmpty) {
      throw Exception(
        'Program ID cannot be empty.',
      );
    }

    await _collection
        .doc(program.id)
        .set(
      {
        ...program.toMap(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  // ==============================================================
  // DELETE PROGRAM
  // ==============================================================

  Future<void> deleteProgram(
    String programId,
  ) async {
    if (programId.trim().isEmpty) {
      return;
    }

    await _collection
        .doc(programId)
        .delete();
  }

  // ==============================================================
  // ENABLE / DISABLE PROGRAM
  // ==============================================================

  Future<void> setProgramActive({
    required String programId,
    required bool isActive,
  }) async {
    if (programId.trim().isEmpty) {
      throw Exception(
        'Program ID cannot be empty.',
      );
    }

    await _collection
        .doc(programId)
        .update({
      'isActive': isActive,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // FEATURE / UNFEATURE PROGRAM
  // ==============================================================

  Future<void> setProgramFeatured({
    required String programId,
    required bool isFeatured,
  }) async {
    if (programId.trim().isEmpty) {
      throw Exception(
        'Program ID cannot be empty.',
      );
    }

    await _collection
        .doc(programId)
        .update({
      'isFeatured': isFeatured,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // UPDATE DISPLAY ORDER
  // ==============================================================

  Future<void> updateDisplayOrder({
    required String programId,
    required int displayOrder,
  }) async {
    if (programId.trim().isEmpty) {
      throw Exception(
        'Program ID cannot be empty.',
      );
    }

    await _collection
        .doc(programId)
        .update({
      'displayOrder': displayOrder,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // SEARCH PROGRAMS
  // ==============================================================
  //
  // Firestore does not support efficient general text search.
  //
  // This method fetches active programs and filters locally.
  //
  // For large datasets later, we can integrate Algolia,
  // Typesense, or another dedicated search solution.
  // ==============================================================

  Future<List<RecoveryProgramModel>>
      searchPrograms(
    String query,
  ) async {
    final searchText =
        query.trim().toLowerCase();

    final programs =
        await getActivePrograms();

    if (searchText.isEmpty) {
      return programs;
    }

    return programs.where(
      (program) {
        return program.title
                .toLowerCase()
                .contains(searchText) ||
            program.category
                .toLowerCase()
                .contains(searchText) ||
            program.description
                .toLowerCase()
                .contains(searchText) ||
            program.conditions.any(
              (condition) => condition
                  .toLowerCase()
                  .contains(searchText),
            );
      },
    ).toList();
  }
}