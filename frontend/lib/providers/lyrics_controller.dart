import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/providers/providers.dart';

class LyricsController extends StateNotifier<LyricsFrame> {
  final Ref ref;
  LyricsController(this.ref) : super(LyricsFrame(hasTimestamps: false, lyrics: []));

  Future<void> loadLyrics(AudioFile song) async {
    final data = await ref.read(localFoldersProvider).fetchLyrics(song.fullPath);
    state = data;
  }

  void clearLyrics() {
    state = LyricsFrame(hasTimestamps: false, lyrics: []);
  }
}