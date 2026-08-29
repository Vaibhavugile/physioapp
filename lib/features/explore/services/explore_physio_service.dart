import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../models/physiotherapist_model.dart';

// ================================================================
// EXPLORE PHYSIO SERVICE
// ================================================================
//
// Fetches real physiotherapists from Firebase Firestore.
//
// Returns only physiotherapists that are:
//
// ✓ Active
// ✓ Verified
// ✓ Approved / Verified status
//
// ================================================================

class ExplorePhysioService {
  const ExplorePhysioService();

  // ==============================================================
  // COLLECTION
  // ==============================================================

  static const String _collectionName = 'physiotherapists';

  // ==============================================================
  // FIRESTORE INSTANCE
  // ==============================================================

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // ==============================================================
  // GET AVAILABLE PHYSIOTHERAPISTS
  // ==============================================================

  Future<List<PhysiotherapistModel>>
      getAvailablePhysiotherapists() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore
              .collection(_collectionName)
              .get();

      final List<PhysiotherapistModel> physiotherapists =
          <PhysiotherapistModel>[];

      for (final QueryDocumentSnapshot<Map<String, dynamic>>
          document in snapshot.docs) {
        try {
          final PhysiotherapistModel physio =
              PhysiotherapistModel.fromFirestore(
            document,
          );

          if (!_isAvailableForExplore(physio)) {
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

      // ============================================================
      // SORT BEST FIRST
      // ============================================================

      physiotherapists.sort(
        (a, b) {
          // Verified first
          if (a.isVerified != b.isVerified) {
            return a.isVerified ? -1 : 1;
          }

          // Higher rating first
          final ratingCompare =
              b.rating.compareTo(a.rating);

          if (ratingCompare != 0) {
            return ratingCompare;
          }

          // More reviews first
          final reviewsCompare =
              b.totalReviews.compareTo(
            a.totalReviews,
          );

          if (reviewsCompare != 0) {
            return reviewsCompare;
          }

          // More experience first
          return b.experienceYears.compareTo(
            a.experienceYears,
          );
        },
      );

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
  // Automatically updates Explore screen when Firebase changes.
  //
  // ==============================================================

  Stream<List<PhysiotherapistModel>>
      streamAvailablePhysiotherapists() {
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map(
      (
        QuerySnapshot<Map<String, dynamic>> snapshot,
      ) {
        final List<PhysiotherapistModel> physiotherapists =
            <PhysiotherapistModel>[];

        for (final QueryDocumentSnapshot<Map<String, dynamic>>
            document in snapshot.docs) {
          try {
            final PhysiotherapistModel physio =
                PhysiotherapistModel.fromFirestore(
              document,
            );

            if (!_isAvailableForExplore(physio)) {
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

        // ==========================================================
        // SORT LIVE RESULTS
        // ==========================================================

        physiotherapists.sort(
          (a, b) {
            if (a.isVerified != b.isVerified) {
              return a.isVerified ? -1 : 1;
            }

            final ratingCompare =
                b.rating.compareTo(a.rating);

            if (ratingCompare != 0) {
              return ratingCompare;
            }

            final reviewsCompare =
                b.totalReviews.compareTo(
              a.totalReviews,
            );

            if (reviewsCompare != 0) {
              return reviewsCompare;
            }

            return b.experienceYears.compareTo(
              a.experienceYears,
            );
          },
        );

        debugPrint(
          '🔄 Live available physiotherapists: '
          '${physiotherapists.length}',
        );

        return physiotherapists;
      },
    );
  }

  // ==============================================================
  // CHECK WHETHER PHYSIO SHOULD APPEAR IN EXPLORE
  // ==============================================================

  bool _isAvailableForExplore(
    PhysiotherapistModel physio,
  ) {
    // ------------------------------------------------------------
    // ACTIVE
    // ------------------------------------------------------------

    if (!physio.isActive) {
      return false;
    }

    // ------------------------------------------------------------
    // VERIFIED
    // ------------------------------------------------------------

    if (!physio.isVerified) {
      return false;
    }

    // ------------------------------------------------------------
    // VERIFICATION STATUS
    // ------------------------------------------------------------

    final String verificationStatus =
        physio.verificationStatus
            .trim()
            .toLowerCase();

    const List<String> allowedStatuses =
        <String>[
      'approved',
      'verified',
    ];

    if (!allowedStatuses.contains(
      verificationStatus,
    )) {
      return false;
    }

    return true;
  }

  // ==============================================================
  // GET SINGLE PHYSIOTHERAPIST
  // ==============================================================

  Future<PhysiotherapistModel?>
      getPhysiotherapistById(
    String uid,
  ) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>>
          document = await _firestore
              .collection(_collectionName)
              .doc(uid)
              .get();

      if (!document.exists) {
        return null;
      }

      final PhysiotherapistModel physio =
          PhysiotherapistModel.fromFirestore(
        document,
      );

      return physio;
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