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
    DateTime initDate = DateTime(date.year, date.month, date.day);
    DateTime startDate = DateTime(now.year, now.month, now.day - starting);
    double dif = initDate.difference(startDate).inDays.toDouble();

    return dif;
  }
}
