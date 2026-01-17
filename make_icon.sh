#!/bin/bash
# Script to create .icns from a source image (Fixed)
# Usage: sh make_icon.sh <source_image>

SOURCE="$1"
ICONSET="HackinTune.iconset"
APP_NAME="HackinTune.app"

rm -rf "$ICONSET"
mkdir -p "$ICONSET"

echo "Resizing images..."
# Explicitly set format to png
sips -z 16 16     -s format png "$SOURCE" --out "$ICONSET/icon_16x16.png"
sips -z 32 32     -s format png "$SOURCE" --out "$ICONSET/icon_16x16@2x.png"
sips -z 32 32     -s format png "$SOURCE" --out "$ICONSET/icon_32x32.png"
sips -z 64 64     -s format png "$SOURCE" --out "$ICONSET/icon_32x32@2x.png"
sips -z 128 128   -s format png "$SOURCE" --out "$ICONSET/icon_128x128.png"
sips -z 256 256   -s format png "$SOURCE" --out "$ICONSET/icon_128x128@2x.png"
sips -z 256 256   -s format png "$SOURCE" --out "$ICONSET/icon_256x256.png"
sips -z 512 512   -s format png "$SOURCE" --out "$ICONSET/icon_256x256@2x.png"
sips -z 512 512   -s format png "$SOURCE" --out "$ICONSET/icon_512x512.png"
sips -z 1024 1024 -s format png "$SOURCE" --out "$ICONSET/icon_512x512@2x.png"

echo "Compiling icns..."
iconutil -c icns "$ICONSET" -o HackinTune.icns

if [ -f "HackinTune.icns" ]; then
    echo "Installing to $APP_NAME..."
    cp HackinTune.icns "$APP_NAME/Contents/Resources/applet.icns"
    touch "$APP_NAME"
    echo "Success! Icon updated."
    rm -rf "$ICONSET"
    rm HackinTune.icns
else
    echo "Error: Failed to create icns file."
    ls -R "$ICONSET"
fi
