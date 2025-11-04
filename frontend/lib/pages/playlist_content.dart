import 'dart:ffi';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/pages/custom_cards.dart';
import 'package:nirvana_desktop/providers/audio_provider.dart';
import 'package:nirvana_desktop/providers/audio_state.dart';
import 'package:nirvana_desktop/providers/providers.dart';

class PlaylistContent extends ConsumerStatefulWidget {
  final Playlist playlist;
  final PlaylistType? type;

  const PlaylistContent({
    super.key,
    required this.playlist,
    this.type = PlaylistType.system,
  });

  @override
  ConsumerState<PlaylistContent> createState() => _PlaylistContentState();
}

class _PlaylistContentState extends ConsumerState<PlaylistContent> {
  List<AudioFile> _tracks = [];
  List<AudioFile> _filteredSongs = [];
  int _totalMs = 0;

  @override
  void initState() {
    super.initState();
    // load songs from your backend or provider
    Future.microtask(() async {
      final id = widget.playlist.id;
      final data = await ref.read(localFoldersProvider).getPlaylistTracks(id);
      setState(() {
        _tracks = data;
        _filteredSongs = _tracks;
        for (AudioFile song in data) {
          _totalMs = _totalMs + song.duration;
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant PlaylistContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playlist.id != widget.playlist.id) {
      Future.microtask(() async {
        final id = widget.playlist.id;
        final data = await ref.read(localFoldersProvider).getPlaylistTracks(id);
        setState(() {
          _totalMs = 0;
          _tracks = data;
          _filteredSongs = _tracks;
          for (AudioFile song in data) {
            _totalMs = _totalMs + song.duration;
          }
        });
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSongs = _tracks;
      } else {
        _filteredSongs = _tracks
            .where(
              (song) =>
                  song.title.toLowerCase().contains(query.toLowerCase()) ||
                  song.album.artist.name.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  song.album.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // WATCH the audio state - widget rebuilds when state changes
    final audioState = ref.watch(audioControllerProvider);
    // READ the controller - use this to call methods
    final audioController = ref.read(audioControllerProvider.notifier);

    final isFour = widget.playlist.artwork.length == 4;

    final Duration totalDuration = Duration(milliseconds: _totalMs);
    // final Duration totalDuration = Duration(minutes: 192);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(
                height: 160,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
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
                                  // SizedBox(width: 8),
                                  Material(
                                    elevation: 8,
                                    borderRadius: BorderRadius.circular(6),
                                    clipBehavior: Clip.antiAlias,
                                    child: ClipRRect(
                                      child: isFour
                                          ? SizedBox(
                                              width: 100,
                                              height: 100,
                                              child: GridView.count(
                                                crossAxisCount: 2,
                                                padding: EdgeInsets.zero,
                                                mainAxisSpacing: 0,
                                                crossAxisSpacing: 0,
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                children: widget.playlist.artwork.map((
                                                  item,
                                                ) {
                                                  return SizedBox(
                                                    width: 50,
                                                    height: 50,
                                                    child: CachedNetworkImage(
                                                      imageUrl: item,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (
                                                            context,
                                                            url,
                                                          ) => const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          ),
                                                      errorWidget:
                                                          (
                                                            context,
                                                            url,
                                                            error,
                                                          ) => const Center(
                                                            child: Icon(
                                                              Icons
                                                                  .broken_image,
                                                            ),
                                                          ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            )
                                          : widget.playlist.artwork.isEmpty
                                          ? Container(
                                              width: 100,
                                              height: 100,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.inversePrimary,
                                              child: Center(
                                                child: Icon(
                                                  widget.playlist.name ==
                                                          "Favourites"
                                                      ? Icons.favorite_rounded
                                                      : widget.playlist.name ==
                                                            "Downloads"
                                                      ? Icons.download_rounded
                                                      : widget.playlist.name ==
                                                            "Recently Played"
                                                      ? Icons.history_rounded
                                                      : Icons
                                                            .broken_image_rounded,
                                                  size: 64,
                                                ),
                                              ),
                                            )
                                          : CachedNetworkImage(
                                              imageUrl:
                                                  widget.playlist.artwork[0],
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                        ),
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
                                        Text(
                                          widget.playlist.name,
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "${_tracks.length} songs - ${formatDuration(totalDuration)}",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    iconSize: 40,
                                    onPressed: () {
                                      if (audioState.hasPlaylist &&
                                          audioState.playlistType ==
                                              'Playlist' &&
                                          audioState.playlistId ==
                                              widget.playlist.id.toString()) {
                                        audioController.togglePlayPause();
                                      } else {
                                        debugPrint(
                                          _filteredSongs.length.toString(),
                                        );
                                        audioController.setPlaylist(
                                          _filteredSongs,
                                          type: 'Playlist',
                                          id: widget.playlist.id.toString(),
                                          route: RouteEntry(
                                            '/playlist',
                                            extra: {
                                              'playlist': widget.playlist,
                                              'type': widget.type,
                                            },
                                          ),
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      audioState.isPlaying &&
                                              audioState.playlistType ==
                                                  'Playlist' &&
                                              audioState.playlistId ==
                                                  widget.playlist.id.toString()
                                          ? Icons.pause_circle
                                          : Icons.play_circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SearchToggle(
                                    onSearchChanged: _onSearchChanged,
                                  ),
                                  const Spacer(),
                                  if (widget.playlist.id != 4)
                                    SongsSorterWidget(
                                      songs: _tracks,
                                      onSorted: (sorted) => setState(() {
                                        _filteredSongs = sorted;
                                      }),
                                    ),
                                  if (widget.type == PlaylistType.user)
                                    const SizedBox(width: 12),

                                  if (widget.type == PlaylistType.user)
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              "Delete this playlist?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStatePropertyAll<
                                                        Color
                                                      >(
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primaryContainer,
                                                      ),
                                                ),
                                                onPressed: () async {
                                                  await ref
                                                      .read(
                                                        localFoldersProvider
                                                            .notifier,
                                                      )
                                                      .deletePlaylist(
                                                        widget.playlist.id,
                                                      );
                                                  if (!context.mounted) return;

                                                  Navigator.of(context).pop();

                                                  context.go('/all-playlists');

                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback((
                                                        _,
                                                      ) {
                                                        if (mounted) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                ref
                                                                    .watch(
                                                                      localFoldersProvider,
                                                                    )
                                                                    .syncMessage,
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      });
                                                },
                                                child: Text(
                                                  "Confirm",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        size: 20,
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
              if (widget.playlist.id != 4)
                AlphabetRow(
                  songs: _tracks,
                  onFilter: (filtered) => setState(() {
                    _filteredSongs = filtered;
                  }),
                ),

              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: const [
                      SizedBox(width: 52, child: Center(child: Text("#"))),
                      Expanded(flex: 4, child: Text("Title")),
                      Expanded(flex: 3, child: Text("Album")),
                      SizedBox(width: 92, child: Text("Duration")),
                    ],
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 4.0,
              //     vertical: 2.0,
              //   ),
              //   child: SongCard(
              //     songNum: 1,
              //     imagePath: song.coverArt ?? "None",
              //     songName: song.title ?? "Unknown",
              //     artistName: song.artist ?? "Unknown",
              //     albumName: song.album ?? "Unknown",
              //     duration: song.duration ?? 0,
              //     onTap: () {},
              //   ),
              // ),
            ],
          ),
        ),

        _filteredSongs.isNotEmpty
            ? SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = _filteredSongs[index];
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 800),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 2.0,
                        ),
                        child: SongCard(
                          songNum: index + 1,
                          song: song,
                          onTap: () => audioController.setPlaylist(
                            _filteredSongs,
                            startIndex: index,
                            type: 'Playlist',
                            id: widget.playlist.id.toString(),
                            route: RouteEntry(
                              '/playlist',
                              extra: {
                                'playlist': widget.playlist,
                                'type': widget.type,
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: _filteredSongs.length),
              )
            : SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("There are no songs here!"),
                  ),
                ),
              ),
      ],
    );
  }
}

// class SongsList extends StatelessWidget {
//   final List<AudioFile> tracks;
//   const SongsList({super.key, required this.tracks});

//   @override
//   Widget build(BuildContext context) {
//     if (tracks.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(8.0),
//         child: Text("There are no available songs!"),
//       );
//     }

//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.all(6.0),
//         child: CustomScrollView(
//           // shrinkWrap: true,
//           // physics: const NeverScrollableScrollPhysics(),
//           slivers: [
//             SliverList(
//               delegate: SliverChildBuilderDelegate((context, index) {
//                 final song = tracks[index];
//                 return SongCard(
//                   songNum: index + 1,
//                   song: song,
//                 );
//               }, childCount: tracks.length),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
