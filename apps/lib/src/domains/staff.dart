import 'package:apps/src/domains/person.dart';

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
  
  String calculatePay();
}