import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/booking_model.dart';

// ================================================================
// BOOKING SERVICE
// ================================================================
//
// Handles:
//
// ✓ Create booking
// ✓ Get booking
// ✓ User booking stream
// ✓ Physiotherapist booking stream
// ✓ Update booking status
// ✓ Update payment status
// ✓ Cancel booking
// ✓ Accept / reject booking
//
// ================================================================

class BookingService {
  const BookingService();

  // ==============================================================
  // COLLECTION
  // ==============================================================

  static const String _collectionName = 'bookings';

  // ==============================================================
  // FIRESTORE INSTANCE
  // ==============================================================

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // ==============================================================
  // BOOKINGS COLLECTION
  // ==============================================================

  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection(_collectionName);

  // ==============================================================
  // CREATE BOOKING
  // ==============================================================

  Future<BookingModel> createBooking(
    BookingModel booking,
  ) async {
    try {
      // ------------------------------------------------------------
      // CREATE DOCUMENT REFERENCE
      // ------------------------------------------------------------

      final document = booking.id.trim().isNotEmpty
          ? _bookingsCollection.doc(booking.id)
          : _bookingsCollection.doc();

      final now = DateTime.now();

      // ------------------------------------------------------------
      // CREATE FINAL BOOKING
      // ------------------------------------------------------------

      final bookingToSave = booking.copyWith(
        id: document.id,
        createdAt: booking.createdAt ?? now,
        updatedAt: now,
      );

      // ------------------------------------------------------------
      // SAVE TO FIRESTORE
      // ------------------------------------------------------------

      await document.set(
        bookingToSave.toMap(),
      );

      debugPrint(
        '✅ Booking created successfully: ${document.id}',
      );

      return bookingToSave;
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error creating booking: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // GET BOOKING BY ID
  // ==============================================================

  Future<BookingModel?> getBookingById(
    String bookingId,
  ) async {
    try {
      if (bookingId.trim().isEmpty) {
        return null;
      }

      final document =
          await _bookingsCollection.doc(bookingId).get();

      if (!document.exists) {
        return null;
      }

      return BookingModel.fromFirestore(document);
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error getting booking $bookingId: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // STREAM BOOKING BY ID
  // ==============================================================

  Stream<BookingModel?> streamBookingById(
    String bookingId,
  ) {
    if (bookingId.trim().isEmpty) {
      return Stream.value(null);
    }

    return _bookingsCollection.doc(bookingId).snapshots().map(
      (document) {
        if (!document.exists) {
          return null;
        }

        return BookingModel.fromFirestore(document);
      },
    );
  }

  // ==============================================================
  // STREAM USER BOOKINGS
  // ==============================================================

  Stream<List<BookingModel>> streamUserBookings(
    String userId,
  ) {
    if (userId.trim().isEmpty) {
      return Stream.value(<BookingModel>[]);
    }

    return _bookingsCollection
        .where(
          'userId',
          isEqualTo: userId,
        )
        .snapshots()
        .map(
      (snapshot) {
        final bookings = snapshot.docs
            .map(BookingModel.fromFirestore)
            .toList();

        // Sort locally to avoid requiring Firestore composite indexes.
        bookings.sort(
          (a, b) {
            final aDate = a.createdAt ?? DateTime(2000);
            final bDate = b.createdAt ?? DateTime(2000);

            return bDate.compareTo(aDate);
          },
        );

        return bookings;
      },
    );
  }

  // ==============================================================
  // STREAM PHYSIOTHERAPIST BOOKINGS
  // ==============================================================

  Stream<List<BookingModel>> streamPhysiotherapistBookings(
    String physiotherapistId,
  ) {
    if (physiotherapistId.trim().isEmpty) {
      return Stream.value(<BookingModel>[]);
    }

    return _bookingsCollection
        .where(
          'physiotherapistId',
          isEqualTo: physiotherapistId,
        )
        .snapshots()
        .map(
      (snapshot) {
        final bookings = snapshot.docs
            .map(BookingModel.fromFirestore)
            .toList();

        bookings.sort(
          (a, b) {
            final aDate = a.createdAt ?? DateTime(2000);
            final bDate = b.createdAt ?? DateTime(2000);

            return bDate.compareTo(aDate);
          },
        );

        return bookings;
      },
    );
  }

  // ==============================================================
  // UPDATE COMPLETE BOOKING
  // ==============================================================

  Future<void> updateBooking(
    BookingModel booking,
  ) async {
    try {
      if (booking.id.trim().isEmpty) {
        throw Exception(
          'Booking ID cannot be empty.',
        );
      }

      final updatedBooking = booking.copyWith(
        updatedAt: DateTime.now(),
      );

      await _bookingsCollection
          .doc(updatedBooking.id)
          .update(updatedBooking.toMap());

      debugPrint(
        '✅ Booking updated: ${updatedBooking.id}',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error updating booking: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // UPDATE BOOKING STATUS
  // ==============================================================

  Future<void> updateBookingStatus({
    required String bookingId,
    required String bookingStatus,
  }) async {
    try {
      if (bookingId.trim().isEmpty) {
        throw Exception(
          'Booking ID cannot be empty.',
        );
      }

      await _bookingsCollection.doc(bookingId).update({
        'bookingStatus': bookingStatus,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      debugPrint(
        '✅ Booking status updated: $bookingStatus',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error updating booking status: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // ACCEPT BOOKING
  // ==============================================================

  Future<void> acceptBooking(
    String bookingId,
  ) async {
    try {
      final now = DateTime.now();

      await _bookingsCollection.doc(bookingId).update({
        'bookingStatus': 'confirmed',
        'acceptedAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      debugPrint(
        '✅ Booking accepted: $bookingId',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error accepting booking: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // REJECT BOOKING
  // ==============================================================

  Future<void> rejectBooking({
    required String bookingId,
    String? reason,
  }) async {
    try {
      final now = DateTime.now();

      await _bookingsCollection.doc(bookingId).update({
        'bookingStatus': 'rejected',
        'rejectionReason': reason,
        'rejectedAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      debugPrint(
        '❌ Booking rejected: $bookingId',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error rejecting booking: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // UPDATE PAYMENT STATUS
  // ==============================================================

  Future<void> updatePaymentStatus({
    required String bookingId,
    required String paymentStatus,
    String? paymentMethod,
    String? paymentOrderId,
    String? paymentId,
    String? transactionId,
    double? paidAmount,
  }) async {
    try {
      final data = <String, dynamic>{
        'paymentStatus': paymentStatus,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (paymentMethod != null) {
        data['paymentMethod'] = paymentMethod;
      }

      if (paymentOrderId != null) {
        data['paymentOrderId'] = paymentOrderId;
      }

      if (paymentId != null) {
        data['paymentId'] = paymentId;
      }

      if (transactionId != null) {
        data['transactionId'] = transactionId;
      }

      if (paidAmount != null) {
        data['paidAmount'] = paidAmount;
      }

      await _bookingsCollection
          .doc(bookingId)
          .update(data);

      debugPrint(
        '💳 Payment updated: $bookingId → $paymentStatus',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error updating payment: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // MARK PAYMENT SUCCESSFUL
  // ==============================================================

  Future<void> markPaymentSuccessful({
    required String bookingId,
    required String paymentId,
    String? paymentOrderId,
    String? transactionId,
    required double paidAmount,
  }) async {
    try {
      final now = DateTime.now();

      await _bookingsCollection.doc(bookingId).update({
        'paymentStatus': 'paid',
        'paymentMethod': 'online',
        'paymentId': paymentId,
        'paymentOrderId': paymentOrderId,
        'transactionId': transactionId,
        'paidAmount': paidAmount,

        // After successful payment, booking waits
        // for physiotherapist acceptance.
        'bookingStatus': 'pendingAcceptance',

        'updatedAt': Timestamp.fromDate(now),
      });

      debugPrint(
        '💳 Payment successful for booking: $bookingId',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error marking payment successful: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // MARK PAYMENT FAILED
  // ==============================================================

  Future<void> markPaymentFailed(
    String bookingId,
  ) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'paymentStatus': 'failed',
        'bookingStatus': 'pendingPayment',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      debugPrint(
        '❌ Payment failed for booking: $bookingId',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error marking payment failed: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // CANCEL BOOKING
  // ==============================================================

  Future<void> cancelBooking({
    required String bookingId,
    required String cancelledBy,
    String? reason,
  }) async {
    try {
      final now = DateTime.now();

      await _bookingsCollection.doc(bookingId).update({
        'bookingStatus': 'cancelled',
        'cancelledBy': cancelledBy,
        'cancellationReason': reason,
        'cancelledAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      debugPrint(
        '🚫 Booking cancelled: $bookingId',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error cancelling booking: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // PHYSIOTHERAPIST ON THE WAY
  // ==============================================================

  Future<void> markPhysiotherapistOnTheWay(
    String bookingId,
  ) async {
    try {
      final now = DateTime.now();

      await _bookingsCollection.doc(bookingId).update({
        'bookingStatus': 'physiotherapistOnTheWay',
        'physiotherapistOnTheWayAt':
            Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      debugPrint(
        '🚗 Physiotherapist is on the way: $bookingId',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error updating on-the-way status: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // MARK ARRIVED
  // ==============================================================

  Future<void> markArrived(
    String bookingId,
  ) async {
    try {
      final now = DateTime.now();

      await _bookingsCollection.doc(bookingId).update({
        'bookingStatus': 'arrived',
        'arrivedAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      debugPrint(
        '📍 Physiotherapist arrived: $bookingId',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error marking arrived: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // START SESSION
  // ==============================================================

  Future<void> startSession(
    String bookingId,
  ) async {
    try {
      final now = DateTime.now();

      await _bookingsCollection.doc(bookingId).update({
        'bookingStatus': 'inProgress',
        'sessionStartedAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      debugPrint(
        '🩺 Session started: $bookingId',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error starting session: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // COMPLETE BOOKING / SESSION
  // ==============================================================

  Future<void> completeBooking(
    String bookingId,
  ) async {
    try {
      final now = DateTime.now();

      await _bookingsCollection.doc(bookingId).update({
        'bookingStatus': 'completed',
        'completedAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      debugPrint(
        '✅ Booking completed: $bookingId',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error completing booking: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ==============================================================
  // DELETE BOOKING
  // ==============================================================
  //
  // Normally, do NOT delete real bookings.
  // Keep this only for testing/admin purposes.
  //
  // ==============================================================

  Future<void> deleteBooking(
    String bookingId,
  ) async {
    try {
      await _bookingsCollection
          .doc(bookingId)
          .delete();

      debugPrint(
        '🗑️ Booking deleted: $bookingId',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error deleting booking: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}