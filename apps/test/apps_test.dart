// apps/test/apps_test.dart

import 'dart:io';
import 'package:apps/src/models/appointment.model.dart';
import 'package:apps/src/models/appointmentService.model.dart';
import 'package:test/test.dart';
import 'package:apps/src/database/database.dart';

// Define paths for our temporary test database files
const String testPatientsFile = 'test_patients.json';
const String testDoctorsFile = 'test_doctors.json';
const String testAppointmentsFile = 'test_appointments.json';
const String testPrescriptionsFile = 'test_prescriptions.json';

// Helper function to delete test files
void _deleteTestFiles() {
  final files = [
    testPatientsFile,
    testDoctorsFile,
    testAppointmentsFile,
    testPrescriptionsFile
  ];
  for (final filename in files) {
    final file = File(filename);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }
}

void main() {
  late Database db;
  late AppointmentService service;
  late String patientId;
  late String doctorId;
  late String patient2Id;
  late String doctor2Id;

  // Runs before *each* test.
  setUp(() {
    // 1. Clean up files from any previous failed test
    _deleteTestFiles();
    
    // 2. Create a new DB instance pointing to our test files
    db = Database(
      patientsFile: testPatientsFile,
      doctorsFile: testDoctorsFile,
      appointmentsFile: testAppointmentsFile,
      prescriptionsFile: testPrescriptionsFile,
    );

    // 3. Create the service
    service = AppointmentService(db);
    
    // 4. Seed data *for this test*
    final patient = db.createPatient('Test Patient 1', '555-0101', 'None');
    final doctor = db.createDoctor('Test Doctor 1', '555-0201', 'Testing');
    final patient2 = db.createPatient('Test Patient 2', '555-0102', 'Asthma');
    final doctor2 = db.createDoctor('Test Doctor 2', '555-0202', 'Surgery');

    patientId = patient.id;
    doctorId = doctor.id;
    patient2Id = patient2.id;
    doctor2Id = doctor2.id;
  });

  // Runs *once* after all tests are done.
  tearDownAll(() {
    _deleteTestFiles();
  });


  group('Domain Layer Tests (AppointmentService)', () {

    test('1. Data is persistent and reloaded', () {
      // We created two patients in setUp.
      expect(db.getAllPatients().length, 2);

      // Create a *new* Database instance. It should load from the test files.
      final db2 = Database(
        patientsFile: testPatientsFile,
        doctorsFile: testDoctorsFile,
        appointmentsFile: testAppointmentsFile,
        prescriptionsFile: testPrescriptionsFile,
      );
      
      // It should find the patients created by the first 'db' instance.
      expect(db2.getAllPatients().length, 2);
      expect(db2.getPatient(patientId)?.name, 'Test Patient 1');
      expect(db2.getDoctor(doctor2Id)?.specialty, 'Surgery');
    });

    test('2. Create Patient and Doctor', () {
      // Data was created in setUp. Check if it exists.
      expect(db.getAllPatients().length, 2);
      expect(db.getAllDoctors().length, 2);
      
      // Check if files were saved
      final patientFile = File(testPatientsFile);
      expect(patientFile.existsSync(), isTrue);
      expect(patientFile.readAsStringSync(), contains('PT000001'));
      expect(patientFile.readAsStringSync(), contains('PT000002'));
    });

    test('3. Update Patient and Doctor', () {
      // 1. Update Patient
      final patient = db.getPatient(patientId);
      expect(patient, isNotNull);
      patient!.name = 'Updated Patient Name';
      db.updatePatient(patient);

      // 2. Update Doctor
      final doctor = db.getDoctor(doctorId);
      expect(doctor, isNotNull);
      doctor!.specialty = 'Updated Specialty';
      db.updateDoctor(doctor);

      // 3. Create a new DB instance to check persistence
      final db2 = Database(
        patientsFile: testPatientsFile,
        doctorsFile: testDoctorsFile,
        appointmentsFile: testAppointmentsFile,
        prescriptionsFile: testPrescriptionsFile,
      );
      
      expect(db2.getPatient(patientId)?.name, 'Updated Patient Name');
      expect(db2.getDoctor(doctorId)?.specialty, 'Updated Specialty');
    });

    test('4. Schedule appointment (Success)', () {
      final dateTime = DateTime.now().add(Duration(days: 1));
      final result = service.scheduleAppointment(patientId, doctorId, dateTime);

      expect(result.success, isTrue);
      expect(result.appointment, isNotNull);
      expect(result.message, 'Appointment scheduled successfully.');
      expect(db.getAllAppointments().length, 1);
      
      // Check if file was saved
      final file = File(testAppointmentsFile);
      expect(file.existsSync(), isTrue);
      expect(file.readAsStringSync(), contains('AP000001'));
    });

    test('5. Fail to schedule (Doctor Busy)', () {
      final dateTime = DateTime(2025, 11, 10, 14, 00); // 10 Nov 2025 @ 2 PM
      
      // Schedule first appointment
      service.scheduleAppointment(patientId, doctorId, dateTime);
      
      // Try to schedule second appointment with a different patient, same doctor/time
      final result = service.scheduleAppointment(patient2Id, doctorId, dateTime);

      expect(result.success, isFalse);
      expect(result.appointment, isNull);
      expect(result.message, contains('Doctor is not available'));
      expect(db.getAllAppointments().length, 1); // Only one should exist
    });
    
    test('6. Fail to schedule (Invalid Patient)', () {
        final dateTime = DateTime.now().add(Duration(days: 1));
        final result = service.scheduleAppointment('invalid-id', doctorId, dateTime);

        expect(result.success, isFalse);
        expect(result.message, 'Patient not found.');
    });

    test('7. Cancel appointment (Success)', () {
       final dateTime = DateTime.now().add(Duration(days: 2));
       final result = service.scheduleAppointment(patientId, doctorId, dateTime);
       
       expect(result.success, isTrue);
       final appId = result.appointment!.id;

       final cancelSuccess = service.cancelAppointment(appId);
       expect(cancelSuccess, isTrue);
       
       final appt = db.getAppointment(appId);
       expect(appt?.status, equals(AppointmentStatus.cancelled));
    });

    test('8. Issue prescription (Success)', () {
      final result = service.issuePrescription(patientId, doctorId, 'TestMed', '100mg');
      
      expect(result.success, isTrue);
      expect(result.prescription, isNotNull);
      expect(result.prescription?.medication, 'TestMed');
      expect(db.getPrescriptionsForPatient(patientId).length, 1);

      // Check if file was saved
      final file = File(testPrescriptionsFile);
      expect(file.existsSync(), isTrue);
      expect(file.readAsStringSync(), contains('PR000001'));
    });

    test('9. Fail to issue (Invalid Doctor)', () {
      final result = service.issuePrescription(patientId, 'invalid-doctor', 'TestMed', '100mg');
      
      expect(result.success, isFalse);
      expect(result.message, 'Doctor not found.');
      expect(db.getPrescriptionsForPatient(patientId).length, 0);
    });

    test('10. Delete Patient & cancel appointments', () {
      // 1. Create an appointment
      final dateTime = DateTime.now().add(Duration(days: 1));
      final apptResult = service.scheduleAppointment(patientId, doctorId, dateTime);
      final appId = apptResult.appointment!.id;
      
      expect(db.getAllPatients().length, 2);
      expect(db.getAllAppointments().length, 1);
      expect(db.getAppointment(appId)?.status, AppointmentStatus.scheduled);

      // 2. Delete the patient
      final deleteSuccess = service.deletePatientAndCancelAppointments(patientId);
      expect(deleteSuccess, isTrue);

      // 3. Check results
      expect(db.getAllPatients().length, 1); // Patient is gone
      expect(db.getPatient(patientId), isNull);
      expect(db.getPatient(patient2Id), isNotNull); // Other patient is safe
      
      // Appointment still exists (for history) but is cancelled
      final appt = db.getAppointment(appId);
      expect(appt, isNotNull);
      expect(appt?.status, AppointmentStatus.cancelled);
    });

    test('11. Delete Doctor & cancel appointments', () {
      // 1. Create an appointment
      final dateTime = DateTime.now().add(Duration(days: 1));
      final apptResult = service.scheduleAppointment(patientId, doctorId, dateTime);
      final appId = apptResult.appointment!.id;
      
      expect(db.getAllDoctors().length, 2);
      expect(db.getAllAppointments().length, 1);

      // 2. Delete the doctor
      final deleteSuccess = service.deleteDoctorAndCancelAppointments(doctorId);
      expect(deleteSuccess, isTrue);

      // 3. Check results
      expect(db.getAllDoctors().length, 1); // Doctor is gone
      expect(db.getDoctor(doctorId), isNull);
      expect(db.getDoctor(doctor2Id), isNotNull); // Other doctor is safe
      
      // Appointment is cancelled
      final appt = db.getAppointment(appId);
      expect(appt, isNotNull);
      expect(appt?.status, AppointmentStatus.cancelled);
    });
  });
}