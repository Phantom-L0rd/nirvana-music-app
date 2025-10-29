// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AudioState {
  bool get isPlaying =>
      throw _privateConstructorUsedError; // Is audio currently playing?
  bool get isLoading =>
      throw _privateConstructorUsedError; // Is audio loading/buffering?
  Duration get currentPosition =>
      throw _privateConstructorUsedError; // Current playback position
  Duration get totalDuration =>
      throw _privateConstructorUsedError; // Total track duration
  double get volume =>
      throw _privateConstructorUsedError; // Volume level (0.0 to 1.0)
  double get playbackSpeed =>
      throw _privateConstructorUsedError; // Playback speed (0.5x to 2.0x)
  String? get currentTrackPath =>
      throw _privateConstructorUsedError; // Path/URL of current track
  String? get currentTrackTitle =>
      throw _privateConstructorUsedError; // Display title of current track
  AudioFile? get currentTrack =>
      throw _privateConstructorUsedError; // Current Track
  String? get error =>
      throw _privateConstructorUsedError; // Error message if something goes wrong
  List<AudioFile> get playlist => throw _privateConstructorUsedError;
  String? get playlistType => throw _privateConstructorUsedError;
  String? get playlistId => throw _privateConstructorUsedError;
  RouteEntry? get playlistRoute => throw _privateConstructorUsedError;
  bool get isShowingLyrics => throw _privateConstructorUsedError;
  int get currentIndex => throw _privateConstructorUsedError;
  bool get shuffle => throw _privateConstructorUsedError;
  bool get repeat =>
      throw _privateConstructorUsedError; // false = no repeat, true = repeat all
  bool get repeatOne =>
      throw _privateConstructorUsedError; // repeat current song
  PlayerState get playerState => throw _privateConstructorUsedError;

  /// Create a copy of AudioState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioStateCopyWith<AudioState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioStateCopyWith<$Res> {
  factory $AudioStateCopyWith(
    AudioState value,
    $Res Function(AudioState) then,
  ) = _$AudioStateCopyWithImpl<$Res, AudioState>;
  @useResult
  $Res call({
    bool isPlaying,
    bool isLoading,
    Duration currentPosition,
    Duration totalDuration,
    double volume,
    double playbackSpeed,
    String? currentTrackPath,
    String? currentTrackTitle,
    AudioFile? currentTrack,
    String? error,
    List<AudioFile> playlist,
    String? playlistType,
    String? playlistId,
    RouteEntry? playlistRoute,
    bool isShowingLyrics,
    int currentIndex,
    bool shuffle,
    bool repeat,
    bool repeatOne,
    PlayerState playerState,
  });
}

