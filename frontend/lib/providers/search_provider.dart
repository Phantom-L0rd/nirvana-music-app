
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_provider.freezed.dart';
part 'search_provider.g.dart';

@freezed
class SearchResultsFrame with _$SearchResultsFrame {
  const factory SearchResultsFrame({
    @Default('') String query,
    @Default([]) List<AudioFile> tracks,
    @Default([]) List<Album> albums,
    @Default([]) List<Artist> artists,
    @Default([]) List<OnlineTrack> onlineTracks,
    @Default(false) bool isLoading,
    @Default(false) bool isOnlineLoading,
    String? error,
  }) = _SearchResultsFrame;
}

@riverpod
class Search extends _$Search {
  @override
  SearchResultsFrame build() => const SearchResultsFrame();

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const SearchResultsFrame();
      return;
    }

    state = state.copyWith(isLoading: true, query: query);

    try {
      // 1. Normalize the query
      final normalizedQuery = query.toLowerCase().trim();
      final musicNotifierState = ref.watch(localFoldersProvider);

      // 2. Apply the filtering logic
      final filteredTracks = musicNotifierState.allSongs.where((track) {
        return track.title.toLowerCase().contains(normalizedQuery) ||
            track.album.name.toLowerCase().contains(normalizedQuery) ||
            track.album.artist.name.toLowerCase().contains(normalizedQuery);
      }).toList();
      final filteredAlbums = musicNotifierState.allAlbums.where((album) {
        return album.name.toLowerCase().contains(normalizedQuery) ||
            album.artist.name.toLowerCase().contains(normalizedQuery);
      }).toList();
      final filteredArtists = musicNotifierState.allArtists.where((artist) {
        return artist.name.toLowerCase().contains(normalizedQuery);
      }).toList();

      state = state.copyWith(
        isLoading: false,
        tracks: filteredTracks,
        albums: filteredAlbums,
        artists: filteredArtists,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> onlineSearch(String query) async {
    if (query.isEmpty) {
      state = const SearchResultsFrame();
      return;
    }

    state = state.copyWith(isOnlineLoading: true);

    try {
      // 1. Normalize the query
      final normalizedQuery = query.toLowerCase().trim();
      final musicNotifier = ref.read(localFoldersProvider);

      // 2. Get Online Search Results
      final onlineTracks = await musicNotifier.fetchYtSearchTracks(
        normalizedQuery,
      );

      state = state.copyWith(
        isOnlineLoading: false,
        onlineTracks: onlineTracks,
      );
    } catch (e) {
      state = state.copyWith(isOnlineLoading: false, error: e.toString());
    }
  }
}
