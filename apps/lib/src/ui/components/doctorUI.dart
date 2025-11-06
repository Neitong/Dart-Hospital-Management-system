import 'package:apps/src/database/database.dart';
import 'package:apps/src/ui/consoleUtils.dart';
import 'package:apps/src/domains/appointmentService.dart';

class Doctorui {
  final Database _db;
  final AppointmentService _appointmentService;

  Doctorui(this._db) : _appointmentService = AppointmentService(_db);


  void showDoctorsMenu() {
    bool running = true;
    while(running) {
      ConsoleUtils.clearScreen();
      ConsoleUtils.printHeader('DOCTOR MANAGEMENT');
      print('${ConsoleUtils.cyan}[1]${ConsoleUtils.reset} Add New Doctor');
      print('${ConsoleUtils.cyan}[2]${ConsoleUtils.reset} View All Doctors');
      print('${ConsoleUtils.cyan}[3]${ConsoleUtils.reset} Update Doctor');
      print('${ConsoleUtils.cyan}[4]${ConsoleUtils.reset} Delete Doctor');
      print('${ConsoleUtils.red}[5]${ConsoleUtils.reset} Back to Main Menu');
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
          '  ${ConsoleUtils.cyan}[${i + 1}].${ConsoleUtils.reset} ${doctors[i].id} - Dr. ${doctors[i].name}');
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
          '  ${ConsoleUtils.cyan}[${i + 1}].${ConsoleUtils.reset} ${doctors[i].id} - Dr. ${doctors[i].name}');
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

}

