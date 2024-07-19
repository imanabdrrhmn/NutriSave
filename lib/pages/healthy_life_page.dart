import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/video_service.dart';
import '../services/favorite_service.dart';
import '../models/video_model.dart';
import 'video_detail_page.dart';

class HealthyLifePage extends StatefulWidget {
  @override
  _HealthyLifePageState createState() => _HealthyLifePageState();
}

class _HealthyLifePageState extends State<HealthyLifePage> {
  late Future<List<Video>> _videosFuture;
  final VideoService _videoService = VideoService();
  final FavoriteService _favoriteService = FavoriteService();
  Set<String> _favoriteVideos = {};

  @override
  void initState() {
    super.initState();
    _videosFuture = _videoService.fetchTrendingHealthVideos();
    _loadFavoriteVideos();
  }

  Future<void> _loadFavoriteVideos() async {
    final favoriteVideos = await _favoriteService.getFavoriteVideos();
    setState(() {
      _favoriteVideos = favoriteVideos.toSet();
    });
  }

  Future<void> _toggleFavorite(String videoId) async {
    await _favoriteService.toggleFavoriteVideo(videoId);
    _loadFavoriteVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Videos',
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
      body: FutureBuilder<List<Video>>(
        future: _videosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No videos found.'));
          } else {
            final videos = snapshot.data!;
            return ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                final isFavorite = _favoriteVideos.contains(video.id);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoDetailPage(
                          video: video,
                          isFavorite: isFavorite,
                          toggleFavorite: _toggleFavorite,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          child: Image.network(
                            video.thumbnailUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title,
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                video.description,
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
