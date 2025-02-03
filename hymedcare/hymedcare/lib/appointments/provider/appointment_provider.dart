import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/appointment_model.dart';
import '../../services/notification_service.dart';

class AppointmentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load appointments for a user (either doctor or patient)
  Future<void> loadAppointments(String userId, String role) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final query = _firestore.collection('appointments')
          .where(role == 'Doctor' ? 'doctorId' : 'patientId', isEqualTo: userId)
          .orderBy('dateTime', descending: false);

      final snapshot = await query.get();
      _appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load appointments: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new appointment
  Future<void> createAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorImageUrl,
    required String patientId,
    required String patientName,
    required String patientImageUrl,
    required DateTime dateTime,
    required String notes,
    List<String> patientFiles = const [],
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final appointmentData = {
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorImageUrl': doctorImageUrl,
        'patientId': patientId,
        'patientName': patientName,
        'patientImageUrl': patientImageUrl,
        'dateTime': Timestamp.fromDate(dateTime),
        'status': 'upcoming',
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
        'patientFiles': patientFiles,
        'doctorFiles': <String>[],
      };

      final docRef = await _firestore.collection('appointments').add(appointmentData);
      final doc = await docRef.get();
      
      // Create appointment model and schedule notifications
      final newAppointment = AppointmentModel.fromFirestore(doc);
      await _notificationService.scheduleAppointmentNotification(newAppointment);

      _appointments.add(newAppointment);
      _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create appointment: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Edit appointment
  Future<void> editAppointment({
    required String appointmentId,
    DateTime? newDateTime,
    String? newNotes,
    List<String>? newPatientFiles,
    String? reasonForChange,
  }) async {
    try {
      final appointmentRef = _firestore.collection('appointments').doc(appointmentId);
      final appointmentDoc = await appointmentRef.get();
      
      if (!appointmentDoc.exists) {
        throw 'Appointment not found';
      }

      final currentAppointment = AppointmentModel.fromFirestore(appointmentDoc);
      
      // Only allow editing if appointment is upcoming
      if (currentAppointment.status != 'upcoming') {
        throw 'Can only edit upcoming appointments';
      }

      final updates = <String, dynamic>{
        'lastModifiedAt': FieldValue.serverTimestamp(),
      };

      if (newDateTime != null) {
        updates['dateTime'] = Timestamp.fromDate(newDateTime);
        updates['originalDateTime'] = Timestamp.fromDate(currentAppointment.dateTime);
      }

      if (newNotes != null) {
        updates['notes'] = newNotes;
      }

      if (newPatientFiles != null) {
        updates['patientFiles'] = newPatientFiles;
      }

      if (reasonForChange != null) {
        updates['reasonForChange'] = reasonForChange;
      }

      await appointmentRef.update(updates);

      // Update local state
      final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
      if (index != -1) {
        final updatedAppointment = currentAppointment.copyWith(
          dateTime: newDateTime ?? currentAppointment.dateTime,
          notes: newNotes ?? currentAppointment.notes,
          patientFiles: newPatientFiles ?? currentAppointment.patientFiles,
          reasonForChange: reasonForChange,
          lastModifiedAt: DateTime.now(),
          originalDateTime: newDateTime != null ? currentAppointment.dateTime : currentAppointment.originalDateTime,
        );
        _appointments[index] = updatedAppointment;
        _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to edit appointment: $e';
      notifyListeners();
    }
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, String newStatus, {String? reasonForChange}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': newStatus,
        'lastModifiedAt': FieldValue.serverTimestamp(),
        if (reasonForChange != null) 'reasonForChange': reasonForChange,
      });

      // If appointment is cancelled or rejected, cancel the notifications
      if (newStatus.toLowerCase() == 'cancelled' || newStatus.toLowerCase() == 'rejected') {
        await _notificationService.cancelAppointmentNotifications(appointmentId);
      }

      // Update local state
      final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          status: newStatus,
          lastModifiedAt: DateTime.now(),
          reasonForChange: reasonForChange,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update appointment status: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add files to appointment
  Future<void> addFilesToAppointment({
    required String appointmentId,
    required List<String> fileUrls,
    required bool isDoctor,
  }) async {
    try {
      final field = isDoctor ? 'doctorFiles' : 'patientFiles';
      
      final appointmentRef = _firestore.collection('appointments').doc(appointmentId);
      final appointmentDoc = await appointmentRef.get();
      
      if (!appointmentDoc.exists) {
        throw 'Appointment not found';
      }

      final currentAppointment = AppointmentModel.fromFirestore(appointmentDoc);
      final currentFiles = isDoctor ? currentAppointment.doctorFiles : currentAppointment.patientFiles;
      final updatedFiles = [...currentFiles, ...fileUrls];

      await appointmentRef.update({
        field: updatedFiles,
        'lastModifiedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
      if (index != -1) {
        _appointments[index] = isDoctor 
          ? _appointments[index].copyWith(doctorFiles: updatedFiles, lastModifiedAt: DateTime.now())
          : _appointments[index].copyWith(patientFiles: updatedFiles, lastModifiedAt: DateTime.now());
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to add files to appointment: $e';
      notifyListeners();
    }
  }

  // Delete/Cancel appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      final appointmentRef = _firestore.collection('appointments').doc(appointmentId);
      final appointmentDoc = await appointmentRef.get();
      
      if (!appointmentDoc.exists) {
        throw 'Appointment not found';
      }

      final currentAppointment = AppointmentModel.fromFirestore(appointmentDoc);
      
      // Only allow deletion if appointment is upcoming
      if (currentAppointment.status != 'upcoming') {
        throw 'Can only delete upcoming appointments';
      }

      await appointmentRef.delete();

      // Update local state
      _appointments.removeWhere((apt) => apt.id == appointmentId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete appointment: $e';
      notifyListeners();
    }
  }

  // Get available time slots for a doctor on a specific date
  Future<List<DateTime>> getAvailableTimeSlots(String doctorId, DateTime date) async {
    try {
      // Get all appointments for the doctor on the specified date
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore.collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dateTime', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final bookedSlots = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .map((apt) => apt.dateTime)
          .toList();

      // Generate all possible time slots (e.g., every 30 minutes from 9 AM to 5 PM)
      final allSlots = <DateTime>[];
      var currentSlot = DateTime(date.year, date.month, date.day, 9, 0); // Start at 9 AM
      final endTime = DateTime(date.year, date.month, date.day, 17, 0); // End at 5 PM

      while (currentSlot.isBefore(endTime)) {
        allSlots.add(currentSlot);
        currentSlot = currentSlot.add(const Duration(minutes: 30));
      }

      // Remove booked slots
      return allSlots.where((slot) {
        return !bookedSlots.any((bookedSlot) =>
            bookedSlot.year == slot.year &&
            bookedSlot.month == slot.month &&
            bookedSlot.day == slot.day &&
            bookedSlot.hour == slot.hour &&
            bookedSlot.minute == slot.minute);
      }).toList();
    } catch (e) {
      _error = 'Failed to get available time slots: $e';
      notifyListeners();
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
