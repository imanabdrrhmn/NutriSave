import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../services/meal_service.dart';
import '../services/favorite_service.dart';
import '../models/meal.dart';
import 'meal_detail_page.dart';

class RecipeBookPage extends StatefulWidget {
  @override
  _RecipeBookPageState createState() => _RecipeBookPageState();
}

class _RecipeBookPageState extends State<RecipeBookPage> {
  final MealService _mealService = MealService();
  final FavoriteService _favoriteService = FavoriteService();
  late Future<List<Meal>> _meals;
  Set<String> _favoriteMeals = {};

  @override
  void initState() {
    super.initState();
    _meals = _mealService.fetchMeals('');
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favoriteMeals = await _favoriteService.getFavoriteMeals();
    setState(() {
      _favoriteMeals = favoriteMeals.toSet(); // Convert List<String> to Set<String>
    });
  }

  Future<void> _toggleFavorite(String mealId) async {
    await _favoriteService.toggleFavoriteMeal(mealId);
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Buku Resep',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Meal>>(
        future: _meals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No meals found'));
          } else {
            final meals = snapshot.data!;
            return StaggeredGridView.countBuilder(
              crossAxisCount: 4,
              itemCount: meals.length,
              itemBuilder: (BuildContext context, int index) {
                final meal = meals[index];
                final isFavorite = _favoriteMeals.contains(meal.id);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealDetailPage(
                          meal: meal,
                          isFavorite: isFavorite,
                          toggleFavorite: _toggleFavorite,
                        ),
                      ),
                    );
                  },
                  child: _build3DCard(meal, isFavorite),
                );
              },
              staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
              mainAxisSpacing: 2.0,
              crossAxisSpacing: 2.0,
            );
          }
        },
      ),
    );
  }

  Widget _build3DCard(Meal meal, bool isFavorite) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(0.1)
          ..rotateY(-0.1),
        alignment: FractionalOffset.center,
        child: Card(
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Image.network(
                      meal.thumbnail,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        _toggleFavorite(meal.id);
                      },
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  meal.name,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  meal.instructions.length > 50
                      ? meal.instructions.substring(0, 50) + '...'
                      : meal.instructions,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
