import 'dart:ffi';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:audio_wave/audio_wave.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/providers/audio_provider.dart';
import 'package:nirvana_desktop/providers/audio_state.dart';
import 'package:nirvana_desktop/providers/download_provider.dart';
import 'package:nirvana_desktop/providers/providers.dart';

class MenuButton extends ConsumerStatefulWidget {
  final int menuId;
  final IconData menuIcon;
  final String menuText;
  final VoidCallback onTap;
  const MenuButton({
    super.key,
    required this.menuId,
    required this.menuIcon,
    required this.menuText,
    required this.onTap,
  });

  @override
  ConsumerState<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends ConsumerState<MenuButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: 50,
          width: 60,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: widget.menuId == ref.watch(menuController)
                        ? Theme.of(context).colorScheme.primary
                        : _isHovering
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.menuIcon,
                      size: 24,
                      color: widget.menuId == ref.watch(menuController)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                    ),
                    SizedBox(
                      width: 44,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          widget.menuText,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AlbumCard extends ConsumerStatefulWidget {
  final Album album;
  final bool inArtist;

  const AlbumCard({super.key, required this.album, this.inArtist = false});

  @override
  ConsumerState<AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends ConsumerState<AlbumCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.go("/album", extra: {"album": widget.album});
        },
        child: SizedBox(
          height: 260,
          width: 180,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isHovering
                  ? Theme.of(context).colorScheme.surfaceContainerHigh
                  : Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Album cover
                Center(
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(6),
                    clipBehavior: Clip.antiAlias,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: widget.album.coverArt ?? "None",
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                ),
                // Album name
                Flexible(
                  child: HoverUnderlineText(
                    text: widget.album.name,
                    fontSize: 14,
                    onTap: () {
                      context.go("/album", extra: {"album": widget.album});
                    },
                  ),
                ),
                Flexible(
                  child: widget.inArtist
                      ? Text(
                          widget.album.year.toString(),
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        )
                      : HoverUnderlineText(
                          text: widget.album.artist.name,
                          fontSize: 13,
                          colour: Colors.grey,
                          onTap: () {
                            context.go(
                              "/artist",
                              extra: {"artist": widget.album.artist},
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ArtistCard extends StatefulWidget {
  final Artist artist;

  const ArtistCard({super.key, required this.artist});

  @override
  State<ArtistCard> createState() => _ArtistCardState();
}

class _ArtistCardState extends State<ArtistCard> {
  bool _isHovering = false;
  // Generates a consistent color based on the name hash

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              context.go("/artist", extra: {"artist": widget.artist});
            },
            child: SizedBox(
              height: 220,
              width: 180,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isHovering
                      ? Theme.of(context).colorScheme.surfaceContainerHigh
                      : Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
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
                                imageUrl: widget.artist.artwork!,
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Center(
                                      child: Icon(Icons.broken_image),
                                    ),
                              )
                            : Container(
                                width: 160,
                                height: 160,
                                color: getRandomColor(widget.artist.name),
                                child: Center(
                                  child: Text(
                                    widget.artist.name.isNotEmpty
                                        ? widget.artist.name[0].toUpperCase()
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
                    Flexible(
                      child: HoverUnderlineText(
                        text: widget.artist.name,
                        fontSize: 14,
                        onTap: () {
                          context.go(
                            "/artist",
                            extra: {"artist": widget.artist},
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AlbumOfTheDay extends ConsumerStatefulWidget {
  final Album album;

  const AlbumOfTheDay({super.key, required this.album});

  @override
  ConsumerState<AlbumOfTheDay> createState() => _AlbumOfTheDayState();
}

class _AlbumOfTheDayState extends ConsumerState<AlbumOfTheDay> {
  @override
  Widget build(BuildContext context) {
    // WATCH the audio state - widget rebuilds when state changes
    final audioState = ref.watch(audioControllerProvider);

    // READ the controller - use this to call methods
    final audioController = ref.read(audioControllerProvider.notifier);

    return SizedBox(
      height: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 🔹 Background image (fills full width)
            CachedNetworkImage(
              imageUrl: widget.album.coverArt ?? "None",
              fit: BoxFit.cover,
            ),

            // 🔹 Blur + overlay
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),

            // foreground content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // cover art
                      Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(6),
                        clipBehavior: Clip.antiAlias,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: widget.album.coverArt ?? "None",
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Text block
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Album of the Day',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            HoverUnderlineText(
                              text: widget.album.name,
                              fontSize: 14,
                              onTap: () {
                                context.go(
                                  "/album",
                                  extra: {"album": widget.album},
                                );
                              },
                            ),
                            HoverUnderlineText(
                              text: widget.album.artist.name,
                              fontSize: 13,
                              colour: Colors.grey,
                              onTap: () {
                                context.go(
                                  "/artist",
                                  extra: {"artist": widget.album.artist},
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Play Button
                      IconButton(
                        iconSize: 40,
                        onPressed: () async {
                          if (audioState.hasPlaylist &&
                              audioState.playlistType == 'Album' &&
                              audioState.playlistId == widget.album.id) {
                            audioController.togglePlayPause();
                          } else {
                            final songs = await ref
                                .read(localFoldersProvider)
                                .fetchAlbumSongs(widget.album.id);
                            audioController.setPlaylist(
                              songs,
                              type: 'Album',
                              id: widget.album.id,
                            );
                          }
                        },
                        icon: Icon(
                          audioState.isPlaying &&
                                  audioState.playlistType == 'Album' &&
                                  audioState.playlistId == widget.album.id
                              ? Icons.pause_circle
                              : Icons.play_circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistCard extends StatefulWidget {
  final Playlist playlist;

  const PlaylistCard({super.key, required this.playlist});

  @override
  State<PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<PlaylistCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              context.go(
                "/playlist",
                extra: {'playlist': widget.playlist, 'type': PlaylistType.user},
              );
            },
            child: SizedBox(
              height: 216,
              width: 180,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isHovering
                      ? Theme.of(context).colorScheme.surfaceContainerHigh
                      : Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Album cover
                    Center(
                      child: Material(
                        elevation: 8,
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl:
                                "https://images.unsplash.com/photo-1494232410401-ad00d5433cfa?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=870",
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                      ),
                    ),
                    // Playlist name
                    Flexible(
                      child: Text(
                        widget.playlist.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SongCard extends ConsumerStatefulWidget {
  final bool forAlbum;
  final bool forArtist;
  final bool forPlaylist;
  final int? songNum;
  final AudioFile song;
  final VoidCallback onTap;
  final String? lyricId;

  const SongCard({
    super.key,
    this.forAlbum = false,
    this.forArtist = false,
    this.forPlaylist = false,
    this.songNum,
    required this.song,
    required this.onTap,
    this.lyricId,
  });

  @override
  ConsumerState<SongCard> createState() => _SongCardState();
}

class _SongCardState extends ConsumerState<SongCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: widget.song.duration);
    final String formattedDuration = formatDuration(duration);
    final formattedDate = DateFormat('d MMM y').format(
      widget.song.dateAdded != null
          ? DateTime.parse(widget.song.dateAdded!) // parse ISO 8601 string
          : DateTime.now(), // fallback if null
    );
    // WATCH the audio state - widget rebuilds when state changes
    final audioState = ref.watch(audioControllerProvider);

    // READ the controller - use this to call methods
    final audioController = ref.read(audioControllerProvider.notifier);

    final downloadNotifier = ref.watch(downloadProvider);

    final isCurrentlyPlaying = audioState.currentTrack != null
        ? audioState.currentTrack!.id == widget.song.id
        : false;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: audioState.isLoading ? null : widget.onTap,
        child: SizedBox(
          height: 60,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
            decoration: BoxDecoration(
              color: isCurrentlyPlaying
                  ? Theme.of(context).colorScheme.surfaceContainerHigh
                  : _isHovering
                  ? Theme.of(context).colorScheme.surfaceContainerHigh
                  : Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                if (widget.songNum != null)
                  isCurrentlyPlaying
                      ? SizedBox(
                          width: 40,
                          child: SpotifyVisualizer(
                            isPlaying: audioState.isPlaying,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : SizedBox(
                          width: 40,
                          child: Center(child: Text("${widget.songNum}")),
                        ),
                const SizedBox(width: 12),
                Flexible(
                  flex: 4,
                  child: Row(
                    children: [
                      if (!widget.forAlbum)
                        Material(
                          elevation: 12,
                          clipBehavior: Clip.antiAlias,
                          child: ClipRRect(
                            // borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: widget.song.album.coverArt ?? "None",
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Center(child: Icon(Icons.broken_image)),
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: widget.forArtist
                            ? Text(
                                widget.song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14),
                                  ),

                                  HoverUnderlineText(
                                    text: widget.song.album.artist.name,
                                    fontSize: 13,
                                    maxLines: 1,
                                    colour: Colors.grey,
                                    onTap: () {
                                      context.go(
                                        "/artist",
                                        extra: {
                                          "artist": widget.song.album.artist,
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
                if (!widget.forAlbum)
                  Expanded(
                    flex: 3,
                    child: HoverUnderlineText(
                      text: widget.song.album.name,
                      fontSize: 13,
                      maxLines: 1,
                      colour: Colors.grey,
                      onTap: () {
                        context.go(
                          "/album",
                          extra: {"album": widget.song.album},
                        );
                      },
                    ),
                  ),

                if (widget.forPlaylist)
                  Expanded(
                    flex: 2,
                    child: Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      formattedDuration,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.song.type == SongType.online &&
                    downloadNotifier.isDownloading &&
                    downloadNotifier.id == widget.song.id)
                  Text("${downloadNotifier.progress.toStringAsFixed(1)}%"),
                widget.song.type == SongType.local
                    ? MoreOptionsWidget(
                        playlistIds: widget.song.playlistIds,
                        songId: widget.song.id,
                      )
                    : IconButton(
                        onPressed: downloadNotifier.isDownloading
                            ? null
                            : () {
                                final OnlineTrack songData = OnlineTrack(
                                  id: widget.song.id,
                                  track: widget.song,
                                  lyricId: widget.lyricId,
                                );
                                ref
                                    .read(downloadProvider)
                                    .startDownload(songData);
                              },
                        icon: Icon(
                          downloadNotifier.isDownloading &&
                                  downloadNotifier.id == widget.song.id
                              ? Icons.close_rounded
                              : Icons.download_rounded,
                        ),
                      ),
                // IconButton(
                //   onPressed: () {},
                //   hoverColor: Colors.transparent,
                //   icon: Icon(Icons.more_vert_rounded),
                // ),
                if (widget.songNum == null) const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum MoreOptions { like, addToQueue, addToPlaylist }

class MoreOptionsWidget extends StatelessWidget {
  final List<int> playlistIds;
  final String songId;
  const MoreOptionsWidget({
    super.key,
    required this.songId,
    required this.playlistIds,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final notifier = ref.read(localFoldersProvider);
        final playlists = notifier.userPlaylists;
        return PopupMenuButton<MoreOptions>(
          tooltip: 'More Options',
          itemBuilder: (context) => <PopupMenuEntry<MoreOptions>>[
            PopupMenuItem(
              value: MoreOptions.like,
              onTap: () async {
                final response = await notifier.addSongToPlaylist(2, songId);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    shape: StadiumBorder(),
                    elevation: 12,
                    padding: EdgeInsets.all(8),
                    content: Center(child: Text(response)),
                  ),
                );
              },
              child: Row(
                spacing: 8,
                children: [
                  Icon(
                    playlistIds.contains(2)
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                  ),
                  Text('Like'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: MoreOptions.addToQueue,
              child: Row(
                spacing: 8,
                children: [
                  Icon(Icons.queue_music_rounded),
                  Text('Add To Queue'),
                ],
              ),
            ),
            PopupMenuItem(
              value: MoreOptions.addToPlaylist,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  // backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                  builder: (context) {
                    return ListView(
                      shrinkWrap: true,
                      children: playlists.map((playlist) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListTile(
                            leading: const Icon(Icons.queue_music),
                            title: Text(playlist.name),
                            onTap: () async {
                              // Add to playlist logic
                              final response = await notifier.addSongToPlaylist(
                                playlist.id,
                                songId,
                              );

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  shape: StadiumBorder(),
                                  elevation: 12,
                                  padding: EdgeInsets.all(8),
                                  content: Center(child: Text(response)),
                                ),
                              );

                              Navigator.pop(context);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
              child: Row(
                spacing: 8,
                children: [
                  Icon(Icons.playlist_add_rounded),
                  Text('Add To Playlist'),
                ],
              ),
            ),
          ],
          child: Icon(Icons.more_vert_rounded),
        );
      },
    );
  }
}

enum SortOption { title, artist, album, duration, recentlyAdded }

class SongsSorterWidget extends StatefulWidget {
  final List<AudioFile> songs;
  final void Function(List<AudioFile>)? onSorted; // optional callback

  const SongsSorterWidget({super.key, required this.songs, this.onSorted});

  @override
  State<SongsSorterWidget> createState() => _SongsSorterWidgetState();
}

class _SongsSorterWidgetState extends State<SongsSorterWidget> {
  SortOption _selectedSort = SortOption.title;
  bool _isAscending = true;

  // safe helpers
  int _nullSafeIntCompare(int? a, int? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.compareTo(b);
  }

  int _nullSafeStringCompare(String? a, String? b) {
    final sa = (a ?? '').toLowerCase();
    final sb = (b ?? '').toLowerCase();
    return sa.compareTo(sb);
  }

  List<AudioFile> _sortSongs(List<AudioFile> songs) {
    final sorted = List<AudioFile>.from(songs);
    sorted.sort((a, b) {
      int cmp = 0;
      switch (_selectedSort) {
        case SortOption.title:
          cmp = _nullSafeStringCompare(a.title, b.title);
          break;
        case SortOption.artist:
          cmp = _nullSafeStringCompare(
            a.album.artist.name,
            b.album.artist.name,
          );
          break;
        case SortOption.album:
          cmp = _nullSafeStringCompare(a.album.name, b.album.name);
          break;
        case SortOption.duration:
          cmp = _nullSafeIntCompare(a.duration, b.duration);
          break;
        case SortOption.recentlyAdded:
          cmp = _nullSafeStringCompare(b.dateAdded, a.dateAdded);
          break;
      }
      return _isAscending ? cmp : -cmp;
    });

    return sorted;
  }

  void _applySort() {
    final sorted = _sortSongs(widget.songs);
    if (widget.onSorted != null) widget.onSorted!(sorted);
    setState(() {}); // ensure UI updates (e.g. icon toggles)
  }

  @override
  Widget build(BuildContext context) {
    // _applySort();
    // Show current selection + toggle
    return Row(
      children: [
        PopupMenuButton<SortOption>(
          tooltip: 'Sort',
          initialValue: _selectedSort,
          onSelected: (opt) {
            setState(() {
              _selectedSort = opt;
            });
            _applySort();
          },
          itemBuilder: (context) => <PopupMenuEntry<SortOption>>[
            const PopupMenuItem(value: SortOption.title, child: Text('Title')),
            const PopupMenuItem(
              value: SortOption.artist,
              child: Text('Artist'),
            ),
            const PopupMenuItem(value: SortOption.artist, child: Text('Album')),
            const PopupMenuItem(
              value: SortOption.duration,
              child: Text('Duration'),
            ),
            const PopupMenuItem(
              value: SortOption.recentlyAdded,
              child: Text('Recently Added'),
            ),
          ],
          child: Row(
            children: [
              const Icon(Icons.sort_rounded, size: 20),
              const SizedBox(width: 6),
              Text(_selectedSort.name),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
          tooltip: _isAscending ? 'Ascending' : 'Descending',
          onPressed: () {
            setState(() {
              _isAscending = !_isAscending;
            });
            _applySort();
          },
        ),
      ],
    );
  }
}

class HoverUnderlineText extends StatefulWidget {
  final String text;
  final double fontSize;
  final int maxLines;
  final Color colour;
  final VoidCallback onTap;

  const HoverUnderlineText({
    super.key,
    required this.text,
    required this.fontSize,
    this.maxLines = 2,
    this.colour = Colors.white,
    required this.onTap,
  });

  @override
  State<HoverUnderlineText> createState() => _HoverUnderlineTextState();
}

class _HoverUnderlineTextState extends State<HoverUnderlineText> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Text(
            widget.text,
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: widget.colour,
              decoration: _isHovering
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}

class AlphabetRow extends StatefulWidget {
  final List<AudioFile> songs;
  final void Function(List<AudioFile>)? onFilter;
  const AlphabetRow({super.key, required this.songs, this.onFilter});

  @override
  State<AlphabetRow> createState() => _AlphabetRowState();
}

class _AlphabetRowState extends State<AlphabetRow> {
  String _selectedChar = '...';

  @override
  Widget build(BuildContext context) {
    List<AudioFile> filtered = [];
    // Generate A-Z using char codes
    final letters = [
      "...",
      "#",
      ...List.generate(26, (index) => String.fromCharCode(65 + index)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: letters
            .map(
              (letter) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: HoverUnderlineText(
                  text: letter,
                  fontSize: 20,
                  colour: _selectedChar == letter
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  onTap: () {
                    if (letter == '...') {
                      filtered = widget.songs;
                      if (widget.onFilter != null) widget.onFilter!(filtered);
                    } else {
                      if (letter != '#') {
                        filtered = widget.songs
                            .where(
                              (element) => element.title.startsWith(letter),
                            )
                            .toList();
                        if (widget.onFilter != null) widget.onFilter!(filtered);
                      } else {
                        filtered = widget.songs
                            .where(
                              (element) => element.title.startsWith(
                                RegExp(r'^[^A-Za-z]'),
                              ),
                            )
                            .toList();
                        if (widget.onFilter != null) widget.onFilter!(filtered);
                      }
                    }
                    _selectedChar = letter;
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class SearchToggle extends StatefulWidget {
  /// Called every time the user types in the search box
  final ValueChanged<String>? onSearchChanged;

  /// Called when search is closed (optional)
  final VoidCallback? onSearchClosed;

  const SearchToggle({super.key, this.onSearchChanged, this.onSearchClosed});

  @override
  State<SearchToggle> createState() => _SearchToggleState();
}

class _SearchToggleState extends State<SearchToggle> {
  bool _isSearching = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && mounted) {
        setState(() => _isSearching = false);
        widget.onSearchClosed?.call();
        _controller.clear();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearching) {
      return SizedBox(
        width: 350,
        height: 36,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          onChanged: widget.onSearchChanged,
          decoration: InputDecoration(
            hintText: "Search...",
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () {
                _controller.clear();
                widget.onSearchChanged?.call('');
                _focusNode.unfocus();
                setState(() => _isSearching = false);
                widget.onSearchClosed?.call();
              },
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.search_rounded, size: 20),
        tooltip: "Search in current view",
        onPressed: () {
          setState(() => _isSearching = true);
          // Focus is handled automatically by autofocus
        },
      );
    }
  }
}

Color getRandomColor(String name) {
  final random = Random(name.hashCode);
  return Color.fromARGB(
    255,
    random.nextInt(200),
    random.nextInt(200),
    random.nextInt(200),
  );
}

class SpotifyVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  const SpotifyVisualizer({
    super.key,
    required this.isPlaying,
    this.color = Colors.greenAccent,
  });

  @override
  State<SpotifyVisualizer> createState() => _SpotifyVisualizerState();
}

class _SpotifyVisualizerState extends State<SpotifyVisualizer>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final int barCount = 4;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      barCount,
      (_) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + Random().nextInt(300)),
      ),
    );

    _animations = _controllers
        .map(
          (controller) => Tween<double>(begin: 5, end: 25).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();

    if (widget.isPlaying) _startAnimations();
  }

  void _startAnimations() {
    for (var controller in _controllers) {
      controller.repeat(reverse: true);
    }
  }

  void _stopAnimations() {
    for (var controller in _controllers) {
      controller.stop();
      controller.value = 0.5; // reset halfway
    }
  }

  @override
  void didUpdateWidget(covariant SpotifyVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controllers.first.isAnimating) {
      _startAnimations();
    } else if (!widget.isPlaying && _controllers.first.isAnimating) {
      _stopAnimations();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(barCount, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 4,
                height: _animations[i].value,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
