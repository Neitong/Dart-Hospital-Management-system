import 'package:apps/src/domains/patient.dart';
import 'package:apps/src/domains/doctor.dart';
import 'package:apps/src/database/database.dart';
import 'appointmentStatus.dart';

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime start;
  AppointmentStatus status;
  String notes;

  late Patient patient;
  late Doctor doctor;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.start,
    this.status = AppointmentStatus.scheduled,
    this.notes = '',
  });

  void linkModels(Database db) {
    final pat = db.getPatient(patientId);
    final doc = db.getDoctor(doctorId);
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
    print('  - Duration: 1 Hour');
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
      status: AppointmentStatus.values
          .firstWhere((e) => e.name == json['status']),
      notes: json['notes'] ?? '',
    );
  }
}