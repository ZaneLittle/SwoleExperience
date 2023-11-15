import 'package:flutter_test/flutter_test.dart';
import 'package:swole_experience/model/unit.dart';

import 'package:swole_experience/util/converter.dart';
void main() {
  group('Converter', ()
  {
    test('toDayScale should return the correct number of days', () {
      // Create a date 30 days ago
      DateTime date = DateTime.now().subtract(const Duration(days: 30));
      expect(Converter.toDayScale(date, starting: 60), 30);
    });

    test('truncateToDay should return a DateTime with only the date', () {
      DateTime date = DateTime.now();
      DateTime truncatedDate = Converter.truncateToDay(date);
      expect(truncatedDate.year, date.year);
      expect(truncatedDate.month, date.month);
      expect(truncatedDate.day, date.day);
      expect(truncatedDate.hour, 0);
      expect(truncatedDate.minute, 0);
      expect(truncatedDate.second, 0);
      expect(truncatedDate.millisecond, 0);
      expect(truncatedDate.microsecond, 0);
    });
  });

  test('roundToNextDay should return a DateTime representing the next day', () {
    DateTime date = DateTime.now();
    DateTime nextDay = Converter.roundToNextDay(date);
    expect(nextDay.difference(date).inDays, 1);
  });

  test('convertUnit should correctly convert from one unit to another', () {
    expect(Converter.convertUnit(1, Unit.g, Unit.oz), 0.03527396);
    expect(Converter.convertUnit(1, Unit.g, Unit.ml), 1);
    expect(Converter.convertUnit(1, Unit.g, Unit.tsp), 0.20288413535352);
    expect(Converter.convertUnit(1, Unit.g, Unit.tbsp), 0.067628045117839);
    expect(Converter.convertUnit(1, Unit.g, Unit.cup), 0.00423);
  });

}