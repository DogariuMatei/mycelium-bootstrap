#!/usr/bin/env python3
import libtorrent as lt
import time
import os
import glob


def create_torrent(file_path, tracker):
    torrent_file = file_path + ".torrent"

    if os.path.exists(torrent_file):
        return torrent_file

    fs = lt.file_storage()
    lt.add_files(fs, file_path)

    t = lt.create_torrent(fs)
    t.add_tracker(tracker)
    t.set_creator("Autonomous Seedbox v0.1")

    lt.set_piece_hashes(t, os.path.dirname(file_path))
    torrent = t.generate()

    with open(torrent_file, "wb") as f:
        f.write(lt.bencode(torrent))

    return torrent_file


def seed_all_torrents_from_directory(dir, tracker):
    ses = lt.session()
    ses.listen_on(6881, 6891)

    # configure session settings
    settings = ses.get_settings()
    settings['listen_interfaces'] = '0.0.0.0:6881'
    ses.apply_settings(settings)


    files = glob.glob(os.path.join(dir, "*"))
    files = [f for f in files if not f.endswith('.torrent')]

    # create torrent for each file + add to session
    handles = []
    for music_file in files:
        torrent_file = create_torrent(music_file, tracker)
        info = lt.torrent_info(torrent_file)
        h = ses.add_torrent({
            'ti': info,
            'save_path': os.path.dirname(music_file)
        })
        handles.append((h, os.path.basename(music_file)))

    if len(handles) == 0:
        print("ERROR: No files found to seed")

        return


    try:
        while True:
            os.system('clear' if os.name == 'posix' else 'cls')
            print(f"Seedbox Status: (Seeding {len(handles)} torrents)")
            print("-" * 50)

            total_upload = 0
            total_peers = 0

            for h, name in handles:
                s = h.status()
                total_upload += s.total_upload
                total_peers += s.num_peers

            print(f"\rTotal: {total_peers} peers | {total_upload / 1024 / 1024:.1f} MB uploaded", end='', flush=True)
            print(flush=True)
            print("-" * 50, flush=True)
            print("\nPress Ctrl+C to exit", end='', flush=True)
            time.sleep(2)


    except KeyboardInterrupt:
        print("\n\nStopping seedbox...")


if __name__ == "__main__":
    MUSIC_DIR = "/home/vagrant/music"
    TRACKER = "udp://tracker.opentrackr.org:1337/announce"
    seed_all_torrents_from_directory(MUSIC_DIR, TRACKER)