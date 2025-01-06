class DayCreatorService {
  static const monthsWith31Days = [1, 3, 5, 7, 8, 10, 12];

  static const monthsWith30Days = [4, 6, 9, 11];

  static int getDays(int month, int year) {
    if (monthsWith31Days.contains(month)) {
      return 31;
    }
    if (monthsWith30Days.contains(month)) {
      return 30;
    }
    return year % 4 == 0 ? 29 : 28;
  }

  static Iterable<int> daysArray(int days, int month, int year) sync* {
    if (days < 1) {
      throw 'daysArray: days given < 1';
    }
    final daysInMonth = getDays(month, year);
    for (var dix = 1; dix <= daysInMonth; dix++) {
      yield dix;
    }
  }
}
