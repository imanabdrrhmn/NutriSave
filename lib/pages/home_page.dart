import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/daily_plan.dart';
import '../models/daily_calories.dart';
import '../widgets/daily_plan_dialog.dart';
import '../widgets/daily_plan_item.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'daily_plan_list_page.dart';
import 'recipe_book_page.dart';
import 'healthy_life_page.dart';
import 'favorite_page.dart';
import 'profile_edit_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  User? _user;
  String _username = '';
  String _profileImageUrl = 'assets/images/profile.png';
  List<DailyPlan> _dailyPlans = [];
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchDailyPlans();
    _checkAndResetDailyPlans();
  }

  Future<void> _fetchUserData() async {
    User? user = await _authService.getCurrentUser();
    if (user != null) {
      Map<String, dynamic>? userData = await _firestoreService.getUserData();
      if (userData != null) {
        setState(() {
          _username = userData['name'] ?? 'Guest';
          if (userData['profileImageUrl'] != null) {
            _profileImageUrl = userData['profileImageUrl'];
          }
        });
      }
    }
  }

  Future<void> _fetchDailyPlans() async {
    List<DailyPlan> plans = await _firestoreService.getDailyPlans();
    setState(() {
      _dailyPlans = plans;
    });
  }

  Future<void> _addOrEditDailyPlan({DailyPlan? plan}) async {
    final newPlan = await showDialog<DailyPlan>(
      context: context,
      builder: (BuildContext context) {
        return DailyPlanDialog(
          plan: plan,
          onSave: (newPlan) async {
            if (plan == null) {
              await _firestoreService.addDailyPlan(newPlan);
            } else {
              await _firestoreService.updateDailyPlan(newPlan);
            }
            _fetchDailyPlans(); // Refresh the list
          },
          onDelete: (planId) async {
            await _firestoreService.deleteDailyPlan(planId);
            _fetchDailyPlans(); // Refresh the list
          },
        );
      },
    );

    if (newPlan != null) {
      _fetchDailyPlans();
    }
  }

  Future<void> _checkAndResetDailyPlans() async {
    DateTime now = DateTime.now();
    if (_currentDate.day != now.day) {
      int totalCalories = _dailyPlans.fold(0, (sum, plan) => sum + int.parse(plan.calories));

      // Save current daily plans to history
      DailyCalories dailyCalories = DailyCalories(
        id: '', // Generate a new ID if needed
        date: _currentDate,
        totalCalories: totalCalories,
        dailyPlans: _dailyPlans,
      );

      await _firestoreService.saveDailyCalories(dailyCalories);

      // Clear current daily plans
      await _firestoreService.clearDailyPlans();

      // Update current date
      setState(() {
        _currentDate = now;
        _dailyPlans = [];
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute<dynamic>);
  }

  @override
  void dispose() {
    RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _fetchUserData();
    _fetchDailyPlans();
    _checkAndResetDailyPlans();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _fetchUserData();
        _fetchDailyPlans();
        _checkAndResetDailyPlans();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: 200,
                  color: Colors.teal,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileEditPage()),
                            ).then((value) {
                              if (value == true) {
                                _fetchUserData();
                              }
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: _profileImageUrl.startsWith('assets/')
                                    ? AssetImage(_profileImageUrl)
                                    : NetworkImage(_profileImageUrl) as ImageProvider,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, $_username 👋',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Selamat datang kembali!',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Pencarian',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _build3DCategoryCard(
                          title: 'Buku Resep',
                          iconPath: 'assets/icons/resep.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RecipeBookPage()),
                            );
                          },
                        ),
                        _build3DCategoryCard(
                          title: 'Hidup Sehat',
                          iconPath: 'assets/icons/hidup sehat.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HealthyLifePage()),
                            );
                          },
                        ),
                        _build3DCategoryCard(
                          title: 'Favorite',
                          iconPath: 'assets/icons/favorite.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FavoritesPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rencana Harian',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DailyPlanListPage()),
                            );
                          },
                          child: Text('Lihat Semua'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    for (var plan in _dailyPlans)
                      DailyPlanItem(
                        plan: plan,
                        onTap: () => _addOrEditDailyPlan(plan: plan),
                        onDelete: () => _deleteDailyPlan(plan.id),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addOrEditDailyPlan(),
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.teal,
          shape: CircleBorder(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: CustomBottomNavigationBar(),
      ),
    );
  }

  void _deleteDailyPlan(String planId) async {
    await _firestoreService.deleteDailyPlan(planId);
    _fetchDailyPlans();
  }

  Widget _build3DCategoryCard({required String title, required String iconPath, required VoidCallback onTap}) {
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
            width: MediaQuery.of(context).size.width / 3.5,
            height: MediaQuery.of(context).size.width / 3.5,
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

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 60);
    var secondEndPoint = Offset(size.width, size.height - 30);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
