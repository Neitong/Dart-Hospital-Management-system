// lib/src/models/prescription.model.dart

import 'package:apps/src/database/database.dart';
import 'package:apps/src/models/doctor.model.dart';
import 'package:apps/src/models/patient.model.dart';
import 'package:apps/src/models/medication.model.dart';

class Prescription {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime date;
  final List<Medication> medications;
  final String? notes;

  // Runtime-linked objects
  late Patient patient;
  late Doctor doctor;

  Prescription({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.date,
    required this.medications,
    this.notes,
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
      'date': date.toIso8601String(),
      'medications': medications.map((med) => med.toJson()).toList(),
      'notes': notes,
    };
  }

  /// Creates an instance from a JSON map.
  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      date: DateTime.parse(json['date']),
      medications: (json['medications'] as List)
          .map((medJson) => Medication.fromJson(medJson))
          .toList(),
      notes: json['notes'],
    );
  }

  String get formattedDate =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}