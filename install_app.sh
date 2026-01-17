#!/bin/bash
# Install HackinTune Native App

echo "Installing HackinTune v4.0 (Native)..."
cd /Users/jack/.gemini/antigravity/brain/505ce7bb-2fad-45be-8ce7-89f85fc3440f
unzip -o HackinTune_Native.zip
chmod +x HackinTune.app/Contents/MacOS/HackinTune
xattr -rc HackinTune.app

echo "Opening App..."
open HackinTune.app
echo "Done! Enjoy the new Single-Page Interface."
