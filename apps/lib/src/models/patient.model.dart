// lib/domain/patient.dart

import 'package:apps/src/models/appointment.model.dart';
import 'package:apps/src/models/person.model.dart';
import 'package:apps/src/ui/consoleUtils.dart';

class Patient extends Person {
  String medicalHistory;
  final List<Appointment> _appointments = [];

  Patient({
    required super.id,
    required super.name,
    required super.contact,
    this.medicalHistory = 'None',
  });

  // Encapsulation
  List<Appointment> get appointments => List.unmodifiable(_appointments);

  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
  }

  void removeAppointment(Appointment appointment) {
    _appointments.remove(appointment);
  }

@override
  void display() {
    // UPDATED to use `id` directly
    print(
        '  ID: ${ConsoleUtils.pad(id, 10)} Name: ${ConsoleUtils.pad(name, 20)} Contact: ${ConsoleUtils.pad(contact, 14)} History: $medicalHistory');
  }
}