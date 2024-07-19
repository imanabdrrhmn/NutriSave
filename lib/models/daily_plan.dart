import 'package:cloud_firestore/cloud_firestore.dart';

class DailyPlan {
  final String id;
  final String title;
  final String calories;
  final DateTime dateTime;
  final String type;
  final String imagePath;

  DailyPlan({
    required this.id,
    required this.title,
    required this.calories,
    required this.dateTime,
    required this.type,
    required this.imagePath,
  });

  factory DailyPlan.fromMap(Map<String, dynamic> data, String documentId) {
    Timestamp timestamp = data['dateTime'];
    return DailyPlan(
      id: documentId,
      title: data['title'],
      calories: data['calories'],
      dateTime: timestamp.toDate(),
      type: data['type'],
      imagePath: data['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'calories': calories,
      'dateTime': Timestamp.fromDate(dateTime),
      'type': type,
      'imagePath': imagePath,
    };
  }
}
