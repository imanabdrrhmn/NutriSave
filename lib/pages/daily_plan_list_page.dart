import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/daily_plan.dart';
import '../services/firestore_service.dart';
import '../widgets/daily_plan_item.dart';
import '../widgets/daily_plan_dialog.dart';
import 'total_calories_page.dart';
import 'daily_calories_page.dart'; // Import DailyCaloriesPage

class DailyPlanListPage extends StatefulWidget {
  @override
  _DailyPlanListPageState createState() => _DailyPlanListPageState();
}

class _DailyPlanListPageState extends State<DailyPlanListPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<DailyPlan>> _dailyPlansFuture;
  int _dailyCalorieNeed = 2500; // Default daily calorie need

  @override
  void initState() {
    super.initState();
    _fetchDailyPlans();
  }

  Future<void> _fetchDailyPlans() async {
    setState(() {
      _dailyPlansFuture = _firestoreService.getDailyPlans();
    });
  }

  void _addOrEditDailyPlan({DailyPlan? plan}) async {
    DailyPlan? result = await showDialog<DailyPlan>(
      context: context,
      builder: (context) => DailyPlanDialog(
        plan: plan,
        onSave: (newPlan) async {
          if (plan == null) {
            await _firestoreService.addDailyPlan(newPlan);
            _showToast('Successfully added!');
          } else {
            await _firestoreService.updateDailyPlan(newPlan);
            _showToast('Successfully updated!');
          }
          _fetchDailyPlans();
        },
        onDelete: (id) async {
          await _firestoreService.deleteDailyPlan(id);
          _showToast('Successfully deleted!');
          _fetchDailyPlans();
        },
      ),
    );

    if (result != null) {
      _fetchDailyPlans();
    }
  }

  void _deleteDailyPlan(String id) async {
    await _firestoreService.deleteDailyPlan(id);
    _fetchDailyPlans();
    _showToast('Successfully deleted!');
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  int _calculateTotalCalories(List<DailyPlan> plans) {
    return plans.fold(0, (sum, plan) => sum + int.parse(plan.calories));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Daily Plans',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _3dCategoryCard(
                title: 'Hitung kalori',
                iconPath: 'assets/icons/calories-calculator.png',
                onTap: () async {
                  List<DailyPlan> dailyPlans = await _dailyPlansFuture;
                  int totalCalories = _calculateTotalCalories(dailyPlans);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TotalCaloriesPage(
                        totalCalories: totalCalories,
                        dailyCalorieNeed: _dailyCalorieNeed,
                        dailyPlans: dailyPlans, // Pass the daily plans
                      ),
                    ),
                  );
                },
              ),
              _3dCategoryCard(
                title: 'Kalori Harian',
                iconPath: 'assets/icons/calories.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DailyCaloriesPage()),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<DailyPlan>>(
              future: _dailyPlansFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading plans'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No plans available'));
                }

                List<DailyPlan> dailyPlans = snapshot.data!;
                return ListView.builder(
                  itemCount: dailyPlans.length,
                  itemBuilder: (context, index) {
                    DailyPlan plan = dailyPlans[index];
                    return Dismissible(
                      key: Key(plan.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _deleteDailyPlan(plan.id);
                      },
                      background: Container(
                        color: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerEnd,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: DailyPlanItem(
                        plan: plan,
                        onTap: () => _addOrEditDailyPlan(plan: plan),
                        onDelete: () => _deleteDailyPlan(plan.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditDailyPlan(),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.teal,
        shape: CircleBorder(),
      ),
    );
  }

  Widget _3dCategoryCard({required String title, required String iconPath, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(0.1)
          ..rotateY(-0.1),
        alignment: FractionalOffset.center,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width / 2.3,
            height: MediaQuery.of(context).size.width / 4.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.teal.withOpacity(0.1),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    iconPath,
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
