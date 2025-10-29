// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SearchResultsFrame {
  String get query => throw _privateConstructorUsedError;
  List<AudioFile> get tracks => throw _privateConstructorUsedError;
  List<Album> get albums => throw _privateConstructorUsedError;
  List<Artist> get artists => throw _privateConstructorUsedError;
  List<OnlineTrack> get onlineTracks => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isOnlineLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of SearchResultsFrame
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchResultsFrameCopyWith<SearchResultsFrame> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResultsFrameCopyWith<$Res> {
  factory $SearchResultsFrameCopyWith(
    SearchResultsFrame value,
    $Res Function(SearchResultsFrame) then,
  ) = _$SearchResultsFrameCopyWithImpl<$Res, SearchResultsFrame>;
  @useResult
  $Res call({
    String query,
    List<AudioFile> tracks,
    List<Album> albums,
    List<Artist> artists,
    List<OnlineTrack> onlineTracks,
    bool isLoading,
    bool isOnlineLoading,
    String? error,
  });
}

/// @nodoc
class _$SearchResultsFrameCopyWithImpl<$Res, $Val extends SearchResultsFrame>
    implements $SearchResultsFrameCopyWith<$Res> {
  _$SearchResultsFrameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchResultsFrame
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? tracks = null,
    Object? albums = null,
    Object? artists = null,
    Object? onlineTracks = null,
    Object? isLoading = null,
    Object? isOnlineLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            query: null == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String,
            tracks: null == tracks
                ? _value.tracks
                : tracks // ignore: cast_nullable_to_non_nullable
                      as List<AudioFile>,
            albums: null == albums
                ? _value.albums
                : albums // ignore: cast_nullable_to_non_nullable
                      as List<Album>,
            artists: null == artists
                ? _value.artists
                : artists // ignore: cast_nullable_to_non_nullable
                      as List<Artist>,
            onlineTracks: null == onlineTracks
                ? _value.onlineTracks
                : onlineTracks // ignore: cast_nullable_to_non_nullable
                      as List<OnlineTrack>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isOnlineLoading: null == isOnlineLoading
                ? _value.isOnlineLoading
                : isOnlineLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchResultsFrameImplCopyWith<$Res>
    implements $SearchResultsFrameCopyWith<$Res> {
  factory _$$SearchResultsFrameImplCopyWith(
    _$SearchResultsFrameImpl value,
    $Res Function(_$SearchResultsFrameImpl) then,
  ) = __$$SearchResultsFrameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String query,
    List<AudioFile> tracks,
    List<Album> albums,
    List<Artist> artists,
    List<OnlineTrack> onlineTracks,
    bool isLoading,
    bool isOnlineLoading,
    String? error,
  });
}

/// @nodoc
class __$$SearchResultsFrameImplCopyWithImpl<$Res>
    extends _$SearchResultsFrameCopyWithImpl<$Res, _$SearchResultsFrameImpl>
    implements _$$SearchResultsFrameImplCopyWith<$Res> {
  __$$SearchResultsFrameImplCopyWithImpl(
    _$SearchResultsFrameImpl _value,
    $Res Function(_$SearchResultsFrameImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchResultsFrame
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? tracks = null,
    Object? albums = null,
    Object? artists = null,
    Object? onlineTracks = null,
    Object? isLoading = null,
    Object? isOnlineLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _$SearchResultsFrameImpl(
        query: null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String,
        tracks: null == tracks
            ? _value._tracks
            : tracks // ignore: cast_nullable_to_non_nullable
                  as List<AudioFile>,
        albums: null == albums
            ? _value._albums
            : albums // ignore: cast_nullable_to_non_nullable
                  as List<Album>,
        artists: null == artists
            ? _value._artists
            : artists // ignore: cast_nullable_to_non_nullable
                  as List<Artist>,
        onlineTracks: null == onlineTracks
            ? _value._onlineTracks
            : onlineTracks // ignore: cast_nullable_to_non_nullable
                  as List<OnlineTrack>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isOnlineLoading: null == isOnlineLoading
            ? _value.isOnlineLoading
            : isOnlineLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SearchResultsFrameImpl implements _SearchResultsFrame {
  const _$SearchResultsFrameImpl({
    this.query = '',
    final List<AudioFile> tracks = const [],
    final List<Album> albums = const [],
    final List<Artist> artists = const [],
    final List<OnlineTrack> onlineTracks = const [],
    this.isLoading = false,
    this.isOnlineLoading = false,
    this.error,
  }) : _tracks = tracks,
       _albums = albums,
       _artists = artists,
       _onlineTracks = onlineTracks;

  @override
  @JsonKey()
  final String query;
  final List<AudioFile> _tracks;
  @override
  @JsonKey()
  List<AudioFile> get tracks {
    if (_tracks is EqualUnmodifiableListView) return _tracks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tracks);
  }

  final List<Album> _albums;
  @override
  @JsonKey()
  List<Album> get albums {
    if (_albums is EqualUnmodifiableListView) return _albums;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_albums);
  }

  final List<Artist> _artists;
  @override
  @JsonKey()
  List<Artist> get artists {
    if (_artists is EqualUnmodifiableListView) return _artists;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_artists);
  }

  final List<OnlineTrack> _onlineTracks;
  @override
  @JsonKey()
  List<OnlineTrack> get onlineTracks {
    if (_onlineTracks is EqualUnmodifiableListView) return _onlineTracks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_onlineTracks);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isOnlineLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'SearchResultsFrame(query: $query, tracks: $tracks, albums: $albums, artists: $artists, onlineTracks: $onlineTracks, isLoading: $isLoading, isOnlineLoading: $isOnlineLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResultsFrameImpl &&
            (identical(other.query, query) || other.query == query) &&
            const DeepCollectionEquality().equals(other._tracks, _tracks) &&
            const DeepCollectionEquality().equals(other._albums, _albums) &&
            const DeepCollectionEquality().equals(other._artists, _artists) &&
            const DeepCollectionEquality().equals(
              other._onlineTracks,
              _onlineTracks,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isOnlineLoading, isOnlineLoading) ||
                other.isOnlineLoading == isOnlineLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    query,
    const DeepCollectionEquality().hash(_tracks),
    const DeepCollectionEquality().hash(_albums),
    const DeepCollectionEquality().hash(_artists),
    const DeepCollectionEquality().hash(_onlineTracks),
    isLoading,
    isOnlineLoading,
    error,
  );

  /// Create a copy of SearchResultsFrame
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResultsFrameImplCopyWith<_$SearchResultsFrameImpl> get copyWith =>
      __$$SearchResultsFrameImplCopyWithImpl<_$SearchResultsFrameImpl>(
        this,
        _$identity,
      );
}

abstract class _SearchResultsFrame implements SearchResultsFrame {
  const factory _SearchResultsFrame({
    final String query,
    final List<AudioFile> tracks,
    final List<Album> albums,
    final List<Artist> artists,
    final List<OnlineTrack> onlineTracks,
    final bool isLoading,
    final bool isOnlineLoading,
    final String? error,
  }) = _$SearchResultsFrameImpl;

  @override
  String get query;
  @override
  List<AudioFile> get tracks;
  @override
  List<Album> get albums;
  @override
  List<Artist> get artists;
  @override
  List<OnlineTrack> get onlineTracks;
  @override
  bool get isLoading;
  @override
  bool get isOnlineLoading;
  @override
  String? get error;

  /// Create a copy of SearchResultsFrame
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchResultsFrameImplCopyWith<_$SearchResultsFrameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
