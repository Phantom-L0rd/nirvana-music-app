import datetime
import hashlib
import sqlite3
import os
from typing import List

from app.models import Album, Artist, AudioFile, Playlist

DB_PATH = os.path.join(os.path.dirname(__file__), "../nirvana.db")

def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON;")
    return conn

def hash_string(base):
    return hashlib.md5(base.encode("utf-8")).hexdigest()

def initialize_db():
    conn = get_connection()
    cursor = conn.cursor()
    
    # folders table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT UNIQUE NOT NULL,
        active BOOLEAN DEFAULT 1
    );
    """)

    # artists table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS artists (
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        artwork TEXT
    );
    """)

    # albums table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS albums (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        artist_id TEXT NOT NULL,
        year INTEGER,
        genre TEXT,
        album_art_path TEXT,
        FOREIGN KEY (artist_id) REFERENCES artists(id) ON DELETE CASCADE
    );
    """)

    # songs table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS songs (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        file_path TEXT UNIQUE NOT NULL,
        duration INTEGER,
        artist_id TEXT NOT NULL,
        album_id TEXT NOT NULL,
        track_number INTEGER,
        FOREIGN KEY (artist_id) REFERENCES artists(id) ON DELETE CASCADE,
        FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE
    );
    """)

    # folder songs table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS folder_songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id TEXT NOT NULL,
        folder_id INTEGER NOT NULL,
        added_at TIMESTAMP NOT NULL,
        FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE,
        FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE CASCADE,
        UNIQUE(song_id, folder_id)
    );
    """)

    # recently played table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS recently_played (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id TEXT NOT NULL,
        played_at TEXT NOT NULL,
        FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE
    );
    """)


    # playlists table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        is_system BOOLEAN NOT NULL DEFAULT 0,
        cover_art TEXT,
        created_at TIMESTAMP NOT NULL
    );
    """)

    # playlist_songs join table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS playlist_songs (
        playlist_id INTEGER NOT NULL,
        song_id TEXT NOT NULL,
        time_added TIMESTAMP NOT NULL,
        PRIMARY KEY (playlist_id, song_id),
        FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
        FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE
    );
    """)

    # app settings table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
    );
    """)

    # initialize default setting
    cursor.execute("""
        INSERT OR IGNORE INTO app_settings (key, value)
        VALUES ('first_startup', '1')
    """)

    # insert system playlists if they don’t already exist
    system_playlists = [
        ("All Songs", 1),
        ("Favourites", 1),
        ("Downloads", 1),
        ("Recently Played", 1)
    ]

    for name, is_system in system_playlists:
        cursor.execute("""
            INSERT INTO playlists (name, is_system, created_at)
            SELECT ?, ?, datetime('now')
            WHERE NOT EXISTS (
                SELECT 1 FROM playlists WHERE name = ?
            )
        """, (name, is_system, name))

    conn.commit()
    conn.close()


def is_first_startup():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT value FROM app_settings WHERE key = 'first_startup'")
    row = cursor.fetchone()

    conn.close()
    return row is None or row[0] == "1"

def add_folder_to_db( folder: str):
    conn = get_connection()
    cursor = conn.cursor()

    # Handles both "new folder" (insert) and "reactivating folder" (update) in one query
    cursor.execute("""
        INSERT INTO folders (path, active)
        VALUES (?, 1)
        ON CONFLICT(path) DO UPDATE SET active = 1
    """, (folder,))

    conn.commit()
    conn.close()

def deactivate_folder(folder: str):
    conn = get_connection()
    cursor = conn.cursor()
    print(folder)
    cursor.execute("""
        UPDATE folders SET active = 0 WHERE path = ?
    """, (folder,))

    conn.commit()
    conn.close()

def mark_startup_complete():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT OR REPLACE INTO app_settings (key, value)
        VALUES ('first_startup', '0')
    """)
    conn.commit()
    conn.close()