/// @nodoc
class _$AudioStateCopyWithImpl<$Res, $Val extends AudioState>
    implements $AudioStateCopyWith<$Res> {
  _$AudioStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AudioState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlaying = null,
    Object? isLoading = null,
    Object? currentPosition = null,
    Object? totalDuration = null,
    Object? volume = null,
    Object? playbackSpeed = null,
    Object? currentTrackPath = freezed,
    Object? currentTrackTitle = freezed,
    Object? currentTrack = freezed,
    Object? error = freezed,
    Object? playlist = null,
    Object? playlistType = freezed,
    Object? playlistId = freezed,
    Object? playlistRoute = freezed,
    Object? isShowingLyrics = null,
    Object? currentIndex = null,
    Object? shuffle = null,
    Object? repeat = null,
    Object? repeatOne = null,
    Object? playerState = null,
  }) {
    return _then(
      _value.copyWith(
            isPlaying: null == isPlaying
                ? _value.isPlaying
                : isPlaying // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentPosition: null == currentPosition
                ? _value.currentPosition
                : currentPosition // ignore: cast_nullable_to_non_nullable
                      as Duration,
            totalDuration: null == totalDuration
                ? _value.totalDuration
                : totalDuration // ignore: cast_nullable_to_non_nullable
                      as Duration,
            volume: null == volume
                ? _value.volume
                : volume // ignore: cast_nullable_to_non_nullable
                      as double,
            playbackSpeed: null == playbackSpeed
                ? _value.playbackSpeed
                : playbackSpeed // ignore: cast_nullable_to_non_nullable
                      as double,
            currentTrackPath: freezed == currentTrackPath
                ? _value.currentTrackPath
                : currentTrackPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentTrackTitle: freezed == currentTrackTitle
                ? _value.currentTrackTitle
                : currentTrackTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentTrack: freezed == currentTrack
                ? _value.currentTrack
                : currentTrack // ignore: cast_nullable_to_non_nullable
                      as AudioFile?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            playlist: null == playlist
                ? _value.playlist
                : playlist // ignore: cast_nullable_to_non_nullable
                      as List<AudioFile>,
            playlistType: freezed == playlistType
                ? _value.playlistType
                : playlistType // ignore: cast_nullable_to_non_nullable
                      as String?,
            playlistId: freezed == playlistId
                ? _value.playlistId
                : playlistId // ignore: cast_nullable_to_non_nullable
                      as String?,
            playlistRoute: freezed == playlistRoute
                ? _value.playlistRoute
                : playlistRoute // ignore: cast_nullable_to_non_nullable
                      as RouteEntry?,
            isShowingLyrics: null == isShowingLyrics
                ? _value.isShowingLyrics
                : isShowingLyrics // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentIndex: null == currentIndex
                ? _value.currentIndex
                : currentIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            shuffle: null == shuffle
                ? _value.shuffle
                : shuffle // ignore: cast_nullable_to_non_nullable
                      as bool,
            repeat: null == repeat
                ? _value.repeat
                : repeat // ignore: cast_nullable_to_non_nullable
                      as bool,
            repeatOne: null == repeatOne
                ? _value.repeatOne
                : repeatOne // ignore: cast_nullable_to_non_nullable
                      as bool,
            playerState: null == playerState
                ? _value.playerState
                : playerState // ignore: cast_nullable_to_non_nullable
                      as PlayerState,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AudioStateImplCopyWith<$Res>
    implements $AudioStateCopyWith<$Res> {
  factory _$$AudioStateImplCopyWith(
    _$AudioStateImpl value,
    $Res Function(_$AudioStateImpl) then,
  ) = __$$AudioStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isPlaying,
    bool isLoading,
    Duration currentPosition,
    Duration totalDuration,
    double volume,
    double playbackSpeed,
    String? currentTrackPath,
    String? currentTrackTitle,
    AudioFile? currentTrack,
    String? error,
    List<AudioFile> playlist,
    String? playlistType,
    String? playlistId,
    RouteEntry? playlistRoute,
    bool isShowingLyrics,
    int currentIndex,
    bool shuffle,
    bool repeat,
    bool repeatOne,
    PlayerState playerState,
  });
}

/// @nodoc
class __$$AudioStateImplCopyWithImpl<$Res>
    extends _$AudioStateCopyWithImpl<$Res, _$AudioStateImpl>
    implements _$$AudioStateImplCopyWith<$Res> {
  __$$AudioStateImplCopyWithImpl(
    _$AudioStateImpl _value,
    $Res Function(_$AudioStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AudioState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlaying = null,
    Object? isLoading = null,
    Object? currentPosition = null,
    Object? totalDuration = null,
    Object? volume = null,
    Object? playbackSpeed = null,
    Object? currentTrackPath = freezed,
    Object? currentTrackTitle = freezed,
    Object? currentTrack = freezed,
    Object? error = freezed,
    Object? playlist = null,
    Object? playlistType = freezed,
    Object? playlistId = freezed,
    Object? playlistRoute = freezed,
    Object? isShowingLyrics = null,
    Object? currentIndex = null,
    Object? shuffle = null,
    Object? repeat = null,
    Object? repeatOne = null,
    Object? playerState = null,
  }) {
    return _then(
      _$AudioStateImpl(
        isPlaying: null == isPlaying
            ? _value.isPlaying
            : isPlaying // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentPosition: null == currentPosition
            ? _value.currentPosition
            : currentPosition // ignore: cast_nullable_to_non_nullable
                  as Duration,
        totalDuration: null == totalDuration
            ? _value.totalDuration
            : totalDuration // ignore: cast_nullable_to_non_nullable
                  as Duration,
        volume: null == volume
            ? _value.volume
            : volume // ignore: cast_nullable_to_non_nullable
                  as double,
        playbackSpeed: null == playbackSpeed
            ? _value.playbackSpeed
            : playbackSpeed // ignore: cast_nullable_to_non_nullable
                  as double,
        currentTrackPath: freezed == currentTrackPath
            ? _value.currentTrackPath
            : currentTrackPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentTrackTitle: freezed == currentTrackTitle
            ? _value.currentTrackTitle
            : currentTrackTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentTrack: freezed == currentTrack
            ? _value.currentTrack
            : currentTrack // ignore: cast_nullable_to_non_nullable
                  as AudioFile?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        playlist: null == playlist
            ? _value._playlist
            : playlist // ignore: cast_nullable_to_non_nullable
                  as List<AudioFile>,
        playlistType: freezed == playlistType
            ? _value.playlistType
            : playlistType // ignore: cast_nullable_to_non_nullable
                  as String?,
        playlistId: freezed == playlistId
            ? _value.playlistId
            : playlistId // ignore: cast_nullable_to_non_nullable
                  as String?,
        playlistRoute: freezed == playlistRoute
            ? _value.playlistRoute
            : playlistRoute // ignore: cast_nullable_to_non_nullable
                  as RouteEntry?,
        isShowingLyrics: null == isShowingLyrics
            ? _value.isShowingLyrics
            : isShowingLyrics // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentIndex: null == currentIndex
            ? _value.currentIndex
            : currentIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        shuffle: null == shuffle
            ? _value.shuffle
            : shuffle // ignore: cast_nullable_to_non_nullable
                  as bool,
        repeat: null == repeat
            ? _value.repeat
            : repeat // ignore: cast_nullable_to_non_nullable
                  as bool,
        repeatOne: null == repeatOne
            ? _value.repeatOne
            : repeatOne // ignore: cast_nullable_to_non_nullable
                  as bool,
        playerState: null == playerState
            ? _value.playerState
            : playerState // ignore: cast_nullable_to_non_nullable
                  as PlayerState,
      ),
    );
  }
}

/// @nodoc

class _$AudioStateImpl implements _AudioState {
  const _$AudioStateImpl({
    this.isPlaying = false,
    this.isLoading = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
    this.currentTrackPath,
    this.currentTrackTitle,
    this.currentTrack,
    this.error,
    final List<AudioFile> playlist = const [],
    this.playlistType,
    this.playlistId,
    this.playlistRoute,
    this.isShowingLyrics = false,
    this.currentIndex = 0,
    this.shuffle = false,
    this.repeat = false,
    this.repeatOne = false,
    this.playerState = PlayerState.stopped,
  }) : _playlist = playlist;

  @override
  @JsonKey()
  final bool isPlaying;
  // Is audio currently playing?
  @override
  @JsonKey()
  final bool isLoading;
  // Is audio loading/buffering?
  @override
  @JsonKey()
  final Duration currentPosition;
  // Current playback position
  @override
  @JsonKey()
  final Duration totalDuration;
  // Total track duration
  @override
  @JsonKey()
  final double volume;
  // Volume level (0.0 to 1.0)
  @override
  @JsonKey()
  final double playbackSpeed;
  // Playback speed (0.5x to 2.0x)
  @override
  final String? currentTrackPath;
  // Path/URL of current track
  @override
  final String? currentTrackTitle;
  // Display title of current track
  @override
  final AudioFile? currentTrack;
  // Current Track
  @override
  final String? error;
  // Error message if something goes wrong
  final List<AudioFile> _playlist;
  // Error message if something goes wrong
  @override
  @JsonKey()
  List<AudioFile> get playlist {
    if (_playlist is EqualUnmodifiableListView) return _playlist;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playlist);
  }

  @override
  final String? playlistType;
  @override
  final String? playlistId;
  @override
  final RouteEntry? playlistRoute;
  @override
  @JsonKey()
  final bool isShowingLyrics;
  @override
  @JsonKey()
  final int currentIndex;
  @override
  @JsonKey()
  final bool shuffle;
  @override
  @JsonKey()
  final bool repeat;
  // false = no repeat, true = repeat all
  @override
  @JsonKey()
  final bool repeatOne;
  // repeat current song
  @override
  @JsonKey()
  final PlayerState playerState;

  @override
  String toString() {
    return 'AudioState(isPlaying: $isPlaying, isLoading: $isLoading, currentPosition: $currentPosition, totalDuration: $totalDuration, volume: $volume, playbackSpeed: $playbackSpeed, currentTrackPath: $currentTrackPath, currentTrackTitle: $currentTrackTitle, currentTrack: $currentTrack, error: $error, playlist: $playlist, playlistType: $playlistType, playlistId: $playlistId, playlistRoute: $playlistRoute, isShowingLyrics: $isShowingLyrics, currentIndex: $currentIndex, shuffle: $shuffle, repeat: $repeat, repeatOne: $repeatOne, playerState: $playerState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioStateImpl &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.currentPosition, currentPosition) ||
                other.currentPosition == currentPosition) &&
            (identical(other.totalDuration, totalDuration) ||
                other.totalDuration == totalDuration) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.playbackSpeed, playbackSpeed) ||
                other.playbackSpeed == playbackSpeed) &&
            (identical(other.currentTrackPath, currentTrackPath) ||
                other.currentTrackPath == currentTrackPath) &&
            (identical(other.currentTrackTitle, currentTrackTitle) ||
                other.currentTrackTitle == currentTrackTitle) &&
            (identical(other.currentTrack, currentTrack) ||
                other.currentTrack == currentTrack) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._playlist, _playlist) &&
            (identical(other.playlistType, playlistType) ||
                other.playlistType == playlistType) &&
            (identical(other.playlistId, playlistId) ||
                other.playlistId == playlistId) &&
            (identical(other.playlistRoute, playlistRoute) ||
                other.playlistRoute == playlistRoute) &&
            (identical(other.isShowingLyrics, isShowingLyrics) ||
                other.isShowingLyrics == isShowingLyrics) &&
            (identical(other.currentIndex, currentIndex) ||
                other.currentIndex == currentIndex) &&
            (identical(other.shuffle, shuffle) || other.shuffle == shuffle) &&
            (identical(other.repeat, repeat) || other.repeat == repeat) &&
            (identical(other.repeatOne, repeatOne) ||
                other.repeatOne == repeatOne) &&
            (identical(other.playerState, playerState) ||
                other.playerState == playerState));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    isPlaying,
    isLoading,
    currentPosition,
    totalDuration,
    volume,
    playbackSpeed,
    currentTrackPath,
    currentTrackTitle,
    currentTrack,
    error,
    const DeepCollectionEquality().hash(_playlist),
    playlistType,
    playlistId,
    playlistRoute,
    isShowingLyrics,
    currentIndex,
    shuffle,
    repeat,
    repeatOne,
    playerState,
  ]);

  /// Create a copy of AudioState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioStateImplCopyWith<_$AudioStateImpl> get copyWith =>
      __$$AudioStateImplCopyWithImpl<_$AudioStateImpl>(this, _$identity);
}

