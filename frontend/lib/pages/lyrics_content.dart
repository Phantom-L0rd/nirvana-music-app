import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/pages/custom_cards.dart';
import 'package:nirvana_desktop/providers/audio_provider.dart';
import 'package:nirvana_desktop/providers/audio_state.dart';
import 'package:nirvana_desktop/providers/providers.dart';

class LyricsContent extends ConsumerStatefulWidget {
  final AudioFile song;
  const LyricsContent({super.key, required this.song});

  @override
  ConsumerState<LyricsContent> createState() => _LyricsContentState();
}

class _LyricsContentState extends ConsumerState<LyricsContent> {
  bool _isLoading = true;
  late ScrollController _scrollController;
  int _currentIndex = -1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    Future.microtask(() async {
      try {
        ref.read(lyricsProvider.notifier).loadLyrics(widget.song);
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        // handle gracefully
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentLine(int index) {
    if (!_scrollController.hasClients) return;
    final offset = (index * 50.0) - 100; // each line ~50px tall, 2 lines above
    _scrollController.animateTo(
      offset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // WATCH the audio state - widget rebuilds when state changes
    final audioState = ref.watch(audioControllerProvider);

    // READ the controller - use this to call methods
    final audioController = ref.read(audioControllerProvider.notifier);

    final lyricsFrame = ref.watch(lyricsProvider);

    final hasLyrics = lyricsFrame.lyrics.isNotEmpty;

    // Find which lyric line matches the current timestamp
    if (lyricsFrame.hasTimestamps) {
      final newIndex = lyricsFrame.lyrics.lastIndexWhere(
        (line) =>
            audioState.currentPosition.inMilliseconds >= line['timestamp'],
      );

      // If a new line becomes active, scroll to it
      if (newIndex != _currentIndex && newIndex >= 0) {
        _currentIndex = newIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCurrentLine(newIndex);
        });
      }
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: audioState.currentTrack!.album.coverArt ?? "None",
              fit: BoxFit.cover,
            ),
          ),
      
          // Blur overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),
      
          // Loading or content
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text("Fetching lyrics...", style: TextStyle(fontSize: 18)),
                ],
              ),
            )
          else if (hasLyrics)
            lyricsFrame.hasTimestamps
                ? ListView.builder(
                    controller: _scrollController,
                    itemCount: lyricsFrame.lyrics.length,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 8,
                    ),
                    itemBuilder: (context, index) {
                      final line = lyricsFrame.lyrics[index]['line'];
                      final timestamp =
                          lyricsFrame.lyrics[index]['timestamp'] as int;
      
                      final isActive =
                          audioState.currentPosition.inMilliseconds >= timestamp;
      
                      return AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: isActive ? 30 : 24,
                          color: isActive ? Colors.white : Colors.grey,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: SizedBox(
                              height: 50,
                              child: HoverUnderlineText(
                                text: line,
                                fontSize: isActive ? 30 : 24,
                                colour: isActive ? Colors.white : Colors.grey,
                                onTap: () {},
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: lyricsFrame.lyrics.length,
                    padding: const EdgeInsets.all(4),
                    itemBuilder: (context, index) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Text(
                            lyricsFrame.lyrics[index],
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  )
          else
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child: Text(
                  "OOPS! There are no lyrics currently available.",
                  style: TextStyle(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
