import 'package:apps/src/domains/appointment.dart';
import 'package:apps/src/domains/person.dart';
import 'package:apps/src/ui/consoleUtils.dart';
import 'package:apps/src/domains/prescription.dart';
import 'package:apps/src/domains/doctor.dart';

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

  //Encapsulation
   List<Appointment> get appointments => List.unmodifiable(_appointments);
   List<Prescription> get prescriptions => List.unmodifiable(_prescriptions);


  void requestAppointment(Doctor doctor, DateTime start, Duration duration) {
    print('Requesting appointment with Dr. ${doctor.name} on ${start.toString()}');
  }

  /// Adds a new [Appointment] to the patient's schedule.
  void scheduleAppointment(Appointment appointment) {
    _appointments.add(appointment);
  }

  /// Cancels an appointment by its unique [appointmentId].
  void cancelAppointment(String appointmentId) {
    _appointments.removeWhere((appt) => appt.id == appointmentId);
  }

  /// Adds a new [Prescription] to the patient's record.
  void receivePrescription(Prescription prescription) {
    _prescriptions.add(prescription);
  }

  @override
  void display() {
    print('  ID: ${ConsoleUtils.pad(id, 10)} Name: ${ConsoleUtils.pad(name, 20)} Contact: ${ConsoleUtils.pad(contact, 14)} DOB: ${birthdate.toIso8601String().split('T')[0]}');
  }

  /// Converts the [Patient] object into a JSON-compatible map.
  ///includes the serializing patient's appointments.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'birthdate': birthdate.toIso8601String(),
    };
  }

  /// Creates a [Patient] instance from a JSON map.
  ///includes deserializing the patient's appointments.
  factory Patient.fromJson(Map<String, dynamic> json) {
    final patient = Patient(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      birthdate: json['birthdate'] != null 
          ? DateTime.parse(json['birthdate'])
          : DateTime(1990, 1, 1),
    );

    return patient;
  }

  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
  }
}