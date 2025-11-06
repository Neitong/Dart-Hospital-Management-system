// apps/lib/src/models/schedule.model.dart

class Schedule {
  static const int workStartHour = 8;
  
  /// Doctors finish work at 5:00 PM (17:00).
  /// The last available 1-hour slot starts at 16:00.
  static const int workEndHour = 17;

  static List<DateTime> getWorkSlotsForDay(DateTime date) {
    final slots = <DateTime>[];
    
    // Create a 'clean' date at midnight
    final day = DateTime(date.year, date.month, date.day);

    for (int hour = workStartHour; hour < workEndHour; hour++) {
      slots.add(day.add(Duration(hours: hour)));
    }
    // Returns [8:00, 9:00, 10:00, 11:00, 12:00, 13:00, 14:00, 15:00, 16:00]
    return slots;
  }

  /// Checks if a specific time is within the allowed working hours.
  static bool isDuringWorkHours(DateTime time) {
    return time.hour >= workStartHour && time.hour < workEndHour;
  }
}