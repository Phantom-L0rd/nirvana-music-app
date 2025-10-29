import 'package:flutter/material.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/pages/custom_cards.dart';
import 'package:nirvana_desktop/pages/playlist_content.dart';

class AllArtistsContent extends StatefulWidget {
  final List<Artist> artists;
  const AllArtistsContent({super.key, required this.artists});

  @override
  State<AllArtistsContent> createState() => _AllArtistsContentState();
}

class _AllArtistsContentState extends State<AllArtistsContent> {
  List<Artist> _filteredArtists = [];

  @override
  void initState() {
    super.initState();
    // load songs from your backend or provider
    _filteredArtists = widget.artists;
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredArtists = widget.artists;
      } else {
        _filteredArtists = widget.artists
            .where(
              (artist) =>
                  artist.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                                        Icons.person_rounded,
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
                                      "Artists",
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${widget.artists.length} Artists",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              SearchToggle(onSearchChanged: _onSearchChanged),
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
        // const SizedBox(height: 16),
        SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 196 / 236,
          ),
          itemCount: _filteredArtists.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ArtistCard(artist: _filteredArtists[index]),
            );
          },
        ),
      ],
    );
  }
}
