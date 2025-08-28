#!/bin/bash

WEBHOOK_URL="Discord channel's webhook link goes here!"
IMAGE_URL=""
THUMBNAIL_URL="https://pbs.twimg.com/profile_images/1517537104645001217/cI1wdSJR_400x400.png"
TITLE="$1"
DESCRIPTION="$2"
COLOR="$3"  # decimal format (e.g., 3066993 = green, 3447003 = blue, 15105570 = orange, 15158332 = red, 16711680 = bright red)

# Current UTC timestamp in ISO 8601 format
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

json_payload=$(cat <<EOF
{
  "embeds": [{
    "title": "$TITLE",
    "description": "$DESCRIPTION",
    "color": $COLOR,
    "timestamp": "$TIMESTAMP",
    "footer": {
      "text": "7DTD Server Automatic Updates",
      "icon_url": "$THUMBNAIL_URL"
    },
    "thumbnail": {
      "url": "$THUMBNAIL_URL"
    },
    "image": {
      "url": "$IMAGE_URL"
    }
  }]
}
EOF
)

curl -H "Content-Type: application/json" \
     -X POST \
     -d "$json_payload" \
     "$WEBHOOK_URL"
