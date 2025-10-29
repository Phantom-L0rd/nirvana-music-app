import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/pages/custom_cards.dart';
import 'package:nirvana_desktop/pages/playlist_content.dart';
import 'package:nirvana_desktop/providers/providers.dart';
import 'package:nirvana_desktop/services/api_service.dart';

class AllPlaylistsContent extends ConsumerStatefulWidget {
  const AllPlaylistsContent({super.key});

  @override
  ConsumerState<AllPlaylistsContent> createState() =>
      _AllPlaylistsContentState();
}

class _AllPlaylistsContentState extends ConsumerState<AllPlaylistsContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(localFoldersProvider);

    final List<Playlist> userPlaylists = notifier.userPlaylists;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
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
                              Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(6),
                                clipBehavior: Clip.antiAlias,
                                child: ClipRRect(
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.inversePrimary,
                                    child: Center(
                                      child: Icon(
                                        Icons.queue_music_rounded,
                                        size: 64,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Playlists",
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${userPlaylists.length} User Playlists",
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
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: TextField(
                                        decoration: const InputDecoration(
                                          hintText: 'Enter playlist name...',
                                          border: OutlineInputBorder(),
                                        ),
                                        onSubmitted: (value) async {
                                          final trimmed = value.trim();
                                          if (trimmed.isEmpty) return;

                                          Navigator.of(context).pop();

                                          final response =
                                              await ApiService.addPlaylist(
                                                trimmed,
                                              );

                                          if (!context.mounted) return;

                                          if (response) {
                                            final lastPlaylist = await notifier
                                                .fetchLastPlaylist();
                                            notifier.getUserPlaylists();

                                            if (!context.mounted) return;

                                            if (lastPlaylist != null) {
                                              context.go(
                                                "/playlist",
                                                extra: {
                                                  'playlist': lastPlaylist,
                                                  'tracks': notifier
                                                      .getPlaylistTracks(
                                                        lastPlaylist.id,
                                                      ),
                                                },
                                              );
                                            }

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Playlist successfully created and loaded",
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Playlist could not be created!",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                                tooltip: "Add a Playlist",
                                icon: Icon(Icons.playlist_add_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const SearchToggle(),
                              const Spacer(),
                              // const SortMenu(),
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
        ),

        userPlaylists.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 190,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 180 / 216,
                ),
                itemCount: userPlaylists.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: PlaylistCard(playlist: userPlaylists[index]),
                  );
                },
              )
            : SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("There are no user playlists here!"),
                  ),
                ),
              ),
      ],
    );
  }
}
