class Converter {

  /// Converts DateTime to double representing the number of days past the
  /// starting interval
  /// For example a date that was 30 days ago, and the starting param is 60,
  /// the function will return 30
  ///
  /// @param DateTime date - the date to convert
  /// @param int starting - the number of days ago to start counting
  double toDayScale(DateTime date, {int starting = 60}) {
    DateTime now = DateTime.now();
    DateTime initDate = truncateToDay(date);
    DateTime startDate = DateTime(now.year, now.month, now.day - starting);
    double dif = initDate.difference(startDate).inDays.toDouble() + 1;

    return dif;
  }

  /// Converts a full DateTime into a DateTime represented date (i.e. precision to the day)
  DateTime truncateToDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  DateTime roundToNextDay(DateTime dateTime)  {
    return DateTime(dateTime.year, dateTime.month, dateTime.day + 1);
  }
}
