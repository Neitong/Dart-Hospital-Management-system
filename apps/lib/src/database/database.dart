// lib/src/data/database.dart

import 'dart:io';
import 'dart:convert';
import 'package:apps/src/models/appointment.model.dart';
import 'package:apps/src/models/doctor.model.dart';
import 'package:apps/src/models/patient.model.dart';
import 'package:apps/src/models/prescription.dart';

// Data Layer - Manages data storage (JSON files)
class Database {
  final Map<String, Patient> _patients = {};
  final Map<String, Doctor> _doctors = {};
  final Map<String, Appointment> _appointments = {};
  final Map<String, Prescription> _prescriptions = {}; // ADDED

 // File paths
  final String _patientsFile;
  final String _doctorsFile;
  final String _appointmentsFile;
  final String _prescriptionsFile;

  // Counters
  int _patientCounter = 1;
  int _doctorCounter = 1;
  int _appointmentCounter = 1;
  int _prescriptionCounter = 1; // ADDED

  Database({
    String patientsFile = 'data/patients.json',
    String doctorsFile = 'data/doctors.json',
    String appointmentsFile = 'data/appointments.json',
    String prescriptionsFile = 'data/prescriptions.json',
  })  : _patientsFile = patientsFile,
        _doctorsFile = doctorsFile,
        _appointmentsFile = appointmentsFile,
        _prescriptionsFile = prescriptionsFile {
    _loadData();
  }

  // --- Private Load/Save Methods ---

  void _loadData() {
    try {
      // 1. Load Patients
      final patientsList = _loadFromFile(_patientsFile);
      for (var json in patientsList) {
        final patient = Patient.fromJson(json);
        _patients[patient.id] = patient;
      }
      _patientCounter = _getNextCounter(_patients.keys, 'PT');

      // 2. Load Doctors
      final doctorsList = _loadFromFile(_doctorsFile);
      for (var json in doctorsList) {
        final doctor = Doctor.fromJson(json);
        _doctors[doctor.id] = doctor;
      }
      _doctorCounter = _getNextCounter(_doctors.keys, 'DR');

      // 3. Load Appointments
      final appointmentsList = _loadFromFile(_appointmentsFile);
      for (var json in appointmentsList) {
        final appointment = Appointment.fromJson(json);
        _appointments[appointment.id] = appointment;
      }
      _appointmentCounter = _getNextCounter(_appointments.keys, 'AP');
      
      // 4. Load Prescriptions
      final prescriptionsList = _loadFromFile(_prescriptionsFile);
      for (var json in prescriptionsList) {
        final prescription = Prescription.fromJson(json);
        _prescriptions[prescription.id] = prescription;
      }
      _prescriptionCounter = _getNextCounter(_prescriptions.keys, 'PR');

      // 5. Link models (Re-hydration)
      for (final appointment in _appointments.values) {
        appointment.linkModels(this);
        appointment.patient.addAppointment(appointment);
        appointment.doctor.addAppointment(appointment);
      }
       for (final prescription in _prescriptions.values) {
        prescription.linkModels(this);
        prescription.patient.addPrescription(prescription);
      }

    } catch (e) {
      print('Error loading data (files might not exist yet): $e');
      seedData(); // If loading fails, seed initial data and save it
    }
  }

  /// Generic helper to load a list from a JSON file.
  List<dynamic> _loadFromFile(String fileName) {
    final file = File(fileName);
    if (file.existsSync()) {
      final content = file.readAsStringSync();
      if (content.isNotEmpty) {
        return jsonDecode(content) as List<dynamic>;
      }
    }
    return [];
  }

  /// Generic helper to save a list to a JSON file.
  void _saveToFile(String fileName, Map<String, dynamic> dataMap) {
    try {
      final listToSave = dataMap.values.map((item) => item.toJson()).toList();

      final encoder = JsonEncoder.withIndent(' ');
      final content = encoder.convert(listToSave);
      File(fileName).writeAsStringSync(content);
    } catch (e) {
      print('Error saving data to $fileName: $e');
    }
  }

  /// Calculates the next available ID.
  int _getNextCounter(Iterable<String> keys, String prefix) {
    int maxId = 0;
    for (final key in keys) {
      try {
        final idNum = int.parse(key.replaceFirst(prefix, ''));
        if (idNum > maxId) maxId = idNum;
      } catch (e) { /* ignore malformed IDs */ }
    }
    return maxId + 1;
  }

  // --- Patient Methods ---
  Patient createPatient(String name, String contact, String medicalHistory) {
    final newId = 'PT${(_patientCounter++).toString().padLeft(6, '0')}';
    final patient = Patient(
      id: newId, name: name, contact: contact, medicalHistory: medicalHistory,
    );
    _patients[patient.id] = patient;
    _saveToFile(_patientsFile, _patients); // Save changes
    return patient;
  }

