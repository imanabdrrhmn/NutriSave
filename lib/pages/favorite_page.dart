import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/meal.dart';
import '../models/video_model.dart';
import '../services/favorite_service.dart';
import '../services/meal_service.dart';
import '../services/video_service.dart';
import 'meal_detail_page.dart';
import 'video_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoriteService _favoriteService = FavoriteService();
  final MealService _mealService = MealService();
  final VideoService _videoService = VideoService();
  late Future<List<Meal>> _favoriteMeals;
  late Future<List<Video>> _favoriteVideos;

  @override
  void initState() {
    super.initState();
    _favoriteMeals = _loadFavoriteMeals();
    _favoriteVideos = _loadFavoriteVideos();
  }

  Future<List<Meal>> _loadFavoriteMeals() async {
    final favoriteMealIds = await _favoriteService.getFavoriteMeals();
    return _mealService.fetchMealsByIds(favoriteMealIds.toList());
  }

  Future<List<Video>> _loadFavoriteVideos() async {
    final favoriteVideoIds = await _favoriteService.getFavoriteVideos();
    return _videoService.fetchVideosByIds(favoriteVideoIds.toList());
  }

  Future<void> _toggleFavoriteMeal(String mealId) async {
    await _favoriteService.toggleFavoriteMeal(mealId);
    setState(() {
      _favoriteMeals = _loadFavoriteMeals();
    });
  }

  Future<void> _toggleFavoriteVideo(String videoId) async {
    await _favoriteService.toggleFavoriteVideo(videoId);
    setState(() {
      _favoriteVideos = _loadFavoriteVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            'Favorites',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Meals'),
              Tab(text: 'Videos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FutureBuilder<List<Meal>>(
              future: _favoriteMeals,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No favorite meals'));
                } else {
                  final meals = snapshot.data!;
                  return ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return ListTile(
                        leading: Image.network(meal.thumbnail, width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(
                          meal.name,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        subtitle: Text(
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
                        trailing: IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          onPressed: () => _toggleFavoriteMeal(meal.id),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MealDetailPage(
                                meal: meal,
                                isFavorite: true,
                                toggleFavorite: _toggleFavoriteMeal,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
            FutureBuilder<List<Video>>(
              future: _favoriteVideos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Fitur ini sedang dalam tahap pengembangan.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No favorite videos'));
                } else {
                  final videos = snapshot.data!;
                  return ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      return ListTile(
                        leading: Image.network(video.thumbnailUrl, width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(
                          video.title,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        subtitle: Text(
                          video.description.length > 50
                              ? video.description.substring(0, 50) + '...'
                              : video.description,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          onPressed: () => _toggleFavoriteVideo(video.id),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoDetailPage(
                                video: video,
                                isFavorite: true,
                                toggleFavorite: _toggleFavoriteVideo,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
