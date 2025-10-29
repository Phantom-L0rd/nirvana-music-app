import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/pages/custom_cards.dart';
import 'package:nirvana_desktop/providers/audio_provider.dart';
import 'package:nirvana_desktop/providers/audio_state.dart';
import 'package:nirvana_desktop/providers/providers.dart';

class AlbumContent extends ConsumerStatefulWidget {
  final Album album;

  const AlbumContent({super.key, required this.album});

  @override
  ConsumerState<AlbumContent> createState() => _AlbumContentState();
}

class _AlbumContentState extends ConsumerState<AlbumContent> {
  List<AudioFile> _tracks = [];
  int _totalMs = 0;

  @override
  void initState() {
    super.initState();
    // fetch songs after widget is built
    Future.microtask(() async {
      final id = widget.album.id;
      final tracks = await ref.read(localFoldersProvider).fetchAlbumSongs(id);

      setState(() {
        _tracks = tracks;
        for (AudioFile song in tracks) {
          _totalMs = _totalMs + song.duration;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Duration totalDuration = Duration(milliseconds: _totalMs);
    final String formattedTotalDuration = formatDuration(totalDuration);

    // WATCH the audio state - widget rebuilds when state changes
    final audioState = ref.watch(audioControllerProvider);

    // READ the controller - use this to call methods
    final audioController = ref.read(audioControllerProvider.notifier);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadiusGeometry.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.album.coverArt ?? "None",
                        fit: BoxFit.cover,
                      ),
                    ),

                    // 🔹 Blur + overlay
                    ClipRRect(
                      borderRadius: BorderRadiusGeometry.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ),

                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 800),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 8),
                                  Material(
                                    elevation: 8,
                                    borderRadius: BorderRadius.circular(6),
                                    clipBehavior: Clip.antiAlias,
                                    child: ClipRRect(
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            widget.album.coverArt ?? "None",
                                        width: 140,
                                        height: 140,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                              child: Icon(Icons.broken_image),
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text("Album"),
                                        Text(
                                          widget.album.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            HoverUnderlineText(
                                              text: widget.album.artist.name,
                                              fontSize: 14,
                                              onTap: () {
                                                context.go(
                                                  "/artist",
                                                  extra: {
                                                    "artist":
                                                        widget.album.artist,
                                                  },
                                                );
                                              },
                                            ),

                                            Text(
                                              " • ${widget.album.year} • ${_tracks.length} songs • $formattedTotalDuration",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    iconSize: 40,
                                    onPressed: () {
                                      if (audioState.hasPlaylist &&
                                          audioState.playlistType == 'Album' &&
                                          audioState.playlistId ==
                                              widget.album.id) {
                                        audioController.togglePlayPause();
                                      } else {
                                        audioController.setPlaylist(
                                          _tracks,
                                          type: "Album",
                                          id: widget.album.id,
                                          route: RouteEntry(
                                            '/album',
                                            extra: {"album": widget.album},
                                          ),
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      audioState.isPlaying &&
                                              audioState.playlistType ==
                                                  'Album' &&
                                              audioState.playlistId ==
                                                  widget.album.id
                                          ? Icons.pause_circle
                                          : Icons.play_circle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            SizedBox(
                              width: 51,
                              child: Center(child: Text("#")),
                            ),
                            SizedBox(width: 15),
                            Expanded(flex: 4, child: Text("Title")),
                            // Expanded(flex: 3, child: Text("Album")),
                            SizedBox(width: 92, child: Text("Duration")),
                          ],
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final song = _tracks[index];
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 2.0,
                  ),
                  child: SongCard(
                    forAlbum: true,
                    songNum: index + 1,
                    song: song,
                    onTap: () => audioController.setPlaylist(
                      _tracks,
                      startIndex: index,
                      type: "Album",
                      id: widget.album.id,
                      route: RouteEntry(
                        '/album',
                        extra: {"album": widget.album},
                      ),
                    ),
                  ),
                ),
              ),
            );
          }, childCount: _tracks.length),
        ),
      ],
    );
  }
}
