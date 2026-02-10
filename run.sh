#!/bin/bash
cd "$(dirname "$0")"

# Kill all running instances
pkill -f "LauncherHub.app" 2>/dev/null
killall LauncherHub 2>/dev/null
sleep 0.3

if [ ! -d "./LauncherHub.app" ]; then
    echo "App not found. Building first..."
    ./build.sh
fi

echo "Running LauncherHub.app..."
open ./LauncherHub.app
