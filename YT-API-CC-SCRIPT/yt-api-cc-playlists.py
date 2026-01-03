#!/usr/bin/env python3

import os
from googleapiclient.discovery import build
from dotenv import load_dotenv



load_dotenv('../.ENV')
API_KEY = os.getenv('YOUTUBE_API_KEY')

if not API_KEY:
    print("Error: YOUTUBE_API_KEY not found in .ENV file")
    exit(1)

# Initialize YouTube API client
youtube = build('youtube', 'v3', developerKey=API_KEY)


def test_api_connection():
    print("Testing YouTube API connection...")
    try:
        test_response = youtube.search().list(
            part='id',
            type='playlist',
            maxResults=1,
            q='music'
        ).execute()
        print("API key is valid and working!")
        return True
    except Exception as e:
        print(f"API connection failed: {e}")
        return False


# Test API connection
if not test_api_connection():
    print("\nExiting due to API connection failure...")
    exit(1)


# Load existing video IDs from cc_urls.txt
print("\nLoading existing URLs from cc_urls.txt...")
cc_video_ids = set()
output_file = 'cc_urls.txt'

if os.path.exists(output_file):
    with open(output_file, 'r') as f:
        for line in f:
            line = line.strip()
            if 'youtube.com/watch?v=' in line:
                video_id = line.split('v=')[-1]
                cc_video_ids.add(video_id)
    print(f"Loaded {len(cc_video_ids)} existing video IDs")
else:
    print("No existing file found")

initial_count = len(cc_video_ids)
quota_used = 100
QUOTA_LIMIT = 9500

# Search keywords for playlists
playlist_keywords = [
    'Public Domain Playlist',
    'DMCA free playlist',
    'License Free Playlist',
    'free to use playlist',
    'Monetization Safe Playlist'
    'No Copyright Playlist',
    # 'Creative Commons Playlist', used - nothing
    # 'Copyright Free Playlist', used - nothing left
    # 'Royalty Free Playlist'  used - nothing left
]

print(f"\nSearching playlists with {len(playlist_keywords)} keywords...")
print()

playlists_processed = 0
new_cc_videos = 0

# For each playlist found per keyword search check for CC videos and add them to the set
for keyword in playlist_keywords:
    if quota_used >= QUOTA_LIMIT:
        print("\nQuota limit reached")
        break

    print(f"Keyword: '{keyword}'")
    try:
        response = youtube.search().list(
            part='id',
            type='playlist',
            maxResults=50,
            q=keyword
        ).execute()
        quota_used += 100

        playlists = response.get('items', [])
        print(f"  Found {len(playlists)} playlists | Quota: {QUOTA_LIMIT-quota_used} remaining")

        for playlist_item in playlists:
            if quota_used >= QUOTA_LIMIT:
                break

            playlist_id = playlist_item['id']['playlistId']
            playlists_processed += 1

            playlist_video_ids = []
            next_page_token = None

            while quota_used < QUOTA_LIMIT:
                try:
                    response = youtube.playlistItems().list(
                        part='snippet',
                        playlistId=playlist_id,
                        maxResults=50,
                        pageToken=next_page_token
                    ).execute()
                    quota_used += 1

                    items = response.get('items', [])
                    for item in items:
                        try:
                            video_id = item['snippet']['resourceId']['videoId']
                            playlist_video_ids.append(video_id)
                        except KeyError:
                            continue

                    next_page_token = response.get('nextPageToken')
                    if not next_page_token:
                        break

                except Exception as e:
                    print(f"    Error extracting videos: {e}")
                    break

            playlist_cc_count = 0
            for i in range(0, len(playlist_video_ids), 50):
                if quota_used >= QUOTA_LIMIT:
                    break

                batch = playlist_video_ids[i:i+50]
                try:
                    response = youtube.videos().list(
                        part='status',
                        id=','.join(batch)
                    ).execute()
                    quota_used += 1

                    for video in response.get('items', []):
                        try:
                            if video['status']['license'] == 'creativeCommon':
                                video_id = video['id']
                                if video_id not in cc_video_ids:
                                    new_cc_videos += 1
                                    playlist_cc_count += 1
                                cc_video_ids.add(video_id)
                        except KeyError:
                            continue

                except Exception as e:
                    print(f"    Error verifying licenses: {e}")
                    continue

            if playlist_cc_count > 0:
                print(f"  Playlist #{playlists_processed}: +{playlist_cc_count} CC videos | Total: {len(cc_video_ids)} | Quota: {QUOTA_LIMIT-quota_used}")

    except Exception as e:
        print(f"  Error: {e}")
        continue

    print()


print(f"Saving to {output_file}...")
with open(output_file, 'w') as f:
    for video_id in sorted(cc_video_ids):
        f.write(f"https://youtube.com/watch?v={video_id}\n")

print(f"Initial videos: {initial_count}")
print(f"New CC videos found: {len(cc_video_ids) - initial_count}")
print(f"Total unique CC videos: {len(cc_video_ids)}")
print(f"Efficiency: {len(cc_video_ids) / quota_used:.2f} videos per quota unit")
print(f"URLs saved to: {output_file}")
