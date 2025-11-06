import 'package:apps/src/ui/consoleUtils.dart';
import 'package:apps/src/services/appointmentService.dart';
import '../../database/database.dart';
import 'package:apps/src/domains/prescription.dart';
import 'package:apps/src/domains/medication.dart';

class Prescriptionui {
  final Database _db;
  final AppointmentService _appointmentService;

  Prescriptionui(this._db) : _appointmentService = AppointmentService(_db);

  void showPrescriptionsMenu() {
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
          _addPrescription();
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


  void _addPrescription() {
    ConsoleUtils.printHeader('ADD New PRESCRIPTION');

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
    ConsoleUtils.printInfo('Available Doctors:');
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
    final medications = <Medication>[];
    bool addMore = true;
    while(addMore) {
      ConsoleUtils.printInfo('Adding Medication ${medications.length + 1}');
      final name = ConsoleUtils.readInput('  Enter Medication Name: ');
      final dosage = ConsoleUtils.readInput('  Enter Dosage (e.g., 500mg): ');
      final days = ConsoleUtils.readInt('  Enter Days (e.g., 7): ') ?? 7;

      medications.add(Medication(name: name, dosage: dosage, days: days));

      final choice = ConsoleUtils.readInput('Add another medication? (y/n): ');
      addMore = (choice.toLowerCase() == 'y');
    }

    final notes = ConsoleUtils.readInput('Enter Notes (optional): ', allowEmpty: true);

    // --- 4. Call the Domain Service ---
    final result = _appointmentService.issuePrescription(
        selectedPatient.id, selectedDoctor.id, medications, notes: notes);

    if (result.success) {
      ConsoleUtils.printSuccess(result.message);
      // Print confirmation report
      _printPrescriptionDetails(result.prescription!);
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
      ConsoleUtils.printInfo('Showing ${prescriptions.length} prescription(s) for ${selectedPatient.name}:');
      // Print a detailed report for EACH prescription
      for (final p in prescriptions) {
        _printPrescriptionDetails(p);
      }
    }
    ConsoleUtils.waitForKey();
  }

  /// Helper to print a formatted table of prescriptions.
  void _printPrescriptionDetails(Prescription p) {
    final labelWidth = 10; // Width for labels like 'ID:'
    final totalFrameWidth = 60; // Total width of the report frame
    final divider = '${ConsoleUtils.magenta}${'=' * totalFrameWidth}${ConsoleUtils.reset}';
    final contentIndent = '  '; // Indent for the content within the frame

    print(''); // Extra space
    print(divider);
    print('${contentIndent}${ConsoleUtils.bold}${ConsoleUtils.cyan}PRESCRIPTION DETAILS${ConsoleUtils.reset}');
    print(divider);

    print(
        '$contentIndent${ConsoleUtils.bold}${ConsoleUtils.pad('ID:', labelWidth)}${ConsoleUtils.reset} ${p.id}');
    print(
        '$contentIndent${ConsoleUtils.bold}${ConsoleUtils.pad('Date:', labelWidth)}${ConsoleUtils.reset} ${p.formattedDate}');
    print(
        '$contentIndent${ConsoleUtils.bold}${ConsoleUtils.pad('Doctor:', labelWidth)}${ConsoleUtils.reset} Dr. ${p.doctor.name}');
    print(
        '$contentIndent${ConsoleUtils.bold}${ConsoleUtils.pad('Patient:', labelWidth)}${ConsoleUtils.reset} ${p.patient.name}');

    print('\n$contentIndent${ConsoleUtils.cyan}--- MEDICATIONS ---${ConsoleUtils.reset}');
    if (p.medications.isEmpty) {
      print('$contentIndent  (No medications listed)');
    } else {
      for (int i = 0; i < p.medications.length; i++) {
        final med = p.medications[i];
        print('$contentIndent  ${ConsoleUtils.bold}${i + 1}. ${med.name}${ConsoleUtils.reset} (${med.dosage}, ${med.days}d)');
      }
    }

    print('\n$contentIndent${ConsoleUtils.cyan}--- NOTES ---${ConsoleUtils.reset}');
    if (p.notes == null || p.notes!.isEmpty) {
      print('$contentIndent  (No notes)');
    } else {
      // Calculate available width for notes (totalFrameWidth - indent for label - '  ' for content)
      final notesAvailableWidth = totalFrameWidth - contentIndent.length * 2; // Subtract indent twice for "  Notes: "

      // Wrap the notes text and print each line
      final wrappedNotes = ConsoleUtils.wrapText(p.notes!, notesAvailableWidth);
      for (final line in wrappedNotes) {
        print('$contentIndent  $line');
      }
    }
    print(divider);
  }
}

