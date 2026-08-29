import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../models/physiotherapist_model.dart';

// ================================================================
// EXPLORE PHYSIO SERVICE
// ================================================================
//
// Fetches real physiotherapists from Firebase Firestore.
//
// Only returns physiotherapists that are:
//
// ✓ Active
// ✓ Verified
// ✓ Profile completed
//
// ================================================================

class ExplorePhysioService {
  const ExplorePhysioService();

  // ==============================================================
  // COLLECTION
  // ==============================================================

  static const String _collectionName =
      'physiotherapists';

  // ==============================================================
  // FIRESTORE INSTANCE
  // ==============================================================

  FirebaseFirestore get _firestore =>
      FirebaseFirestore.instance;

  // ==============================================================
  // GET AVAILABLE PHYSIOTHERAPISTS
  // ==============================================================

  Future<List<PhysiotherapistModel>>
      getAvailablePhysiotherapists() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .get();

      final physiotherapists =
          <PhysiotherapistModel>[];

      for (final document in snapshot.docs) {
        try {
          // ========================================================
          // CREATE MODEL DIRECTLY FROM FIRESTORE DOCUMENT
          // ========================================================

          final physio =
              PhysiotherapistModel.fromFirestore(
            document,
          );

          // ========================================================
          // ONLY ACTIVE PHYSIOS
          // ========================================================

          if (!physio.isActive) {
            continue;
          }

          // ========================================================
          // ONLY VERIFIED PHYSIOS
          // ========================================================

          if (!physio.isVerified) {
            continue;
          }

          // ========================================================
          // ONLY APPROVED PROFILES
          // ========================================================

          final verificationStatus =
              physio.verificationStatus
                  .trim()
                  .toLowerCase();

          if (verificationStatus != 'approved' &&
              verificationStatus != 'verified') {
            continue;
          }

          physiotherapists.add(physio);
        } catch (error, stackTrace) {
          debugPrint(
            '❌ Error parsing physiotherapist '
            '${document.id}: $error',
          );

          debugPrintStack(
            stackTrace: stackTrace,
          );
        }
      }

      debugPrint(
        '✅ Available physiotherapists: '
        '${physiotherapists.length}',
      );

      return physiotherapists;
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error fetching physiotherapists: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // STREAM AVAILABLE PHYSIOTHERAPISTS
  // ==============================================================
  //
  // Automatically updates Explore screen when Firebase data changes.
  //
  // ==============================================================

  Stream<List<PhysiotherapistModel>>
      streamAvailablePhysiotherapists() {
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map(
      (snapshot) {
        final physiotherapists =
            <PhysiotherapistModel>[];

        for (final document in snapshot.docs) {
          try {
            // ======================================================
            // FIRESTORE → MODEL
            // ======================================================

            final physio =
                PhysiotherapistModel.fromFirestore(
              document,
            );

            // ======================================================
            // ACTIVE CHECK
            // ======================================================

            if (!physio.isActive) {
              continue;
            }

            // ======================================================
            // VERIFIED CHECK
            // ======================================================

            if (!physio.isVerified) {
              continue;
            }

            // ======================================================
            // APPROVAL CHECK
            // ======================================================

            final verificationStatus =
                physio.verificationStatus
                    .trim()
                    .toLowerCase();

            if (verificationStatus != 'approved' &&
                verificationStatus != 'verified') {
              continue;
            }

            physiotherapists.add(physio);
          } catch (error, stackTrace) {
            debugPrint(
              '❌ Error parsing physiotherapist '
              '${document.id}: $error',
            );

            debugPrintStack(
              stackTrace: stackTrace,
            );
          }
        }

        debugPrint(
          '🔄 Live available physiotherapists: '
          '${physiotherapists.length}',
        );

        return physiotherapists;
      },
    );
  }

  // ==============================================================
  // GET SINGLE PHYSIOTHERAPIST
  // ==============================================================

  Future<PhysiotherapistModel?>
      getPhysiotherapistById(
    String uid,
  ) async {
    try {
      final document = await _firestore
          .collection(_collectionName)
          .doc(uid)
          .get();

      if (!document.exists) {
        return null;
      }

      return PhysiotherapistModel.fromFirestore(
        document,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error fetching physiotherapist '
        '$uid: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}