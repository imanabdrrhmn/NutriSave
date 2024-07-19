import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService() {
    // Initialize the plugin
    final InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<void> addNotification(Map<String, dynamic> notification) async {
    User? user = await getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('notifications').add(notification);
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    User? user = await getCurrentUser();
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore.collection('users').doc(user.uid).collection('notifications').get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<void> deleteNotification(String id) async {
    User? user = await getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('notifications').doc(id).delete();
    }
  }

  Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledTime) async {
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
