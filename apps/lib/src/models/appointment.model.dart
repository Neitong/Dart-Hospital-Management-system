// lib/domain/appointment.dart

import 'package:apps/src/models/patient.model.dart';
import 'package:apps/src/models/doctor.model.dart';
import 'package:apps/src/database/database.dart';


enum AppointmentStatus { scheduled, completed, cancelled }

class Appointment {
  final String id;
  final Patient patientId;
  final Doctor doctorId;
  final DateTime dateTime;
  AppointmentStatus status;

  late Patient patient;
  late Doctor doctor;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    this.status = AppointmentStatus.scheduled,
  });

  void linkModels(Database db) {
    final pat = db.getPatient(patientId.id);
    final doc = db.getDoctor(doctorId.id);
    if (pat == null || doc == null) {
      throw Exception('Failed to link appointment $id: Patient or Doctor not found.');
    }
    patient = pat;
    doctor = doc;
  }

  void display() {
    print('  - Appointment ID: $id');
    print('  - Patient: ${patient.name}');
    print('  - Doctor: Dr. ${doctor.name} (${doctor.specialty})');
    print('  - Date: ${dateTime.toLocal().toString().split(' ')[0]}');
    print('  - Time: ${dateTime.toLocal().hour}:00');
    print('  - Status: $status');
  }

  String get formattedDate {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String get formattedTime {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedStatus {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'dateTime': dateTime.toIso8601String(),
      'status': status.name, // Saves "scheduled" as a string
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      dateTime: DateTime.parse(json['dateTime']),
      status: AppointmentStatus.values
          .firstWhere((e) => e.name == json['status']),
    );
  }
}