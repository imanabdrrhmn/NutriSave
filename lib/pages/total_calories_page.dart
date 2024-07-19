import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/daily_calories.dart';
import '../models/daily_plan.dart';
import '../services/firestore_service.dart';
import '../widgets/read_only_daily_plan_item.dart'; // Import the new widget

class TotalCaloriesPage extends StatefulWidget {
  final int totalCalories;
  final int dailyCalorieNeed;
  final List<DailyPlan> dailyPlans;

  TotalCaloriesPage({
    required this.totalCalories,
    required this.dailyCalorieNeed,
    required this.dailyPlans,
  });

  @override
  _TotalCaloriesPageState createState() => _TotalCaloriesPageState();
}

class _TotalCaloriesPageState extends State<TotalCaloriesPage> {
  late int _totalCalories;
  late int _dailyCalorieNeed;
  final TextEditingController _calorieNeedController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _totalCalories = widget.totalCalories;
    _dailyCalorieNeed = widget.dailyCalorieNeed;
    _calorieNeedController.text = _dailyCalorieNeed.toString();
    _saveDailyCalories();
  }

  void _updateDailyCalorieNeed() {
    setState(() {
      _dailyCalorieNeed = int.tryParse(_calorieNeedController.text) ?? _dailyCalorieNeed;
    });
    Navigator.of(context).pop();
    _saveDailyCalories();
  }

  void _saveDailyCalories() async {
    DateTime today = DateTime.now();
    String id = "${today.year}-${today.month}-${today.day}";
    DailyCalories dailyCalories = DailyCalories(
      id: id,
      date: today,
      totalCalories: _totalCalories,
      dailyPlans: widget.dailyPlans,
    );
    await _firestoreService.saveDailyCalories(dailyCalories);
  }

  void _showEditCalorieNeedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Kebutuhan Kalori'),
          content: TextField(
            controller: _calorieNeedController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Kebutuhan Kalori Harian',
              hintText: 'Enter daily calorie need',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _updateDailyCalorieNeed,
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Kalori', style: GoogleFonts.poppins(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${DateTime.now().day}, ${_formatMonth(DateTime.now().month)}',
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 30),
            Center(
              child: Container(
                height: 250, // Increased size
                width: 250, // Increased size
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sections: _getPieChartSections(),
                        startDegreeOffset: -90,
                        sectionsSpace: 0,
                        centerSpaceRadius: 60,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_totalCalories / $_dailyCalorieNeed',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'calories',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: _showEditCalorieNeedDialog,
              child: Text(
                'Kebutuhan Kalori: $_dailyCalorieNeed',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.dailyPlans.length,
                itemBuilder: (context, index) {
                  DailyPlan plan = widget.dailyPlans[index];
                  return ReadOnlyDailyPlanItem(
                    plan: plan,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    if (_totalCalories > _dailyCalorieNeed) {
      return [
        PieChartSectionData(
          color: Colors.red,
          value: 1,
          radius: 70, // Increased radius
          title: '',
        ),
      ];
    } else {
      return [
        PieChartSectionData(
          color: Colors.teal,
          value: _totalCalories.toDouble(),
          radius: 70, // Increased radius
          title: '',
        ),
        PieChartSectionData(
          color: Colors.grey[100],
          value: (_dailyCalorieNeed - _totalCalories).toDouble(),
          radius: 70, // Increased radius
          title: '',
        ),
      ];
    }
  }

  String _formatMonth(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
