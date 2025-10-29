from collections import defaultdict
import datetime
import os
import hashlib
import random
import re
import subprocess
from typing import List
from mutagen import File
import requests
import yt_dlp
from app.models import Album, Artist, AudioFile, LyricLine, LyricsFrame, OnlineTrack
from app.db import insert_song
from ytmusicapi import YTMusic


def is_audio_file(filename: str) -> bool:
    audio_extensions = ['.mp3', '.m4a', '.flac', '.wav', '.aac', '.ogg']
    return any(filename.lower().endswith(ext) for ext in audio_extensions)


def scan_folder(folder_path: str) -> set[str]:
    seen = set()  # To track duplicates

    for root, _, files in os.walk(folder_path):
        for filename in files:
            full_path = os.path.join(root, filename)
            if not is_audio_file(filename):
                continue

            try:
                audio = File(full_path)
                if not audio:
                    print("failed at audio")
                    continue
                
                apic = audio.tags.get('APIC:') if audio.tags else None

                # Extract metadata
                title = audio.get('TIT2', [None])[0]
                artist = audio.get('TPE1', [None])[0]
                album = audio.get('TALB', [None])[0]
                duration = int(audio.info.length * 1000) if audio.info else None

                base = f"{title.lower().strip()}|{artist.lower().strip()}|{album.lower().strip()}|{duration}"
                unique_key = hashlib.md5(base.encode("utf-8")).hexdigest()
                
                
                
                tdrc = audio.get('TDRC')
                if tdrc:
                    try:
                        year_str = str(tdrc.text[0])
                        match = re.search(r'\b(19|20)\d{2}\b', year_str)
                        year = int(match.group()) if match else None
                    except Exception:
                        year = None
                else:
                    year = None
                
                time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

                if unique_key in seen:
                    continue
                seen.add(unique_key)

                insert_song(
                    id=unique_key,
                    full_path=full_path,
                    duration=duration,
                    artist=artist,
                    title=title,
                    album=album,
                    cover_art=save_album_art(apic.data) if apic else None,
                    year=year,
                    track_num=None,
                    date_added=time,
                    folder=folder_path
                )


            except Exception as e:
                continue
    return seen


def save_album_art(apic_data: bytes, base_path='static/images'):
    # Hash to uniquely identify image
    h = hashlib.sha256(apic_data).hexdigest()
    filename = f"{h}.jpg"
    path = os.path.join(base_path, filename)

    if not os.path.exists(path):
        os.makedirs(base_path, exist_ok=True)
        with open(path, 'wb') as f:
            f.write(apic_data)
    return f"http://127.0.0.1:8000/static/images/{filename}"


def get_album_of_the_day(albums: List[Album]) -> Album:
    """
    Returns a deterministic 'album of the day' from a list of albums.
    Uses the current date to rotate selection.
    
    Args:
        albums (List[Dict]): List of album dictionaries.
        
    Returns:
        Dict: The selected album of the day.
    """
    if not albums:
        return Album(name="No Album",artist="No Artist",tracks=[])

    # Use today's date as a seed
    today = datetime.date.today().isoformat()
    hash_val = int(hashlib.sha256(today.encode()).hexdigest(), 16)

    index = hash_val % len(albums)
    # index = random.randint(0,2)
    return albums[index]

def get_top_albums(albums: List[Album]) -> List[Album]:
    if not albums:
        return []
    
    # Get a hash value for today's date
    today = datetime.date.today().isoformat()
    hash_val = int(hashlib.sha256(today.encode()).hexdigest(), 16)
    
    # Seed the random module with today's hash
    rng = random.Random(hash_val)

    # Return 10 albums deterministically based on today's seed
    return rng.sample(albums, k=min(10, len(albums)))

def generate_artists(albums: List[Album]) -> List[Artist]:
    artist_dict = defaultdict(list)
    for album in albums:
        artist_dict[album.artist].append(album)

    all_artists = [
        Artist(name=artist_name, albums=artist_albums)
        for artist_name, artist_albums in artist_dict.items()
    ]
    return all_artists

def get_top_artists(artists: List[Artist]) -> List[Artist]:
    if not artists:
        return []
    
    # Get a hash value for today's date
    today = datetime.date.today().isoformat()
    hash_val = int(hashlib.sha256(today.encode()).hexdigest(), 16)
    
    # Seed the random module with today's hash
    rng = random.Random(hash_val)

    return rng.sample(artists, k=min(10,len(artists)))

def timestamp_to_ms(timestamp_str):
    """
    Converts a timestamp string in 'MM:SS.ms' format to total milliseconds (int).
    """
    # Extract minutes, seconds, and hundredths based on fixed positions
    minutes = int(timestamp_str[0:2])
    seconds = int(timestamp_str[3:5])
    hundredths = int(timestamp_str[6:8])
    
    # Calculate total milliseconds
    total_milliseconds = (minutes * 60 * 1000) + (seconds * 1000) + (hundredths * 10)
    
    return total_milliseconds

