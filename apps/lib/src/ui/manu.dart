import '../database/database.dart';
import 'package:apps/src/ui/consoleUtils.dart';

//Import UI components
import 'components/appointmentUI.dart';
import 'components/patientUI.dart';
import 'components/doctorUI.dart';
import 'components/prescriptionUI.dart';


// UI Layer - Handles user interaction
class MainMenu {
  final Database _db;

  MainMenu(this._db);

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
          AppointmentMenu( _db).showAppointmentsMenu();
          break;
        case '2':
          Patientui(_db).showPatientsMenu();
          break;
        case '3':
          Doctorui(_db).showDoctorsMenu();
          break;
        case '4':
          Prescriptionui(_db).showPrescriptionsMenu();
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
}