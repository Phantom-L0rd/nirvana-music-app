// lib/providers/audio_provider.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'audio_state.dart';

// This tells the code generator to create the provider code
part 'audio_provider.g.dart';

@riverpod
class AudioController extends _$AudioController {
  late AudioPlayer _player; // The actual audio player instance
  bool _hasCompletedTrack = false;
  List<int> _shuffledIndices = [];
  bool _hasAddedToRecents = false;

  @override
  AudioState build() {
    // This is called when the provider is first accessed
    _player = AudioPlayer();
    _setupListeners();

    // Clean up when the provider is disposed (app closes, etc.)
    ref.onDispose(() {
      _player.dispose();
    });

    // Return the initial state
    return const AudioState();
  }

  void _setupListeners() {
    // Listen to when player state changes (playing, paused, stopped, etc.)
    _player.onPlayerStateChanged.listen((PlayerState playerState) {
      state = state.copyWith(
        playerState: playerState,
        isPlaying: playerState == PlayerState.playing,
        // ✅ CORRECT: Don't set isLoading based on PlayerState
        // isLoading will be managed manually in the play methods
      );
    });

    // Listen to position changes (for progress bar updates and to add song to recently played)
    _player.onPositionChanged.listen((Duration position) async {
      state = state.copyWith(currentPosition: position);
      if (position.inSeconds < 2 && _hasCompletedTrack) {
        _hasCompletedTrack = false;
      }

      // Add to recents once 15 seconds have passed
      if (position.inSeconds >= 15 && !_hasAddedToRecents) {
        _hasAddedToRecents = true; // ensure it's only added once per song
        final currentTrack = state.currentTrack;
        if (currentTrack != null) {
          debugPrint("added to recently played");
          await ref
              .read(localFoldersProvider.notifier)
              .addToRecents(currentTrack.id);
        }
      }
    });

    // Listen to duration changes (when we know how long the track is)
    _player.onDurationChanged.listen((Duration duration) {
      state = state.copyWith(totalDuration: duration, isLoading: false);
    });

    // Listen to when track finishes playing - auto-replay or load default
    _player.onPlayerComplete.listen((_) async {
      _hasCompletedTrack = true;

      state = state.copyWith(
        isPlaying: false,
        currentPosition: state.totalDuration,
      );

      // Handle auto-advance based on repeat settings
      await _handleSongCompletion();
    });
  }

  // PLAYLIST MANAGEMENT

  // Set entire playlist
  Future<void> setPlaylist(
    List<AudioFile> songs, {
    int startIndex = 0,
    String type = 'playlist',
    String id = '',
    RouteEntry? route,
  }) async {
    state = state.copyWith(
      playlist: songs,
      currentIndex: startIndex.clamp(0, songs.length - 1),
      playlistType: type,
      playlistId: id,
      playlistRoute: route,
    );

    _generateShuffledIndices();

    if (songs.isNotEmpty) {
      await _loadAndPlayCurrentSong();
    }
  }

  // Add songs to playlist
  void addToPlaylist(List<AudioFile> songs) {
    final newPlaylist = [...state.playlist, ...songs];
    state = state.copyWith(playlist: newPlaylist);
    _generateShuffledIndices();
  }

  // Add single song
  void addSong(AudioFile song) {
    final newPlaylist = [...state.playlist, song];
    state = state.copyWith(playlist: newPlaylist);
    _generateShuffledIndices();
  }

  // Remove song from playlist
  void removeSong(int index) {
    if (index < 0 || index >= state.playlist.length) return;

    final newPlaylist = [...state.playlist];
    newPlaylist.removeAt(index);

    int newCurrentIndex = state.currentIndex;
    if (index < state.currentIndex) {
      newCurrentIndex--;
    } else if (index == state.currentIndex && newPlaylist.isNotEmpty) {
      newCurrentIndex = newCurrentIndex.clamp(0, newPlaylist.length - 1);
    }

    state = state.copyWith(
      playlist: newPlaylist,
      currentIndex: newCurrentIndex,
    );
    _generateShuffledIndices();
  }

  // Clear playlist
  void clearPlaylist() {
    state = state.copyWith(playlist: [], currentIndex: 0, currentTrack: null);
    _player.stop();
  }

