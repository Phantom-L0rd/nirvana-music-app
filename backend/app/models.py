from pydantic import BaseModel
from typing import Optional, List

class Artist(BaseModel):
    id: str
    name: str
    artwork: Optional[str] = None # leaving empty as of now, will later implement a better way to get artwork

class Album(BaseModel):
    id: str
    name: str
    artist: Artist
    cover_art: Optional[str] = None
    year: Optional[int] = None
    genre: Optional[str] = None

class AudioFile(BaseModel):
    id: str
    full_path: str
    duration: int
    title: str
    album: Album
    trackNum: Optional[int] = None
    date_added: Optional[str] = None
    playlist_ids: Optional[List[int]] = None
    is_local: Optional[bool] = True

class OnlineTrack(BaseModel):
    id: str
    lyrics_id: Optional[str] = None
    track_info: AudioFile

class OnlineSongRequest(BaseModel):
    song: OnlineTrack

class Playlist(BaseModel):
    id: int
    name: str
    is_system: bool = True
    created_at: str
    artwork: Optional[List[str]] = None


class Folders(BaseModel):
    local_folders: List[str]

class FolderRequest(BaseModel):
    folder: str

class IdRequest(BaseModel):
    id: str

class FoldersResponse(BaseModel):
    message: str
    received_folders_count: int
    folders: List[str]

class LyricLine(BaseModel):
    timestamp: int
    line: str

class LyricsFrame(BaseModel):
    has_timestamps: bool
    lyrics: List

class AddSongRequest(BaseModel):
    playlist_id: int
    song_id: str

class ApiResponse(BaseModel):
    success: bool
    message: str