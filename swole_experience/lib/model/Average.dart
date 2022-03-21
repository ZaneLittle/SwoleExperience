import '../util/Converter.dart';

class Average {
  Average({
    required this.date,
    required this.average,
    required this.threeDayAverage,
    required this.sevenDayAverage,
  });

  final DateTime date;
  final double average;
  final double threeDayAverage;
  final double sevenDayAverage;

  Average.fromMap(Map<String, dynamic> map)
      : date = DateTime.parse(map['dateTime'] as String),
        average = map['average'] as double,
        threeDayAverage = map['threeDayAverage'] as double,
        sevenDayAverage = map['sevenDayAverage'] as double;

  Map<String, dynamic> toMap() {
    return {
      'dateTime': Converter().truncateToDay(date).toString(),
      'average': average,
      'threeDayAverage': threeDayAverage,
      'sevenDayAverage': sevenDayAverage,
    };
  }

  @override
  String toString() {
    return '''Average:
        DateTime:$date
        Average:$average
        ThreeDayAverage:$threeDayAverage
        SevenDayAverage:$sevenDayAverage
      ''';
  }
}