def load_folders_from_db() -> List[str]:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT path FROM folders WHERE active = 1 ")
    rows = cursor.fetchall()

    conn.close()

    return[row[0] for row in rows]

def get_or_create_artist(name: str) -> str:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT id FROM artists WHERE name = ?", (name,))
    row = cursor.fetchone()
    if row:
        conn.close()
        return row[0]
    
    unique_id = hash_string(name.strip().lower())
    cursor.execute("INSERT INTO artists (id, name) VALUES (?, ?)", (unique_id,name))
    conn.commit()
    conn.close()
    return unique_id


def get_or_create_album(title: str, artist_id: str, artist_name: str, year: int = None, genre: str =None, album_art_path: str = None) -> str:
 
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id FROM albums WHERE title = ? AND artist_id = ?
    """, (title, artist_id))
    row = cursor.fetchone()
    if row:
        conn.close()
        return row[0]
    

    unique_id = hash_string(f"{title.strip().lower()}|{artist_name.strip().lower()}|{year or ''}")
    cursor.execute("""
        INSERT INTO albums (id, title, artist_id, year, genre, album_art_path)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (unique_id, title, artist_id, year, genre, album_art_path))
    
    conn.commit()
    conn.close()
    return unique_id


def insert_song(id,full_path,duration,artist,title,album,cover_art,year,track_num,date_added, folder: str):
    

    # 1. Ensure artist
    artist_id = get_or_create_artist(artist or "Unknown Artist")
    # print("here", artist, artist_id)
    # 2. Ensure album
    album_id = get_or_create_album(
        title=album or "Unknown Album",
        artist_id=artist_id,
        artist_name=artist or "Unknown Artist",
        year=year,
        album_art_path=cover_art
    )
    # print("here", album, album_id)
    conn = get_connection()
    cursor = conn.cursor()
    
    # 3. Insert song
    cursor.execute("""
        INSERT INTO songs
            (id, title, file_path, duration, artist_id, album_id, track_number)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
            title = excluded.title,
            file_path = excluded.file_path,
            duration = excluded.duration,
            artist_id = excluded.artist_id,
            album_id = excluded.album_id,
            track_number = excluded.track_number
    """, (
        id,
        title,
        full_path,
        duration,
        artist_id,
        album_id,
        track_num,
    ))

    # print(folder[:-1])
    # 4. get folder id
    cursor.execute("SELECT id FROM folders WHERE path = ?", (folder,))
    folder_id = cursor.fetchone()[0]

    # 5. Link song to folder
    cursor.execute("""
        INSERT OR IGNORE INTO folder_songs (song_id, folder_id, added_at)
        VALUES (?, ?, ?)
    """, (id, folder_id, date_added))

    conn.commit()
    conn.close()

def cleanup_removed_songs(all_seen_ids: set[str]):
    conn = get_connection()
    cursor = conn.cursor()

    # Get all songs linked to active folders
    cursor.execute("""
        SELECT s.id, s.file_path
        FROM songs s
        JOIN folder_songs fs ON s.id = fs.song_id
        JOIN folders f ON fs.folder_id = f.id
        WHERE f.active = 1
    """)
    db_songs = cursor.fetchall()

    for song_id, file_path in db_songs:
        if song_id not in all_seen_ids or not os.path.exists(file_path):
            # Soft-remove: unlink from folder_songs, keep song for history
            cursor.execute("DELETE FROM folder_songs WHERE song_id = ?", (song_id,))

    conn.commit()
    conn.close()


