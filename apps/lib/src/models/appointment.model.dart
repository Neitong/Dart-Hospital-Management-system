// lib/domain/appointment.dart

import 'package:apps/src/models/patient.model.dart';
import 'package:apps/src/models/doctor.model.dart';

enum AppointmentStatus { scheduled, completed, cancelled }

class Appointment {
  final String id;
  final Patient patient;
  final Doctor doctor;
  final DateTime dateTime;
  AppointmentStatus status;

  Appointment({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.dateTime,
    this.status = AppointmentStatus.scheduled,
  });

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
      default:
        return 'Unknown';
    }
  }
}