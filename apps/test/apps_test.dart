// apps/test/apps_test.dart

import 'dart:io';
import 'package:apps/src/domains/appointmentStatus.dart';
import 'package:apps/src/domains/medication.dart';
import 'package:apps/src/domains/appointmentService.dart';
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
    final patient = db.createPatient('Test Patient 1', '555-0101', birthdate: DateTime(1990, 1, 1));
    final doctor = db.createDoctor('Test Doctor 1', '555-0201', 'Testing');
    final patient2 = db.createPatient('Test Patient 2', '555-0102', birthdate: DateTime(1985, 5, 15));
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

  group('Data Persistence & JSON', () {
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
  });

  // --- Test Group 2: Appointment Logic ---
  group('Appointment Service', () {
    test('4. Schedule appointment (Success)', () {
      final dateTime = DateTime(2025, 12, 25, 10, 00); // 10:00 AM (Valid slot)
      final result = service.scheduleAppointment(patientId, doctorId, dateTime);

      expect(result.success, isTrue);
      expect(result.appointment, isNotNull);
      expect(result.message, 'Appointment scheduled successfully.');
      expect(db.getAllAppointments().length, 1);

      final file = File(testAppointmentsFile);
      expect(file.existsSync(), isTrue);
      expect(file.readAsStringSync(), contains('AP000001'));
    });

    test('5. Fail to schedule (Doctor Busy)', () {
      final dateTime = DateTime(2025, 11, 10, 14, 00); // 2:00 PM (Valid slot)

      // Schedule first appointment
      service.scheduleAppointment(patientId, doctorId, dateTime);

      // Try to schedule second appointment at the same time
      final result = service.scheduleAppointment(patient2Id, doctorId, dateTime);

      expect(result.success, isFalse);
      expect(result.appointment, isNull);
      expect(result.message, contains('Doctor is not available'));
      expect(db.getAllAppointments().length, 1); // Only one should exist
    });

    test('6. Fail to schedule (Invalid Patient)', () {
      final dateTime = DateTime(2025, 12, 25, 10, 00);
      final result = service.scheduleAppointment('invalid-id', doctorId, dateTime);

      expect(result.success, isFalse);
      expect(result.message, 'Patient not found.');
    });

    test('7. Fail to schedule (Outside work hours)', () {
      final dateTime = DateTime(2025, 12, 25, 7, 00); // 7:00 AM (Too early)
      final result = service.scheduleAppointment(patientId, doctorId, dateTime);

      expect(result.success, isFalse);
      expect(result.message, contains('Doctor is not available'));

      final dateTime2 = DateTime(2025, 12, 25, 17, 00); // 5:00 PM (Too late)
      final result2 = service.scheduleAppointment(patientId, doctorId, dateTime2);
      expect(result2.success, isFalse);
    });

    test('8. Cancel appointment (Success)', () {
      final dateTime = DateTime(2025, 12, 25, 11, 00);
      final result = service.scheduleAppointment(patientId, doctorId, dateTime);

      expect(result.success, isTrue);
      final appId = result.appointment!.id;

      final cancelSuccess = service.cancelAppointment(appId);
      expect(cancelSuccess, isTrue);

      final appt = db.getAppointment(appId);
      expect(appt?.status, equals(AppointmentStatus.cancelled));
    });

    test('9. Reschedule appointment (Success)', () {
      final originalTime = DateTime(2025, 12, 26, 9, 00);
      final newTime = DateTime(2025, 12, 26, 11, 00);

      final scheduleResult = service.scheduleAppointment(patientId, doctorId, originalTime);
      expect(scheduleResult.success, isTrue);
      final appointmentId = scheduleResult.appointment!.id;

      final rescheduleResult = service.rescheduleAppointment(appointmentId, newTime);
      expect(rescheduleResult.success, isTrue);
      expect(rescheduleResult.appointment?.start, equals(newTime));
      expect(rescheduleResult.message, 'Appointment rescheduled successfully.');

      // Verify the appointment in the database has the new time
      final updatedAppt = db.getAppointment(appointmentId);
      expect(updatedAppt?.start, equals(newTime));

      // Verify original slot is now free for this doctor
      final tryScheduleOriginalSlot = service.scheduleAppointment(patient2Id, doctorId, originalTime);
      expect(tryScheduleOriginalSlot.success, isTrue); // Should succeed

      // Verify new slot is now busy for this doctor
      final tryScheduleNewSlot = service.scheduleAppointment(patient2Id, doctorId, newTime);
      expect(tryScheduleNewSlot.success, isFalse); // Should fail
      expect(tryScheduleNewSlot.message, contains('Doctor is not available'));
    });

    test('10. Fail to reschedule (Doctor Busy at new time)', () {
      final originalTime = DateTime(2025, 12, 27, 9, 00);
      final busyTime = DateTime(2025, 12, 27, 10, 00);

      // Schedule first appointment for patientId with doctorId
      final scheduleResult = service.scheduleAppointment(patientId, doctorId, originalTime);
      expect(scheduleResult.success, isTrue);
      final appointmentId = scheduleResult.appointment!.id;

      // Schedule another appointment for doctorId at the busy time with patient2Id
      service.scheduleAppointment(patient2Id, doctorId, busyTime);

      // Attempt to reschedule the first appointment to the busy time
      final rescheduleResult = service.rescheduleAppointment(appointmentId, busyTime);
      expect(rescheduleResult.success, isFalse);
      expect(rescheduleResult.message, contains('Doctor is not available at the new time'));

      // Verify original appointment time has not changed
      final currentAppt = db.getAppointment(appointmentId);
      expect(currentAppt?.start, equals(originalTime));
    });

    test('11. Fail to reschedule (Patient Busy at new time)', () {
      final originalTime = DateTime(2025, 12, 28, 9, 00);
      final busyTime = DateTime(2025, 12, 28, 10, 00);

      // Schedule first appointment for patientId with doctorId
      final scheduleResult = service.scheduleAppointment(patientId, doctorId, originalTime);
      expect(scheduleResult.success, isTrue);
      final appointmentId = scheduleResult.appointment!.id;

      // Schedule another appointment for patientId at the busy time with doctor2Id
      service.scheduleAppointment(patientId, doctor2Id, busyTime);

      // Attempt to reschedule the first appointment to the busy time
      final rescheduleResult = service.rescheduleAppointment(appointmentId, busyTime);
      expect(rescheduleResult.success, isFalse);
      expect(rescheduleResult.message, contains('Patient already has another appointment at the new time.'));

      // Verify original appointment time has not changed
      final currentAppt = db.getAppointment(appointmentId);
      expect(currentAppt?.start, equals(originalTime));
    });

    test('12. Fail to reschedule (Invalid Appointment ID)', () {
      final newTime = DateTime(2025, 12, 29, 9, 00);
      final rescheduleResult = service.rescheduleAppointment('invalid-app-id', newTime);

      expect(rescheduleResult.success, isFalse);
      expect(rescheduleResult.message, 'Appointment not found.');
    });
  });

  // --- Test Group 3: Prescription Logic ---
  group('Prescription Service', () {
    test('13. Issue prescription (Success)', () { // Renumbered from 9 to 13
      final medications = [
        Medication(name: 'TestMed', dosage: '100mg', days: 7),
        Medication(name: 'TestMed2', dosage: '50mg', days: 3),
      ];
      final result = service.issuePrescription(patientId, doctorId, medications, notes: 'Test notes');

      expect(result.success, isTrue);
      expect(result.prescription, isNotNull);
      expect(result.prescription?.medications.length, 2);
      expect(result.prescription?.medications.first.name, 'TestMed');
      expect(db.getPrescriptionsForPatient(patientId).length, 1);

      final file = File(testPrescriptionsFile);
      expect(file.existsSync(), isTrue);
      expect(file.readAsStringSync(), contains('PR000001'));
      expect(file.readAsStringSync(), contains('TestMed2'));
    });

    test('14. Fail to issue (Invalid Doctor)', () { // Renumbered from 10 to 14
      final medications = [
        Medication(name: 'TestMed', dosage: '100mg', days: 7)
      ];
      final result = service.issuePrescription(patientId, 'invalid-doctor', medications);

      expect(result.success, isFalse);
      expect(result.message, 'Doctor not found.');
      expect(db.getPrescriptionsForPatient(patientId).length, 0);
    });
  });

  // --- Test Group 4: Deletion Logic ---
  group('Deletion Service', () {
    test('15. Delete Patient & cancel their appointments', () { // Renumbered from 11 to 15
      final dateTime = DateTime(2025, 12, 25, 10, 00);
      final apptResult = service.scheduleAppointment(patientId, doctorId, dateTime);
      final appId = apptResult.appointment!.id;

      expect(db.getAllPatients().length, 2);
      expect(db.getAllAppointments().length, 1);
      expect(db.getAppointment(appId)?.status, AppointmentStatus.scheduled);

      // Delete the patient
      final deleteSuccess = service.deletePatientAndCancelAppointments(patientId);
      expect(deleteSuccess, isTrue);

      // Check results
      expect(db.getAllPatients().length, 1); // Patient is gone
      expect(db.getPatient(patientId), isNull);
      expect(db.getPatient(patient2Id), isNotNull); // Other patient is safe

      // Appointment still exists (for history) but is cancelled
      final appt = db.getAppointment(appId);
      expect(appt, isNotNull);
      expect(appt?.status, AppointmentStatus.cancelled);
    });

    test('16. Delete Doctor & cancel their appointments', () { // Renumbered from 12 to 16
      final dateTime = DateTime(2025, 12, 25, 10, 00);
      final apptResult = service.scheduleAppointment(patientId, doctorId, dateTime);
      final appId = apptResult.appointment!.id;

      expect(db.getAllDoctors().length, 2);
      expect(db.getAllAppointments().length, 1);

      // Delete the doctor
      final deleteSuccess = service.deleteDoctorAndCancelAppointments(doctorId);
      expect(deleteSuccess, isTrue);

      // Check results
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