def get_lyrics(path):
    # Regex to capture ONLY the 'MM:SS.ms' part of the timestamp
    TIMESTAMP_REGEX = r"^(\[\d{2}:\d{2}\.\d{2}\])\s*(.*)$"

    # result = LyricsFrame(has_timestamps=False)

    try:
        audio = File(path)
        lyrics = []
        has_timestamp = False
        if not audio:
            return None
        
        lyrics_frame = audio.get('USLT::eng')
        if not lyrics_frame:
            return LyricsFrame(has_timestamps=False,lyrics=[])
        
        for line in lyrics_frame.text.split("\n"):
            match = re.match(TIMESTAMP_REGEX,line)

            if match:
                has_timestamp = True
                timestamp_str = match.group(1)
                ms_int = timestamp_to_ms(timestamp_str.strip('[]'))
                # ms_int = 0
                line_str = match.group(2)

                lyrics.append(LyricLine(timestamp=ms_int,line=line_str))
            else:
                lyrics.append(line)

        return LyricsFrame(has_timestamps=has_timestamp,lyrics=lyrics)
        
    except Exception as e:
        return LyricsFrame(has_timestamps=False,lyrics=[])


# YOUTUBE MUSIC API

def update_yt_dlp():
    """Update yt_dlp to latest version silently."""
    subprocess.run(["pip", "install", "-U", "yt-dlp"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)


def test_url(url):
    """Check if the URL actually works (returns 200)."""
    try:
        r = requests.head(url, allow_redirects=True, timeout=5)
        return r.status_code == 200
    except Exception:
        return False
    
def get_yt_search(query):
    ytmusic = YTMusic()

    results = []

    all_results = ytmusic.search(query, filter='songs', limit=20)

    for song in all_results:
        video_id = song["videoId"]
        song_watch_details = ytmusic.get_watch_playlist(video_id, limit=1)

        song_details = ytmusic.get_song(video_id)

        lyric_id = song_watch_details['lyrics'] if song_watch_details['lyrics'] else None

        track = song_watch_details['tracks'][0]

        duration = int(song_details['videoDetails']['lengthSeconds']) * 1000
        title = track['title']
        
        cover_art = track['thumbnail'][-1]['url'] if track['thumbnail'] else None
        album_id = track['album']['id'] if track['album']['id'] else ''
        album_name = track['album']['name'] if track['album']['name'] else ''
        year = int(track['year']) if track['year'] else None

        artist_id = track['artists'][0]['id'] if track['artists'][0]['id'] else ''
        artist_name = track['artists'][0]['name'] if track['artists'][0]['name'] else ''

        # results.append(track)

        results.append(
            OnlineTrack(
                id=video_id,
                lyrics_id=lyric_id,
                track_info=AudioFile(
                    id=video_id,
                    full_path="",
                    duration=duration,
                    title=title,
                    album=Album(
                        id=album_id,
                        name=album_name,
                        year=year,
                        artist=Artist(
                            id=artist_id,
                            name=artist_name,
                        ),
                        cover_art=cover_art
                    )
                )
            )
        )


    # video_id = all_results[0]["videoId"]
    # song_details = ytmusic.get_song(video_id)

    # song_watch_details = ytmusic.get_watch_playlist(video_id, limit=1)

    return results


def get_stream_url(video_id: str):
    if not video_id:
        return {'error': 'Missing video_id'}

    video_url = f"https://www.youtube.com/watch?v={video_id}"

    ydl_opts = {
        'format': "bestaudio[ext=m4a]/bestaudio/best",
        'quiet': True,
        'noplaylist': True,
        'skip_download': True,
        "nocheckcertificate": True,
        "ignoreerrors": True,
        "extract_flat": False,
    }

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(video_url, download=False)
            if "url" in info:
                audio_url = info.get('url')
                if test_url(audio_url):
                    return {'url': audio_url}
            else:
                return {"error": "No playable audio found"}
    except Exception as e:
       return {"error": str(e)}

    

    # ydl_opts = {
    #     "quiet": True,
    #     "skip_download": True,
    #     "format": "bestaudio/best",
    # }
    # with yt_dlp.YoutubeDL(ydl_opts) as ydl:
    #     info = ydl.extract_info(f"https://www.youtube.com/watch?v={video_id}", download=False)
    #     audio_url = info["url"]
    # return {"url": audio_url}


# APIC:
# TALB - album
# TDRC - year
# TIT2 - title
# TPE1 - artist
# TSSE
# TXXX:comment
# TXXX:description
# TXXX:synopsis
# TXXX:purl
# USLT::eng
# COMM:ID3v1 Comment:eng
# TRCK
# full_path = "/home/tri_poloski/Music/1 - Opeth.mp3" 
# full_path = "/home/tri_poloski/Music/Countless Skies - Belakor.mp3"
# full_path = "/home/tri_poloski/Music/Voice of the Soul - Death.mp3" 
# full_path = "/home/tri_poloski/Downloads/Travis Scott - Travis Scott, Don Toliver - CHAMPAIN & VACAY (Official Audio).mp3"
# audio = File(full_path)
# lyrics_frame = audio.get('USLT::eng')
# if lyrics_frame:
#     print("Lyrics:", lyrics_frame.text)
#     print("Language:", lyrics_frame.lang)
#     print("Description:", lyrics_frame.desc)

# from mutagen.id3 import USLT

# lyrics = None
# for tag in audio.tags.values():
#     if isinstance(tag, USLT):
#         lyrics = tag.text
#         break

# print(lyrics)