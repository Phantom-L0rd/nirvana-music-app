import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/pages/custom_cards.dart';
import 'package:nirvana_desktop/providers/audio_provider.dart';
import 'package:nirvana_desktop/providers/providers.dart';
import 'package:nirvana_desktop/providers/search_provider.dart';
import 'package:nirvana_desktop/services/api_service.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  // final String query;
  const SearchResultsPage({super.key});

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  // @override
  // void initState() {
  //   super.initState();

  //   Future.microtask(() async {
  //     try {
  //       ref.read(searchProvider.notifier).search(widget.query);
  //       setState(() {});
  //     } catch (_) {}
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // READ the controller - use this to call methods
    final audioController = ref.read(audioControllerProvider.notifier);

    final searchState = ref.watch(searchProvider);

    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
      slivers: [
        // SliverToBoxAdapter(
        //   child: Center(
        //     child: Column(
        //       spacing: 4,
        //       children: [
        //         Text("isLoading: ${searchState.isLoading}"),
        //         Text("error: ${searchState.error}"),
        //         Text("query: ${searchState.query}"),
        //       ],
        //     ),
        //   ),
        // ),

        if (searchState.tracks.isNotEmpty)
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
                        const Text(
                          "Tracks",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: min(5, searchState.tracks.length),
                          itemBuilder: (context, index) {
                            final song = searchState.tracks[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                                vertical: 2.0,
                              ),
                              child: SongCard(
                                song: song,
                                onTap: () => audioController.setPlaylist(
                                  searchState.tracks,
                                  startIndex: index,

                                  route: RouteEntry('/search'),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (searchState.albums.isNotEmpty)
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
                        const Text(
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
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 190,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 180 / 220,
                              ),
                          itemCount: min(4, searchState.albums.length),
                          itemBuilder: (context, index) {
                            final album = searchState.albums[index];
                            return AlbumCard(album: album);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        if (searchState.artists.isNotEmpty)
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
                        const Text(
                          "Artists",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 190,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 196 / 236,
                              ),
                          itemCount: min(4, searchState.artists.length),
                          itemBuilder: (context, index) {
                            final artist = searchState.artists[index];
                            return ArtistCard(artist: artist);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

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
                      const Text(
                        "Online Tracks",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      searchState.isOnlineLoading
                          ? Center(child: CircularProgressIndicator())
                          : searchState.onlineTracks.isEmpty
                          ? Center(child: const Text("No results available"))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: min(
                                20,
                                searchState.onlineTracks.length,
                              ),
                              itemBuilder: (context, index) {
                                final onlineTrack =
                                    searchState.onlineTracks[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                    vertical: 2.0,
                                  ),
                                  child: SongCard(
                                    song: onlineTrack.track,
                                    onTap: () async {
                                      final url = await ApiService.getStreamUrl(
                                        onlineTrack.id,
                                      );
                                      audioController.playFromUrl(
                                        url,
                                        track: onlineTrack.track,
                                      );
                                    },
                                  ),
                                );
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
