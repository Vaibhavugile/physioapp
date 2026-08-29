import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment_model.dart';

class AppointmentService {
  // ==============================================================
  // FIRESTORE
  // ==============================================================

  final FirebaseFirestore _firestore;

  AppointmentService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  // ==============================================================
  // COLLECTION
  // ==============================================================

  static const String _collectionName =
      'appointments';

  CollectionReference<Map<String, dynamic>>
      get _appointmentsCollection =>
          _firestore.collection(
            _collectionName,
          );

  // ==============================================================
  // CREATE APPOINTMENT
  // ==============================================================

  Future<String> createAppointment({
    required AppointmentModel appointment,
  }) async {
    final documentReference =
        appointment.id.isNotEmpty
            ? _appointmentsCollection.doc(
                appointment.id,
              )
            : _appointmentsCollection.doc();

    final appointmentData =
        appointment.copyWith(
          id: documentReference.id,
        );

    await documentReference.set(
      appointmentData.toMap(),
    );

    return documentReference.id;
  }

  // ==============================================================
  // GET SINGLE APPOINTMENT
  // ==============================================================

  Future<AppointmentModel?>
      getAppointment(
    String appointmentId,
  ) async {
    final document =
        await _appointmentsCollection
            .doc(appointmentId)
            .get();

    if (!document.exists) {
      return null;
    }

    return AppointmentModel.fromDocument(
      document,
    );
  }

  // ==============================================================
  // STREAM SINGLE APPOINTMENT
  // ==============================================================

  Stream<AppointmentModel?>
      streamAppointment(
    String appointmentId,
  ) {
    return _appointmentsCollection
        .doc(appointmentId)
        .snapshots()
        .map((document) {
      if (!document.exists) {
        return null;
      }

      return AppointmentModel.fromDocument(
        document,
      );
    });
  }

  // ==============================================================
  // UPDATE APPOINTMENT
  // ==============================================================

  Future<void> updateAppointment({
    required String appointmentId,
    required Map<String, dynamic> data,
  }) async {
    final updateData =
        Map<String, dynamic>.from(data);

    updateData['updatedAt'] =
        FieldValue.serverTimestamp();

    await _appointmentsCollection
        .doc(appointmentId)
        .update(updateData);
  }

  // ==============================================================
  // UPDATE FULL APPOINTMENT
  // ==============================================================

  Future<void> saveAppointment({
    required AppointmentModel appointment,
  }) async {
    if (appointment.id.isEmpty) {
      await createAppointment(
        appointment: appointment,
      );

      return;
    }

    await _appointmentsCollection
        .doc(appointment.id)
        .set(
          appointment.toMap(),
          SetOptions(merge: true),
        );
  }

  // ==============================================================
  // DELETE APPOINTMENT
  // ==============================================================
  //
  // Normally we should NOT delete appointments.
  // We keep history and mark them as cancelled.
  //
  // This method is available for admin/testing.
  // ==============================================================

  Future<void> deleteAppointment(
    String appointmentId,
  ) async {
    await _appointmentsCollection
        .doc(appointmentId)
        .delete();
  }

  // ==============================================================
  // GET USER APPOINTMENTS
  // ==============================================================

  Future<List<AppointmentModel>>
      getUserAppointments({
    required String userId,
    int limit = 50,
  }) async {
    final snapshot =
        await _appointmentsCollection
            .where(
              'userId',
              isEqualTo: userId,
            )
            .orderBy(
              'appointmentDate',
              descending: true,
            )
            .limit(limit)
            .get();

    return snapshot.docs
        .map(
          AppointmentModel.fromDocument,
        )
        .toList();
  }

  // ==============================================================
  // STREAM USER APPOINTMENTS
  // ==============================================================

