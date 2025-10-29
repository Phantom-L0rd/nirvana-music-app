import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/pages/custom_cards.dart';
import 'package:nirvana_desktop/providers/providers.dart';

class LibraryContent extends StatelessWidget {
  const LibraryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final foldersNotifier = ref.watch(localFoldersProvider);
        return DefaultTabController(
          length: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Text(
                      "Your Library",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {},
                      tooltip: "Add a Playlist",
                      icon: Icon(Icons.playlist_add_rounded),
                    ),
                  ],
                ),
              ),
              TabBar(
                tabs: [
                  Tab(text: "Playlists"),
                  Tab(text: "Artists"),
                  Tab(text: "Albums"),
                ],
                dividerHeight: 0,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    LibraryPlaylistContent(
                      corePlaylists: foldersNotifier.corePlaylists,
                    ),
                    LibraryArtistContent(artists: foldersNotifier.allArtists),
                    LibraryAlbumContent(albums: foldersNotifier.allAlbums),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LibraryPlaylistContent extends StatefulWidget {
  final List<Playlist> corePlaylists;
  final List<Playlist>? userPlaylists;
  const LibraryPlaylistContent({
    super.key,
    required this.corePlaylists,
    this.userPlaylists,
  });

  @override
  State<LibraryPlaylistContent> createState() => _LibraryPlaylistContentState();
}

class _LibraryPlaylistContentState extends State<LibraryPlaylistContent> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final foldersNotifier = ref.watch(localFoldersProvider);
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // core playlists
              SizedBox(
                height: 232, // adjust based on PlaylistCard height
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.all(8.0),
                  itemCount: widget.corePlaylists.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: PlaylistCard(
                       playlist: widget.corePlaylists[index],
                      ),
                    );
                  },
                ),
              ),

              // const SizedBox(height: 12,),
              const Divider(),
              const Text("Playlists"),
            ],
          ),
        );
      },
    );
  }
}

class LibraryArtistContent extends StatefulWidget {
  final List<Artist> artists;
  const LibraryArtistContent({super.key, required this.artists});

  @override
  State<LibraryArtistContent> createState() => _LibraryArtistContentState();
}

class _LibraryArtistContentState extends State<LibraryArtistContent> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 196 / 236,
      ),
      itemCount: widget.artists.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ArtistCard(
            artist: widget.artists[index],
          ),
        );
      },
    );
  }
}

class LibraryAlbumContent extends StatefulWidget {
  final List<Album> albums;
  const LibraryAlbumContent({super.key, required this.albums});

  @override
  State<LibraryAlbumContent> createState() => _LibraryAlbumContentState();
}

class _LibraryAlbumContentState extends State<LibraryAlbumContent> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 190,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 180 / 260,
      ),
      itemCount: widget.albums.length,
      itemBuilder: (context, index) {
        return AlbumCard(album: widget.albums[index]);
      },
    );
  }
}