def get_artists_from_db() -> List[Artist]:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT ar.id, ar.name, ar.artwork
        FROM songs s
        JOIN folder_songs fs ON s.id = fs.song_id
        JOIN folders f ON fs.folder_id = f.id
        JOIN artists ar ON s.artist_id = ar.id
        WHERE f.active = 1
        GROUP BY ar.id
        ORDER BY ar.name
    """)
    rows = cursor.fetchall()

    artists = []
    for row in rows:
        artists.append(
            Artist(
                id=row[0],
                name=row[1],
                artwork=row[2]
            )
        )
    
    conn.close()
    return artists

def get_albums_from_db() -> List[Album]:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT al.id, al.title, al.artist_id, ar.name, ar.artwork, al.album_art_path, al.year, al.genre
        FROM songs s
        JOIN folder_songs fs ON s.id = fs.song_id
        JOIN folders f ON fs.folder_id = f.id
        JOIN artists ar ON s.artist_id = ar.id
        JOIN albums al ON s.album_id = al.id
        WHERE f.active = 1
        GROUP BY al.id
        ORDER BY al.title
    """)
    rows = cursor.fetchall()

    albums = []
    for row in rows:
        albums.append(
            Album(
                id=row[0],
                name=row[1],
                artist=Artist(
                    id=row[2],
                    name=row[3],
                    artwork=row[4]
                ),
                cover_art=row[5],
                year=row[6],
                genre=row[7]
            )
        )
    
    conn.close()
    return albums


def get_songs_from_db() -> List[AudioFile]:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        WITH playlist_ids_cte AS (
            SELECT song_id, group_concat(playlist_id ORDER BY playlist_id, ', ') AS playlist_ids FROM playlist_songs
            GROUP BY song_id
        )
        SELECT 
            s.id,
            s.file_path,
            s.duration,
            s.artist_id,
            ar.name AS artist,
            ar.artwork,
            s.title,
            s.album_id,
            al.title AS album,
            al.album_art_path AS cover_art,
            al.year,
            al.genre,
            s.track_number,
            MIN(fs.added_at) AS added_at,
            pic.playlist_ids
        FROM songs s
        JOIN artists ar ON s.artist_id = ar.id
        LEFT JOIN albums al ON s.album_id = al.id
        JOIN folder_songs fs ON s.id = fs.song_id
        JOIN folders f ON fs.folder_id = f.id
        LEFT JOIN playlist_ids_cte pic ON s.id = pic.song_id
        WHERE f.active = 1
        GROUP BY s.id
        ORDER BY s.title;
    """)

    rows = cursor.fetchall()

    songs = []
    for row in rows:
        songs.append(AudioFile(
            id=row[0],
            full_path=row[1], 
            duration=row[2],  
            title=row[6],
            album=Album(
                id=row[7],
                name=row[8],
                artist=Artist(
                    id=row[3],
                    name=row[4],
                    artwork=row[5]
                ),
                cover_art=row[9],
                year=row[10],
                genre=row[11]
            ), 
            trackNum=row[12],
            date_added=row[13],
            playlist_ids= list(map(int,row[14].split(','))) if row[14] else None
        ))

    conn.close()
    return songs

def get_artist(id: str) -> Artist:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT ar.id, ar.name, ar.artwork
    FROM songs s
    JOIN folder_songs fs ON s.id = fs.song_id
    JOIN folders f ON fs.folder_id = f.id
    JOIN artists ar ON s.artist_id = ar.id
    WHERE f.active = 1 AND ar.id = ?
    GROUP BY ar.id;
    """,(id,))

    result = cursor.fetchone()

    conn.close()

    if result:
        return Artist(
            id=result[0],
            name=result[1],
            artwork=result[2]
        )
    return Artist(id='',name='')

