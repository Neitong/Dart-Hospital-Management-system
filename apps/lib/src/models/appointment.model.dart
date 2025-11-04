// lib/domain/appointment.dart

import 'package:apps/src/models/patient.model.dart';
import 'package:apps/src/models/doctor.model.dart';
import 'package:apps/src/database/database.dart';


enum AppointmentStatus { scheduled, completed, cancelled }

class Appointment {
  final String id;
  final Patient patientId;
  final Doctor doctorId;
  final DateTime start;
  final Duration duration;
  AppointmentStatus status;
  String notes;

  late Patient patient;
  late Doctor doctor;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.start,
    required this.duration,
    this.status = AppointmentStatus.scheduled,
    this.notes = '',
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
    print('  - Date: ${start.toLocal().toString().split(' ')[0]}');
    print('  - Time: ${start.toLocal().hour}:00');
    print('  - Duration: ${duration.inMinutes} minutes');
    print('  - Status: $status');
    if (notes.isNotEmpty) {
      print('  - Notes: $notes');
    }
  }

  String get formattedDate {
    return '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
  }

  String get formattedTime {
    return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
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
      'start': start.toIso8601String(),
      'duration': duration.inMinutes,
      'status': status.name,
      'notes': notes,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      start: DateTime.parse(json['start']),
      duration: Duration(minutes: json['duration']),
      status: AppointmentStatus.values
          .firstWhere((e) => e.name == json['status']),
      notes: json['notes'] ?? '',
    );
  }
}