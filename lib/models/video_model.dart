class Video {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
  });

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id']['videoId'],
      title: map['snippet']['title'],
      description: map['snippet']['description'],
      thumbnailUrl: map['snippet']['thumbnails']['high']['url'],
      videoUrl: 'https://www.youtube.com/watch?v=${map['id']['videoId']}',
    );
  }
}
