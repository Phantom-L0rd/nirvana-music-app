import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nirvana_desktop/models/models.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:8000'; // Change for production

  static Future<dynamic> getFolders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-folders'));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Folders.fromJson(decoded);
      } else {
        throw Exception('Failed to sync folders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> addFolder(String newFolder) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add-folder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"folder": newFolder}),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> removeFolder(String folder) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/remove-folder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"folder": folder}),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> addPlaylist(String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add-playlist?name=$name'),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<ApiResponse> deletePlaylist(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete-playlist?id=$id'),
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else {
        return ApiResponse(
          success: false,
          message: "Failed with ${response.statusCode}",
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: "Network error: $e");
    }
  }

  static Future<String> addSongToPlaylist(int playlistId, String songId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add-song-to-playlist'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"playlist_id": playlistId, "song_id": songId}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['message'];
      } else {
        return 'Failed to add song to playlist: ${response.statusCode}';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  static Future<void> addToRecents(String songId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add-to-recents?id=$songId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add recent');
      }
    } catch (_) {}
  }

  static Future<bool> rescanFolders() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/rescan'));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<AudioFile>> getAllSongs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-all-songs'));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => AudioFile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to sync folders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<AudioFile>> getRecents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-recents'));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => AudioFile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get reccent rongs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Album> getAlbumOfTheDay() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-album-of-the-day'),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Album.fromJson(json);
      } else {
        throw Exception('Failed to sync test song: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Album>> getAlbumsForYou() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-albums-for-you'));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Album.fromJson(json)).toList();
      } else {
        throw Exception('Failed to sync folders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Album>> getAllAlbums() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-all-albums'));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Album.fromJson(json)).toList();
      } else {
        throw Exception('Failed to sync folders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Artist>> getArtistsForYou() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-artists-for-you'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Artist.fromJson(json)).toList();
      } else {
        throw Exception('Failed to sync folders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Artist>> getAllArtists() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-all-artists'));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Artist.fromJson(json)).toList();
      } else {
        throw Exception('Failed to sync folders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Artist> getArtist(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-artist?id=$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Artist.fromJson(json);
      } else {
        throw Exception('Failed to get artist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Album> getAlbum(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-album?id=$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Album.fromJson(json);
      } else {
        throw Exception('Failed to get album: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Playlist>> getCorePlaylists() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-core-playlists'));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Playlist.fromJson(json)).toList();
      } else {
        throw Exception('Failed to sync folders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Playlist>> getUserPlaylists() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-user-playlists'));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Playlist.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get playlists: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<AudioFile>> getAlbumSongs(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-album-songs?id=$id'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => AudioFile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to sync folders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<AudioFile>> getArtistSongs(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-artist-songs?id=$id'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => AudioFile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to sync folders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Album>> getArtistAlbums(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-artist-albums?id=$id'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Album.fromJson(json)).toList();
      } else {
        throw Exception('Failed to sync folders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<LyricsFrame> getLyrics(String path) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-lyrics?path=$path'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        return LyricsFrame.fromJson(decoded);
      } else {
        throw Exception('Failed to get lyrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<OnlineTrack>> getSearchTracks(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-yt-results?q=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);

        return decoded.map((json) => OnlineTrack.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to get yt search results: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<String> getStreamUrl(String videoId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stream/$videoId'));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        return decoded['url'];
      } else {
        throw Exception(
          'Failed to get yt search results: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Playlist> getLastPlaylist() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-last-playlist'));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Playlist.fromJson(decoded);
      } else {
        throw Exception('Failed to get last playlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<AudioFile>> getPlaylistSongs(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-playlist-songs?id=$id'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => AudioFile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get Album songs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  

}
