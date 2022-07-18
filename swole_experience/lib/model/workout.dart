class Workout {
  Workout({
    required this.id,
    required this.day,
    required this.dayOrder,
    required this.name,
    required this.weight,
    required this.sets,
    required this.reps,
    this.notes,
  });

  final String id;
  final int day;
  final int dayOrder;
  final String name;
  final double weight;
  final int sets;
  final int reps;
  final String? notes;

  Workout.fromMap(Map<String, dynamic> map)
      : id =  map['id'] as String,
        day = map['day'] as int,
        dayOrder = map['dayOrder'] as int,
        name = map['name'] as String,
        weight = map['weight'] as double,
        sets = map['sets'] as int,
        reps = map['reps'] as int,
        notes = map['notes'] as String;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day,
      'dayOrder': dayOrder,
      'name': name,
      'weight': weight,
      'sets': sets,
      'reps': reps,
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'Workout:\n\tID:$id\n\tDay:$day\n\tOrder:$dayOrder\n\tName:$name\n\tWeight:$weight\n\tSets:$sets\n\tReps:$reps\n\tNotes:$notes';
  }
}