#!/usr/bin/env bash
touch .build/browser-dev-sync
browser-sync start -p localhost:8080 &

watchexec -w Sources -e .swift -r 'swift build --product twitch-chat-colors && touch .build/browser-dev-sync' &
watchexec -w .build/browser-dev-sync --ignore-nothing -r '.build/debug/twitch-chat-colors'
