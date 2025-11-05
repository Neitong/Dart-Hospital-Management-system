// lib/domain/patient.dart

import 'package:apps/src/models/appointment.model.dart';
import 'package:apps/src/models/person.model.dart';
import 'package:apps/src/ui/consoleUtils.dart';
import 'package:apps/src/models/prescription.dart';
import 'package:apps/src/models/doctor.model.dart';

class Patient extends Person {
  DateTime birthdate;
  final List<Appointment> _appointments = [];
  final List<Prescription> _prescriptions = [];


  Patient({
    required super.id,
    required super.name,
    required super.contact,
    required this.birthdate,
  });

  // Encapsulation
  List<Appointment> get appointments => List.unmodifiable(_appointments);
  List<Prescription> get prescriptions => List.unmodifiable(_prescriptions);

  void requestAppointment(Doctor doctor, DateTime start, Duration duration) {
    // This method could be used to create an appointment request
    // Implementation would involve creating the appointment and adding it
    print('Requesting appointment with Dr. ${doctor.name} on ${start.toString()}');
  }

  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
  }

  void cancelAppointment(String appointmentId) {
    _appointments.removeWhere((appt) => appt.id == appointmentId);
  }

  void receivePrescription(Prescription prescription) {
    _prescriptions.add(prescription);
  }

@override
  void display() {
    // UPDATED to use `id` directly
    print(
        '  ID: ${ConsoleUtils.pad(id, 10)} Name: ${ConsoleUtils.pad(name, 20)} Contact: ${ConsoleUtils.pad(contact, 14)} DOB: ${birthdate.toIso8601String().split('T')[0]}');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'birthdate': birthdate.toIso8601String(),
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      birthdate: json['birthdate'] != null 
          ? DateTime.parse(json['birthdate'])
          : DateTime.now().subtract(const Duration(days: 365 * 30)), // Default to 30 years ago
    );
  }

}