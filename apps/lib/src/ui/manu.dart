import 'dart:io';
import '../data/database.dart';
import 'package:apps/src/models/appointmentService.model.dart';
import 'package:apps/src/ui/consoleUtils.dart';
import 'package:apps/src/models/appointment.model.dart';

// UI Layer - Handles user interaction
class MainMenu {
  final Database _db;
  final AppointmentService _appointmentService;

  MainMenu(this._db) : _appointmentService = AppointmentService(_db) {
    _db.seedData(); // Load demo data
  }

  void show() {
    bool running = true;
    while (running) {
      ConsoleUtils.clearScreen();
      ConsoleUtils.printHeader('HOSPITAL MANAGEMENT SYSTEM');
      print('${ConsoleUtils.cyan}1.${ConsoleUtils.reset} Manage Appointments');
      print('${ConsoleUtils.cyan}2.${ConsoleUtils.reset} Manage Patients');
      print('${ConsoleUtils.cyan}3.${ConsoleUtils.reset} Manage Doctors');
      print('${ConsoleUtils.red}4.${ConsoleUtils.reset} Exit');
      
      String choice = ConsoleUtils.readInput('Enter your choice: ');

      switch (choice) {
        case '1':
          _showAppointmentsMenu();
          break;
        case '2':
          _showPatientsMenu();
          break;
        case '3':
          _showDoctorsMenu();
          break;
        case '4':
          running = false;
          print('\nGoodbye!');
          break;
        default:
          ConsoleUtils.printError('Invalid choice. Please try again.');
          ConsoleUtils.waitForKey();
      }
    }
  }

  void _showPatientsMenu() {
     ConsoleUtils.printHeader('PATIENT MANAGEMENT');
     print('${ConsoleUtils.cyan}1.${ConsoleUtils.reset} Add New Patient');
     print('${ConsoleUtils.cyan}2.${ConsoleUtils.reset} View All Patients');
     print('${ConsoleUtils.red}3.${ConsoleUtils.reset} Back to Main Menu');
     String choice = ConsoleUtils.readInput('Enter your choice: ');

      switch (choice) {
        case '1':
          _addPatient();
          break;
        case '2':
          _listAllPatients(wait: true);
          break;
        case '3':
          return;
        default:
          ConsoleUtils.printError('Invalid choice.');
          ConsoleUtils.waitForKey();
      }
  }

  void _showAppointmentsMenu() {
    bool running = true;
    while(running) {
      ConsoleUtils.clearScreen();
      ConsoleUtils.printHeader('APPOINTMENT MANAGEMENT');
      print('${ConsoleUtils.cyan}1.${ConsoleUtils.reset} Schedule New Appointment');
      print('${ConsoleUtils.cyan}2.${ConsoleUtils.reset} View All Appointments');
      print('${ConsoleUtils.cyan}3.${ConsoleUtils.reset} Cancel Appointment');
      print('${ConsoleUtils.red}4.${ConsoleUtils.reset} Back to Main Menu');
      String choice = ConsoleUtils.readInput('Enter your choice: ');

      switch (choice) {
        case '1':
          _scheduleAppointment();
          break;
        case '2':
          _viewAllAppointments();
          break;
        case '3':
          _cancelAppointment();
          break;
        case '4':
          running = false;
          break;
        default:
          ConsoleUtils.printError('Invalid choice.');
          ConsoleUtils.waitForKey();
      }
    }
  }