def get_album(id: str) -> Artist:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT al.id, al.title, al.artist_id, ar.name, ar.artwork, al.album_art_path, al.year, al.genre
    FROM songs s
    JOIN folder_songs fs ON s.id = fs.song_id
    JOIN folders f ON fs.folder_id = f.id
    JOIN artists ar ON s.artist_id = ar.id
    JOIN albums al ON s.album_id = al.id
    WHERE f.active = 1 AND al.id = ?
    GROUP BY al.id;
    """,(id,))

    result = cursor.fetchone()

    conn.close()

    if result:
        return Album(
            id=result[0],
            name=result[1],
            artist=Artist(
                id=result[2],
                name=result[3],
                artwork=result[4]
            ),
            cover_art=result[5],
            year=result[6],
            genre=result[7]
        )
    return Album(id='',artist=Artist(id='',name=''),name='')

def load_core_playlists_db() -> List[Playlist]:
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, name, cover_art, created_at FROM playlists WHERE is_system = 1 ORDER BY id")
    rows = cursor.fetchall()

    playlists = []
    for row in rows:
        playlist_id, name, artwork, created = row

        # Case 1: "All Songs"
        if playlist_id == 1:
            cursor.execute("""
                SELECT album_art_path
                FROM albums
                LIMIT 4;
            """)
            rs = cursor.fetchall()
            playlists.append(Playlist(
                id=playlist_id,
                name=name,
                created_at=created,
                artwork=[r[0] for r in rs]
            ))

        # Case 2: Core system playlists (liked, downloaded, recent) — no artwork
        elif playlist_id in (2, 3, 4):
            playlists.append(Playlist(id=playlist_id, name=name, created_at=created))

        # Case 3: Other system playlists with no artwork — generate
        elif playlist_id >= 5 and artwork is None:
            cursor.execute("""
                SELECT s.cover_art
                FROM playlist_songs p
                JOIN songs s ON p.song_id = s.id
                WHERE p.playlist_id = ?
                LIMIT 4;
            """, (playlist_id,))
            rs = cursor.fetchall()
            playlists.append(Playlist(
                id=playlist_id,
                name=name,
                created_at=created,
                artwork=[r[0] for r in rs]
            ))

        # Case 4: Artwork already exists — use it
        else:
            playlists.append(Playlist(id=playlist_id, name=name, artwork=[artwork]))

    conn.close()
    return playlists

def get_album_songs(id: str) -> List[AudioFile]:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        WITH playlist_ids_cte AS (
            SELECT song_id, group_concat(playlist_id ORDER BY playlist_id, ', ') AS playlist_ids FROM playlist_songs
            GROUP BY song_id
        )
        SELECT 
            s.id,
            s.file_path,
            s.duration,
            s.artist_id,
            ar.name AS artist,
            ar.artwork,
            s.title,
            s.album_id,
            al.title AS album,
            al.album_art_path AS cover_art,
            al.year,
            al.genre,
            s.track_number,
            MIN(fs.added_at) AS added_at,
            pic.playlist_ids
        FROM songs s
        JOIN folder_songs fs ON s.id = fs.song_id
        JOIN folders f ON fs.folder_id = f.id
        JOIN artists ar ON s.artist_id = ar.id
        JOIN albums al ON s.album_id = al.id
        LEFT JOIN playlist_ids_cte pic ON s.id = pic.song_id
        WHERE f.active = 1 AND s.album_id = ?
        GROUP BY s.id;
    """, (id,))

    rows = cursor.fetchall()

    songs = []
    for row in rows:
        songs.append(AudioFile(
            id=row[0],
            full_path=row[1], 
            duration=row[2],
            title=row[6],
            album=Album(
                id=row[7],
                name=row[8],
                artist=Artist(
                    id=row[3],
                    name=row[4],
                    artwork=row[5]
                ),
                cover_art=row[9],
                year=row[10],
                genre=row[11]
            ), 
            trackNum=row[12],
            date_added=row[13],
            playlist_ids= list(map(int,row[14].split(',')))  if row[14] else None
        ))

    conn.close()
    return songs


