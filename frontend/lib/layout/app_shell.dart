import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/pages/custom_cards.dart';
import 'package:nirvana_desktop/providers/audio_provider.dart';
import 'package:nirvana_desktop/providers/audio_state.dart';
import 'package:nirvana_desktop/providers/providers.dart';
import 'package:nirvana_desktop/providers/search_provider.dart';
import '../services/history_service.dart';

class AppShell extends ConsumerStatefulWidget {
  final HistoryService history;
  final Widget child;

  const AppShell({required this.child, required this.history, super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  // FocusNode for the search bar, persists with this StatefulWidget
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Helper method for onChanged
  void _onSearchChanged(BuildContext context, String q) {
    if (q.isNotEmpty) {
      if (GoRouterState.of(context).uri.toString() != '/search') {
        // If not on the search page, navigate to it
        context.go('/search');

        // **Crucially, the FocusNode is still valid because the TextField hasn't left the tree.**
        // We only need to request focus if the field somehow lost it during transition
        // Schedule focus request for the next frame after rebuild
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _searchFocusNode.requestFocus();
          }
        });
        ref.read(searchProvider.notifier).search(q);
      } else {
        ref.read(searchProvider.notifier).search(q);
      }
    } else {
      // Go back to the home route when the search bar is empty
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(localFoldersProvider);

    if (notifier.isSyncing) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.history.canGoBack
              ? () {
                  final route = widget.history.goBack();
                  if (route != null) {
                    context.go(route.path, extra: route.extra);
                    ref.read(audioControllerProvider.notifier).setLyricsOff();
                  }
                }
              : null,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: widget.history.canGoForward
                ? () {
                    final route = widget.history.goForward();
                    if (route != null) {
                      context.go(route.path, extra: route.extra);
                      ref.read(audioControllerProvider.notifier).setLyricsOff();
                    }
                  }
                : null,
          ),
        ],

        title: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final searchBarWidth = (width * 0.6).clamp(0.0, 600.0); // max 600

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: searchBarWidth),
                child: TextField(
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search for songs, artists, and more',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    filled: true,
                  ),
                  focusNode: _searchFocusNode,
                  controller: _searchController,
                  // onChanged: (q) {
                  //   _onSearchChanged(context, q);
                  // },
                  onSubmitted: (q) {
                    if (q.isNotEmpty) {
                      if (GoRouterState.of(context).uri.toString() !=
                          '/search') {
                        context.go('/search');

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref.read(searchProvider.notifier).search(q);
                          ref.read(searchProvider.notifier).onlineSearch(q);
                        });
                      } else {
                        ref.read(searchProvider.notifier).search(q);
                        ref.read(searchProvider.notifier).onlineSearch(q);
                      }
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
      body: Row(
        children: [
          _SidePanel(history: widget.history),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
                NowPlayingPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GlobalSearchBar extends StatefulWidget {
  // final FocusNode? _focusNode;
  // final TextEditingController? _controller;
  const GlobalSearchBar({super.key});

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  // 1. Declare and initialize the FocusNode
  final FocusNode _textFieldFocusNode = FocusNode();

  @override
  void dispose() {
    // 2. Dispose the FocusNode
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void _refocusTextField() {
    _textFieldFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final searchBarWidth = (width * 0.6).clamp(0.0, 600.0); // max 600

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: searchBarWidth),
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search for songs, artists, and more',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
              ),
              focusNode: _textFieldFocusNode,
              onChanged: (q) {
                if (q.isNotEmpty) {
                  debugPrint(GoRouterState.of(context).uri.toString());
                  if (GoRouterState.of(context).uri.toString() == '/search') {
                    debugPrint("running other code ....");
                  } else {
                    context.go('/search');
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _refocusTextField();
                    });
                  }
                } else {
                  context.go('/');
                }
              },
              onSubmitted: (q) {
                context.go('/search');
              },
            ),
          ),
        );
      },
    );
  }
}

class _SidePanel extends StatelessWidget {
  final HistoryService history;

