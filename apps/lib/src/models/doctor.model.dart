// lib/domain/doctor.dart

import 'package:apps/src/models/appointment.model.dart';
import 'package:apps/src/models/staff.model.dart';
import 'package:apps/src/ui/consoleUtils.dart';

class Doctor extends Staff {
  String specialty;
  final List<Appointment> _appointments = [];

  Doctor({
    required super.id,
    required super.name,
    required super.contact,
    required super.staffId,
    required this.specialty,
    super.department = 'Medical',
  });

  // Encapsulation
  List<Appointment> get appointments => List.unmodifiable(_appointments);

  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
  }

  void removeAppointment(Appointment appointment) {
    _appointments.remove(appointment);
  }

  bool isAvailable(DateTime time) {
    // Check if the doctor has another appointment at the same time
    return !_appointments.any((appt) =>
        appt.dateTime.year == time.year &&
        appt.dateTime.month == time.month &&
        appt.dateTime.day == time.day &&
        appt.dateTime.hour == time.hour &&
        appt.status == AppointmentStatus.scheduled);
  }

  @override
  void display() {
    // UPDATED to use `id` directly
    print(
        '  ID: ${ConsoleUtils.pad(id, 10)} Name: ${ConsoleUtils.pad('Dr. ' + name, 20)} Specialty: ${ConsoleUtils.pad(specialty, 17)} Contact: $contact');
  }

  @override
  String calculatePay() {
    // Polymorphism example: A doctor's pay calculation would be specific
    return "Calculated pay for Doctor (Specialty: $specialty)";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'staffId': staffId,
      'specialty': specialty,
      'department': department,
    };
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      staffId: json['staffId'],
      specialty: json['specialty'],
      department: json['department'],
    );
  }
}