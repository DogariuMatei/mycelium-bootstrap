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
            type='video',
            videoLicense='creativeCommon',
            maxResults=1,
            q='*'
        ).execute()

        print("API key is valid and working!")
        return True

    except Exception as e:
        print(f"API connection failed: {e}")
        return False

# First test the API connection
if not test_api_connection():
    print("\nExiting due to API connection failure....")
    exit(1)

# Load existing video IDs from file
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

quota_used = 100  # from connection test
QUOTA_LIMIT = 10000

# Search keywords - this sucks
search_keywords = [
    '*',
    'No Copyright',
    'Creative Commons',
    'Copyright Free',
    'Royalty Free',
    'CC BY',
    'CC0',
    'Free Music',
    'NCS',
]

print("\nStarting Creative Commons video collection...")
print(f"Search using {len(search_keywords)} different keywords")
print()

# Try different keywords
for keyword in search_keywords:
    if quota_used >= QUOTA_LIMIT:
        break

    print(f"Searching with keyword: '{keyword}'")
    next_page_token = None

    # Paginate through results
    while quota_used < QUOTA_LIMIT:
        try:
            response = youtube.search().list(
                part='id',
                type='video',
                videoLicense='creativeCommon',
                maxResults=50,
                pageToken=next_page_token,
                q=keyword
            ).execute()

            quota_used += 100

            items = response.get('items', [])
            print(f"  Got {len(items)} results | Total unique: {len(cc_video_ids)} | Quota: {QUOTA_LIMIT-quota_used} remaining")

            # Add ids to set
            for item in items:
                video_id = item['id']['videoId']
                cc_video_ids.add(video_id)

            # Get next page token
            next_page_token = response.get('nextPageToken')
            if not next_page_token:
                print(f"  Finished with '{keyword}'")
                break

        except Exception as e:
            print(f"  Error: {e}")
            break

    print()

print()
print(f"!Requests finished!")
print(f"Unique videos: {len(cc_video_ids)}")
print(f"Quota used: {quota_used}")

# Convert to URLs and write to file
output_file = 'cc_urls.txt'
with open(output_file, 'w') as f:
    for video_id in sorted(cc_video_ids):
        url = f"https://youtube.com/watch?v={video_id}"
        f.write(url + '\n')

print(f"URLs saved to: {output_file}")
