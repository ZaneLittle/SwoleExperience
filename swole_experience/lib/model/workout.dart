class Workout {
  Workout({
    required this.id,
    required this.name,
    required this.weight,
    required this.sets,
    required this.reps,
    this.notes,
    this.supersetParent,
    this.supersetChild,
    this.altParent,
    this.altChild,
  });

  final String id;
  final String name;
  final double weight;
  final int sets;
  final int reps;
  final String? notes;
  final Workout? supersetParent;
  final Workout? supersetChild;
  final Workout? altParent;
  final Workout? altChild;


  Workout.fromMap(Map<String, dynamic> map)
      : id =  map['id'] as String,
        name = map['name'] as String,
        weight = map['weight'] as double,
        sets = map['sets'] as int,
        reps = map['reps'] as int,
        notes = map['notes'] as String?,
        supersetParent = map['supersetParent'] as Workout?,
        supersetChild = map['supersetChild'] as Workout?,
        altParent = map['altChild'] as Workout?,
        altChild = map['altParent'] as Workout?;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'sets': sets,
      'reps': reps,
      'notes': notes,
      'supersetParent': supersetParent,
      'supersetChild': supersetChild,
      'altParent': altParent,
      'altChild': altChild,
    };
  }

  @override
  String toString() {
    return 'Workout:'
        '\n\tID:$id'
        '\n\tName:$name'
        '\n\tWeight:$weight'
        '\n\tSets:$sets'
        '\n\tReps:$reps'
        '\n\tNotes:$notes'
        '\n\tSuperset (Parent):${supersetParent.toString()}'
        '\n\tSuperset (Child):${supersetChild.toString()}'
        '\n\tAlternative (Parent):${altParent.toString()}'
        '\n\tAlternative (Child):${altChild.toString()}';
  }

  Workout copy({
    String? id,
    String? name,
    double? weight,
    int? sets,
    int? reps,
    String? notes,
    Workout? supersetParent,
    Workout? supersetChild,
    Workout? altParent,
    Workout? altChild,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      notes: notes ?? this.notes,
      supersetParent: supersetParent ?? this.supersetParent,
      supersetChild: supersetChild ?? this.supersetChild,
      altParent: altParent ?? this.altParent,
      altChild: altChild ?? this.altChild,
    );
  }
}