  Patient? getPatient(String id) => _patients[id];

  List<Patient> getAllPatients() => List.unmodifiable(_patients.values);

  Patient? updatePatient(Patient patient) {
    if (_patients.containsKey(patient.id)) {
      _patients[patient.id] = patient;
      _saveToFile(_patientsFile, _patients); // Save changes
      return patient;
    }
    return null;
  }

  bool deletePatient(String id) {
    final result = _patients.remove(id) != null;
    if (result) {
      _saveToFile(_patientsFile, _patients); // Save changes
    }
    return result;
  }

  // --- Doctor Methods ---
  Doctor createDoctor(String name, String contact, String specialty) {
    final newId = 'DR${(_doctorCounter++).toString().padLeft(6, '0')}';
    final doctor = Doctor(
      id: newId, name: name, contact: contact, staffId: newId, specialty: specialty,
    );
    _doctors[doctor.id] = doctor;
    _saveToFile(_doctorsFile, _doctors); // Save changes
    return doctor;
  }

  Doctor? getDoctor(String id) => _doctors[id];

  List<Doctor> getAllDoctors() => List.unmodifiable(_doctors.values);

  Doctor? updateDoctor(Doctor doctor) {
    if (_doctors.containsKey(doctor.id)) {
      _doctors[doctor.id] = doctor;
      _saveToFile(_doctorsFile, _doctors); // Save changes
      return doctor;
    }
    return null;
  }

  bool deleteDoctor(String id) {
    final result = _doctors.remove(id) != null;
    if (result) {
      _saveToFile(_doctorsFile, _doctors); // Save changes
    }
    return result;
  }

  // --- Appointment Methods ---
  Appointment? createAppointment(Patient patient, Doctor doctor, DateTime dateTime) {
    final newId = 'AP${(_appointmentCounter++).toString().padLeft(6, '0')}';
    final appointment = Appointment(
      id: newId,
      patientId: patient, // Store ID
      doctorId: doctor,   // Store ID
      dateTime: dateTime,
    );
    appointment.linkModels(this); // Link runtime objects
    _appointments[appointment.id] = appointment;
    patient.addAppointment(appointment);
    doctor.addAppointment(appointment);
    _saveToFile(_appointmentsFile, _appointments); // Save changes
    return appointment;
  }

  Appointment? getAppointment(String id) => _appointments[id];

  Appointment? updateAppointment(Appointment appointment) {
    if (_appointments.containsKey(appointment.id)) {
      _appointments[appointment.id] = appointment;
      _saveToFile(_appointmentsFile, _appointments); // Save changes
      return appointment;
    }
    return null;
  }

  List<Appointment> getAllAppointments() => List.unmodifiable(_appointments.values);

  List<Appointment> getAppointmentsForPatient(String patientId) {
    return _appointments.values.where((a) => a.patient.id == patientId).toList();
  }

  List<Appointment> getAppointmentsForDoctor(String doctorId) {
    return _appointments.values.where((a) => a.doctor.id == doctorId).toList();
  }
  
  // --- Prescription Methods (NEW) ---
  Prescription? createPrescription(
    Patient patient, Doctor doctor, String medication, String dosage) {
    final newId = 'PR${(_prescriptionCounter++).toString().padLeft(6, '0')}';
    final prescription = Prescription(
      id: newId,
      patientId: patient.id,
      doctorId: doctor.id,
      medication: medication,
      dosage: dosage,
      dateIssued: DateTime.now(),
    );
    prescription.linkModels(this); // Link runtime objects
    _prescriptions[prescription.id] = prescription;
    patient.addPrescription(prescription);
    _saveToFile(_prescriptionsFile, _prescriptions); // Save changes
    return prescription;
  }

  List<Prescription> getPrescriptionsForPatient(String patientId) {
    return _prescriptions.values
        .where((p) => p.patientId == patientId)
        .toList();
  }

  // --- Seeding utility ---
  void seedData() {
    if (_patients.isEmpty && _doctors.isEmpty) {
      print('Seeding initial data...');
      final drHouse =
          createDoctor('Gregory House', '555-0101', 'Diagnostician');
      final drCuddy = createDoctor('Lisa Cuddy', '555-0102', 'Endocrinology');

      final patientJohn =
          createPatient('John Doe', '555-0201', 'Pollen Allergy');
      createPatient('Jane Smith', '555-0202', 'Asthma');

      final time = DateTime.now().add(Duration(days: 1, hours: 2));
      createAppointment(patientJohn, drHouse, time);
      
      createPrescription(patientJohn, drHouse, 'Vicodin', '500mg');
      
      print('Seeding complete. Data saved to .json files.');
    }
  }
}