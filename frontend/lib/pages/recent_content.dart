import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nirvana_desktop/pages/custom_cards.dart';

class RecentContent extends StatelessWidget {
  const RecentContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Text(
            "Recently Played",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return RecentSongCard(
                  imagePath:
                      "https://lh3.googleusercontent.com/TsiwDZL1y5PWawEN3aozCx23IkTXFYiHxc8dB_bZc1LR22s0PJrp7pcNU0fOdniSxRwYm7-JG9wt17E=w60-h60-l90-rj",
                  songName:
                      "Bigmouth Strikes Again #$index Ronnie Rising Medley (Includes A Light In The Black, Tarot Woman, Stargazer & Kill The King)",
                  artistName:
                      "Ronnie Rising Medley (Includes A Light In The Black, Tarot Woman, Stargazer & Kill The King)",

                  duration: 192.0,
                  onTap: () {},
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class RecentSongCard extends StatefulWidget {
  final String imagePath;
  final String songName;
  final String artistName;
  final double duration;
  final VoidCallback onTap;

  const RecentSongCard({
    super.key,
    required this.imagePath,
    required this.songName,
    required this.artistName,
    required this.duration,
    required this.onTap,
  });

  @override
  State<RecentSongCard> createState() => _RecentSongCardState();
}

class _RecentSongCardState extends State<RecentSongCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final minutes = widget.duration ~/ 60;
    final seconds = (widget.duration % 60).ceil();
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: 60,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
            decoration: BoxDecoration(
              color: _isHovering
                  ? Theme.of(context).colorScheme.surfaceContainerHigh
                  : Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: widget.imagePath,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.songName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14),
                      ),
                      HoverUnderlineText(
                        text: widget.artistName,
                        fontSize: 13,
                        maxLines: 1,
                        colour: Colors.grey,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 50),
                Text("$minutes:$seconds"),
                IconButton(
                  onPressed: () {},
                  hoverColor: Colors.transparent,
                  icon: Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