  const _SidePanel({required this.history});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final notifier = ref.watch(localFoldersProvider);
        return SizedBox(
          width: 60,
          child: Column(
            children: [
              MenuButton(
                menuId: 0,
                menuIcon: Icons.home,
                menuText: "Home",
                onTap: () {
                  context.go('/');
                  ref.read(menuController.notifier).state = 0;
                },
              ),
              const SizedBox(height: 12),
              MenuButton(
                menuId: 1,
                menuIcon: Icons.music_note_rounded,
                menuText: "Songs",
                onTap: () {
                  context.go(
                    "/playlist",
                    extra: {'playlist': notifier.corePlaylists[0]},
                  );
                  ref.read(menuController.notifier).state = 1;
                },
              ),
              const SizedBox(height: 12),
              MenuButton(
                menuId: 2,
                menuIcon: Icons.person_rounded,
                menuText: "Artists",
                onTap: () {
                  context.go(
                    "/all-artists",
                    extra: {"artists": notifier.allArtists},
                  );
                  ref.read(menuController.notifier).state = 2;
                },
              ),
              const SizedBox(height: 12),
              MenuButton(
                menuId: 3,
                menuIcon: Icons.album_rounded,
                menuText: "Albums",
                onTap: () {
                  context.go(
                    '/all-albums',
                    extra: {"albums": notifier.allAlbums},
                  );
                  ref.read(menuController.notifier).state = 3;
                },
              ),
              const SizedBox(height: 12),
              MenuButton(
                menuId: 4,
                menuIcon: Icons.library_music_rounded,
                menuText: "Playlists",
                onTap: () {
                  context.go('/all-playlists');
                  ref.read(menuController.notifier).state = 4;
                },
              ),
              const SizedBox(height: 12),
              MenuButton(
                menuId: 5,
                menuIcon: Icons.favorite_rounded,
                menuText: "Favourites",
                onTap: () {
                  context.go(
                    "/playlist",
                    extra: {'playlist': notifier.corePlaylists[1]},
                  );
                  ref.read(menuController.notifier).state = 5;
                },
              ),
              const SizedBox(height: 12),
              MenuButton(
                menuId: 6,
                menuIcon: Icons.download_rounded,
                menuText: "Downloads",
                onTap: () {
                  context.go(
                    "/playlist",
                    extra: {'playlist': notifier.corePlaylists[2]},
                  );
                  ref.read(menuController.notifier).state = 6;
                },
              ),
              const SizedBox(height: 12),
              MenuButton(
                menuId: 7,
                menuIcon: Icons.history_rounded,
                menuText: "Recents",
                onTap: () {
                  context.go(
                    "/playlist",
                    extra: {'playlist': notifier.corePlaylists[3]},
                  );
                  ref.read(menuController.notifier).state = 7;
                },
              ),
              const SizedBox(height: 12),

              const Spacer(),

              MenuButton(
                menuId: 8,
                menuIcon: Icons.settings_rounded,
                menuText: "Settings",
                onTap: () {
                  context.go('/settings');
                  ref.read(menuController.notifier).state = 8;
                },
              ),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('v1.0', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NowPlayingPanel extends ConsumerStatefulWidget {
  const NowPlayingPanel({super.key});

  @override
  ConsumerState<NowPlayingPanel> createState() => _NowPlayingPanelState();
}

class _NowPlayingPanelState extends ConsumerState<NowPlayingPanel> {
  bool _spaceDown = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleRawKey);
  }

  bool _handleRawKey(KeyEvent event) {
    // Only handle space key
    if (event.logicalKey != LogicalKeyboardKey.space) return false;

    // If user is typing in a text field (EditableText), don't toggle.
    final primary = FocusManager.instance.primaryFocus;
    bool typing = false;
    final ctx = primary?.context;
    if (ctx != null) {
      ctx.visitAncestorElements((element) {
        if (element.widget is EditableText) {
          typing = true;
          return false; // Stop searching up
        }
        return true;
      });
    }

    if (typing) return false;

    // Debounce repeats: only toggle on first KeyDown, and reset on KeyUp.
    if (event is KeyDownEvent) {
      if (!_spaceDown) {
        _spaceDown = true;
        final audioController = ref.read(audioControllerProvider.notifier);
        audioController.togglePlayPause();
      }
    } else if (event is KeyUpEvent) {
      _spaceDown = false;
    }

    // Return true to signal that we handled this key event
    return true;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleRawKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // WATCH the audio state - widget rebuilds when state changes
    final audioState = ref.watch(audioControllerProvider);

    // READ the controller - use this to call methods
    final audioController = ref.read(audioControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: SizedBox(
          height: 76,
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Material(
                      elevation: 12,
                      // borderRadius: BorderRadius.circular(6),
                      clipBehavior: Clip.antiAlias,
                      child: ClipRRect(
                        child: CachedNetworkImage(
                          imageUrl: audioState.currentTrack != null
                              ? audioState.currentTrack!.album.coverArt ??
                                    "None"
                              : "None",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            audioState.currentTrack != null
                                ? audioState.currentTrack!.title
                                : "No Track",
                            maxLines: 1,
                            style: TextStyle(fontSize: 14),
                          ),
                          HoverUnderlineText(
                            text: audioState.currentTrack != null
                                ? audioState.currentTrack!.album.artist.name
                                : "No Track artist",
                            fontSize: 13,
                            colour: Colors.grey,
                            maxLines: 1,
                            onTap: () {
                              audioState.currentTrack != null
                                  ? context.go(
                                      "/artist",
                                      extra: {
                                        "artist": audioState
                                            .currentTrack!
                                            .album
                                            .artist,
                                      },
                                    )
                                  : null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                flex: 3,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.shuffle_rounded,
                                // size: 24,
                                color: audioState.shuffle
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                              iconSize: 24,
                              hoverColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              padding: EdgeInsets.zero,
                              tooltip: "Enable Shuffle",
                              constraints: BoxConstraints(),
                              color: audioState.shuffle
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              onPressed: audioController.toggleShuffle,
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: Icon(Icons.skip_previous_rounded),
                              iconSize: 28,
                              hoverColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              padding: EdgeInsets.zero,
                              tooltip: "Previous",
                              constraints: BoxConstraints(),
                              onPressed: audioState.hasPlaylist
                                  ? audioController.previousSong
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: Icon(
                                audioState.isLoading
                                    ? Icons
                                          .hourglass_empty // Show different icon when loading
                                    : audioState.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              iconSize: 28,
                              hoverColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              padding: EdgeInsets.zero,
                              tooltip: audioState.isLoading
                                  ? "Loading..."
                                  : audioState.isPlaying
                                  ? 'Pause'
                                  : 'Play',
                              constraints: BoxConstraints(),
                              onPressed: audioState.isLoading
                                  ? null
                                  : () {
                                      audioState.hasPlaylist
                                          ? audioController.togglePlayPause()
                                          : null;
                                    },
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: Icon(Icons.skip_next_rounded),
                              iconSize: 28,
                              hoverColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              padding: EdgeInsets.zero,
                              tooltip: "Next",
                              constraints: BoxConstraints(),
                              onPressed: audioState.hasPlaylist
                                  ? audioController.nextSong
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: Icon(
                                audioState.repeatOne
                                    ? Icons.repeat_one_rounded
                                    : audioState.repeat
                                    ? Icons.repeat_rounded
                                    : Icons.repeat_rounded,

                                color:
                                    (audioState.repeat || audioState.repeatOne)
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                              iconSize: 24,
                              hoverColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              padding: EdgeInsets.zero,
                              tooltip: audioState.repeatOne
                                  ? 'Repeat One'
                                  : audioState.repeat
                                  ? 'Repeat All'
                                  : 'No Repeat',
                              constraints: BoxConstraints(),
                              onPressed: audioController.toggleRepeat,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              formatDuration(audioState.currentPosition),
                              style: TextStyle(fontSize: 10),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4.0,
                                  padding: EdgeInsets.zero,
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),

                                  overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 16.0,
                                  ),
                                ),
                                child: Slider(
                                  value: audioState.totalDuration.inSeconds > 0
                                      ? audioState.currentPosition.inSeconds
                                            .toDouble()
                                            .clamp(
                                              0.0,
                                              audioState.totalDuration.inSeconds
                                                  .toDouble(),
                                            )
                                      : 0.0,
                                  max: audioState.totalDuration.inSeconds > 0
                                      ? audioState.totalDuration.inSeconds
                                            .toDouble()
                                      : 1.0, // Prevent max = 0 which causes slider issues
                                  activeColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  inactiveColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.3),
                                  onChanged:
                                      audioState.totalDuration.inSeconds > 0
                                      ? (val) {
                                          audioController.seek(
                                            Duration(seconds: val.toInt()),
                                          );
                                        }
                                      : null, // Disable slider when no track loaded
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatDuration(audioState.totalDuration),
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Debug info
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 200),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.lyrics_rounded, size: 20),
                          padding: EdgeInsets.zero,
                          tooltip: "Lyrics",
                          constraints: BoxConstraints(),
                          onPressed: audioState.currentTrack != null
                              ? () {
                                  if (audioState.isShowingLyrics) {
                                    audioState.playlistRoute != null
                                        ? context.go(
                                            audioState.playlistRoute!.path,
                                            extra:
                                                audioState.playlistRoute!.extra,
                                          )
                                        : context.go("/");
                                  } else {
                                    context.go(
                                      '/lyrics',
                                      extra: {'song': audioState.currentTrack!},
                                    );
                                    audioController.setLyricsOn();
                                  }
                                }
                              : null,
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(Icons.line_weight_rounded, size: 20),
                          padding: EdgeInsets.zero,
                          tooltip: "Queue",
                          constraints: BoxConstraints(),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled:
                                  true, // optional: makes it expand more
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                              builder: (context) {
                                return QueueBottomModal();
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: audioState.volume > 0.5
                              ? Icon(Icons.volume_up_rounded, size: 20)
                              : audioState.volume > 0
                              ? Icon(Icons.volume_down_rounded, size: 20)
                              : Icon(Icons.volume_mute_rounded, size: 20),
                          padding: EdgeInsets.zero,
                          tooltip: "Mute",
                          constraints: BoxConstraints(),
                          onPressed: () {},
                        ),

                        const SizedBox(width: 12),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              padding: EdgeInsets.zero,
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 4,
                              ),
                              overlayShape: RoundSliderOverlayShape(
                                overlayRadius: 8.0,
                              ),
                            ),
                            child: Slider(
                              value: audioState.volume > 0
                                  ? audioState.volume.clamp(0.0, 1.0)
                                  : 0.0,
                              max: 1.0,
                              activeColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              onChanged: (val) {
                                audioController.setVolume(val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QueueBottomModal extends ConsumerStatefulWidget {
  const QueueBottomModal({super.key});

  @override
  ConsumerState<QueueBottomModal> createState() => _QueueBottomModalState();
}

class _QueueBottomModalState extends ConsumerState<QueueBottomModal> {
  @override
  Widget build(BuildContext context) {
    // WATCH the audio state - widget rebuilds when state changes
    final audioState = ref.watch(audioControllerProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  "Now Playing:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: audioState.currentTrack != null
                    ? SongCard(song: audioState.currentTrack!, onTap: () {})
                    : SizedBox(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  "Next:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: QueuePanel()),
            ],
          ),
        );
      },
    );
  }
}

class QueuePanel extends ConsumerStatefulWidget {
  const QueuePanel({super.key});

  @override
  ConsumerState<QueuePanel> createState() => _QueuePanelState();
}

class _QueuePanelState extends ConsumerState<QueuePanel> {
  @override
  Widget build(BuildContext context) {
    // WATCH the audio state - widget rebuilds when state changes
    final audioState = ref.watch(audioControllerProvider);

    // READ the controller - use this to call methods
    final audioController = ref.read(audioControllerProvider.notifier);

    List<AudioFile> shuffledList = audioController.getShuffledList();

    List<AudioFile> queue = audioState.shuffle
        ? shuffledList.isNotEmpty
              ? shuffledList.sublist(
                  shuffledList.indexOf(audioState.currentTrack!) + 1,
                )
              : shuffledList
        : audioState.playlist.isNotEmpty
        ? audioState.playlist.sublist(audioState.currentIndex + 1)
        : audioState.playlist;

    return queue.isNotEmpty
        ? ReorderableListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: queue.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              setState(() {
                final item = queue.removeAt(oldIndex);
                queue.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                key: ValueKey(queue[index].id),
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: SongCard(
                  song: queue[index],
                  onTap: () {
                    audioController.playSong(queue[index]);
                  },
                ),
              );
            },
          )
        : Center(child: const Text("There is no song in queue"));
  }
}
