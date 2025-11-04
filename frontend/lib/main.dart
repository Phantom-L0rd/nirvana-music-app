import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/pages/album_content.dart';
import 'package:nirvana_desktop/pages/all_albums_content.dart';
import 'package:nirvana_desktop/pages/all_artists_content.dart';
import 'package:nirvana_desktop/pages/all_playlists_content.dart';
import 'package:nirvana_desktop/pages/artist_content.dart';
import 'package:nirvana_desktop/pages/home_content.dart';
import 'package:nirvana_desktop/pages/library_content.dart';
import 'package:nirvana_desktop/pages/lyrics_content.dart';
import 'package:nirvana_desktop/pages/playlist_content.dart';
import 'package:nirvana_desktop/pages/recent_content.dart';
import 'package:nirvana_desktop/pages/search_content.dart';
import 'package:nirvana_desktop/pages/settings_content.dart';
import 'package:nirvana_desktop/providers/audio_provider.dart';
import 'package:nirvana_desktop/providers/providers.dart';
import 'package:nirvana_desktop/layout/app_shell.dart';
import 'package:nirvana_desktop/services/history_service.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow(
    WindowOptions(
      minimumSize: const Size(800, 600),
      size: const Size(1000, 800),
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  final HistoryService history = HistoryService();

  MyApp({super.key});

  late final GoRouter _router = GoRouter(
    initialLocation: "/",
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Consumer(
            builder: (context, ref, _) {
              final currentPath = state.uri.toString();
              final currentExtra = state.extra;

              final currentRoute = RouteEntry(currentPath, extra: currentExtra);

              // Only push if it's not a back/forward navigation
              if (history.currentRoute?.path != currentRoute.path ||
                  history.currentRoute?.extra != currentRoute.extra) {
                history.push(currentRoute);
                if (currentPath != '/lyrics') {
                  Future.microtask(() {
                    ref.read(audioControllerProvider.notifier).setLyricsOff();
                  });
                }
              }

              return AppShell( history: history, child: child,);
            },
          );
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (_, __) => const HomeContent(),
          ),
          GoRoute(
            path: '/songs',
            name: 'songs',
            builder: (_, __) => const LibraryContent(),
          ),
          GoRoute(
            path: '/recents',
            name: 'recents',
            builder: (_, __) => const RecentContent(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (_, __) => const SettingsContent(),
          ),
          GoRoute(
            path: '/playlist',
            name: 'playlist',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              final Playlist playlist = extra['playlist'];
              // final List<AudioFile> tracks = (extra['tracks'] as List)
              //     .map((e) => AudioFile.fromJson(e as Map<String, dynamic>))
              //     .toList();
              final PlaylistType? type = extra['type'];

              return PlaylistContent(playlist: playlist, type: type,);
            },
          ),
          GoRoute(
            path: "/all-artists",
            name: 'all artists',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              final List<Artist> artists = List<Artist>.from(extra["artists"]);

              return AllArtistsContent(artists: artists);
            },
          ),
          GoRoute(
            path: "/all-albums",
            name: 'all albums',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              final List<Album> albums = List<Album>.from(extra["albums"]);

              return AllAlbumsContent(albums: albums);
            },
          ),
          GoRoute(
            path: "/all-playlists",
            name: 'all playlists',
            builder: (context, state) {
              return AllPlaylistsContent();
            },
          ),
          GoRoute(
            path: '/album',
            name: 'album',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              final Album album = extra["album"];

              return AlbumContent(album: album);
            },
          ),
          GoRoute(
            path: '/artist',
            name: 'artist',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              final Artist artist = extra["artist"];

              return ArtistContent(artist: artist);
            },
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) {
            
              return SearchResultsPage();
            },
          ),
          GoRoute(
            path: '/lyrics',
            name: 'lyrics',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              final AudioFile song = extra["song"];

              return LyricsContent(song: song);
            },
          ),
        ],
      ),
    ],
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final seedColor = ref.watch(themeNotifierProvider).seedColor;

        return MaterialApp.router(
          title: 'Nirvana',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          routerDelegate: _router.routerDelegate,
          routeInformationParser: _router.routeInformationParser,
          routeInformationProvider: _router.routeInformationProvider,
        );
      },
    );
  }
}
