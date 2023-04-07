import 'package:swole_experience/model/workout_history.dart';

class Workout {
  Workout({
    required this.id,
    required this.name,
    required this.weight,
    required this.sets,
    required this.reps,
    this.notes,
    this.supersetParentId,
    this.altParentId,
  });

  final String id;
  final String name;
  final double weight;
  final int sets;
  final int reps;
  final String? notes;
  final String? supersetParentId;
  final String? altParentId;

  /// Restriction constants
  static const int _nameLengthLimit = 22;
  static const int _notesLengthLimit = 256;
  static const int _weightLimit = 9999;
  static const int _setsLimit = 9999;
  static const int _repsLimit = 9999;

  Workout.fromMap(Map<String, dynamic> map)
      : id = map['id'] as String,
        name = map['name'] as String,
        weight = map['weight'] as double,
        sets = map['sets'] as int,
        reps = map['reps'] as int,
        notes = map['notes'] as String?,
        supersetParentId = map['supersetParentId'] as String?,
        altParentId = map['altParentId'] as String?;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'sets': sets,
      'reps': reps,
      'notes': notes,
      'supersetParentId': supersetParentId,
      'altParentId': altParentId,
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
        '\n\tSuperset ID (Parent):${supersetParentId.toString()}'
        '\n\tAlternative ID (Parent):${altParentId.toString()}';
  }

  Workout copy({
    String? id,
    String? name,
    double? weight,
    int? sets,
    int? reps,
    String? notes,
    String? supersetParentId,
    String? altParentId,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      notes: notes ?? this.notes,
      supersetParentId: supersetParentId ?? this.supersetParentId,
      altParentId: altParentId ?? this.altParentId,
    );
  }

  bool hasNote() {
    return notes != null && notes != '';
  }

  /// Enforces model restrictions:
  ///  - name   = cannot exceed 22 characters
  ///  - notes  = cannot exceed 256 characters
  ///  - Weight = cannot exceed 9999
  ///  - reps   = cannot exceed 9999
  ///  - sets   = cannot exceed 9999
  void validate() {
    if (name.length > _nameLengthLimit) {
      throw const FormatException('Name cannot exceed $_nameLengthLimit characters.');
    }
    if (notes != null && notes!.length > _notesLengthLimit) {
      throw const FormatException('Notes cannot exceed $_notesLengthLimit characters.');
    }
    if (weight > _weightLimit) {
      throw const FormatException('Weight cannot exceed $_weightLimit.');
    }
    if (reps > _repsLimit) {
      throw const FormatException('Reps cannot exceed $_repsLimit.');
    }
    if (sets > _setsLimit) {
      throw const FormatException('Sets cannot exceed $_setsLimit.');
    }
  }

  /// Returns a subset of @param workoutList that are alternatives for `this`
  List<Workout> getAlternatives(List<Workout> workoutList) {
    String id =
        this is WorkoutHistory ? (this as WorkoutHistory).workoutId : this.id;
    List<Workout> alternatives =
        workoutList.where((w) => w.altParentId == id).toList();
    return alternatives;
  }

  /// Returns a subset of @param workoutList that are supersets of `this`
  List<Workout> getSupersets(List<Workout> workoutList) {
    String id =
        this is WorkoutHistory ? (this as WorkoutHistory).workoutId : this.id;
    List<Workout> supersets =
        workoutList.where((w) => w.supersetParentId == id).toList();
    return supersets;
  }
}
