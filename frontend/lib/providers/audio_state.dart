// lib/providers/audio_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:nirvana_desktop/models/models.dart';

// This tells the code generator to create the _$AudioState class
part 'audio_state.freezed.dart';

@freezed
class AudioState with _$AudioState {
  const factory AudioState({
    @Default(false) bool isPlaying, // Is audio currently playing?
    @Default(false) bool isLoading, // Is audio loading/buffering?
    @Default(Duration.zero)
    Duration currentPosition, // Current playback position
    @Default(Duration.zero) Duration totalDuration, // Total track duration
    @Default(1.0) double volume, // Volume level (0.0 to 1.0)
    @Default(1.0) double playbackSpeed, // Playback speed (0.5x to 2.0x)
    String? currentTrackPath, // Path/URL of current track
    String? currentTrackTitle, // Display title of current track
    AudioFile? currentTrack, // Current Track
    String? error, // Error message if something goes wrong
    @Default([]) List<AudioFile> playlist,
    String? playlistType,
    String? playlistId,
    RouteEntry? playlistRoute,
    @Default(false) bool isShowingLyrics,
    @Default(0) int currentIndex,
    @Default(false) bool shuffle,
    @Default(false) bool repeat, // false = no repeat, true = repeat all
    @Default(false) bool repeatOne, // repeat current song
    @Default(PlayerState.stopped)
    PlayerState playerState, // Current player state
  }) = _AudioState;
}

// Computed properties
extension AudioStateExtension on AudioState {
  bool get hasNextSong => currentIndex < playlist.length - 1;
  bool get hasPreviousSong => currentIndex > 0;
  bool get hasPlaylist => playlist.isNotEmpty;
}


/*
EXPLANATION OF FREEZED:
- @freezed creates an immutable class with copyWith() method
- @Default() sets default values for fields
- The part directive tells where to generate the code
- _$AudioState is the generated class that contains all the implementation
- copyWith() lets you create new instances with some fields changed
*/