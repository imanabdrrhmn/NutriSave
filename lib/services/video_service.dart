import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';

class VideoService {
  final String apiKey = 'AIzaSyAd5tSkkSzo1Wgt0eiSbnRc_gvxDuOB3u8';

  Future<List<Video>> fetchTrendingHealthVideos() async {
    final url = Uri.parse('https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=20&q=healthy%20food&type=video&key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> videoList = data['items'];
      return videoList.map((json) => Video.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }

  Future<List<Video>> fetchVideosByIds(List<String> videoIds) async {
    final ids = videoIds.join(',');
    final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/videos?part=snippet&id=$ids&key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> videoList = data['items'];
      return videoList.map((json) => Video.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }
}
