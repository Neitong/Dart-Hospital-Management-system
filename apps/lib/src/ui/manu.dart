import '../database/database.dart';
import 'package:apps/src/models/appointmentService.model.dart';
import 'package:apps/src/ui/consoleUtils.dart';
import 'package:apps/src/models/appointment.model.dart';
import 'package:apps/src/models/prescription.dart';


// UI Layer - Handles user interaction
class MainMenu {
  final Database _db;
  final AppointmentService _appointmentService;

  MainMenu(this._db) : _appointmentService = AppointmentService(_db) {
    // _db.seedData(); // Load demo data
  }

  void show() {
    bool running = true;
    while (running) {
      ConsoleUtils.clearScreen();
      ConsoleUtils.printHeader('HOSPITAL MANAGEMENT SYSTEM');
      print('${ConsoleUtils.cyan}[1]${ConsoleUtils.reset} Manage Appointments');
      print('${ConsoleUtils.cyan}[2]${ConsoleUtils.reset} Manage Patients');
      print('${ConsoleUtils.cyan}[3]${ConsoleUtils.reset} Manage Doctors');
      print('${ConsoleUtils.cyan}[4]${ConsoleUtils.reset} Manage Prescriptions');
      print('${ConsoleUtils.red}[5]${ConsoleUtils.reset} Exit');
      
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
          _showPrescriptionsMenu();
          break;
        case '5':
          running = false;
          print('\nGoodbye!');
        default:
          ConsoleUtils.printError('Invalid choice. Please try again.');
          ConsoleUtils.waitForKey();
      }
    }
  }

  void _showPatientsMenu() {
    bool running = true;
    while (running) {
      ConsoleUtils.clearScreen();
      ConsoleUtils.printHeader('PATIENT MANAGEMENT');
      print('${ConsoleUtils.cyan}1.${ConsoleUtils.reset} Add New Patient');
      print('${ConsoleUtils.cyan}2.${ConsoleUtils.reset} View All Patients');
      print('${ConsoleUtils.cyan}3.${ConsoleUtils.reset} Update Patient');
      print('${ConsoleUtils.cyan}4.${ConsoleUtils.reset} Delete Patient');
      print('${ConsoleUtils.red}5.${ConsoleUtils.reset} Back to Main Menu');
      String choice = ConsoleUtils.readInput('Enter your choice: ');

      switch (choice) {
        case '1':
          _addPatient();
          break;
        case '2':
          _listAllPatients(wait: true);
          break;
        case '3':
          _updatePatient(); // New option
          break;
        case '4':
          _deletePatient(); // New option
          break;
        case '5':
          running = false;
          break;
        default:
          ConsoleUtils.printError('Invalid choice.');
          ConsoleUtils.waitForKey();
      }
    }
  }

  void _updatePatient() {
    ConsoleUtils.printHeader('UPDATE PATIENT');

    // 1. Select the patient to update
    final patients = _db.getAllPatients();
    if (patients.isEmpty) {
      ConsoleUtils.printInfo('No patients found to update.');
      ConsoleUtils.waitForKey();
      return;
    }

    ConsoleUtils.printInfo('Select a patient to update:');
    for (int i = 0; i < patients.length; i++) {
      print(
          '  ${ConsoleUtils.cyan}${i + 1}.${ConsoleUtils.reset} ${patients[i].id} - ${patients[i].name}');
    }

    final index = ConsoleUtils.readInt('\nEnter Number (0 to go back): ');
    if (index == null || index == 0) return; // Go back

    if (index < 1 || index > patients.length) {
      ConsoleUtils.printError('Invalid selection.');
      ConsoleUtils.waitForKey();
      return;
    }

    final patientToUpdate = patients[index - 1];

    // 2. Get new information (press Enter to keep existing)
    ConsoleUtils.printInfo(
        'Enter new information (or press Enter to keep current):');

    String newName = ConsoleUtils.readInput(
        '  Name (${patientToUpdate.name}): ',
        allowEmpty: true);
    if (newName.isEmpty) newName = patientToUpdate.name;

    String newContact = ConsoleUtils.readInput(
        '  Contact (${patientToUpdate.contact}): ',
        allowEmpty: true);
    if (newContact.isEmpty) newContact = patientToUpdate.contact;

    final currentBirthdateStr = patientToUpdate.birthdate.toIso8601String().split('T')[0];
    String newBirthdateStr = ConsoleUtils.readInput(
        '  Birthdate ($currentBirthdateStr): ',
        allowEmpty: true);
    DateTime newBirthdate = patientToUpdate.birthdate;
    if (newBirthdateStr.isNotEmpty) {
      try {
        newBirthdate = DateTime.parse(newBirthdateStr);
      } catch (e) {
        ConsoleUtils.printError('Invalid date format. Keeping existing.');
      }
    }

    // 3. Apply updates to the patient object
    patientToUpdate.name = newName;
    patientToUpdate.contact = newContact;
    patientToUpdate.birthdate = newBirthdate;
    
    // 4. Save the updated object to the database
    _db.updatePatient(patientToUpdate);

    ConsoleUtils.printSuccess('Patient ${patientToUpdate.id} updated successfully!');
    
    // 5. Show the updated patient in the table format
    const int idWidth = 10, nameWidth = 20, contactWidth = 15, birthdateWidth = 15;
    print(
        '\n${ConsoleUtils.bold}${ConsoleUtils.cyan}'
        '${ConsoleUtils.pad("ID", idWidth)}'
        '${ConsoleUtils.pad("Name", nameWidth)}'
        '${ConsoleUtils.pad("Contact", contactWidth)}'
        '${ConsoleUtils.pad("Birthdate", birthdateWidth)}'
        '${ConsoleUtils.reset}');
    print('${ConsoleUtils.cyan}${'-' * (idWidth + nameWidth + contactWidth + birthdateWidth)}${ConsoleUtils.reset}');
    final birthdateStr = patientToUpdate.birthdate.toIso8601String().split('T')[0];
    print(
        '${ConsoleUtils.pad(patientToUpdate.id, idWidth)}'
        '${ConsoleUtils.pad(patientToUpdate.name, nameWidth)}'
        '${ConsoleUtils.pad(patientToUpdate.contact, contactWidth)}'
        '${ConsoleUtils.pad(birthdateStr, birthdateWidth)}');

    ConsoleUtils.waitForKey();
  }

  void _deletePatient() {
    ConsoleUtils.printHeader('DELETE PATIENT');

    // 1. Select the patient to delete
    final patients = _db.getAllPatients();
    if (patients.isEmpty) {
      ConsoleUtils.printInfo('No patients found to delete.');
      ConsoleUtils.waitForKey();
      return;
    }

    ConsoleUtils.printInfo('Select a patient to DELETE:');
    for (int i = 0; i < patients.length; i++) {
      print(
          '  ${ConsoleUtils.cyan}${i + 1}.${ConsoleUtils.reset} ${patients[i].id} - ${patients[i].name}');
    }

    final index = ConsoleUtils.readInt('\nEnter Number (0 to go back): ');
    if (index == null || index == 0) return; // Go back

    if (index < 1 || index > patients.length) {
      ConsoleUtils.printError('Invalid selection.');
      ConsoleUtils.waitForKey();
      return;
    }

    final patientToDelete = patients[index - 1];

    // 2. Add a confirmation step to prevent accidents
    ConsoleUtils.printError(
        'WARNING: This will delete the patient and CANCEL all their scheduled appointments.');
    String confirmation = ConsoleUtils.readInput(
        'Type \'${patientToDelete.id}\' to confirm deletion: ');

    if (confirmation != patientToDelete.id) {
      ConsoleUtils.printInfo('Deletion cancelled.');
      ConsoleUtils.waitForKey();
      return;
    }

    // 3. Call the service layer to perform the deletion
    final success =
        _appointmentService.deletePatientAndCancelAppointments(patientToDelete.id);

    if (success) {
      ConsoleUtils.printSuccess(
          'Patient ${patientToDelete.id} and their appointments have been deleted/cancelled.');
    } else {
      ConsoleUtils.printError('Error: Could not delete patient.');
    }
    ConsoleUtils.waitForKey();
  }

  void _showAppointmentsMenu() {
    bool running = true;
    while(running) {
      ConsoleUtils.clearScreen();
      ConsoleUtils.printHeader('APPOINTMENT MANAGEMENT');
      print('${ConsoleUtils.cyan}[1]${ConsoleUtils.reset} Schedule New Appointment');
      print('${ConsoleUtils.cyan}[2]${ConsoleUtils.reset} View All Appointments');
      print('${ConsoleUtils.cyan}[3]${ConsoleUtils.reset} Cancel Appointment');
      print('${ConsoleUtils.red}[4]${ConsoleUtils.reset} Back to Main Menu');
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
    
    final durationMinutes = ConsoleUtils.readInt('Enter Duration (minutes, default 30): ') ?? 30;

    try {
      final dateTime = DateTime.parse('$dateStr $hour:00:00');
      final duration = Duration(minutes: durationMinutes);

      // Call the Domain Service
      final result = _appointmentService.scheduleAppointment(
          selectedPatient.id, selectedDoctor.id, dateTime, duration);

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
      // --- NEW TABLE UI BLOCK ---
      const int idWidth = 10;
      const int nameWidth = 20;
      const int contactWidth = 15;
      const int birthdateWidth = 15;

      // 1. Print Header
      print(
          '\n${ConsoleUtils.bold}${ConsoleUtils.cyan}'
          '${ConsoleUtils.pad("ID", idWidth)}'
          '${ConsoleUtils.pad("Name", nameWidth)}'
          '${ConsoleUtils.pad("Contact", contactWidth)}'
          '${ConsoleUtils.pad("Birthdate", birthdateWidth)}'
          '${ConsoleUtils.reset}');

      // 2. Print Separator
      print('${ConsoleUtils.cyan}${'-' * (idWidth + nameWidth + contactWidth + birthdateWidth)}${ConsoleUtils.reset}');

      // 3. Print Data Rows
      for (var patient in patients) {
        final birthdateStr = patient.birthdate.toIso8601String().split('T')[0];
        print(
            '${ConsoleUtils.pad(patient.id, idWidth)}'
            '${ConsoleUtils.pad(patient.name, nameWidth)}'
            '${ConsoleUtils.pad(patient.contact, contactWidth)}'
            '${ConsoleUtils.pad(birthdateStr, birthdateWidth)}');
      }
      // --- END OF NEW TABLE UI BLOCK ---
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
    final birthdateInput = ConsoleUtils.readInput('Enter Birthdate (YYYY-MM-DD): ');
    
    DateTime? birthdate;
    try {
      birthdate = DateTime.parse(birthdateInput);
    } catch (e) {
      ConsoleUtils.printError('Invalid date format. Using default.');
    }

    final patient = _db.createPatient(name, contact, birthdate: birthdate);
    ConsoleUtils.printSuccess('Patient added successfully!');

    // --- NEW TABLE UI BLOCK ---
    const int idWidth = 10;
    const int nameWidth = 20;
    const int contactWidth = 15;
    const int birthdateWidth = 15;

    // 1. Print Header
    print(
        '\n${ConsoleUtils.bold}${ConsoleUtils.cyan}'
        '${ConsoleUtils.pad("ID", idWidth)}'
        '${ConsoleUtils.pad("Name", nameWidth)}'
        '${ConsoleUtils.pad("Contact", contactWidth)}'
        '${ConsoleUtils.pad("Birthdate", birthdateWidth)}'
        '${ConsoleUtils.reset}');

    // 2. Print Separator
    print('${ConsoleUtils.cyan}${'-' * (idWidth + nameWidth + contactWidth + birthdateWidth)}${ConsoleUtils.reset}');

    // 3. Print Data Row
    final birthdateStr = patient.birthdate.toIso8601String().split('T')[0];
    print(
        '${ConsoleUtils.pad(patient.id, idWidth)}'
        '${ConsoleUtils.pad(patient.name, nameWidth)}'
        '${ConsoleUtils.pad(patient.contact, contactWidth)}'
        '${ConsoleUtils.pad(birthdateStr, birthdateWidth)}');
    // --- END OF NEW TABLE UI BLOCK ---

    ConsoleUtils.waitForKey();
  }

  void _listAllDoctors({bool wait = false}) {
    ConsoleUtils.printHeader('ALL DOCTORS');
    final doctors = _db.getAllDoctors();

    if (doctors.isEmpty) {
      ConsoleUtils.printInfo('No doctors found.');
    } else {
      // --- NEW TABLE UI BLOCK ---
      const int idWidth = 10;
      const int nameWidth = 20;
      const int contactWidth = 15;
      const int specialtyWidth = 20;

      // 1. Print Header
      print(
          '\n${ConsoleUtils.bold}${ConsoleUtils.cyan}'
          '${ConsoleUtils.pad("ID", idWidth)}'
          '${ConsoleUtils.pad("Name", nameWidth)}'
          '${ConsoleUtils.pad("Contact", contactWidth)}'
          '${ConsoleUtils.pad("Specialty", specialtyWidth)}'
      '${ConsoleUtils.reset}');

      // 2. Print Separator
      print('${ConsoleUtils.cyan}${'-' * (idWidth + nameWidth + contactWidth + specialtyWidth)}${ConsoleUtils.reset}');

      // 3. Print Data Rows
      for (var doctor in doctors) {
        print(
            '${ConsoleUtils.pad(doctor.id, idWidth)}'
            '${ConsoleUtils.pad('Dr. ' + doctor.name, nameWidth)}'
            '${ConsoleUtils.pad(doctor.contact, contactWidth)}'
            '${ConsoleUtils.pad(doctor.specialty, specialtyWidth)}');
      }
      // --- END OF NEW TABLE UI BLOCK ---
    }
    if (wait) ConsoleUtils.waitForKey();
  }


  void _showDoctorsMenu() {
    bool running = true;
    while(running) {
      ConsoleUtils.clearScreen();
      ConsoleUtils.printHeader('DOCTOR MANAGEMENT');
      print('${ConsoleUtils.cyan}1.${ConsoleUtils.reset} Add New Doctor');
      print('${ConsoleUtils.cyan}2.${ConsoleUtils.reset} View All Doctors');
      print('${ConsoleUtils.cyan}3.${ConsoleUtils.reset} Update Doctor');
      print('${ConsoleUtils.cyan}4.${ConsoleUtils.reset} Delete Doctor');
      print('${ConsoleUtils.red}5.${ConsoleUtils.reset} Back to Main Menu');
      String choice = ConsoleUtils.readInput('Enter your choice: ');

      switch (choice) {
        case '1':
          _addDoctor();
          break;
        case '2':
          _listAllDoctors(wait: true);
          break;
        case '3':
          _updateDoctor(); // New option
          break;
        case '4':
          _deleteDoctor(); // New option
          break;
        case '5':
          running = false;
          break;
        default:
          ConsoleUtils.printError('Invalid choice.');
          ConsoleUtils.waitForKey();
      }
    }
  }

  void _updateDoctor() {
    ConsoleUtils.printHeader('UPDATE DOCTOR');

    // 1. Select the doctor to update
    final doctors = _db.getAllDoctors();
    if (doctors.isEmpty) {
      ConsoleUtils.printInfo('No doctors found to update.');
      ConsoleUtils.waitForKey();
      return;
    }

    ConsoleUtils.printInfo('Select a doctor to update:');
    for (int i = 0; i < doctors.length; i++) {
      print(
          '  ${ConsoleUtils.cyan}${i + 1}.${ConsoleUtils.reset} ${doctors[i].id} - Dr. ${doctors[i].name}');
    }

    final index = ConsoleUtils.readInt('\nEnter Number (0 to go back): ');
    if (index == null || index == 0) return; // Go back

    if (index < 1 || index > doctors.length) {
      ConsoleUtils.printError('Invalid selection.');
      ConsoleUtils.waitForKey();
      return;
    }

    final doctorToUpdate = doctors[index - 1];

    // 2. Get new information (press Enter to keep existing)
    ConsoleUtils.printInfo(
        'Enter new information (or press Enter to keep current):');

    String newName = ConsoleUtils.readInput(
        '  Name (Dr. ${doctorToUpdate.name}): ',
        allowEmpty: true);
    if (newName.isEmpty) newName = doctorToUpdate.name;

    String newContact = ConsoleUtils.readInput(
        '  Contact (${doctorToUpdate.contact}): ',
        allowEmpty: true);
    if (newContact.isEmpty) newContact = doctorToUpdate.contact;

    String newSpecialty = ConsoleUtils.readInput(
        '  Specialty (${doctorToUpdate.specialty}): ',
        allowEmpty: true);
    if (newSpecialty.isEmpty) newSpecialty = doctorToUpdate.specialty;
    
    // 3. Apply updates to the doctor object
    doctorToUpdate.name = newName;
    doctorToUpdate.contact = newContact;
    doctorToUpdate.specialty = newSpecialty;
    
    // 4. Save the updated object to the database
    _db.updateDoctor(doctorToUpdate);

    ConsoleUtils.printSuccess('Doctor ${doctorToUpdate.id} updated successfully!');
    
    // 5. Show the updated doctor in the table format
    const int idWidth = 10, nameWidth = 20, contactWidth = 15, specialtyWidth = 20;
    print(
        '\n${ConsoleUtils.bold}${ConsoleUtils.cyan}'
        '${ConsoleUtils.pad("ID", idWidth)}'
        '${ConsoleUtils.pad("Name", nameWidth)}'
        '${ConsoleUtils.pad("Contact", contactWidth)}'
        '${ConsoleUtils.pad("Specialty", specialtyWidth)}'
        '${ConsoleUtils.reset}');
    print('${ConsoleUtils.cyan}${'-' * (idWidth + nameWidth + contactWidth + specialtyWidth)}${ConsoleUtils.reset}');
    print(
        '${ConsoleUtils.pad(doctorToUpdate.id, idWidth)}'
        '${ConsoleUtils.pad('Dr. ' + doctorToUpdate.name, nameWidth)}'
        '${ConsoleUtils.pad(doctorToUpdate.contact, contactWidth)}'
        '${ConsoleUtils.pad(doctorToUpdate.specialty, specialtyWidth)}');

    ConsoleUtils.waitForKey();
  }

  void _deleteDoctor() {
    ConsoleUtils.printHeader('DELETE DOCTOR');

    // 1. Select the doctor to delete
    final doctors = _db.getAllDoctors();
    if (doctors.isEmpty) {
      ConsoleUtils.printInfo('No doctors found to delete.');
      ConsoleUtils.waitForKey();
      return;
    }

    ConsoleUtils.printInfo('Select a doctor to DELETE:');
    for (int i = 0; i < doctors.length; i++) {
      print(
          '  ${ConsoleUtils.cyan}${i + 1}.${ConsoleUtils.reset} ${doctors[i].id} - Dr. ${doctors[i].name}');
    }

    final index = ConsoleUtils.readInt('\nEnter Number (0 to go back): ');
    if (index == null || index == 0) return; // Go back

    if (index < 1 || index > doctors.length) {
      ConsoleUtils.printError('Invalid selection.');
      ConsoleUtils.waitForKey();
      return;
    }

    final doctorToDelete = doctors[index - 1];

    // 2. Add a confirmation step to prevent accidents
    ConsoleUtils.printError(
        'WARNING: This will delete the doctor and CANCEL all their scheduled appointments.');
    String confirmation = ConsoleUtils.readInput(
        'Type \'${doctorToDelete.id}\' to confirm deletion: ');

    if (confirmation != doctorToDelete.id) {
      ConsoleUtils.printInfo('Deletion cancelled.');
      ConsoleUtils.waitForKey();
      return;
    }

    // 3. Call the service layer to perform the deletion
    final success =
        _appointmentService.deleteDoctorAndCancelAppointments(doctorToDelete.id);

    if (success) {
      ConsoleUtils.printSuccess(
          'Doctor ${doctorToDelete.id} and their appointments have been deleted/cancelled.');
    } else {
      ConsoleUtils.printError('Error: Could not delete doctor.');
    }
    ConsoleUtils.waitForKey();
  }

  void _addDoctor() {
    ConsoleUtils.printHeader('ADD NEW DOCTOR');
    final name = ConsoleUtils.readInput('Enter Name: ');
    final contact = ConsoleUtils.readInput('Enter Contact (Phone): ');
    final specialty = ConsoleUtils.readInput('Enter Specialty: ');

    final doctor = _db.createDoctor(name, contact, specialty);
    ConsoleUtils.printSuccess('Doctor added successfully!');

    // --- NEW TABLE UI BLOCK ---
    const int idWidth = 10;
    const int nameWidth = 20;
    const int contactWidth = 15;
    const int specialtyWidth = 20;

    // 1. Print Header
    print(
        '\n${ConsoleUtils.bold}${ConsoleUtils.cyan}'
        '${ConsoleUtils.pad("ID", idWidth)}'
        '${ConsoleUtils.pad("Name", nameWidth)}'
        '${ConsoleUtils.pad("Contact", contactWidth)}'
        '${ConsoleUtils.pad("Specialty", specialtyWidth)}'
        '${ConsoleUtils.reset}');

    // 2. Print Separator
    print('${ConsoleUtils.cyan}${'-' * (idWidth + nameWidth + contactWidth + specialtyWidth)}${ConsoleUtils.reset}');

    // 3. Print Data Row
    print(
        '${ConsoleUtils.pad(doctor.id, idWidth)}'
        '${ConsoleUtils.pad('Dr. ' + doctor.name, nameWidth)}'
        '${ConsoleUtils.pad(doctor.contact, contactWidth)}'
        '${ConsoleUtils.pad(doctor.specialty, specialtyWidth)}');
    // --- END OF NEW TABLE UI BLOCK ---

    ConsoleUtils.waitForKey();
  }

  void _showPrescriptionsMenu() {
    bool running = true;
    while(running) {
      ConsoleUtils.clearScreen();
      ConsoleUtils.printHeader('PRESCRIPTION MANAGEMENT');
      print('${ConsoleUtils.cyan}[1]${ConsoleUtils.reset} Issue New Prescription');
      print('${ConsoleUtils.cyan}[2]${ConsoleUtils.reset} View Patient Prescriptions');
      print('${ConsoleUtils.red}[3]${ConsoleUtils.reset} Back to Main Menu');
      String choice = ConsoleUtils.readInput('Enter your choice: ');

      switch (choice) {
        case '1':
          _issuePrescription();
          break;
        case '2':
          _viewPatientPrescriptions();
          break;
        case '3':
          running = false;
          break;
        default:
          ConsoleUtils.printError('Invalid choice.');
          ConsoleUtils.waitForKey();
      }
    }
  }

  void _issuePrescription() {
    ConsoleUtils.printHeader('ISSUE PRESCRIPTION');

    // --- 1. Select Patient ---
    final patients = _db.getAllPatients();
    if (patients.isEmpty) {
      ConsoleUtils.printError('No patients found.');
      ConsoleUtils.waitForKey();
      return;
    }
    ConsoleUtils.printInfo('Available Patients:');
    for (int i = 0; i < patients.length; i++) {
      print('  ${ConsoleUtils.cyan}${i + 1}.${ConsoleUtils.reset} ${patients[i].name} (${patients[i].contact})');
    }
    final patientIndex = ConsoleUtils.readInt('Enter Patient Number: ');
    if (patientIndex == null || patientIndex < 1 || patientIndex > patients.length) {
      ConsoleUtils.printError('Invalid selection.');
      ConsoleUtils.waitForKey();
      return;
    }
    final selectedPatient = patients[patientIndex - 1];

    // --- 2. Select Doctor (Issuer) ---
    final doctors = _db.getAllDoctors();
    if (doctors.isEmpty) {
      ConsoleUtils.printError('No doctors found.');
      ConsoleUtils.waitForKey();
      return;
    }
    ConsoleUtils.printInfo('Available Doctors (Issuer):');
    for (int i = 0; i < doctors.length; i++) {
      print('  ${ConsoleUtils.cyan}${i + 1}.${ConsoleUtils.reset} Dr. ${doctors[i].name} (${doctors[i].specialty})');
    }
    final doctorIndex = ConsoleUtils.readInt('Enter Doctor Number: ');
    if (doctorIndex == null || doctorIndex < 1 || doctorIndex > doctors.length) {
      ConsoleUtils.printError('Invalid selection.');
      ConsoleUtils.waitForKey();
      return;
    }
    final selectedDoctor = doctors[doctorIndex - 1];

    // --- 3. Get Prescription Details ---
    final medication = ConsoleUtils.readInput('Enter Medication: ');
    final dosage = ConsoleUtils.readInput('Enter Dosage (e.g., 500mg, 1 tablet 2x/day): ');

    // --- 4. Call the Domain Service ---
    final result = _appointmentService.issuePrescription(
        selectedPatient.id, selectedDoctor.id, medication, dosage);

    if (result.success) {
      ConsoleUtils.printSuccess(result.message);
      // Print confirmation table
      _printPrescriptionTable([result.prescription!]);
    } else {
      ConsoleUtils.printError(result.message);
    }
    ConsoleUtils.waitForKey();
  }

  void _viewPatientPrescriptions() {
    ConsoleUtils.printHeader('VIEW PATIENT PRESCRIPTIONS');

    // --- 1. Select Patient ---
    final patients = _db.getAllPatients();
    if (patients.isEmpty) {
      ConsoleUtils.printError('No patients found.');
      ConsoleUtils.waitForKey();
      return;
    }
    ConsoleUtils.printInfo('Select Patient:');
    for (int i = 0; i < patients.length; i++) {
      print('  ${ConsoleUtils.cyan}${i + 1}.${ConsoleUtils.reset} ${patients[i].name} (${patients[i].contact})');
    }
    final patientIndex = ConsoleUtils.readInt('Enter Patient Number: ');
    if (patientIndex == null || patientIndex < 1 || patientIndex > patients.length) {
      ConsoleUtils.printError('Invalid selection.');
      ConsoleUtils.waitForKey();
      return;
    }
    final selectedPatient = patients[patientIndex - 1];

    // --- 2. Get and Display Prescriptions ---
    final prescriptions = _db.getPrescriptionsForPatient(selectedPatient.id);
    if (prescriptions.isEmpty) {
      ConsoleUtils.printInfo('No prescriptions found for ${selectedPatient.name}.');
    } else {
      ConsoleUtils.printInfo('Showing prescriptions for ${selectedPatient.name}:');
      _printPrescriptionTable(prescriptions);
    }
    ConsoleUtils.waitForKey();
  }

  /// Helper to print a formatted table of prescriptions.
  void _printPrescriptionTable(List<Prescription> prescriptions) {
    const int idWidth = 10;
    const int dateWidth = 12;
    const int doctorWidth = 20;
    const int medWidth = 20;
    const int dosageWidth = 20;

    // 1. Print Header
    print(
        '\n${ConsoleUtils.bold}${ConsoleUtils.cyan}'
        '${ConsoleUtils.pad("ID", idWidth)}'
        '${ConsoleUtils.pad("Date", dateWidth)}'
        '${ConsoleUtils.pad("Doctor", doctorWidth)}'
        '${ConsoleUtils.pad("Medication", medWidth)}'
        '${ConsoleUtils.pad("Dosage", dosageWidth)}'
        '${ConsoleUtils.reset}');

    // 2. Print Separator
    print('${ConsoleUtils.cyan}${'-' * (idWidth + dateWidth + doctorWidth + medWidth + dosageWidth)}${ConsoleUtils.reset}');

    // 3. Print Data Rows
    for (var p in prescriptions) {
      final medicationsStr = p.medications.map((m) => m.name).join(', ');
      final dosageStr = p.medications.isNotEmpty ? p.medications.first.dosage : 'N/A';
      print(
          '${ConsoleUtils.pad(p.id, idWidth)}'
          '${ConsoleUtils.pad(p.formattedDate, dateWidth)}'
          '${ConsoleUtils.pad('Dr. ${p.doctor.name}', doctorWidth)}'
          '${ConsoleUtils.pad(medicationsStr, medWidth)}'
          '${ConsoleUtils.pad(dosageStr, dosageWidth)}');
    }
  }
}