enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday }

extension WeekDayExtension on WeekDay {
  static WeekDay fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'MONDAY':
        return WeekDay.monday;
      case 'TUESDAY':
        return WeekDay.tuesday;
      case 'WEDNESDAY':
        return WeekDay.wednesday;
      case 'THURSDAY':
        return WeekDay.thursday;
      case 'FRIDAY':
        return WeekDay.friday;
      case 'SATURDAY':
        return WeekDay.saturday;
      default:
        throw ArgumentError('Invalid week day: $value');
    }
  }

  String get apiValue {
    switch (this) {
      case WeekDay.monday:
        return 'Monday';
      case WeekDay.tuesday:
        return 'Tuesday';
      case WeekDay.wednesday:
        return 'Wednesday';
      case WeekDay.thursday:
        return 'Thursday';
      case WeekDay.friday:
        return 'Friday';
      case WeekDay.saturday:
        return 'Saturday';
    }
  }

  String get shortName {
    switch (this) {
      case WeekDay.monday:
        return 'Mon';
      case WeekDay.tuesday:
        return 'Tue';
      case WeekDay.wednesday:
        return 'Wed';
      case WeekDay.thursday:
        return 'Thu';
      case WeekDay.friday:
        return 'Fri';
      case WeekDay.saturday:
        return 'Sat';
    }
  }

  String get fullName {
    switch (this) {
      case WeekDay.monday:
        return 'Monday';
      case WeekDay.tuesday:
        return 'Tuesday';
      case WeekDay.wednesday:
        return 'Wednesday';
      case WeekDay.thursday:
        return 'Thursday';
      case WeekDay.friday:
        return 'Friday';
      case WeekDay.saturday:
        return 'Saturday';
    }
  }

  static WeekDay get today {
    switch (DateTime.now().weekday) {
      case DateTime.monday:
        return WeekDay.monday;
      case DateTime.tuesday:
        return WeekDay.tuesday;
      case DateTime.wednesday:
        return WeekDay.wednesday;
      case DateTime.thursday:
        return WeekDay.thursday;
      case DateTime.friday:
        return WeekDay.friday;
      case DateTime.saturday:
        return WeekDay.saturday;
      default:
        // Sunday
        return WeekDay.monday;
    }
  }
}
