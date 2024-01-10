enum Unit {
  g,
  mg,
  oz,
  ml,
  tsp,
  tbsp,
  cup,
  custom,
}

// TODO: can I format this as a companion object and call as unit.parse()
/// If no matches are found, returns 'custom'
Unit parseUnit(String? value) {
  // First try basic conversion
  List<Unit> res = Unit.values.where((unit) {
    return (unit.name == value?.toLowerCase());
  }).toList();

  if (res.isEmpty) {
    // Known alternatives
    switch (value?.toLowerCase()) {
      case 'gr':
      case 'grm':
      case 'gram':
      case 'grams':
        return Unit.g;
      case 'IU':
        return Unit.tbsp;
      case 'MLT':
        return Unit.ml;

    }
    return Unit.custom;
  }
  return res[0];
}
