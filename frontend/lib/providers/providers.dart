import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/providers/download_provider.dart';
import 'package:nirvana_desktop/providers/lyrics_controller.dart';
import 'package:nirvana_desktop/providers/search_provider.dart';
import 'package:nirvana_desktop/services/download_service.dart'
    hide DownloadService;
import 'package:nirvana_desktop/services/local_folders_notifier.dart';
import 'package:nirvana_desktop/services/theme_notifier.dart';
// the file where you define the class

final localFoldersProvider = ChangeNotifierProvider(
  (ref) => LocalFoldersNotifier(),
);

// final artistProvider = FutureProvider.family<Artist, String>((
//   ref,
//   artistId,
// ) async {
//   final localFolders = ref.read(localFoldersProvider);
//   return localFolders.fetchArtist(artistId);
// });

final themeNotifierProvider = ChangeNotifierProvider((ref) => ThemeNotifier());

final menuController = StateProvider<int>((ref) {
  return 0;
});

final lyricsProvider = StateNotifierProvider<LyricsController, LyricsFrame>((
  ref,
) {
  return LyricsController(ref);
});

final downloadProvider = ChangeNotifierProvider((ref) => DownloadService());
