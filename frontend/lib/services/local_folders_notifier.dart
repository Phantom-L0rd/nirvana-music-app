// local_folders_notifier.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/pages/custom_cards.dart';
import 'package:nirvana_desktop/services/api_service.dart';

class LocalFoldersNotifier extends ChangeNotifier {
  List<String> _localFolders = [];
  String _syncMessage = '';
  List<AudioFile> _allSongs = [];
  Album _albumOfTheDay = Album(
    id: "",
    name: "No Album",
    artist: Artist(id: "", name: "None"),
  );

  bool _isSyncing = true;
  // AudioFile _testSong = AudioFile(
  //   id: "idk",
  //   fullPath: "something",
  //   duration: 3300000,
  //   artist: Artist(id: "idk3", name: "Opeth"),
  //   title: "Harvest",
  //   album: Album(id: "idk2", name: "Blackwater Park", artistId: "idk3"),
  // );

  List<Album> _albumsForYou = [];
  List<Album> _allAlbums = [];
  List<Artist> _artistsForYou = [];
  List<Artist> _allArtists = [];
  List<Playlist> _corePlaylists = [];
  List<Playlist> _userPlaylists = [];

  List<String> get localFolders => _localFolders;
  List<AudioFile> get allSongs => _allSongs;
  String get syncMessage => _syncMessage;
  bool get isSyncing => _isSyncing;
  // AudioFile get testSong => _testSong;

  Album get albumOfTheDay => _albumOfTheDay;
  List<Album> get albumsForYou => _albumsForYou;
  List<Artist> get artistsForYou => _artistsForYou;
  List<Album> get allAlbums => _allAlbums;
  List<Artist> get allArtists => _allArtists;
  List<Playlist> get corePlaylists => _corePlaylists;
  List<Playlist> get userPlaylists => _userPlaylists;

  LocalFoldersNotifier() {
    fetchFolders();
    fetchAllSongs();
    getAlbumOfTheDay();
    getalbumsForYou();
    getartistsForYou();
    getArtists();
    getAlbums();
    getCorePlaylists();
    getUserPlaylists();
  }

