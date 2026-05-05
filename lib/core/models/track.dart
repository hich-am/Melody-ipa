class Track {
  final String id;
  final String name;
  final String artistName;
  final String albumName;
  final String image;
  final String audioUrl;
  final int duration;

  const Track({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumName,
    required this.image,
    required this.audioUrl,
    required this.duration,
  });

  factory Track.fromJamendoJson(Map<String, dynamic> json) {
    return Track(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Title',
      artistName: json['artist_name']?.toString() ?? 'Unknown Artist',
      albumName: json['album_name']?.toString() ?? 'Unknown Album',
      image: json['image']?.toString() ?? '',
      audioUrl: json['audio']?.toString() ?? '',
      duration: json['duration'] is int ? json['duration'] : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
    );
  }

  factory Track.fromFirestoreMap(String mapId, Map<String, dynamic> data) {
    return Track(
      id: mapId,
      name: data['name'] ?? data['title'] ?? 'Unknown Title',
      artistName: data['artistName'] ?? data['artist'] ?? 'Unknown Artist',
      albumName: data['albumName'] ?? 'Unknown Album',
      image: data['image'] ?? data['coverUrl'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      duration: data['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'artistName': artistName,
      'albumName': albumName,
      'image': image,
      'audioUrl': audioUrl,
      'duration': duration,
    };
  }

  @override
  bool operator ==(Object other) => other is Track && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
