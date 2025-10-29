import 'dart:math';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/pages/custom_cards.dart';
import 'package:nirvana_desktop/providers/audio_provider.dart';
import 'package:nirvana_desktop/providers/audio_state.dart';
import 'package:nirvana_desktop/providers/providers.dart';

class ArtistContent extends ConsumerStatefulWidget {
  final Artist artist;

  const ArtistContent({super.key, required this.artist});

  @override
  ConsumerState<ArtistContent> createState() => _ArtistContentState();
}

class _ArtistContentState extends ConsumerState<ArtistContent> {
  List<AudioFile> _tracks = [];
  List<Album> _albums = [];

  @override
  void initState() {
    super.initState();
    // fetch songs after widget is built
    Future.microtask(() async {
      final id = widget.artist.id;
      final tracks = await ref.read(localFoldersProvider).fetchArtistSongs(id);
      final albums = await ref.read(localFoldersProvider).fetchArtistAlbums(id);
      setState(() {
        _tracks = tracks;
        _albums = albums;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(
                height: 240,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.artist.artwork != null &&
                            widget.artist.artwork!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadiusGeometry.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            child: CachedNetworkImage(
                              imageUrl:
                                  "https://lastfm.freetls.fastly.net/i/u/770x0/2924d658b98dd78812f7018d8dc2a38b.jpg#2924d658b98dd78812f7018d8dc2a38b",
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ),

                    // Blur + overlay
                    if (widget.artist.artwork != null &&
                        widget.artist.artwork!.isNotEmpty)
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
                          child: Row(
                            children: [
                              Material(
                                elevation: 8,
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                                child: ClipOval(
                                  child:
                                      widget.artist.artwork != null &&
                                          widget.artist.artwork!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl:
                                              "https://lastfm.freetls.fastly.net/i/u/770x0/2924d658b98dd78812f7018d8dc2a38b.jpg#2924d658b98dd78812f7018d8dc2a38b",
                                          width: 160,
                                          height: 160,
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
                                        )
                                      : Container(
                                          width: 160,
                                          height: 160,
                                          color: getRandomColor(
                                            widget.artist.name,
                                          ),
                                          child: Center(
                                            child: Text(
                                              widget.artist.name.isNotEmpty
                                                  ? widget.artist.name[0]
                                                        .toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                fontSize: 108,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                widget.artist.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        TracksCard(artist: widget.artist, tracks: _tracks),

        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800),
              child: Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Albums",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 190,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 180 / 220,
                        ),
                        itemCount: _albums.length,
                        itemBuilder: (context, index) {
                          final album = _albums[index];
                          return AlbumCard(album: album, inArtist: true);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TracksCard extends ConsumerStatefulWidget {
  final Artist artist;
  final List<AudioFile> tracks;
  const TracksCard({super.key, required this.artist, required this.tracks});

  @override
  ConsumerState<TracksCard> createState() => _TracksCardState();
}

class _TracksCardState extends ConsumerState<TracksCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // WATCH the audio state - widget rebuilds when state changes
    final audioState = ref.watch(audioControllerProvider);

    // READ the controller - use this to call methods
    final audioController = ref.read(audioControllerProvider.notifier);

    int viewCount = isExpanded
        ? widget.tracks.length
        : min(5, widget.tracks.length);
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "This is ${widget.artist.name}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        iconSize: 40,
                        onPressed: () {
                          if (audioState.hasPlaylist &&
                              audioState.playlistType == 'Artist' &&
                              audioState.playlistId == widget.artist.id) {
                            audioController.togglePlayPause();
                          } else {
                            audioController.setPlaylist(
                              widget.tracks,
                              type: "Artist",
                              id: widget.artist.id,
                              route: RouteEntry(
                                '/artist',
                                extra: {"artist": widget.artist},
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          audioState.isPlaying &&
                                  audioState.playlistType == 'Artist' &&
                                  audioState.playlistId == widget.artist.id
                              ? Icons.pause_circle
                              : Icons.play_circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: viewCount,
                    itemBuilder: (context, index) {
                      final song = widget.tracks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 2.0,
                        ),
                        child: SongCard(
                          songNum: index + 1,
                          forArtist: true,
                          song: song,
                          onTap: () => audioController.setPlaylist(
                            widget.tracks,
                            startIndex: index,
                            type: "Artist",
                            id: song.album.artist.id,
                            route: RouteEntry(
                              '/artist',
                              extra: {"artist": widget.artist},
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  if (widget.tracks.length > 5)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (isExpanded) {
                            isExpanded = false;
                            viewCount = min(5, widget.tracks.length);
                          } else {
                            isExpanded = true;
                            viewCount = widget.tracks.length;
                          }
                        });
                      },
                      child: isExpanded
                          ? const Text("Show less...")
                          : const Text("Show more..."),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
