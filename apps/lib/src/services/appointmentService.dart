import 'package:apps/src/domains/appointment.dart';
import 'package:apps/src/database/database.dart';
import 'package:apps/src/domains/prescription.dart';
import 'package:apps/src/domains/medication.dart';
import 'package:apps/src/domains/scedule.dart';
import '../domains/appointmentStatus.dart';

// Domain Service - Contains main business logic
class AppointmentService {
  final Database _db;

  AppointmentService(this._db);

  // Result sealed class for better error handling
  ScheduleAppointmentResult scheduleAppointment(
      String patientId,
      String doctorId,
      DateTime dateTime) {
    final patient = _db.getPatient(patientId);
    if (patient == null) {
      return ScheduleAppointmentResult(
          success: false, message: 'Patient not found.');
    }

    final doctor = _db.getDoctor(doctorId);
    if (doctor == null) {
      return ScheduleAppointmentResult(
          success: false, message: 'Doctor not found.');
    }

    // Business Rule: Check if doctor is available
    if (!doctor.isAvailable(dateTime)) {
      return ScheduleAppointmentResult(
          success: false,
          message: 'Doctor is not available at this time. Please choose another slot.');
    }

    // Business Rule: Check if patient is available
    if (patient.appointments.any((appt) =>
        appt.start == dateTime &&
        appt.status == AppointmentStatus.scheduled)) {
      return ScheduleAppointmentResult(
          success: false,
          message: 'Patient already has an appointment at this time.');
    }

    final appointment = _db.createAppointment(patient, doctor, dateTime);
    if (appointment != null) {
      return ScheduleAppointmentResult(
          success: true,
          appointment: appointment,
          message: 'Appointment scheduled successfully.');
    } else {
      return ScheduleAppointmentResult(
          success: false, message: 'Failed to create appointment in database.');
    }
  }

  IssuePrescriptionResult issuePrescription(
      String patientId, String doctorId, List<Medication> medications, {String? notes}) { // Changed to List<Medication>

    final patient = _db.getPatient(patientId);
    if (patient == null) {
      return IssuePrescriptionResult(
          success: false, message: 'Patient not found.');
    }

    final doctor = _db.getDoctor(doctorId);
    if (doctor == null) {
      return IssuePrescriptionResult(
          success: false, message: 'Doctor not found.');
    }

    if (medications.isEmpty) { // Check if list is empty
      return IssuePrescriptionResult(
          success: false, message: 'Medication and Dosage cannot be empty.');
    }

    final prescription = _db.createPrescription(patient, doctor, medications, notes: notes); // Pass the list

    if (prescription != null) {
      return IssuePrescriptionResult(
          success: true,
          prescription: prescription,
          message: 'Prescription issued successfully.');
    } else {
      return IssuePrescriptionResult(
          success: false, message: 'Failed to create prescription in database.');
    }
  }
  bool deletePatientAndCancelAppointments(String patientId) {
    final patient = _db.getPatient(patientId);
    if (patient == null) {
      return false; // Patient not found
    }

    // Create a copy of the appointments list to avoid modification errors during iteration.
    final patientAppointments = List.of(patient.appointments);

    for (final appt in patientAppointments) {
      // If the appointment is scheduled, cancel it.
      if (appt.status == AppointmentStatus.scheduled) {
        // We re-use our existing cancellation logic.
        // This updates the status and removes it from the doctor's list.
        cancelAppointment(appt.id);
      }
      // No need to handle completed or already cancelled appointments.
    }

    // After handling all appointments, delete the patient from the database.
    // This is the single source of truth for patient records.
    return _db.deletePatient(patientId);
  }

  bool deleteDoctorAndCancelAppointments(String doctorId) {
    final doctor = _db.getDoctor(doctorId);
    if (doctor == null) {
      return false; // Doctor not found
    }

    // BUSINESS RULE: Find all appointments for this doctor
    final doctorAppointments = _db.getAppointmentsForDoctor(doctorId);
    
    for (final appt in doctorAppointments) {
      // If the appointment is scheduled, cancel it
      if (appt.status == AppointmentStatus.scheduled) {
        // We re-use our existing cancellation logic
        cancelAppointment(appt.id);
      }
    }

    // After handling appointments, delete the doctor from the database
    return _db.deleteDoctor(doctorId);
  }

  bool cancelAppointment(String appointmentId) {
    final appointment = _db.getAppointment(appointmentId);
    if (appointment == null) {
      return false;
    }

    // Business Rule: Change status to cancelled
    appointment.status = AppointmentStatus.cancelled;
    
    // Also remove from doctor and patient lists for availability
    appointment.doctor.removeAppointment(appointment.id);
    appointment.patient.cancelAppointment(appointment.id);
    
    _db.updateAppointment(appointment);
    return true;
  }

  List<Appointment> getAppointmentsForPatient(String patientId) {
    final patient = _db.getPatient(patientId);
    return patient?.appointments
            .where((appt) => appt.status == AppointmentStatus.scheduled)
            .toList() ??
        [];
  }

  List<Appointment> getAppointmentsForDoctor(String doctorId) {
    final doctor = _db.getDoctor(doctorId);
    return doctor?.appointments
            .where((appt) => appt.status == AppointmentStatus.scheduled)
            .toList() ??
        [];
  }

  List<DateTime> getAvailableSlots(String doctorId, DateTime date) {
    final doctor = _db.getDoctor(doctorId);
    if (doctor == null) {
      return [];
    }

    // 1. Get all 1-hour slots for the day (8:00, 9:00, ..., 16:00)
    final allSlots = Schedule.getWorkSlotsForDay(date);
    final availableSlots = <DateTime>[];

    // 2. Loop through each possible slot
    for (final slot in allSlots) {
      // 3. Ask the doctor object if they are available for 1 hour
      if (doctor.isAvailable(slot)) {
        availableSlots.add(slot);
      }
    }
    return availableSlots;
  }
}

class ScheduleAppointmentResult {
  final bool success;
  final String message;
  final Appointment? appointment;

  ScheduleAppointmentResult(
      {required this.success, required this.message, this.appointment});
}

class IssuePrescriptionResult {
  final bool success;
  final String message;
  final Prescription? prescription;

  IssuePrescriptionResult(
      {required this.success, required this.message, this.prescription});
}