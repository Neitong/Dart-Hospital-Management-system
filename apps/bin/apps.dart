// bin/apps.dart

import 'package:apps/src/database/database.dart';
import 'package:apps/src/ui/manu.dart';

void main(List<String> arguments) {
  // 1. Initialize Data Layer
  final db = Database();
  
  // 2. Initialize UI Layer (which initializes Domain Layer)
  final menu = MainMenu(db);

  // 3. Start the application
  menu.show();
}