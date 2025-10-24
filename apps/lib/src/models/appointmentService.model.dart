// lib/domain/appointment_service.dart

import 'package:apps/src/models/appointment.model.dart';
import 'package:apps/src/data/database.dart';

// Domain Service - Contains main business logic
class AppointmentService {
  final Database _db;

  AppointmentService(this._db);

  // Result sealed class for better error handling
  ScheduleAppointmentResult scheduleAppointment(
      String patientId, String doctorId, DateTime dateTime) {
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
          message:
              'Doctor is not available at this time. Please choose another slot.');
    }

    // Business Rule: Check if patient is available
    if (patient.appointments.any((appt) =>
        appt.dateTime == dateTime &&
        appt.status == AppointmentStatus.scheduled)) {
      return ScheduleAppointmentResult(
          success: false,
          message:
              'Patient already has an appointment at this time.');
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

  bool cancelAppointment(String appointmentId) {
    final appointment = _db.getAppointment(appointmentId);
    if (appointment == null) {
      return false;
    }

    // Business Rule: Change status to cancelled
    appointment.status = AppointmentStatus.cancelled;
    
    // Also remove from doctor and patient lists for availability
    appointment.doctor.removeAppointment(appointment);
    appointment.patient.removeAppointment(appointment);
    
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
}

class ScheduleAppointmentResult {
  final bool success;
  final String message;
  final Appointment? appointment;

  ScheduleAppointmentResult(
      {required this.success, required this.message, this.appointment});
}