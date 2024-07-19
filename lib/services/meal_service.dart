import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class MealService {
  final String apiUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Meal>> fetchMeals(String query) async {
    final url = Uri.parse('$apiUrl/search.php?s=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> mealList = data['meals'];
      return mealList.map((json) => Meal.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<List<Meal>> fetchMealsByIds(List<String> mealIds) async {
    final meals = <Meal>[];
    for (String id in mealIds) {
      final url = Uri.parse('$apiUrl/lookup.php?i=$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meal = Meal.fromMap(data['meals'][0]);
        meals.add(meal);
      } else {
        throw Exception('Failed to load meal');
      }
    }
    return meals;
  }
}
