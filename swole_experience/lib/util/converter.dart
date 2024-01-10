import 'package:logger/logger.dart';
import 'package:swole_experience/model/unit.dart';

class Converter {
  static final Logger logger = Logger();

  // Uses water for volumetric conversions
  static final Map<Unit, double> _gramMap = {
    Unit.g: 1,
    Unit.mg: 1000,
    Unit.ml: 1,
    Unit.oz: 0.03527396,
    Unit.tsp: 0.20288413535352,
    Unit.tbsp: 0.067628045117839,
    Unit.cup: 0.00423,
    Unit.custom: 0,
  };


  /// Converts DateTime to double representing the number of days past the
  /// starting interval
  /// For example a date that was 30 days ago, and the starting param is 60,
  /// the function will return 30
  ///
  /// @param DateTime date - the date to convert
  /// @param int starting - the number of days ago to start counting
  static double toDayScale(DateTime date, {int starting = 60}) {
    DateTime now = DateTime.now();
    DateTime initDate = truncateToDay(date);
    DateTime startDate = DateTime(now.year, now.month, now.day - starting);
    double dif = initDate.difference(startDate).inDays.toDouble() + 1;

    return dif;
  }

  /// Converts a full DateTime into a DateTime represented date (i.e. precision to the day)
  static DateTime truncateToDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static DateTime roundToNextDay(DateTime dateTime)  {
    return DateTime(dateTime.year, dateTime.month, dateTime.day + 1);
  }


  /// Converts @amount from @inputUnit to @outputUnit
  static double convertUnit(double amount, Unit inputUnit, Unit outputUnit) {
    if (inputUnit == Unit.custom) {
      logger.i("Cannot convert amount $amount to $outputUnit from custom unit");
    }
    double amountInG = (inputUnit != Unit.g || inputUnit != Unit.ml)
        ? amount * _gramMap[inputUnit]!
        : amount;
    return amountInG / _gramMap[outputUnit]!;
  }
}
