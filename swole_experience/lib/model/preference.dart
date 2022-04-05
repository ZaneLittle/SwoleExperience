class Preference {
  Preference({required this.preference, this.value, this.lastUpdated});

  final String preference;
  final String? value;
  final DateTime? lastUpdated;

  Preference.fromMap(Map<String, dynamic> map)
      : preference = map['preference'] as String,
        value = map['value'] as String,
        lastUpdated = DateTime.parse(map['lastUpdated'] as String);

  Map<String, dynamic> toMap() {
    return {
      'preference': preference,
      'value': value,
      'lastUpdated': lastUpdated.toString(),
    };
  }

  @override
  String toString() {
    return 'Preference\n\tPreference:$preference\n\tValue:$value\n\tLastUpdated:$lastUpdated';
  }
}
