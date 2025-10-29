// lib/domain/patient.dart

import 'package:apps/src/models/appointment.model.dart';
import 'package:apps/src/models/person.model.dart';
import 'package:apps/src/ui/consoleUtils.dart';
import 'package:apps/src/models/prescription.dart';

class Patient extends Person {
  String medicalHistory;
  final List<Appointment> _appointments = [];
  final List<Prescription> _prescriptions = [];


  Patient({
    required super.id,
    required super.name,
    required super.contact,
    this.medicalHistory = 'None',
  });

  // Encapsulation
  List<Appointment> get appointments => List.unmodifiable(_appointments);
  List<Prescription> get prescriptions => List.unmodifiable(_prescriptions);

  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
  }

  void removeAppointment(Appointment appointment) {
    _appointments.remove(appointment);
  }

  void addPrescription(Prescription prescription) { // ADDED
    _prescriptions.add(prescription);
  }

@override
  void display() {
    // UPDATED to use `id` directly
    print(
        '  ID: ${ConsoleUtils.pad(id, 10)} Name: ${ConsoleUtils.pad(name, 20)} Contact: ${ConsoleUtils.pad(contact, 14)} History: $medicalHistory');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'medicalHistory': medicalHistory,
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      medicalHistory: json['medicalHistory'],
    );
  }

}