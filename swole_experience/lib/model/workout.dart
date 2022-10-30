class Workout {
  Workout({
    required this.id,
    required this.name,
    required this.weight,
    required this.sets,
    required this.reps,
    this.notes,
  });

  final String id;
  final String name;
  final double weight;
  final int sets;
  final int reps;
  final String? notes;

  Workout.fromMap(Map<String, dynamic> map)
      : id =  map['id'] as String,
        name = map['name'] as String,
        weight = map['weight'] as double,
        sets = map['sets'] as int,
        reps = map['reps'] as int,
        notes = map['notes'] as String?;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'sets': sets,
      'reps': reps,
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'Workout:\n\tID:$id\n\tName:$name\n\tWeight:$weight\n\tSets:$sets\n\tReps:$reps\n\tNotes:$notes';
  }

  Workout copy({
    String? id,
    String? name,
    double? weight,
    int? sets,
    int? reps,
    String? notes,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      notes: notes ?? this.notes,
    );
  }
}