def get_artist_songs(id: str) -> List[AudioFile]:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        WITH playlist_ids_cte AS (
            SELECT song_id, group_concat(playlist_id ORDER BY playlist_id, ', ') AS playlist_ids FROM playlist_songs
            GROUP BY song_id
        )
        SELECT 
            s.id,
            s.file_path,
            s.duration,
            s.artist_id,
            ar.name AS artist,
            ar.artwork,
            s.title,
            s.album_id,
            al.title AS album,
            al.album_art_path AS cover_art,
            al.year,
            al.genre,
            s.track_number,
            MIN(fs.added_at) AS added_at,
            pic.playlist_ids
        FROM songs s
        JOIN folder_songs fs ON s.id = fs.song_id
        JOIN folders f ON fs.folder_id = f.id
        JOIN artists ar ON s.artist_id = ar.id
        JOIN albums al ON s.album_id = al.id
        LEFT JOIN playlist_ids_cte pic ON s.id = pic.song_id
        WHERE f.active = 1 AND s.artist_id = ?
        GROUP BY s.id;
    """, (id,))

    rows = cursor.fetchall()

    songs = []
    for row in rows:
        songs.append(AudioFile(
            id=row[0],
            full_path=row[1], 
            duration=row[2],  
            title=row[6],
            album=Album(
                id=row[7],
                name=row[8],
                artist=Artist(
                    id=row[3],
                    name=row[4],
                    artwork=row[5]
                ),
                cover_art=row[9],
                year=row[10],
                genre=row[11]
            ), 
            trackNum=row[12],
            date_added=row[13],
            playlist_ids=list(map(int,row[14].split(','))) if row[14] else None
        ))

    conn.close()
    return songs


def get_artist_albums(id: str) -> List[Album]:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT 
        al.id,
        al.title,
        al.artist_id,
        ar.name,
        ar.artwork,
        al.album_art_path,
        al.year,
        al.genre
    FROM songs s
    JOIN folder_songs fs ON s.id = fs.song_id
    JOIN folders f ON fs.folder_id = f.id
    JOIN artists ar ON s.artist_id = ar.id
    JOIN albums al ON s.album_id = al.id
    WHERE f.active = 1 AND s.artist_id = ?
    GROUP BY s.album_id;
    """, (id,))

    rows = cursor.fetchall()

    albums = []
    for row in rows:
        albums.append(
            Album(
                id=row[0],
                name=row[1],
                artist=Artist(
                    id=row[2],
                    name=row[3],
                    artwork=row[4]
                ),
                cover_art=row[5],
                year=row[6],
                genre=row[7]
            )
        )
    
    conn.close()
    return albums

def add_playlist_db(name: str):
    conn = get_connection()
    cursor = conn.cursor()

    time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    cursor.execute("""
        INSERT INTO playlists (name, created_at)
        VALUES (?, ?)
    """, (name, time))
    conn.commit()
    conn.close()

def add_song_to_playlist_db(playlist_id: int, song_id: str) -> bool:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT * FROM playlist_songs WHERE playlist_id = ? AND song_id = ?
    """, (playlist_id,song_id))
    row = cursor.fetchone()
    if row:
        conn.close()
        return False
    
    time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    cursor.execute("""
        INSERT OR IGNORE INTO playlist_songs (playlist_id, song_id, time_added)
        VALUES (?, ?, ?)
    """, (playlist_id, song_id, time))

    conn.commit()
    conn.close()
    return True

def add_song_to_recents_db(song_id: str):
    conn = get_connection()
    cursor = conn.cursor()
    
    time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    cursor.execute("""
        INSERT INTO recently_played (song_id, played_at)
        VALUES (?, ?)
    """, (song_id, time))

    conn.commit()
    conn.close()



def get_last_playlist_db() -> Playlist:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT * FROM playlists ORDER BY id DESC LIMIT 1
    """)

    row_last = cursor.fetchone()
    conn.close()
    return Playlist(
        id=row_last[0],
        name=row_last[1],
        is_system=row_last[2],
        created_at=row_last[4],
        artwork= [row_last[3]] if row_last[3] else None
    )

def get_user_playlists_db()-> List[Playlist]:
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM playlists WHERE is_system = 0 ORDER BY id DESC")
    rows = cursor.fetchall()

    playlists = []
    for row in rows:
        playlist_id, name, is_system, artwork,created_at = row

        playlists.append(Playlist(
            id=playlist_id,
            name=name,
            is_system=is_system,
            created_at=created_at,
            artwork=[artwork] if artwork else None
        ))
    
    conn.close()
    return playlists


