// lib/domain/doctor.dart

import 'package:apps/src/models/appointment.model.dart';
import 'package:apps/src/models/staff.model.dart';
import 'package:apps/src/ui/consoleUtils.dart';
import 'package:apps/src/models/prescription.dart';
import 'package:apps/src/models/patient.model.dart';
import 'package:apps/src/models/medication.model.dart';

class Doctor extends Staff {
  String specialty;
  List<String> specializations;
  final List<Appointment> _appointments = [];

  Doctor({
    required super.id,
    required super.name,
    required super.contact,
    required super.staffId,
    required this.specialty,
    List<String>? specializations,
    super.department = 'Medical',
  }) : specializations = specializations ?? [specialty];

  // Encapsulation
  List<Appointment> get appointments => List.unmodifiable(_appointments);

  void scheduleAppointment(Appointment appointment) {
    _appointments.add(appointment);
  }

  void removeAppointment(String appointmentId) {
    _appointments.removeWhere((appt) => appt.id == appointmentId);
  }

  bool isAvailable(DateTime start, Duration duration) {
    // Check if the doctor has another appointment at the same time
    final end = start.add(duration);
    return !_appointments.any((appt) {
      if (appt.status != AppointmentStatus.scheduled) return false;
      final apptEnd = appt.start.add(appt.duration);
      // Check for overlap: appointment starts before end time and ends after start time
      return appt.start.isBefore(end) && apptEnd.isAfter(start);
    });
  }

  Prescription createPrescription(
      String prescriptionId, Patient patient, List<Medication> medications, String? notes) {
    final prescription = Prescription(
      id: prescriptionId,
      patientId: patient.id,
      doctorId: id,
      date: DateTime.now(),
      medications: medications,
      notes: notes,
    );
    return prescription;
  }

  @override
  void display() {
    // UPDATED to use `id` directly
    print(
        '  ID: ${ConsoleUtils.pad(id, 10)} Name: ${ConsoleUtils.pad('Dr. ' + name, 20)} Specialty: ${ConsoleUtils.pad(specialty, 17)} Contact: $contact');
  }

  @override
  String calculatePay() {
    // Polymorphism example: A doctor's pay calculation would be specific
    return "Calculated pay for Doctor (Specialty: $specialty)";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'staffId': staffId,
      'specialty': specialty,
      'specializations': specializations,
      'department': department,
    };
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      staffId: json['staffId'],
      specialty: json['specialty'],
      specializations: json['specializations'] != null 
          ? List<String>.from(json['specializations'])
          : null,
      department: json['department'],
    );
  }
}