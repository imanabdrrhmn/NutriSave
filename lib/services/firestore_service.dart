import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_calories.dart';
import '../models/daily_plan.dart';
import '../models/reminder.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    User? user = await getCurrentUser();
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    User? user = await getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update(profileData);
    }
  }

  Future<List<DailyPlan>> getDailyPlans() async {
    User? user = await getCurrentUser();
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_plans')
          .orderBy('dateTime', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => DailyPlan.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    }
    return [];
  }

  Future<void> addDailyPlan(DailyPlan plan) async {
    User? user = await getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('daily_plans').add(plan.toMap());
    }
  }

  Future<void> updateDailyPlan(DailyPlan plan) async {
    User? user = await getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('daily_plans').doc(plan.id).update(plan.toMap());
    }
  }

  Future<void> deleteDailyPlan(String id) async {
    User? user = await getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('daily_plans').doc(id).delete();
    }
  }

  Future<void> saveDailyCalories(DailyCalories dailyCalories) async {
    User? user = await getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('daily_calories').doc(dailyCalories.id).set(dailyCalories.toMap());
    }
  }

  Future<DailyCalories?> getDailyCaloriesForDate(DateTime date) async {
    User? user = await getCurrentUser();
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_calories')
          .where('date', isEqualTo: date.toIso8601String())
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return DailyCalories.fromMap(querySnapshot.docs.first.data() as Map<String, dynamic>, querySnapshot.docs.first.id);
      }
    }
    return null;
  }

  Future<List<DailyCalories>> getDailyCalories() async {
    User? user = await getCurrentUser();
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_calories')
          .orderBy('date', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => DailyCalories.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    }
    return [];
  }

  Future<void> clearDailyPlans() async {
    User? user = await getCurrentUser();
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore.collection('users').doc(user.uid).collection('daily_plans').get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    User? user = await getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('reminders').add(reminder.toMap());
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    User? user = await getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('reminders').doc(reminder.id).update(reminder.toMap());
    }
  }

  Future<void> deleteReminder(String id) async {
    User? user = await getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('reminders').doc(id).delete();
    }
  }

  Future<List<Reminder>> getReminders() async {
    User? user = await getCurrentUser();
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore.collection('users').doc(user.uid).collection('reminders').get();
      return querySnapshot.docs.map((doc) {
        return Reminder.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    }
    return [];
  }

  Future<void> addFavoriteMeal(Map<String, dynamic> meal) async {
    User? user = await getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('favorite_meals').add(meal);
    }
  }

  Future<List<Map<String, dynamic>>> getFavoriteMeals() async {
    User? user = await getCurrentUser();
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore.collection('users').doc(user.uid).collection('favorite_meals').get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<void> addFavoriteVideo(Map<String, dynamic> video) async {
    User? user = await getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('favorite_videos').add(video);
    }
  }

  Future<List<Map<String, dynamic>>> getFavoriteVideos() async {
    User? user = await getCurrentUser();
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore.collection('users').doc(user.uid).collection('favorite_videos').get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    }
    return [];
  }

  String createDocumentId(String collectionPath) {
    return _firestore.collection(collectionPath).doc().id;
  }
}
