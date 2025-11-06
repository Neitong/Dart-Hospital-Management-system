import 'package:apps/src/domains/prescription.dart';

class PrescriptionResult {
  final bool success;
  final String message;
  final Prescription? prescription;

  PrescriptionResult(
      {required this.success, required this.message, this.prescription});
}