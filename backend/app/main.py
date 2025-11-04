# app/main.py
import asyncio
import os
import time
from fastapi.staticfiles import StaticFiles
from fastapi import BackgroundTasks, FastAPI, Form, WebSocket
import json
from typing import Dict, List
from app.models import AddSongRequest, Album, ApiResponse, Artist, AudioFile, FolderRequest, Folders, IdRequest, LyricsFrame, OnlineSongRequest, OnlineTrack, Playlist
from app.utils import download_song, get_album_of_the_day, get_lyrics, get_stream_url, get_top_albums, get_top_artists, get_yt_search, scan_folder
from app.db import add_folder_to_db, add_playlist_db, add_song_to_playlist_db, add_song_to_recents_db, cleanup_removed_songs, deactivate_folder, delete_playlist_db, get_album, get_album_songs, get_albums_from_db, get_artist, get_artist_albums, get_artist_songs,  get_artists_from_db, get_last_playlist_db, get_playlist_songs, get_recents_db, get_songs_from_db, get_user_playlists_db, initialize_db, is_first_startup, load_folders_from_db, load_core_playlists_db,mark_startup_complete
from contextlib import asynccontextmanager


# Global variables
first_startup = False



@asynccontextmanager
async def lifespan(app: FastAPI):
    global first_startup

    # This replaces `@app.on_event("startup")`
    initialize_db()

    # Load cached state at startup
    first_startup = is_first_startup()
    if first_startup:
        default_folder = os.path.expanduser("~/Videos/test_songs/A")
        if os.path.exists(default_folder) and os.path.isdir(default_folder):
            add_folder_to_db(default_folder)
            _ = scan_folder(default_folder)
        mark_startup_complete()

    yield
    # You can also put shutdown logic after `yield` if needed



app = FastAPI(title="Nirvana Backend API",lifespan=lifespan)
app.mount("/static", StaticFiles(directory="static"), name="static")

progress_tracker: Dict[str, float] = {}


@app.get("/")
def root():
    if first_startup:
        msg = "Did first startup"
    else:
        msg = "Did not do first startup"
    return {"message": f"Nirvana backend is running: {msg}"}

@app.get("/get-folders", response_model=Folders)
def get_folders():
    """
    This is called at the start of the flutter app to get folders or when folders is updated
    """
    folders = load_folders_from_db()
    return Folders(local_folders=folders)

@app.post("/add-folder")
async def add_folders(request: FolderRequest):
    new_folder = request.folder
    add_folder_to_db(new_folder)
    _ = scan_folder(new_folder)

    return {"message": "Folder added successfully"}

@app.post("/add-playlist")
async def add_playlist(name: str):
    add_playlist_db(name)

    return {"message" : "Playlist added successfully"}

@app.post("/add-song-to-playlist")
async def add_song_to_playlist(request: AddSongRequest):
    if add_song_to_playlist_db(request.playlist_id, request.song_id):
        return {"message" : "Song added to playlist successfully"}
    
    return {"message" : "Song already exists in playlist"}

@app.post("/add-to-recents")
def add_song_to_recents(id: str):
    add_song_to_recents_db(song_id=id)

@app.post("/delete-playlist")
async def delete_playlist(id: int):
    delete_playlist_db(id)
    return {
        "success" : True,
        "message" : "Playlist Deleted"
    }


@app.post("/remove-folder")
async def remove_folder(request: FolderRequest):
    folder = request.folder
    deactivate_folder(folder)


    return {"message": "Folder added successfully"}

@app.post("/rescan")
async def rescan():

    scanned_folders = load_folders_from_db()
    all_seen_ids = set()

    for folder in scanned_folders:
        all_seen_ids.update(scan_folder(folder))
    
    cleanup_removed_songs(all_seen_ids)

@app.get("/get-album-of-the-day", response_model=Album)
def send_album_of_the_day():
    albums = get_albums_from_db()
    return get_album_of_the_day(albums)

@app.get("/get-albums-for-you", response_model=List[Album])
def send_albums_for_you():
    albums = get_albums_from_db()
    return get_top_albums(albums)

@app.get("/get-artists-for-you", response_model=List[Artist])
def send_artists_for_you():
    artists = get_artists_from_db()
    return get_top_artists(artists)

@app.get("/get-all-songs", response_model=List[AudioFile])
def send_all_songs():
    return get_songs_from_db()

@app.get("/get-recents", response_model=List[AudioFile])
def send_recents():
    return get_recents_db()

@app.get("/get-all-artists", response_model=List[Artist])
def send_all_artist():
    return get_artists_from_db()

@app.get("/get-all-albums", response_model=List[Album])
def send_all_albums():
    return get_albums_from_db()

@app.get("/get-core-playlists", response_model=List[Playlist])
def send_core_playlists():
    return load_core_playlists_db()

@app.get("/get-album-songs", response_model=List[AudioFile])
def send_album_songs(id: str):
    return get_album_songs(id)

@app.get("/get-artist-songs", response_model=List[AudioFile])
def send_artist_songs(id: str):
    return get_artist_songs(id)

@app.get("/get-artist-albums", response_model=List[Album])
def send_artist_albums(id: str):
    return get_artist_albums(id)

@app.get("/get-artist", response_model=Artist)
def send_artist(id: str):
    return get_artist(id)

@app.get("/get-album", response_model=Album)
def send_album(id: str):
    return get_album(id)

@app.get("/get-lyrics", response_model=LyricsFrame)
def send_lyrics(path: str):
    return get_lyrics(path)

@app.get("/get-yt-results")
def send_search_results(q: str):
    return get_yt_search(q)

@app.get("/stream/{video_id}")
def send_stream_info(video_id: str):
    return get_stream_url(video_id)

@app.post("/download", response_model=ApiResponse)
async def download(song: OnlineTrack):
    return download_song(song)

@app.get('/get-last-playlist', response_model=Playlist)
def send_last_playlist():
    return get_last_playlist_db()

@app.get("/get-user-playlists", response_model=List[Playlist])
def send_user_playlists():
    return get_user_playlists_db()

@app.get("/get-playlist-songs", response_model=List[AudioFile])
def send_album_songs(id: int):
    return get_playlist_songs(id)

# @app.websocket("/ws/download")
# async def websocket_download(websocket: WebSocket):
#     await websocket.accept()

#     data = await websocket.receive_json()
#     song = data["song"]

#     def progress_hook(d):
#         if d['status'] == 'downloading':
#             percent = d.get('_percent_str', '0%').replace('%', '')
#             asyncio.create_task(websocket.send_text(json.dumps({
#                 "stage": "downloading",
#                 "progress": float(percent)
#             })))
#         elif d['status'] == 'finished':
#             asyncio.create_task(websocket.send_text(json.dumps({
#                 "stage": "processing",
#                 "progress": 100
#             })))

#     download_song(song,progress_hook)

#     await websocket.send_json({"stage": "done", "progress": 100})
#     await websocket.close()

@app.post("/start-download")
def start_download( background_tasks: BackgroundTasks, song: OnlineTrack):
    # song = request.song
    print(song )
    job_id = str(time.time())  # simple ID
    progress_tracker[job_id] = 0
    background_tasks.add_task(download_song, song, job_id, progress_tracker)
    return {"job_id": job_id}

@app.get("/progress/{job_id}")
def get_progress(job_id: str):
    return {"progress": progress_tracker.get(job_id, 0)}
