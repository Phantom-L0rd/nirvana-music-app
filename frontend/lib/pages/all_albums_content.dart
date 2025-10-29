import 'package:flutter/material.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/pages/custom_cards.dart';
import 'package:nirvana_desktop/pages/playlist_content.dart';

class AllAlbumsContent extends StatefulWidget {
  final List<Album> albums;
  const AllAlbumsContent({super.key, required this.albums});

  @override
  State<AllAlbumsContent> createState() => _AllAlbumsContentState();
}

class _AllAlbumsContentState extends State<AllAlbumsContent> {
  List<Album> _filteredAlbums = [];

  @override
  void initState() {
    super.initState();
    // load songs from your backend or provider
    _filteredAlbums = widget.albums;
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAlbums = widget.albums;
      } else {
        _filteredAlbums = widget.albums
            .where(
              (album) =>
                  album.name.toLowerCase().contains(query.toLowerCase()) ||
                  album.artist.name.toLowerCase().contains(query.toLowerCase()),
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
                                        Icons.album_rounded,
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
                                      "Albums",
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${widget.albums.length} Albums",
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
        SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 190,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 180 / 260,
          ),
          itemCount: _filteredAlbums.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: AlbumCard(album: _filteredAlbums[index]),
            );
          },
        ),
      ],
    );
  }
}
