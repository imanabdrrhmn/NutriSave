import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../models/daily_calories.dart';
import '../widgets/calories_chart.dart';

class DailyCaloriesPage extends StatefulWidget {
  @override
  _DailyCaloriesPageState createState() => _DailyCaloriesPageState();
}

class _DailyCaloriesPageState extends State<DailyCaloriesPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<DailyCalories>> _dailyCaloriesFuture;

  @override
  void initState() {
    super.initState();
    _fetchDailyCalories();
  }

  Future<void> _fetchDailyCalories() async {
    setState(() {
      _dailyCaloriesFuture = _firestoreService.getDailyCalories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalori Harian', style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.teal,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            )
        )),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.teal),
      ),
      body: FutureBuilder<List<DailyCalories>>(
        future: _dailyCaloriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fitur ini sedang dalam tahap pengembangan.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          List<DailyCalories> dailyCalories = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: CaloriesChart(dailyCalories: dailyCalories),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
