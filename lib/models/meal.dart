class Meal {
  final String id;
  final String name;
  final String thumbnail;
  final String instructions;

  Meal({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.instructions,
  });

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['idMeal'],
      name: map['strMeal'],
      thumbnail: map['strMealThumb'],
      instructions: map['strInstructions'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strMealThumb': thumbnail,
      'strInstructions': instructions,
    };
  }
}