  void _scheduleAppointment() {
    ConsoleUtils.printHeader('SCHEDULE APPOINTMENT');

    // --- 1. Select Patient ---
    final patients = _db.getAllPatients();
    if (patients.isEmpty) {
      ConsoleUtils.printError('No patients found. Please add a patient first.');
      ConsoleUtils.waitForKey();
      return;
    }

    ConsoleUtils.printInfo('Available Patients:');
    for (int i = 0; i < patients.length; i++) {
      print(
          '  ${ConsoleUtils.cyan}${i + 1}.${ConsoleUtils.reset} ${patients[i].name} (${patients[i].contact})');
    }

    final patientIndex = ConsoleUtils.readInt('Enter Patient Number: ');
    if (patientIndex == null ||
        patientIndex < 1 ||
        patientIndex > patients.length) {
      ConsoleUtils.printError('Invalid selection.');
      ConsoleUtils.waitForKey();
      return;
    }
    final selectedPatient = patients[patientIndex - 1];

    // --- 2. Select Doctor ---
    final doctors = _db.getAllDoctors();
    if (doctors.isEmpty) {
      ConsoleUtils.printError('No doctors found. Please add a doctor first.');
      ConsoleUtils.waitForKey();
      return;
    }

    ConsoleUtils.printInfo('Available Doctors:');
    for (int i = 0; i < doctors.length; i++) {
      print(
          '  ${ConsoleUtils.cyan}${i + 1}.${ConsoleUtils.reset} Dr. ${doctors[i].name} (${doctors[i].specialty})');
    }

    final doctorIndex = ConsoleUtils.readInt('Enter Doctor Number: ');
    if (doctorIndex == null ||
        doctorIndex < 1 ||
        doctorIndex > doctors.length) {
      ConsoleUtils.printError('Invalid selection.');
      ConsoleUtils.waitForKey();
      return;
    }
    final selectedDoctor = doctors[doctorIndex - 1];

    // --- 3. Get Date and Time ---
    final dateStr = ConsoleUtils.readInput('Enter Date (YYYY-MM-DD): ');
    final hour = ConsoleUtils.readInt('Enter Hour (0-23): ');

    if (hour == null || hour < 0 || hour > 23) {
      ConsoleUtils.printError('Invalid hour.');
      ConsoleUtils.waitForKey();
      return;
    }

    try {
      final dateTime = DateTime.parse('$dateStr $hour:00:00');

      // Call the Domain Service
      final result = _appointmentService.scheduleAppointment(
          selectedPatient.id, selectedDoctor.id, dateTime);

      if (result.success) {
        ConsoleUtils.printSuccess(result.message);

        if (result.appointment != null) {
          final appt = result.appointment!;
          final labelWidth = 10; 

          print(
              '\n  ${ConsoleUtils.cyan}--- APPOINTMENT DETAILS ---${ConsoleUtils.reset}');
          // UPDATED to use `id`
          print(
              '  ${ConsoleUtils.bold}${ConsoleUtils.pad('ID:', labelWidth)}${ConsoleUtils.reset} ${appt.id}');
          print(
              '  ${ConsoleUtils.bold}${ConsoleUtils.pad('Patient:', labelWidth)}${ConsoleUtils.reset} ${appt.patient.name}');
          print(
              '  ${ConsoleUtils.bold}${ConsoleUtils.pad('Doctor:', labelWidth)}${ConsoleUtils.reset} Dr. ${appt.doctor.name}');
          print(
              '  ${ConsoleUtils.bold}${ConsoleUtils.pad('Date:', labelWidth)}${ConsoleUtils.reset} ${appt.formattedDate}');
          print(
              '  ${ConsoleUtils.bold}${ConsoleUtils.pad('Time:', labelWidth)}${ConsoleUtils.reset} ${appt.formattedTime}');
          print(
              '  ${ConsoleUtils.bold}${ConsoleUtils.pad('Status:', labelWidth)}${ConsoleUtils.reset} ${ConsoleUtils.yellow}${appt.formattedStatus}${ConsoleUtils.reset}');
          print(
              '  ${ConsoleUtils.cyan}-----------------------------${ConsoleUtils.reset}');
        }
      } else {
        ConsoleUtils.printError(result.message);
      }
    } catch (e) {
      ConsoleUtils.printError('Invalid date format. Please use YYYY-MM-DD.');
    }
    ConsoleUtils.waitForKey();
  }

  void _listAllPatients({bool wait = false}) {
    ConsoleUtils.printHeader('ALL PATIENTS');
    final patients = _db.getAllPatients();
    if (patients.isEmpty) {
      ConsoleUtils.printInfo('No patients found.');
    } else {
      for (var p in patients) {
        p.display(); // This now calls our new single-line display method
      }
    }
    if (wait) ConsoleUtils.waitForKey();
  }

  void _viewAllAppointments() {
    ConsoleUtils.printHeader('ALL APPOINTMENTS');
    final appointments = _db.getAllAppointments();

    if (appointments.isEmpty) {
      ConsoleUtils.printInfo('No appointments found.');
    } else {    // 1. Define column widths
      const int idWidth = 10;
      const int patientWidth = 20;
      const int doctorWidth = 20;
      const int dateWidth = 12;
      const int timeWidth = 7;
      const int statusWidth = 11;

      // 2. Print the table header
      print(''); // Add a blank line for spacing
      print(
          '${ConsoleUtils.bold}${ConsoleUtils.cyan}'
          '${ConsoleUtils.pad("ID", idWidth)}'
          '${ConsoleUtils.pad("Patient", patientWidth)}'
          '${ConsoleUtils.pad("Doctor", doctorWidth)}'
          '${ConsoleUtils.pad("Date", dateWidth)}'
          '${ConsoleUtils.pad("Time", timeWidth)}'
          '${ConsoleUtils.pad("Status", statusWidth)}'
          '${ConsoleUtils.reset}');

      // Print a separator line
      print('${ConsoleUtils.cyan}${'-' * (idWidth + patientWidth + doctorWidth + dateWidth + timeWidth + statusWidth)}${ConsoleUtils.reset}');

      // 3. Print each appointment as a row
      for (var appt in appointments) {
        String statusColor;
        switch (appt.status) {
          case AppointmentStatus.scheduled:
            statusColor = ConsoleUtils.yellow;
            break;
          case AppointmentStatus.completed:
            statusColor = ConsoleUtils.green;
            break;
          case AppointmentStatus.cancelled:
            statusColor = ConsoleUtils.red;
            break;
        }

        print(
            // UPDATED to use `id`
            '${ConsoleUtils.pad(appt.id, idWidth)}'
            '${ConsoleUtils.pad(appt.patient.name, patientWidth)}'
            '${ConsoleUtils.pad('Dr. ${appt.doctor.name}', doctorWidth)}'
            '${ConsoleUtils.pad(appt.formattedDate, dateWidth)}'
            '${ConsoleUtils.pad(appt.formattedTime, timeWidth)}'
            '$statusColor${ConsoleUtils.pad(appt.formattedStatus, statusWidth)}${ConsoleUtils.reset}');
      }
    }
    ConsoleUtils.waitForKey();
  }

