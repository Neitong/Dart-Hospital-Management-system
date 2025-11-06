
class Medication {
  final String name;
  final String dosage;
  final int days;

  Medication({
    required this.name,
    required this.dosage,
    required this.days,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'days': days,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'],
      dosage: json['dosage'],
      days: json['days'],
    );
  }

  @override
  String toString() {
    return '$name - $dosage for $days days';
  }
}
