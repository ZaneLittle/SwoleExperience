class DaySetting {
  DaySetting({required this.dayNumber, this.name, this.lastUpdated});

  final int dayNumber;
  final String? name;
  final DateTime? lastUpdated;

  DaySetting.fromMap(Map<String, dynamic> map)
      : dayNumber = map['dayNumber'] as int,
        name = map['name'] as String,
        lastUpdated = DateTime.tryParse(map['lastUpdated'] as String);

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'name': name,
      'lastUpdated': lastUpdated.toString(),
    };
  }

  @override
  String toString() {
    return 'DaySetting\n\tDay Number:$dayNumber\n\tName:$name\n\tLastUpdated:$lastUpdated';
  }
}
