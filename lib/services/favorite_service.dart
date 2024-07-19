import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<List<String>> getFavoriteMeals() async {
    User? user = await getCurrentUser();
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorite_meals')
          .get();
      return querySnapshot.docs.map((doc) => doc.id).toList();
    }
    return [];
  }

  Future<void> toggleFavoriteMeal(String mealId) async {
    User? user = await getCurrentUser();
    if (user != null) {
      DocumentReference mealRef = _firestore.collection('users').doc(user.uid).collection('favorite_meals').doc(mealId);
      DocumentSnapshot docSnapshot = await mealRef.get();
      if (docSnapshot.exists) {
        await mealRef.delete();
      } else {
        await mealRef.set(<String, dynamic>{});
      }
    }
  }

  Future<List<String>> getFavoriteVideos() async {
    User? user = await getCurrentUser();
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorite_videos')
          .get();
      return querySnapshot.docs.map((doc) => doc.id).toList();
    }
    return [];
  }

  Future<void> toggleFavoriteVideo(String videoId) async {
    User? user = await getCurrentUser();
    if (user != null) {
      DocumentReference videoRef = _firestore.collection('users').doc(user.uid).collection('favorite_videos').doc(videoId);
      DocumentSnapshot docSnapshot = await videoRef.get();
      if (docSnapshot.exists) {
        await videoRef.delete();
      } else {
        await videoRef.set(<String, dynamic>{});
      }
    }
  }
}