def get_playlist_songs(id: int) -> List[AudioFile]:
    conn = get_connection()
    cursor = conn.cursor()
 
    cursor.execute("""
        WITH playlist_ids_cte AS (
            SELECT song_id, group_concat(playlist_id ORDER BY playlist_id, ', ') AS playlist_ids FROM playlist_songs
            GROUP BY song_id
        )
        SELECT 
            s.id,
            s.file_path,
            s.duration,
            s.artist_id,
            ar.name AS artist,
            ar.artwork,
            s.title,
            s.album_id,
            al.title AS album,
            al.album_art_path AS cover_art,
            al.year,
            al.genre,
            s.track_number,
            MIN(ps.time_added) AS added_at,
            pic.playlist_ids
        FROM playlist_songs ps
        JOIN songs s ON s.id = ps.song_id
        JOIN folder_songs fs ON s.id = fs.song_id
        JOIN folders f ON fs.folder_id = f.id
        JOIN artists ar ON s.artist_id = ar.id
        JOIN albums al ON s.album_id = al.id
        LEFT JOIN playlist_ids_cte pic ON s.id = pic.song_id
        WHERE f.active = 1 AND ps.playlist_id = ?
        GROUP BY ps.song_id;
    """, (id,))

    rows = cursor.fetchall()

    songs = []
    for row in rows:
        songs.append(AudioFile(
            id=row[0],
            full_path=row[1], 
            duration=row[2],
            title=row[6],
            album=Album(
                id=row[7],
                name=row[8],
                artist=Artist(
                    id=row[3],
                    name=row[4],
                    artwork=row[5]
                ),
                cover_art=row[9],
                year=row[10],
                genre=row[11]
            ), 
            trackNum=row[12],
            date_added=row[13],
            playlist_ids= list(map(int,row[14].split(','))) if row[14] else None
        ))

    conn.close()
    return songs


def delete_playlist_db(id: int):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        DELETE FROM playlists WHERE id = ?
    """, (id,))

    conn.commit()
    conn.close


def get_recents_db() -> List[AudioFile]:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        WITH playlist_ids_cte AS (
            SELECT song_id, group_concat(playlist_id ORDER BY playlist_id, ', ') AS playlist_ids FROM playlist_songs
            GROUP BY song_id
        )
        SELECT 
            s.id,
            s.file_path,
            s.duration,
            s.artist_id,
            ar.name AS artist,
            ar.artwork,
            s.title,
            s.album_id,
            al.title AS album,
            al.album_art_path AS cover_art,
            al.year,
            al.genre,
            s.track_number,
            MIN(fs.added_at) AS added_at,
            pic.playlist_ids
        FROM songs s
        JOIN artists ar ON s.artist_id = ar.id
        LEFT JOIN albums al ON s.album_id = al.id
        JOIN folder_songs fs ON s.id = fs.song_id
        JOIN folders f ON fs.folder_id = f.id
        LEFT JOIN playlist_ids_cte pic ON s.id = pic.song_id
        JOIN recently_played rp ON s.id = rp.song_id
        WHERE f.active = 1
        GROUP BY rp.id
        ORDER BY rp.id DESC
        LIMIT 50;
    """)

    rows = cursor.fetchall()

    songs = []
    for row in rows:
        songs.append(AudioFile(
            id=row[0],
            full_path=row[1], 
            duration=row[2],  
            title=row[6],
            album=Album(
                id=row[7],
                name=row[8],
                artist=Artist(
                    id=row[3],
                    name=row[4],
                    artwork=row[5]
                ),
                cover_art=row[9],
                year=row[10],
                genre=row[11]
            ), 
            trackNum=row[12],
            date_added=row[13],
            playlist_ids= list(map(int,row[14].split(','))) if row[14] else None
        ))

    conn.close()
    return songs
