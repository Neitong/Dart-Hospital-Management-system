// lib/domain/staff.dart

import 'package:apps/src/models/person.model.dart';

// Abstract class demonstrating inheritance and polymorphism
abstract class Staff extends Person {
  String staffId;
  String department;

  Staff({
    required super.id,
    required super.name,
    required super.contact,
    required this.staffId,
    required this.department,
  });

  // Abstract method for Polymorphism
  String calculatePay();
}