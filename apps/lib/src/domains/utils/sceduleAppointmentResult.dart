import 'package:apps/src/domains/appointment.dart';

class ScheduleAppointmentResult {
  final bool success;
  final String message;
  final Appointment? appointment;

  ScheduleAppointmentResult(
      {required this.success, required this.message, this.appointment});
}
