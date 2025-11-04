class ApiResponse {
  final bool success;
  final String message;

  ApiResponse({required this.success, required this.message});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

enum SongType { local, online }

class AudioFile {
  final String id;
  final String fullPath;
  final int duration; // in milliseconds
  final String title;
  final Album album;
  final int? trackNum;
  final String? dateAdded; // ISO 8601 string
  final List<int> playlistIds;
  final SongType type;

  AudioFile({
    required this.id,
    required this.fullPath,
    required this.duration,
    required this.title,
    required this.album,
    this.trackNum,
    this.dateAdded,
    required this.playlistIds,
    this.type = SongType.local,
  });

  factory AudioFile.fromJson(Map<String, dynamic> json) {
    return AudioFile(
      id: json['id'],
      fullPath: json['full_path'],
      duration: json['duration'],
      title: json['title'],
      album: Album.fromJson(json['album']),
      trackNum: json['trackNum'],
      dateAdded: json['date_added'],
      playlistIds: List<int>.from(json['playlist_ids'] ?? []),
      type: json['is_local'] ? SongType.local : SongType.online,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_path': fullPath,
      'duration': duration,
      'title': title,
      'album': album.toJson(),
      'trackNum': trackNum,
      'date_added': dateAdded,
      'playlist_ids': playlistIds,
      'is_local': type == SongType.local,
    };
  }
}

class Album {
  final String id;
  final String name;
  final Artist artist;
  final String? coverArt;
  final int? year;
  final String? genre;

  Album({
    required this.id,
    required this.name,
    required this.artist,
    this.coverArt,
    this.year,
    this.genre,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      name: json['name'],
      artist: Artist.fromJson(json['artist']),
      coverArt: json['cover_art'],
      year: json['year'],
      genre: json['genre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artist': artist.toJson(),
      'cover_art': coverArt,
      'year': year,
      'genre': genre,
    };
  }
}

class Artist {
  final String id;
  final String name;
  final String? artwork; // nullable

  Artist({required this.id, required this.name, this.artwork});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(id: json['id'], name: json['name'], artwork: json['artwork']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'artwork': artwork};
  }
}

enum PlaylistType { system, user }

class Playlist {
  final int id;
  final String name;
  final PlaylistType type;
  final String createdAt;
  final List<String> artwork; // nullable list of strings

  Playlist({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.artwork,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      type: json['is_system'] ? PlaylistType.system : PlaylistType.user,
      createdAt: json['created_at'],
      artwork: List<String>.from(json['artwork'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_system': type == PlaylistType.system,
      'created_at': createdAt,
      'artwork': artwork,
    };
  }
}

class Folders {
  final List<String> localFolders;

  Folders({required this.localFolders});

  factory Folders.fromJson(Map<String, dynamic> json) {
    return Folders(
      localFolders: List<String>.from(json['local_folders'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'local_folders': localFolders};
  }
}

class LyricsFrame {
  final bool hasTimestamps;
  final List<dynamic> lyrics;

  LyricsFrame({required this.hasTimestamps, required this.lyrics});

  factory LyricsFrame.fromJson(Map<String, dynamic> json) {
    return LyricsFrame(
      hasTimestamps: json['has_timestamps'],
      lyrics: List<dynamic>.from(json['lyrics'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'has_timestamps': hasTimestamps, 'lyrics': lyrics};
  }
}

class LyricLine {
  final int timestamp;
  final String line;

  LyricLine({required this.timestamp, required this.line});

  factory LyricLine.fromJson(Map<String, dynamic> json) {
    return LyricLine(timestamp: json['timestamp'], line: json['line']);
  }

  Map<String, dynamic> toJson() {
    return {'timestamp': timestamp, 'line': line};
  }
}

class OnlineTrack {
  final String id;
  final String? lyricId;
  final AudioFile track;

  OnlineTrack({required this.id, required this.track, this.lyricId});

  factory OnlineTrack.fromJson(Map<String, dynamic> json) {
    return OnlineTrack(
      id: json['id'],
      track: AudioFile.fromJson(json['track_info']),
      lyricId: json['lyric_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'lyric_id': lyricId, 'track_info': track.toJson()};
  }
}

String formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = d.inHours;
  final minutes = twoDigits(d.inMinutes.remainder(60));
  final seconds = twoDigits(d.inSeconds.remainder(60));
  if (hours == 0) {
    return '$minutes:$seconds';
  }
  return '$hours:$minutes:$seconds';
}

class RouteEntry {
  final String path;
  final Object? extra;
  RouteEntry(this.path, {this.extra});
}
