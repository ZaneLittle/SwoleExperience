class Food {
  Food({
    required this.id,
    this.fdcId,
    required this.lastUpdated,
    required this.name,
    this.brand,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
  });

  final String id;
  final int? fdcId;
  final DateTime lastUpdated;
  final String name;
  final String? brand;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;

  Food.fromMap(Map<String, dynamic> map)
      : id = map['id'] as String,
        fdcId = int.tryParse(map['fcdId']),
        lastUpdated = DateTime.parse(map['lastUpdated'] as String),
        name = map['name'] as String,
        brand = map['brand'] as String,
        calories = double.parse(map['calories']),
        protein = double.parse(map['protein']),
        fat = double.parse(map['fat']),
        carbohydrates = double.parse(map['carbohydrates'])


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fdcId': fdcId,
      'lastUpdated': lastUpdated.toString(),
      'name': name,
      'brand': brand,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbohydrates': carbohydrates,
    };
  }

  @override
  String toString() {
    return 'Food:\n\tID:$id\n\tFDC (USDA) ID:$fdcId\n\tLast Updated:$lastUpdated\n\tName:$name\n\Brand:$brand\n\tCalories:$calories\n\tProtein:$protein\n\tFat:$fat\n\tcarbohydrates:$carbohydrates';
  }
}