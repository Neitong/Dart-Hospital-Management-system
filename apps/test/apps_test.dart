// test/appointment_service_test.dart

import 'package:apps/src/models/appointment.model.dart';
import 'package:apps/src/models/appointmentService.model.dart';
import 'package:test/test.dart';
import 'package:apps/src/data/database.dart';

void main() {
  late Database db;
  late AppointmentService service;
  late String patientId;
  late String doctorId;

  // setUp runs before each test
  setUp(() {
    db = Database();
    service = AppointmentService(db);
    
    // Seed data for tests
    final patient = db.createPatient('Test Patient', '555-TEST', 'None');
    final doctor = db.createDoctor('Test Doctor', '555-TEST', 'Testing');
    patientId = patient.id;
    doctorId = doctor.id;
  });

  group('AppointmentService Tests', () {
    test('1. Schedule appointment successfully', () {
      final dateTime = DateTime.now().add(Duration(days: 1));
      final result = service.scheduleAppointment(patientId, doctorId, dateTime);

      // Check assertions
      expect(result.success, isTrue);
      expect(result.appointment, isNotNull);
      expect(result.message, 'Appointment scheduled successfully.');
      expect(db.getAllAppointments().length, 1);
    });

    test('2. Fail to schedule appointment with busy doctor', () {
      final dateTime = DateTime(2025, 11, 10, 14, 00); // 10 Nov 2025 @ 2 PM
      
      // Schedule first appointment
      service.scheduleAppointment(patientId, doctorId, dateTime);
      
      // Try to schedule second appointment at the same time
      final result = service.scheduleAppointment(patientId, doctorId, dateTime);

      expect(result.success, isFalse);
      expect(result.appointment, isNull);
      expect(result.message, contains('Doctor is not available'));
      expect(db.getAllAppointments().length, 1); // Only one should exist
    });

    test('3. Cancel appointment successfully', () {
       final dateTime = DateTime.now().add(Duration(days: 2));
       final result = service.scheduleAppointment(patientId, doctorId, dateTime);
       
       expect(result.success, isTrue);
       final appId = result.appointment!.id;

       final cancelSuccess = service.cancelAppointment(appId);
       expect(cancelSuccess, isTrue);
       
       final appt = db.getAppointment(appId);
       expect(appt?.status, equals(AppointmentStatus.cancelled));
    });

    test('4. Get appointments for a specific patient', () {
      final time1 = DateTime.now().add(Duration(days: 3));
      final time2 = DateTime.now().add(Duration(days: 4));

      service.scheduleAppointment(patientId, doctorId, time1);
      service.scheduleAppointment(patientId, doctorId, time2);

      final appointments = service.getAppointmentsForPatient(patientId);
      expect(appointments.length, 2);
      expect(appointments[0].patient.id, patientId);
    });

     test('5. Fail to schedule with invalid patient ID', () {
        final dateTime = DateTime.now().add(Duration(days: 1));
        final result = service.scheduleAppointment('invalid-id', doctorId, dateTime);

        expect(result.success, isFalse);
        expect(result.message, 'Patient not found.');
     });
  });
}