  void _cancelAppointment() {
    ConsoleUtils.printHeader('CANCEL APPOINTMENT');

    // 1. Get *only* cancellable (scheduled) appointments
    final scheduledAppointments = _db.getAllAppointments()
        .where((a) => a.status == AppointmentStatus.scheduled)
        .toList();

    if (scheduledAppointments.isEmpty) {
      ConsoleUtils.printInfo('No scheduled appointments to cancel.');
      ConsoleUtils.waitForKey();
      return;
    }

    // 2. Display them as a numbered list
    ConsoleUtils.printInfo('Select an appointment to cancel:');
    for (int i = 0; i < scheduledAppointments.length; i++) {
      final appt = scheduledAppointments[i];
      print(
          '  ${ConsoleUtils.cyan}${i + 1}.${ConsoleUtils.reset} ${appt.id} - ${appt.patient.name} with Dr. ${appt.doctor.name} on ${appt.formattedDate} @ ${appt.formattedTime}');
    }

    // 3. Get user's choice
    final index = ConsoleUtils.readInt('\nEnter Number to cancel (0 to go back): ');

    if (index == null || index == 0) {
      return; // Go back
    }

    if (index < 1 || index > scheduledAppointments.length) {
      ConsoleUtils.printError('Invalid selection.');
      ConsoleUtils.waitForKey();
      return;
    }

    // 4. Process the cancellation using the real ID
    final selectedAppointment = scheduledAppointments[index - 1];
    final success = _appointmentService.cancelAppointment(selectedAppointment.id);

    if (success) {
      ConsoleUtils.printSuccess(
          'Appointment ${selectedAppointment.id} has been cancelled.');
    } else {
      // This error should no longer happen
      ConsoleUtils.printError('Error: Could not find appointment to cancel.');
    }
    ConsoleUtils.waitForKey();
  }

  void _addPatient() {
    ConsoleUtils.printHeader('ADD NEW PATIENT');
    final name = ConsoleUtils.readInput('Enter Name: ');
    final contact = ConsoleUtils.readInput('Enter Contact (Phone): ');
    final history = ConsoleUtils.readInput('Enter Medical History: ');
    
    final patient = _db.createPatient(name, contact, history);
    ConsoleUtils.printSuccess('Patient added successfully!');
    patient.display();
    ConsoleUtils.waitForKey();
  }

  void _listAllDoctors({bool wait = false}) {
    ConsoleUtils.printHeader('ALL DOCTORS');
    final doctors = _db.getAllDoctors();
    if (doctors.isEmpty) {
      ConsoleUtils.printInfo('No doctors found.');
    } else {
      for (var d in doctors) {
        d.display(); // This now calls our new single-line display method
      }
    }
    if (wait) ConsoleUtils.waitForKey();
  }


  void _showDoctorsMenu() {
    ConsoleUtils.printHeader('DOCTOR MANAGEMENT');
     print('${ConsoleUtils.cyan}1.${ConsoleUtils.reset} Add New Doctor');
     print('${ConsoleUtils.cyan}2.${ConsoleUtils.reset} View All Doctors');
     print('${ConsoleUtils.red}3.${ConsoleUtils.reset} Back to Main Menu');
     String choice = ConsoleUtils.readInput('Enter your choice: ');

      switch (choice) {
        case '1':
          _addDoctor();
          break;
        case '2':
          _listAllDoctors(wait: true);
          break;
        case '3':
          return;
        default:
          ConsoleUtils.printError('Invalid choice.');
          ConsoleUtils.waitForKey();
      }
  }

  void _addDoctor() {
    ConsoleUtils.printHeader('ADD NEW DOCTOR');
    final name = ConsoleUtils.readInput('Enter Name: ');
    final contact = ConsoleUtils.readInput('Enter Contact (Phone): ');
    final specialty = ConsoleUtils.readInput('Enter Specialty: ');
    
    final doctor = _db.createDoctor(name, contact, specialty);
    ConsoleUtils.printSuccess('Doctor added successfully!');
    doctor.display();
    ConsoleUtils.waitForKey();
  }
}