  Future<void> completeSync() async {
    try {
      _isSyncing = false;
    } catch (_) {
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> addFolder(String folderPath) async {
    if (!_localFolders.contains(folderPath)) {
      _isSyncing = true;
      notifyListeners();

      try {
        final success = await ApiService.addFolder(folderPath);
        if (success) {
          _localFolders.add(folderPath);
          notifyListeners();
          fetchAllSongs();
          getAlbumOfTheDay();
          getalbumsForYou();
          getartistsForYou();
          getArtists();
          getAlbums();
          getCorePlaylists();
          getUserPlaylists();
        }
        return success;
      } catch (_) {
        return false;
      } finally {
        _isSyncing = false;
        notifyListeners();
      }
    }
    return false;
  }

  Future<bool> removeFolder(String folderPath) async {
    _isSyncing = true;
    notifyListeners();

    try {
      final success = await ApiService.removeFolder(folderPath);
      if (success) {
        _localFolders.remove(folderPath);
        notifyListeners();
        fetchAllSongs();
        getAlbumOfTheDay();
        getalbumsForYou();
        getartistsForYou();
        getArtists();
        getAlbums();
        getCorePlaylists();
        getUserPlaylists();
      }
      return success;
    } catch (_) {
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> fetchFolders() async {
    _isSyncing = true;
    notifyListeners();
    try {
      final folders = await ApiService.getFolders();
      _localFolders = folders.localFolders;
    } catch (_) {
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> rescanFolders() async {
    _isSyncing = true;
    notifyListeners();
    try {
      final success = await ApiService.rescanFolders();
      if (success) {
        fetchFolders();
        fetchAllSongs();
        getAlbumOfTheDay();
        getalbumsForYou();
        getartistsForYou();
        getArtists();
        getAlbums();
        getCorePlaylists();
        getUserPlaylists();
      }
      return success;
    } catch (_) {
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllSongs() async {
    _isSyncing = true;
    notifyListeners();
    try {
      final response = await ApiService.getAllSongs();
      // sleep(Duration(seconds: 5));
      _allSongs = response;
      // if (_allSongs.isNotEmpty) _testSong = _allSongs[747];
    } catch (_) {
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> getAlbumOfTheDay() async {
    _isSyncing = true;
    notifyListeners();
    try {
      final response = await ApiService.getAlbumOfTheDay();
      _albumOfTheDay = response;
    } catch (_) {
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> getalbumsForYou() async {
    _isSyncing = true;
    notifyListeners();
    try {
      final response = await ApiService.getAlbumsForYou();
      _albumsForYou = response;
    } catch (_) {
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> getAlbums() async {
    _isSyncing = true;
    notifyListeners();
    try {
      final response = await ApiService.getAllAlbums();
      _allAlbums = response;
    } catch (_) {
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> getartistsForYou() async {
    _isSyncing = true;
    notifyListeners();
    try {
      final response = await ApiService.getArtistsForYou();
      _syncMessage = 'Sync completed';
      _artistsForYou = response;
    } catch (_) {
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> getArtists() async {
    _isSyncing = true;
    notifyListeners();
    try {
      final response = await ApiService.getAllArtists();
      _allArtists = response;
    } catch (_) {
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> getCorePlaylists() async {
    _isSyncing = true;
    notifyListeners();
    try {
      final response = await ApiService.getCorePlaylists();
      _corePlaylists = response;
    } catch (_) {
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> getUserPlaylists() async {
    _isSyncing = true;
    notifyListeners();
    try {
      final response = await ApiService.getUserPlaylists();
      _userPlaylists = response;
    } catch (_) {
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<Playlist?> fetchLastPlaylist() async {
    try {
      final response = await ApiService.getLastPlaylist();
      return response;
    } catch (_) {
      return null;
    }
  }

  Future<List<AudioFile>> getPlaylistTracks(int id) async {
    if (id == 1) {
      return _allSongs;
    } else {
      try {
        final response = await ApiService.getPlaylistSongs(id);
        return response;
      } catch (_) {
        return [];
      }
    }
  }

  Future<List<AudioFile>> fetchAlbumSongs(String id) async {
    try {
      final response = await ApiService.getAlbumSongs(id);
      return response;
    } catch (_) {
      return [];
    }
  }

  Future<List<AudioFile>> fetchArtistSongs(String id) async {
    try {
      final response = await ApiService.getArtistSongs(id);
      return response;
    } catch (_) {
      return [];
    }
  }

  Future<List<Album>> fetchArtistAlbums(String id) async {
    try {
      final response = await ApiService.getArtistAlbums(id);
      return response;
    } catch (_) {
      return [];
    }
  }

  Future<Album> fetchAlbum(String id) async {
    try {
      final response = await ApiService.getAlbum(id);
      return response;
    } catch (_) {
      return Album(
        artist: Artist(id: "", name: "Not found"),
        id: '',
        name: 'No found',
      );
    }
  }

  // Future<Artist> fetchArtist(String id) async {
  //   try {
  //     final response = await ApiService.getArtist(id);
  //     return response;
  //   } catch (_) {
  //     return Artist(id: "", name: "");
  //   }
  // }

  Future<LyricsFrame> fetchLyrics(String path) async {
    try {
      final response = await ApiService.getLyrics(path);
      return response;
    } catch (_) {
      return LyricsFrame(hasTimestamps: false, lyrics: []);
    }
  }

  Future<List<OnlineTrack>> fetchYtSearchTracks(String query) async {
    try {
      final response = await ApiService.getSearchTracks(query);
      return response;
    } catch (_) {
      return [];
    }
  }

  Future<String> addSongToPlaylist(int playlistId, String songId) async {
    try {
      final response = await ApiService.addSongToPlaylist(playlistId, songId);
      return response;
    } catch (_) {
      return "something went wrong";
    }
  }
}
