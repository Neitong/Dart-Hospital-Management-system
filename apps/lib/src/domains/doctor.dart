import 'package:apps/src/domains/appointment.dart';
import 'package:apps/src/domains/staff.dart';
import 'package:apps/src/ui/consoleUtils.dart';
import 'package:apps/src/domains/prescription.dart';
import 'package:apps/src/domains/patient.dart';
import 'package:apps/src/domains/medication.dart';
import 'package:apps/src/domains/utils/scedule.dart';
import 'appointmentStatus.dart';


class Doctor extends Staff {
  String specialty;
  List<String> specializations;
  final List<Appointment> _appointments = [];

  Doctor({
    required super.id,
    required super.name,
    required super.contact,
    required super.staffId,
    required this.specialty,
    List<String>? specializations,
    super.department = 'Medical',
  }) : specializations = specializations ?? [specialty];

  // Encapsulation
  List<Appointment> get appointments => List.unmodifiable(_appointments);

  void scheduleAppointment(Appointment appointment) {
    _appointments.add(appointment);
  }

  void removeAppointment(String appointmentId) {
    _appointments.removeWhere((appt) => appt.id == appointmentId);
  }

  // Checking doctor are available or not!
  bool isAvailable(DateTime start) {
    //Check the doctor During work Hour from 8:00 AM to 5:00PM
    if (!Schedule.isDuringWorkHours(start)) {
      return false;
    }

    return !_appointments.any((appt) {
      if (appt.status != AppointmentStatus.scheduled) return false;
      // Check if the start time of the existing appointment is the same
      return appt.start.year == start.year &&
          appt.start.month == start.month &&
          appt.start.day == start.day &&
          appt.start.hour == start.hour;
    });
  }

  //Create prescription
  Prescription createPrescription(
      String prescriptionId,
      Patient patient, 
      List<Medication> medications, 
      String? notes) {
    final prescription = Prescription(
      id: prescriptionId,
      patientId: patient.id,
      doctorId: id,
      date: DateTime.now(),
      medications: medications,
      notes: notes,
    );
    return prescription;
  }

  @override
  void display() {
    print('  ID: ${ConsoleUtils.pad(id, 10)} Name: ${ConsoleUtils.pad('Dr. ' + name, 20)} Specialty: ${ConsoleUtils.pad(specialty, 17)} Contact: $contact');
  }

  @override
  String calculatePay() {
    return "Calculated pay for Doctor (Specialty: $specialty)";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'staffId': staffId,
      'specialty': specialty,
      'specializations': specializations,
      'department': department,
    };
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final doctor = Doctor(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      staffId: json['staffId'],
      specialty: json['specialty'],
      specializations: json['specializations'] != null 
          ? List<String>.from(json['specializations'])
          : null,
      department: json['department'],
    );

    return doctor;
  }
}