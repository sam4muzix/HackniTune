#!/bin/bash
set -e

echo "Cleaning up..."
rm -rf HackinTune.app HackinTune_Native.zip HackinTune HackinTune.icns HackinTune.iconset masked_icon.png IconProcessor

echo "1. Building Icon Processor & Masking Icon..."
swiftc IconProcessor.swift -o IconProcessor
./IconProcessor icon_source.png masked_icon.png

echo "2. Compiling Main App..."
swiftc -parse-as-library HackinTune.swift -o HackinTune

echo "3. Creating Bundle Structure..."
mkdir -p HackinTune.app/Contents/MacOS
mkdir -p HackinTune.app/Contents/Resources

echo "4. Installing Binary & Assets..."
mv HackinTune HackinTune.app/Contents/MacOS/
chmod +x HackinTune.app/Contents/MacOS/HackinTune
cp qrcode.png HackinTune.app/Contents/Resources/
cp efi_builder.sh HackinTune.app/Contents/Resources/
chmod +x HackinTune.app/Contents/Resources/efi_builder.sh
cp Info.plist HackinTune.app/Contents/

echo "5. Generating & Installing Icon..."
sh make_icon.sh masked_icon.png
# Rename correctly for Native App (Info.plist expects HackinTune.icns)
mv HackinTune.app/Contents/Resources/applet.icns HackinTune.app/Contents/Resources/HackinTune.icns

echo "6. Packaging..."
zip -r HackinTune_Native.zip HackinTune.app

echo "Build Complete!"
