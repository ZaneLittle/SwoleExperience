
class Pages {
  static const String macros = 'macros';

  static const String weight = 'weight';

  static const String workout = 'workout';

  static const Map<String, int> pageMap = {
    'macros': 0,
    'weight': 1,
    'workout': 2
  };

  static String? getPage(int index) {
    for (MapEntry<String, int> page in pageMap.entries) {
      if (page.value == index) {
        return page.key;
      }
    }
    return null;
  }
}
