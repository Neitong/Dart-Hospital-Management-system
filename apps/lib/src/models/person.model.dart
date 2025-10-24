// lib/domain/person.dart

// Base class demonstrating Inheritance
abstract class Person {
  final String id;
  String name;
  String contact;

  Person({required this.id, required this.name, required this.contact});

  // ADD THIS GETTER
  /// Returns the first 8 characters of the ID.
  // String get shortId => id.split('-').first;

  void display();
}