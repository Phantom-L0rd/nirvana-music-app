import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirvana_desktop/models/models.dart';

import 'package:nirvana_desktop/pages/custom_cards.dart';
import 'package:nirvana_desktop/providers/providers.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final foldersNotifier = ref.watch(localFoldersProvider);
        if (foldersNotifier.isSyncing) {
          return Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AlbumOfTheDay(
                  album: foldersNotifier.albumOfTheDay,
                ),

                const SizedBox(height: 16),
                AlbumScrollSection(albums: foldersNotifier.albumsForYou),
                const SizedBox(height: 16),
                ArtistScrollSection(artists: foldersNotifier.artistsForYou),
                const SizedBox(height: 16),
                // MoodScrollSection(),
                // const SizedBox(height: 16),
                // Text(foldersNotifier.localFolders.length.toString()),
                // const SizedBox(height: 16),
                // ListView.builder(
                //   itemCount: songs.length,
                //   shrinkWrap: true,
                //   physics: NeverScrollableScrollPhysics(),
                //   itemBuilder: (context, index) {
                //     final song = songs[index];
                //     return ListTile(
                //       title: Text(song.title ?? "unkown"),
                //       subtitle: Text(song.artist ?? "unkown"),
                //     );
                //   },
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AlbumScrollSection extends StatefulWidget {
  final List<Album> albums;

  const AlbumScrollSection({super.key, required this.albums});

  @override
  State<AlbumScrollSection> createState() => _AlbumScrollSectionState();
}

class _AlbumScrollSectionState extends State<AlbumScrollSection> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 302,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Top Picks For You',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: _scrollLeft,
              ),
              Expanded(
                child: SizedBox(
                  height: 260, // or adjust as needed
                  child: ListView.separated(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: widget.albums.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) =>
                        AlbumCard(album: widget.albums[index]),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: _scrollRight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ArtistScrollSection extends StatefulWidget {
  final List<Artist> artists;
  const ArtistScrollSection({super.key, required this.artists});

  @override
  State<ArtistScrollSection> createState() => _ArtistScrollSectionState();
}

class _ArtistScrollSectionState extends State<ArtistScrollSection> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 262,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Why Not Listen To',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: _scrollLeft,
              ),
              Expanded(
                child: SizedBox(
                  height: 220, // or adjust as needed
                  child: ListView.separated(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: widget.artists.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) =>
                        ArtistCard(artist: widget.artists[index]),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: _scrollRight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MoodScrollSection extends StatefulWidget {
  const MoodScrollSection({super.key});

  @override
  State<MoodScrollSection> createState() => _MoodScrollSectionState();
}

class _MoodScrollSectionState extends State<MoodScrollSection> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 302,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Play By Mood',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: _scrollLeft,
              ),
              // Expanded(
              //   child: SizedBox(
              //     height: 260, // or adjust as needed
              //     child: ListView.separated(
              //       controller: _scrollController,
              //       scrollDirection: Axis.horizontal,
              //       padding: const EdgeInsets.symmetric(horizontal: 8),
              //       itemCount: 10,
              //       separatorBuilder: (_, __) => const SizedBox(width: 16),
              //       itemBuilder: (context, index) => AlbumCard(
              //         album: widget.albums[index],
              //       ),
              //     ),
              //   ),
              // ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: _scrollRight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