abstract class _AudioState implements AudioState {
  const factory _AudioState({
    final bool isPlaying,
    final bool isLoading,
    final Duration currentPosition,
    final Duration totalDuration,
    final double volume,
    final double playbackSpeed,
    final String? currentTrackPath,
    final String? currentTrackTitle,
    final AudioFile? currentTrack,
    final String? error,
    final List<AudioFile> playlist,
    final String? playlistType,
    final String? playlistId,
    final RouteEntry? playlistRoute,
    final bool isShowingLyrics,
    final int currentIndex,
    final bool shuffle,
    final bool repeat,
    final bool repeatOne,
    final PlayerState playerState,
  }) = _$AudioStateImpl;

  @override
  bool get isPlaying; // Is audio currently playing?
  @override
  bool get isLoading; // Is audio loading/buffering?
  @override
  Duration get currentPosition; // Current playback position
  @override
  Duration get totalDuration; // Total track duration
  @override
  double get volume; // Volume level (0.0 to 1.0)
  @override
  double get playbackSpeed; // Playback speed (0.5x to 2.0x)
  @override
  String? get currentTrackPath; // Path/URL of current track
  @override
  String? get currentTrackTitle; // Display title of current track
  @override
  AudioFile? get currentTrack; // Current Track
  @override
  String? get error; // Error message if something goes wrong
  @override
  List<AudioFile> get playlist;
  @override
  String? get playlistType;
  @override
  String? get playlistId;
  @override
  RouteEntry? get playlistRoute;
  @override
  bool get isShowingLyrics;
  @override
  int get currentIndex;
  @override
  bool get shuffle;
  @override
  bool get repeat; // false = no repeat, true = repeat all
  @override
  bool get repeatOne; // repeat current song
  @override
  PlayerState get playerState;

  /// Create a copy of AudioState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioStateImplCopyWith<_$AudioStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
