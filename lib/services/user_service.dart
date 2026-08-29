import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserService {
  // ==============================================================
  // FIRESTORE INSTANCE
  // ==============================================================

  final FirebaseFirestore _firestore;

  UserService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  // ==============================================================
  // COLLECTION
  // ==============================================================

  CollectionReference<Map<String, dynamic>>
      get _usersCollection =>
          _firestore.collection('users');

  // ==============================================================
  // CREATE USER PROFILE
  // ==============================================================
  //
  // Creates:
  //
  // users/{uid}
  //
  // We use set() with merge so we don't accidentally overwrite
  // existing fields if this method is called again.
  // ==============================================================

  Future<void> createUser({
    required UserModel user,
  }) async {
    await _usersCollection
        .doc(user.uid)
        .set(
          user.toFirestore(),
          SetOptions(merge: true),
        );
  }

  // ==============================================================
  // GET USER
  // ==============================================================
  //
  // Direct document read = fast and cheap.
  //
  // users/{uid}
  // ==============================================================

  Future<UserModel?> getUser(
    String uid,
  ) async {
    final document =
        await _usersCollection.doc(uid).get();

    if (!document.exists) {
      return null;
    }

    return UserModel.fromFirestore(document);
  }

  // ==============================================================
  // CHECK IF USER EXISTS
  // ==============================================================

  Future<bool> userExists(
    String uid,
  ) async {
    final document =
        await _usersCollection.doc(uid).get();

    return document.exists;
  }

  // ==============================================================
  // UPDATE USER PROFILE
  // ==============================================================

  Future<void> updateUser({
    required String uid,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    bool? isActive,
    bool? isProfileCompleted,
  }) async {
    final Map<String, dynamic> data = {};

    // Only update fields that were actually provided.

    if (name != null) {
      data['name'] = name.trim();
    }

    if (email != null) {
      data['email'] = email.trim();
    }

    if (phone != null) {
      data['phone'] = phone.trim();
    }

    if (profileImageUrl != null) {
      data['profileImageUrl'] =
          profileImageUrl.trim();
    }

    if (isActive != null) {
      data['isActive'] = isActive;
    }

    if (isProfileCompleted != null) {
      data['isProfileCompleted'] =
          isProfileCompleted;
    }

    // Always update modification time.
    data['updatedAt'] =
        FieldValue.serverTimestamp();

    await _usersCollection
        .doc(uid)
        .update(data);
  }

  // ==============================================================
  // UPDATE COMPLETE USER MODEL
  // ==============================================================

  Future<void> saveUser(
    UserModel user,
  ) async {
    await _usersCollection
        .doc(user.uid)
        .set(
          user.toFirestore(),
          SetOptions(merge: true),
        );
  }

  // ==============================================================
  // UPDATE PROFILE IMAGE
  // ==============================================================

  Future<void> updateProfileImage({
    required String uid,
    required String imageUrl,
  }) async {
    await _usersCollection
        .doc(uid)
        .update({
      'profileImageUrl': imageUrl,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // DELETE PROFILE IMAGE
  // ==============================================================

  Future<void> removeProfileImage({
    required String uid,
  }) async {
    await _usersCollection
        .doc(uid)
        .update({
      'profileImageUrl': null,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // MARK PROFILE COMPLETED
  // ==============================================================

  Future<void> completeProfile({
    required String uid,
  }) async {
    await _usersCollection
        .doc(uid)
        .update({
      'isProfileCompleted': true,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // DEACTIVATE USER
  // ==============================================================

  Future<void> deactivateUser({
    required String uid,
  }) async {
    await _usersCollection
        .doc(uid)
        .update({
      'isActive': false,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==============================================================
  // REAL-TIME USER STREAM
  // ==============================================================
  //
  // Use this ONLY where live profile updates are useful.
  // Don't use it everywhere unnecessarily.
  // ==============================================================

  Stream<UserModel?> watchUser(
    String uid,
  ) {
    return _usersCollection
        .doc(uid)
        .snapshots()
        .map(
      (document) {
        if (!document.exists) {
          return null;
        }

        return UserModel.fromFirestore(
          document,
        );
      },
    );
  }

  // ==============================================================
  // DELETE USER DOCUMENT
  // ==============================================================
  //
  // NOTE:
  // This deletes only the Firestore profile.
  // It does NOT delete Firebase Authentication.
  // ==============================================================

  Future<void> deleteUserDocument(
    String uid,
  ) async {
    await _usersCollection
        .doc(uid)
        .delete();
  }
}