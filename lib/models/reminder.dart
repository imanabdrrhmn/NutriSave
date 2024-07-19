import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id;
  final String title;
  final DateTime time;
  final List<String> days;
  final bool isEnabled;

  Reminder({
    required this.id,
    required this.title,
    required this.time,
    required this.days,
    required this.isEnabled,
  });

  factory Reminder.fromMap(Map<String, dynamic> data, String id) {
    return Reminder(
      id: id,
      title: data['title'],
      time: (data['time'] as Timestamp).toDate(),
      days: List<String>.from(data['days']),
      isEnabled: data['isEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'time': Timestamp.fromDate(time),
      'days': days,
      'isEnabled': isEnabled,
    };
  }

  Reminder copyWith({
    String? id,
    String? title,
    DateTime? time,
    List<String>? days,
    bool? isEnabled,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      days: days ?? this.days,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
