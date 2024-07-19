import 'daily_plan.dart';

class DailyCalories {
  String id;
  DateTime date;
  int totalCalories;
  List<DailyPlan> dailyPlans;

  DailyCalories({
    required this.id,
    required this.date,
    required this.totalCalories,
    required this.dailyPlans,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'totalCalories': totalCalories,
      'dailyPlans': dailyPlans.map((plan) => plan.toMap()).toList(),
    };
  }

  factory DailyCalories.fromMap(Map<String, dynamic> map, String id) {
    return DailyCalories(
      id: id,
      date: DateTime.parse(map['date']),
      totalCalories: map['totalCalories'],
      dailyPlans: List<DailyPlan>.from(map['dailyPlans']?.map((x) => DailyPlan.fromMap(x, x['id']))),
    );
  }
}
