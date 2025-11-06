import 'package:apps/src/ui/consoleUtils.dart';
import 'package:apps/src/services/appointmentService.dart';
import '../../database/database.dart';

//Import UI components

class Patientui {
  final Database _db;
  final AppointmentService _appointmentService;


  Patientui(this._db) :_appointmentService = AppointmentService(_db);

  void showPatientsMenu() {
    bool running = true;
    while (running) {
      ConsoleUtils.clearScreen();
      ConsoleUtils.printHeader('PATIENT MANAGEMENT');
      print('${ConsoleUtils.cyan}[1]${ConsoleUtils.reset} Add New Patient');
      print('${ConsoleUtils.cyan}[2]${ConsoleUtils.reset} View All Patients');
      print('${ConsoleUtils.cyan}[3]${ConsoleUtils.reset} Update Patient');
      print('${ConsoleUtils.cyan}[4]${ConsoleUtils.reset} Delete Patient');
      print('${ConsoleUtils.red}[5]${ConsoleUtils.reset} Back to Main Menu');
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
          '  ${ConsoleUtils.cyan}[${i + 1}].${ConsoleUtils.reset} ${patients[i].id} - ${patients[i].name}');
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
          '  ${ConsoleUtils.cyan}[${i + 1}].${ConsoleUtils.reset} ${patients[i].id} - ${patients[i].name}');
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


}