  Stream<List<AppointmentModel>>
      streamUserAppointments({
    required String userId,
    int limit = 50,
  }) {
    return _appointmentsCollection
        .where(
          'userId',
          isEqualTo: userId,
        )
        .orderBy(
          'appointmentDate',
          descending: true,
        )
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            AppointmentModel.fromDocument,
          )
          .toList();
    });
  }

  // ==============================================================
  // GET UPCOMING APPOINTMENTS
  // ==============================================================

  Future<List<AppointmentModel>>
      getUpcomingAppointments({
    required String userId,
    int limit = 20,
  }) async {
    final now = Timestamp.fromDate(
      DateTime.now(),
    );

    final snapshot =
        await _appointmentsCollection
            .where(
              'userId',
              isEqualTo: userId,
            )
            .where(
              'appointmentDate',
              isGreaterThanOrEqualTo: now,
            )
            .orderBy(
              'appointmentDate',
            )
            .limit(limit)
            .get();

    final appointments = snapshot.docs
        .map(
          AppointmentModel.fromDocument,
        )
        .where(
          (appointment) =>
              appointment.status != 'cancelled' &&
              appointment.status != 'completed' &&
              appointment.status != 'noShow',
        )
        .toList();

    return appointments;
  }

  // ==============================================================
  // STREAM UPCOMING APPOINTMENTS
  // ==============================================================

  Stream<List<AppointmentModel>>
      streamUpcomingAppointments({
    required String userId,
    int limit = 20,
  }) {
    final now = Timestamp.fromDate(
      DateTime.now(),
    );

    return _appointmentsCollection
        .where(
          'userId',
          isEqualTo: userId,
        )
        .where(
          'appointmentDate',
          isGreaterThanOrEqualTo: now,
        )
        .orderBy(
          'appointmentDate',
        )
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            AppointmentModel.fromDocument,
          )
          .where(
            (appointment) =>
                appointment.status != 'cancelled' &&
                appointment.status != 'completed' &&
                appointment.status != 'noShow',
          )
          .toList();
    });
  }

  // ==============================================================
  // GET NEXT UPCOMING APPOINTMENT
  // ==============================================================
  //
  // This is what we'll use on HomeScreen.
  // ==============================================================

  Future<AppointmentModel?>
      getNextUpcomingAppointment({
    required String userId,
  }) async {
    final appointments =
        await getUpcomingAppointments(
      userId: userId,
      limit: 10,
    );

    if (appointments.isEmpty) {
      return null;
    }

    return appointments.first;
  }

  // ==============================================================
  // STREAM NEXT UPCOMING APPOINTMENT
  // ==============================================================
  //
  // PERFECT FOR HOMESCREEN
  // ==============================================================

  Stream<AppointmentModel?>
      streamNextUpcomingAppointment({
    required String userId,
  }) {
    return streamUpcomingAppointments(
      userId: userId,
      limit: 10,
    ).map((appointments) {
      if (appointments.isEmpty) {
        return null;
      }

      return appointments.first;
    });
  }

  // ==============================================================
  // CONFIRM APPOINTMENT
  // ==============================================================

  Future<void> confirmAppointment({
    required String appointmentId,
  }) async {
    await updateAppointment(
      appointmentId: appointmentId,
      data: {
        'status': 'confirmed',
      },
    );
  }

  // ==============================================================
  // ASSIGN PHYSIOTHERAPIST
  // ==============================================================

  Future<void> assignPhysiotherapist({
    required String appointmentId,
    required String physiotherapistId,
    required String physiotherapistName,
    required String physiotherapistImageUrl,
    required String specialization,
  }) async {
    await updateAppointment(
      appointmentId: appointmentId,
      data: {
        'physiotherapistId':
            physiotherapistId,

        'physiotherapistName':
            physiotherapistName,

        'physiotherapistImageUrl':
            physiotherapistImageUrl,

        'physiotherapistSpecialization':
            specialization,

        'isPhysiotherapistAssigned':
            true,

        'status': 'assigned',
      },
    );
  }

  // ==============================================================
  // MARK CHECKED IN
  // ==============================================================

  Future<void> checkIn({
    required String appointmentId,
  }) async {
    await updateAppointment(
      appointmentId: appointmentId,
      data: {
        'status': 'checkedIn',

        'checkedInAt':
            FieldValue.serverTimestamp(),
      },
    );
  }

  // ==============================================================
  // START SESSION
  // ==============================================================

  Future<void> startSession({
    required String appointmentId,
  }) async {
    await updateAppointment(
      appointmentId: appointmentId,
      data: {
        'status': 'inProgress',

        'sessionStartedAt':
            FieldValue.serverTimestamp(),
      },
    );
  }

  // ==============================================================
  // COMPLETE SESSION
  // ==============================================================

  Future<void> completeSession({
    required String appointmentId,
  }) async {
    final appointment =
        await getAppointment(
      appointmentId,
    );

    if (appointment == null) {
      throw Exception(
        'Appointment not found.',
      );
    }

    final updateData =
        <String, dynamic>{
      'status': 'completed',

      'sessionCompletedAt':
          FieldValue.serverTimestamp(),
    };

    // ------------------------------------------------------------
    // PACKAGE SESSION UPDATE
    // ------------------------------------------------------------

    if (appointment.isPackageBooking) {
      final completedSessions =
          (appointment.completedSessions ?? 0) + 1;

      final totalSessions =
          appointment.totalSessions ?? 0;

      final remainingSessions =
          totalSessions - completedSessions;

      updateData['completedSessions'] =
          completedSessions;

      updateData['remainingSessions'] =
          remainingSessions < 0
              ? 0
              : remainingSessions;
    }

    await updateAppointment(
      appointmentId: appointmentId,
      data: updateData,
    );
  }

  // ==============================================================
  // CANCEL APPOINTMENT
  // ==============================================================

  Future<void> cancelAppointment({
    required String appointmentId,
    required String reason,

    String cancelledBy = 'user',
  }) async {
    await updateAppointment(
      appointmentId: appointmentId,
      data: {
        'status': 'cancelled',

        'cancellationReason':
            reason.trim(),

        'cancelledBy':
            cancelledBy,

        'cancelledAt':
            FieldValue.serverTimestamp(),
      },
    );
  }

  // ==============================================================
  // RESCHEDULE APPOINTMENT
  // ==============================================================

  Future<void> rescheduleAppointment({
    required String appointmentId,

    required DateTime newDate,

    required String newStartTime,

    String? newEndTime,

    String? reason,
  }) async {
    final appointment =
        await getAppointment(
      appointmentId,
    );

    if (appointment == null) {
      throw Exception(
        'Appointment not found.',
      );
    }

    await updateAppointment(
      appointmentId: appointmentId,
      data: {
        'status': 'rescheduled',

        'isRescheduled': true,

        'originalAppointmentDate':
            Timestamp.fromDate(
          appointment.appointmentDate,
        ),

        'originalStartTime':
            appointment.startTime,

        'appointmentDate':
            Timestamp.fromDate(
          newDate,
        ),

        'startTime':
            newStartTime.trim(),

        if (newEndTime != null)
          'endTime':
              newEndTime.trim(),

        if (reason != null)
          'rescheduleReason':
              reason.trim(),
      },
    );
  }

  // ==============================================================
  // UPDATE PAYMENT
  // ==============================================================

  Future<void> updatePayment({
    required String appointmentId,

    required String paymentStatus,

    String? paymentMethod,

    String? transactionId,
  }) async {
    await updateAppointment(
      appointmentId: appointmentId,
      data: {
        'paymentStatus':
            paymentStatus,

        if (paymentMethod != null)
          'paymentMethod':
              paymentMethod,

        if (transactionId != null)
          'transactionId':
              transactionId,
      },
    );
  }

  // ==============================================================
  // ADD REVIEW
  // ==============================================================

  Future<void> addReview({
    required String appointmentId,

    required double rating,

    String? review,
  }) async {
    if (rating < 1 || rating > 5) {
      throw Exception(
        'Rating must be between 1 and 5.',
      );
    }

    await updateAppointment(
      appointmentId: appointmentId,
      data: {
        'rating': rating,

        'review':
            review?.trim() ?? '',

        'reviewedAt':
            FieldValue.serverTimestamp(),
      },
    );
  }

  // ==============================================================
  // MARK NO SHOW
  // ==============================================================

  Future<void> markNoShow({
    required String appointmentId,
  }) async {
    await updateAppointment(
      appointmentId: appointmentId,
      data: {
        'status': 'noShow',
      },
    );
  }

  // ==============================================================
  // GET APPOINTMENTS BY STATUS
  // ==============================================================

  Future<List<AppointmentModel>>
      getAppointmentsByStatus({
    required String userId,
    required String status,
    int limit = 50,
  }) async {
    final snapshot =
        await _appointmentsCollection
            .where(
              'userId',
              isEqualTo: userId,
            )
            .where(
              'status',
              isEqualTo: status,
            )
            .orderBy(
              'appointmentDate',
              descending: true,
            )
            .limit(limit)
            .get();

    return snapshot.docs
        .map(
          AppointmentModel.fromDocument,
        )
        .toList();
  }

  // ==============================================================
  // STREAM APPOINTMENTS BY STATUS
  // ==============================================================

  Stream<List<AppointmentModel>>
      streamAppointmentsByStatus({
    required String userId,
    required String status,
    int limit = 50,
  }) {
    return _appointmentsCollection
        .where(
          'userId',
          isEqualTo: userId,
        )
        .where(
          'status',
          isEqualTo: status,
        )
        .orderBy(
          'appointmentDate',
          descending: true,
        )
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            AppointmentModel.fromDocument,
          )
          .toList();
    });
  }
}