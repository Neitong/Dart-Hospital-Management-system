// lib/src/models/prescription.model.dart

import 'package:apps/src/database/database.dart';
import 'package:apps/src/models/doctor.model.dart';
import 'package:apps/src/models/patient.model.dart';

class Prescription {
  final String id;
  final String patientId;
  final String doctorId;
  final String medication;
  final String dosage;
  final DateTime dateIssued;

  // Runtime-linked objects
  late Patient patient;
  late Doctor doctor;

  Prescription({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.medication,
    required this.dosage,
    required this.dateIssued,
  });

  /// Links the patient and doctor objects after loading from JSON.
  void linkModels(Database db) {
    final pat = db.getPatient(patientId);
    final doc = db.getDoctor(doctorId);
    if (pat == null || doc == null) {
      throw Exception('Failed to link prescription $id: Patient or Doctor not found.');
    }
    patient = pat;
    doctor = doc;
  }

  /// Converts this object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'medication': medication,
      'dosage': dosage,
      'dateIssued': dateIssued.toIso8601String(),
    };
  }

  /// Creates an instance from a JSON map.
  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      medication: json['medication'],
      dosage: json['dosage'],
      dateIssued: DateTime.parse(json['dateIssued']),
    );
  }

  String get formattedDate =>
      '${dateIssued.year}-${dateIssued.month.toString().padLeft(2, '0')}-${dateIssued.day.toString().padLeft(2, '0')}';
}