  // PLAY METHODS - Different sources of audio

  // Play a local file from device storage
  Future<void> playFromPath(AudioFile track) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Tell audioplayers to play from device file
      await _player.play(DeviceFileSource(track.fullPath));

      state = state.copyWith(currentTrack: track, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Play from internet URL
  Future<void> playFromUrl(String url, {AudioFile? track}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _player.play(UrlSource(url));

      state = state.copyWith(currentTrack: track, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Play from app assets (bundled with app)
  // Future<void> playFromAsset(String assetPath, {String? title}) async {
  //   try {
  //     state = state.copyWith(isLoading: true, error: null);

  //     await _player.play(AssetSource(assetPath));

  //     state = state.copyWith(
  //       currentTrackPath: assetPath,
  //       currentTrackTitle: title ?? assetPath,
  //       isLoading: false,
  //     );
  //   } catch (e) {
  //     state = state.copyWith(error: e.toString(), isLoading: false);
  //   }
  // }

  // PLAYBACK CONTROLS

  // Play specific song by index
  Future<void> playAtIndex(int index) async {
    if (index < 0 || index >= state.playlist.length) return;

    state = state.copyWith(currentIndex: index);
    await _loadAndPlayCurrentSong();
  }

  // Play specific song
  Future<void> playSong(AudioFile song) async {
    final index = state.playlist.indexOf(song);
    if (index != -1) {
      await playAtIndex(index);
    } else {
      // Add song to playlist and play it
      addSong(song);
      await playAtIndex(state.playlist.length - 1);
    }
  }

  // Next song
  Future<void> nextSong() async {
    if (!state.hasPlaylist) return;

    int nextIndex;
    if (state.shuffle && _shuffledIndices.isNotEmpty) {
      final currentShuffleIndex = _shuffledIndices.indexOf(state.currentIndex);
      if (currentShuffleIndex < _shuffledIndices.length - 1) {
        nextIndex = _shuffledIndices[currentShuffleIndex + 1];
      } else if (state.repeat) {
        nextIndex = _shuffledIndices[0]; // Loop back to first in shuffle
      } else {
        return; // End of shuffled playlist
      }
    } else {
      if (state.hasNextSong) {
        nextIndex = state.currentIndex + 1;
      } else if (state.repeat) {
        nextIndex = 0; // Loop back to beginning
      } else {
        return; // End of playlist
      }
    }

    await playAtIndex(nextIndex);
  }

  // Previous song
  Future<void> previousSong() async {
    if (!state.hasPlaylist) return;

    // If more than 3 seconds into song, restart current song
    if (state.currentPosition.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    int prevIndex;
    if (state.shuffle && _shuffledIndices.isNotEmpty) {
      final currentShuffleIndex = _shuffledIndices.indexOf(state.currentIndex);
      if (currentShuffleIndex > 0) {
        prevIndex = _shuffledIndices[currentShuffleIndex - 1];
      } else if (state.repeat) {
        prevIndex = _shuffledIndices.last; // Loop to last in shuffle
      } else {
        return;
      }
    } else {
      if (state.hasPreviousSong) {
        prevIndex = state.currentIndex - 1;
      } else if (state.repeat) {
        prevIndex = state.playlist.length - 1; // Loop to end
      } else {
        return;
      }
    }

    await playAtIndex(prevIndex);
  }

  // CONTROL METHODS

  // Toggle between play and pause
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
      return;
    }

    // If song has completed, restart it from the beginning
    if (_hasCompletedTrack && state.currentTrack != null) {
      await _restartCurrentSong();
      return;
    }

    // If paused and we have a current track, just resume
    if (state.playerState == PlayerState.paused && state.currentTrack != null) {
      await resume();
      return;
    }

    // If no track loaded, need to load one first
    if (state.currentTrack == null) {
      // This will need to be handled by your widget
      state = state.copyWith(error: "No track loaded");
      return;
    }

    // If we have a current track path but player is stopped, replay it
    if (state.playerState == PlayerState.stopped &&
        state.currentTrack != null) {
      await playFromPath(state.currentTrack!);
      return;
    }

    // Fallback - try to resume
    await resume();
  }

  // SHUFFLE AND REPEAT

  void toggleShuffle() {
    state = state.copyWith(shuffle: !state.shuffle);
    _generateShuffledIndices();
  }

  void toggleRepeat() {
    if (!state.repeat && !state.repeatOne) {
      // No repeat -> Repeat all
      state = state.copyWith(repeat: true, repeatOne: false);
    } else if (state.repeat && !state.repeatOne) {
      // Repeat all -> Repeat one
      state = state.copyWith(repeat: false, repeatOne: true);
    } else {
      // Repeat one -> No repeat
      state = state.copyWith(repeat: false, repeatOne: false);
    }
  }

  // PRIVATE METHODS

  Future<void> _handleSongCompletion() async {
    if (state.repeatOne) {
      // Repeat current song
      await _restartCurrentSong();
    } else if (state.hasNextSong || state.repeat) {
      // Go to next song (or loop if repeat is on)
      await nextSong();
    }
    // Otherwise, just stop (end of playlist)
  }

  Future<void> _loadAndPlayCurrentSong() async {
    if (state.playlist.isEmpty || state.currentIndex >= state.playlist.length) {
      return;
    }

    final song = state.playlist[state.currentIndex];

    try {
      state = state.copyWith(isLoading: true, error: null, currentTrack: song);

      await _player.stop();
      await _player.play(DeviceFileSource(song.fullPath));

      _hasCompletedTrack = false;
      _hasAddedToRecents = false;

      state = state.copyWith(isLoading: false, currentPosition: Duration.zero);

      Future.microtask(() async {
        if (state.isShowingLyrics) {
          await ref
              .read(lyricsProvider.notifier)
              .loadLyrics(state.currentTrack!);
        }
      });
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> _restartCurrentSong() async {
    if (state.currentTrack == null) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      await _player.stop();
      await _player.play(DeviceFileSource(state.currentTrack!.fullPath));

      _hasCompletedTrack = false;

      state = state.copyWith(isLoading: false, currentPosition: Duration.zero);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void _generateShuffledIndices() {
    if (state.playlist.isEmpty) {
      _shuffledIndices = [];
      return;
    }

    _shuffledIndices = List.generate(state.playlist.length, (index) => index);
    _shuffledIndices.shuffle(Random());

    // Move current song to front if it exists
    if (state.currentIndex >= 0 &&
        state.currentIndex < _shuffledIndices.length) {
      _shuffledIndices.remove(state.currentIndex);
      _shuffledIndices.insert(0, state.currentIndex);
    }
  }

  // EXISTING METHODS (enhanced)

  // Pause playback (can be resumed from same position)
  Future<void> pause() async {
    await _player.pause();
  }

  // Resume from paused position
  Future<void> resume() async {
    await _player.resume();
  }

  // Stop playback completely (resets position to beginning)
  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(isPlaying: false, currentPosition: Duration.zero);
  }

  // Jump to specific position in track
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // Change volume level
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0); // Ensure 0-1 range
    await _player.setVolume(clampedVolume);
    state = state.copyWith(volume: clampedVolume);
  }

  // Change playback speed (0.5x = half speed, 2.0x = double speed)
  Future<void> setPlaybackSpeed(double speed) async {
    await _player.setPlaybackRate(speed);
    state = state.copyWith(playbackSpeed: speed);
  }

  // Load audio file without playing it (preload)
  Future<void> setSource(AudioFile track) async {
    try {
      await _player.setSource(DeviceFileSource(track.fullPath));
      state = state.copyWith(currentTrack: track);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<AudioFile> getShuffledList() {
    List<AudioFile> shuffledList = [];

    for (int x in _shuffledIndices) {
      shuffledList.add(state.playlist[x]);
    }

    return shuffledList;
  }

  void setLyricsOn() {
    state = state.copyWith(isShowingLyrics: true);
  }

  void setLyricsOff() {
    state = state.copyWith(isShowingLyrics: false);
  }
}

/*
EXPLANATION OF RIVERPOD GENERATOR:
- @riverpod creates a provider automatically
- build() method is like initState() - called once when provider is created
- state variable holds the current AudioState
- state = state.copyWith() updates the state and notifies all listeners
- ref.onDispose() cleans up resources when provider is destroyed
- All methods are available to any widget that uses this provider
*/
