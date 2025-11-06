import 'package:apps/src/domains/appointment.dart';
import 'package:apps/src/database/database.dart';
import 'package:apps/src/domains/medication.dart';
import 'package:apps/src/domains/utils/scedule.dart';
import 'package:apps/src/domains/appointmentStatus.dart';
import 'package:apps/src/domains/utils/prescriptionResult.dart';
import "package:apps/src/domains/utils/sceduleAppointmentResult.dart";

/// Domain Service - Contains main business logic
class AppointmentService {
  final Database _db;

  AppointmentService(this._db);

  /// Schedule Appointment
  ScheduleAppointmentResult scheduleAppointment(
      String patientId,
      String doctorId,
      DateTime dateTime) {
    final patient = _db.getPatient(patientId);

    /// Business Rule: Check if patient exists
    if (patient == null) {
      return ScheduleAppointmentResult(
          success: false,
          message: 'Patient not found.');
    }

    /// GETTING DATA: get doctor by ID
    final doctor = _db.getDoctor(doctorId);

    /// BUSINESS RULE: Check if Doctor exists
    if (doctor == null) {
      return ScheduleAppointmentResult(
          success: false,
          message: 'Doctor not found.');
    }

    /// BUSINESS RULE: Check if doctor is available
    if (!doctor.isAvailable(dateTime)) {
      return ScheduleAppointmentResult(
          success: false,
          message: 'Doctor is not available at this time. Please choose another slot.');
    }

    /// BUSINESS RULE: Check if patient is available
    if (patient.appointments.any((appt) =>
        appt.start == dateTime &&
        appt.status == AppointmentStatus.scheduled)) {
      return ScheduleAppointmentResult(
          success: false,
          message: 'Patient already has an appointment at this time.');
    }

    ///
    final appointment = _db.createAppointment(patient, doctor, dateTime);

    /// BUSINESS RULE: If appointment is created,
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

  /// Reschedule Appointment
  ScheduleAppointmentResult rescheduleAppointment(
      String appointmentId,
      DateTime newDateTime) {
    final originalAppointment = _db.getAppointment(appointmentId);

    if (originalAppointment == null) {
      return ScheduleAppointmentResult(
          success: false,
          message: 'Appointment not found.');
    }

    final doctor = originalAppointment.doctor;
    final patient = originalAppointment.patient;

    // Check if doctor is available at the new time
    if (!doctor.isAvailable(newDateTime)) {
      return ScheduleAppointmentResult(
          success: false,
          message: 'Doctor is not available at the new time. Please choose another slot.');
    }

    // Check if patient is available at the new time, excluding the current appointment
    if (patient.appointments.any((appt) =>
        appt.id != appointmentId &&
        appt.start == newDateTime &&
        appt.status == AppointmentStatus.scheduled)) {
      return ScheduleAppointmentResult(
          success: false,
          message: 'Patient already has another appointment at the new time.');
    }

    // If all checks pass, create a new appointment with the new time
    final newAppointment = Appointment(
      id: originalAppointment.id,
      patientId: originalAppointment.patientId,
      doctorId: originalAppointment.doctorId,
      start: newDateTime,
      status: originalAppointment.status,
      notes: originalAppointment.notes,
    );

    // Link models for the new appointment
    newAppointment.linkModels(_db);

    // Remove the original appointment from doctor and patient and add the new one
    doctor.removeAppointment(originalAppointment.id);
    doctor.scheduleAppointment(newAppointment);
    patient.cancelAppointment(originalAppointment.id); // This actually removes from patient's list
    patient.scheduleAppointment(newAppointment);

    // Update the appointment in the database
    _db.updateAppointment(newAppointment);
    return ScheduleAppointmentResult(
        success: true,
        appointment: newAppointment,
        message: 'Appointment rescheduled successfully.');
  }

  /// --- Prescription ---
  PrescriptionResult issuePrescription(
      String patientId, String doctorId, List<Medication> medications, {String? notes}) { // Changed to List<Medication>

    /// GETTING DATA: get patient by ID
    final patient = _db.getPatient(patientId);

    /// BUSINESS RULE: check if patient exists
    if (patient == null) {
      return PrescriptionResult(
          success: false, message: 'Patient not found.');
    }

    /// GETTING DATA: get doctor by ID
    final doctor = _db.getDoctor(doctorId);

    /// BUSINESS RULE: check if doctor exists
    if (doctor == null) {
      return PrescriptionResult(
          success: false, message: 'Doctor not found.');
    }

    /// BUSINESS RULE: check if doctor is available
    if (medications.isEmpty) {
      return PrescriptionResult(
          success: false, message: 'Medication and Dosage cannot be empty.');
    }

    /// GETTING DATA: create prescription
    final prescription = _db.createPrescription(patient, doctor, medications, notes: notes);

    /// BUSINESS RULE: if prescription is created,
    if (prescription != null) {
      return PrescriptionResult(
          success: true,
          prescription: prescription,
          message: 'Prescription issued successfully.');
    } else {
      return PrescriptionResult(
          success: false, message: 'Failed to create prescription in database.');
    }
  }

  /// --- Patient && Appointment ---
  bool deletePatientAndCancelAppointments(String patientId) {

    /// GETTING DATA: get patient by ID
    final patient = _db.getPatient(patientId);

    /// BUSINESS RULE: check if patient exists
    if (patient == null) {
      return false;
    }

    /// GETTING DATA: get all appointments for the patient
    final patientAppointments = List.of(patient.appointments);

    /// BUSINESS RULE: cancel all scheduled appointments
    for (final appt in patientAppointments) {
      if (appt.status == AppointmentStatus.scheduled) {
        cancelAppointment(appt.id);
      }
    }
    return _db.deletePatient(patientId);
  }

  /// --- Doctor && Appointment ---
  bool deleteDoctorAndCancelAppointments(String doctorId) {
    /// GETTING DATA: get doctor by ID
    final doctor = _db.getDoctor(doctorId);
    if (doctor == null) {
      return false;
    }

    /// BUSINESS RULE: Find all appointments for this doctor
    final doctorAppointments = _db.getAppointmentsForDoctor(doctorId);

    /// BUSINESS RULE: Cancel all scheduled appointments
    for (final appt in doctorAppointments) {
      if (appt.status == AppointmentStatus.scheduled) {
        cancelAppointment(appt.id);
      }
    }
    return _db.deleteDoctor(doctorId);
  }

  /// Appointment
  bool cancelAppointment(String appointmentId) {

    /// GETTING DATA: get appointment by ID
    final appointment = _db.getAppointment(appointmentId);
    if (appointment == null) {
      return false;
    }

    /// Business Rule: Change status to cancelled
    appointment.status = AppointmentStatus.cancelled;
    
    /// Business Rule: Remove appointment from doctor and patient
    appointment.doctor.removeAppointment(appointment.id);
    appointment.patient.cancelAppointment(appointment.id);

    /// BUSINESS RULE: Update appointment in database
    _db.updateAppointment(appointment);
    return true;
  }

  /// List of get appointment from patient by ID
  List<Appointment> getAppointmentsForPatient(String patientId) {

    /// GETTING DATA: get patient by ID
    final patient = _db.getPatient(patientId);

    ///BUSINESS DATA: get all appointments for the patient to list
    return patient?.appointments
            .where((appt) => appt.status == AppointmentStatus.scheduled) // Only scheduled appointments
            .toList() ?? [];
  }

  /// List of get appointment from doctor by ID
  List<Appointment> getAppointmentsForDoctor(String doctorId) {

    ///GETTING DATA: get doctor by ID
    final doctor = _db.getDoctor(doctorId);

    /// BUSINESS DATA: get all appointments for the doctor to list
    return doctor?.appointments
            .where((appt) => appt.status == AppointmentStatus.scheduled) // Only scheduled appointments
            .toList() ?? [];
  }

  /// List of get available slots from doctor by ID
  List<DateTime> getAvailableSlots(String doctorId, DateTime date) {

    /// GETTING DATA: get doctor by ID
    final doctor = _db.getDoctor(doctorId);
    if (doctor == null) {
      return [];
    }

    // 1. Get all 1-hour slots for the day (8:00, 9:00, ..., 16:00)
    final allSlots = Schedule.getWorkSlotsForDay(date);
    final availableSlots = <DateTime>[];
    // const duration = Duration(hours: 1); // We are checking 1-hour slots

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