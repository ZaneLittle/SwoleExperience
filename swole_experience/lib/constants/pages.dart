
class Pages {
  static const String macros = 'macros';

  static const String weight = 'weight';

  static const String workout = 'workout';

  static const Map<String, int> pageMap = {
    'macros': -1, // TODO: Increment each when macros page is implemented
    'weight': 0,
    'workout': 1
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
