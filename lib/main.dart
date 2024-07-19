import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nutrisave/pages/favorite_page.dart';
import 'package:nutrisave/pages/healthy_life_page.dart';
import 'package:nutrisave/pages/recipe_book_page.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/reset_password_page.dart';
import 'pages/change_password_page.dart';
import 'pages/confirmation_page.dart';
import 'pages/verification_page.dart';
import 'pages/profile_page.dart';
import 'pages/profile_edit_page.dart';
import 'pages/settings_page.dart';
import 'pages/about_page.dart';
import 'pages/reminder_page.dart';
import 'pages/splash_screen.dart';
import 'theme.dart';
import 'my_http_overrides.dart';
import 'pages/daily_calories_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  NotificationService notificationService = NotificationService();
  tz.initializeTimeZones();
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('core/duplicate-app')) {
      print('Firebase app already initialized');
    } else {
      rethrow;
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriSave',
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/register': (context) => RegisterPage(),
        '/reset_password': (context) => ResetPasswordPage(),
        '/change_password': (context) => ChangePasswordPage(),
        '/confirmation': (context) => ConfirmationPage(),
        '/verification': (context) => VerificationPage(email: 'example@gmail.com'),
        '/profile': (context) => ProfilePage(),
        '/profile_edit': (context) => ProfileEditPage(),
        '/settings': (context) => SettingsPage(),
        '/about': (context) => AboutPage(),
        '/reminder': (context) => ReminderPage(),
        '/recipe-book': (context) => RecipeBookPage(),
        '/favorites': (context) => FavoritesPage(),
        '/videos': (context) => HealthyLifePage(),
        '/daily_calories': (context) => DailyCaloriesPage(),
      },
    );
  }
}
