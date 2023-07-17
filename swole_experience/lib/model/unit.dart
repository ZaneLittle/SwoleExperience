enum Unit {
  g,
  oz,
  ml,
  tsp,
  tbsp,
  cup,
}

Unit? unitFromString(String value) {
  List<Unit> res = Unit.values.where((unit) {
    return (unit.toString() == value);
  }).toList();

  if (res.isEmpty) {
    return null;
  }
  return res[0];
}
