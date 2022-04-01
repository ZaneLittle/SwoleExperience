class Weight {
  Weight({
    required this.id,
    required this.dateTime,
    required this.weight,
  });

  final String? id;
  final DateTime dateTime;
  final double weight;

  Weight.fromMap(Map<String, dynamic> map)
      : id =  map['id'] as String,
        dateTime = DateTime.parse(map['dateTime'] as String),
        weight = map['weight'] as double;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toString(),
      'weight': weight,
    };
  }

  @override
  String toString() {
    return 'Weight:\n\tID:$id\n\tDateTime:$dateTime\n\tWeight:$weight';
  }
}