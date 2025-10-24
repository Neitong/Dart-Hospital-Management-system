// import 'package:uuid/uuid.dart';
import 'package:apps/src/models/appointment.model.dart';
import 'package:apps/src/models/doctor.model.dart';
import 'package:apps/src/models/patient.model.dart';

// Data Layer - Manages data storage (in-memory)
class Database {
  final Map<String, Patient> _patients = {};
  final Map<String, Doctor> _doctors = {};
  final Map<String, Appointment> _appointments = {};
  
  // ADD THESE COUNTERS
  int _patientCounter = 1;
  int _doctorCounter = 1;
  int _appointmentCounter = 1;

  // --- Patient Methods ---
  Patient createPatient(String name, String contact, String medicalHistory) {
    // UPDATED ID GENERATION
    final newId = 'PT${(_patientCounter++).toString().padLeft(6, '0')}';
    final patient = Patient(
      id: newId,
      name: name,
      contact: contact,
      medicalHistory: medicalHistory,
    );
    _patients[patient.id] = patient;
    return patient;
  }

  Patient? getPatient(String id) {
    return _patients[id];
  }

  List<Patient> getAllPatients() {
    return List.unmodifiable(_patients.values);
  }

  // --- Doctor Methods ---
  Doctor createDoctor(String name, String contact, String specialty) {
    // UPDATED ID GENERATION
    final newId = 'DR${(_doctorCounter++).toString().padLeft(6, '0')}';
    final doctor = Doctor(
      id: newId,
      name: name,
      contact: contact,
      staffId: newId, // Use the same ID for staffId
      specialty: specialty,
    );
    _doctors[doctor.id] = doctor;
    return doctor;
  }

  Doctor? getDoctor(String id) {
    return _doctors[id];
  }

  List<Doctor> getAllDoctors() {
    return List.unmodifiable(_doctors.values);
  }

  // --- Appointment Methods ---
  Appointment? createAppointment(
      Patient patient, Doctor doctor, DateTime dateTime) {
    // UPDATED ID GENERATION
    final newId = 'AP${(_appointmentCounter++).toString().padLeft(6, '0')}';
    final appointment = Appointment(
      id: newId,
      patient: patient,
      doctor: doctor,
      dateTime: dateTime,
    );
    _appointments[appointment.id] = appointment;
    // Link appointment to patient and doctor
    patient.addAppointment(appointment);
    doctor.addAppointment(appointment);
    return appointment;
  }

  Appointment? getAppointment(String id) {
    return _appointments[id];
  }

  Appointment? updateAppointment(Appointment appointment) {
    if (_appointments.containsKey(appointment.id)) {
      _appointments[appointment.id] = appointment;
      return appointment;
    }
    return null;
  }

  List<Appointment> getAllAppointments() {
    return List.unmodifiable(_appointments.values);
  }

  // --- Seeding utility for demo data ---
  void seedData() {
    if (_patients.isEmpty && _doctors.isEmpty) {
      print('Seeding initial data...');
      final drHouse =
          createDoctor('Gregory House', '555-0101', 'Diagnostician');
      final drCuddy = createDoctor('Lisa Cuddy', '555-0102', 'Endocrinology');

      final patientJohn =
          createPatient('John Doe', '555-0201', 'Pollen Allergy');
      final patientJane =
          createPatient('Jane Smith', '555-0202', 'Asthma');

      // Seed an appointment
      final time = DateTime.now().add(Duration(days: 1, hours: 2));
      createAppointment(patientJohn, drHouse, time);
    }
  }
}