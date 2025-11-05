#!/bin/bash
# Simple script to fetch URL with cookie handling
# Usage: ./fetch-url.sh <url>

URL="${1:-https://www.tiwall.com/p/kaa}"

# Fetch with cookie handling
curl -sL \
  -c /tmp/cookies_$$.txt \
  -b /tmp/cookies_$$.txt \
  -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36" \
  "$URL"

# Cleanup
rm -f /tmp/cookies_$$.txt

