class Food {
  Food({
    required this.id,
    this.fdcId,
    this.barcode,
    required this.lastUpdated,
    required this.name,
    this.brand,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  final String id;
  final int? fdcId;
  final int? barcode;
  final DateTime lastUpdated;
  final String name;
  final String? brand;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  Food.fromMap(Map<String, dynamic> map)
      : id = map['id'] as String,
        fdcId = int.tryParse(map['fcdId']),
        barcode = int.tryParse(map['barcode']),
        lastUpdated = DateTime.parse(map['lastUpdated'] as String),
        name = map['name'] as String,
        brand = map['brand'] as String,
        calories = double.parse(map['calories']),
        protein = double.parse(map['protein']),
        fat = double.parse(map['fat']),
        carbs = double.parse(map['carbs']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fdcId': fdcId,
      'barcode': barcode,
      'lastUpdated': lastUpdated.toString(),
      'name': name,
      'brand': brand,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    };
  }

  @override
  String toString() {
    return 'Food:\n\tID:$id\n\tFDC (USDA) ID:$fdcId\n\tBarcode:$barcode\n\tLast Updated:$lastUpdated\n\tName:$name\n\Brand:$brand\n\tCalories:$calories\n\tProtein:$protein\n\tFat:$fat\n\carbs:$carbs';
  }
}