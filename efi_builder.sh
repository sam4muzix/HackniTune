#!/bin/bash

# HacksInTune EFI Builder Script
# Arguments: 
# $1 = Destination Folder Name (e.g. HackinTune_EFI_Ultimate)
# $2 = Platform (intel_12_plus, intel_10_11, amd)
# $3 = WiFi Type (intel, none)

DEST_DIR="$HOME/Desktop/$1"
PLATFORM=${2:-intel_12_plus}
WIFI_TYPE=${3:-none}
TEMP_DIR="/tmp/hackintune_temp_$$"

# GitHub Release URLs
OC_URL="https://github.com/acidanthera/OpenCorePkg/releases/download/1.0.0/OpenCore-1.0.0-RELEASE.zip"
LILU_URL="https://github.com/acidanthera/Lilu/releases/download/1.6.7/Lilu-1.6.7-RELEASE.zip"
SMC_URL="https://github.com/acidanthera/VirtualSMC/releases/download/1.3.2/VirtualSMC-1.3.2-RELEASE.zip"
WEG_URL="https://github.com/acidanthera/WhateverGreen/releases/download/1.6.6/WhateverGreen-1.6.6-RELEASE.zip"
ALC_URL="https://github.com/acidanthera/AppleALC/releases/download/1.9.0/AppleALC-1.9.0-RELEASE.zip"

# WiFi URLs
ITLWM_URL="https://github.com/OpenIntelWireless/itlwm/releases/download/v2.3.0/AirportItlwm_v2.3.0_stable_Sonoma.kext.zip"
INTEL_BT_URL="https://github.com/OpenIntelWireless/IntelBluetoothFirmware/releases/download/v2.4.0/IntelBluetoothFirmware-v2.4.0.zip"

echo "Starting EFI Generation for $PLATFORM (WiFi: $WIFI_TYPE)..."
mkdir -p "$DEST_DIR"
mkdir -p "$TEMP_DIR"

# 1. Download & Extract OpenCore
echo "Downloading OpenCore..."
curl -L -o "$TEMP_DIR/oc.zip" "$OC_URL"
unzip -q "$TEMP_DIR/oc.zip" -d "$TEMP_DIR/oc"

# Move Base EFI Structure
echo "Assembling Base Configuration..."
cp -r "$TEMP_DIR/oc/X64/EFI" "$DEST_DIR/"

# 2. Download Kexts
KEXTS_DIR="$DEST_DIR/EFI/OC/Kexts"

download_kext() {
    NAME=$1
    URL=$2
    echo "Downloading $NAME..."
    curl -L -o "$TEMP_DIR/$NAME.zip" "$URL"
    unzip -q -o "$TEMP_DIR/$NAME.zip" -d "$TEMP_DIR/$NAME"
    
    # Find kext file recursively and copy
    find "$TEMP_DIR/$NAME" -name "*.kext" -maxdepth 2 -exec cp -r {} "$KEXTS_DIR/" \;
}

download_kext "Lilu" "$LILU_URL"
download_kext "VirtualSMC" "$SMC_URL"
download_kext "WhateverGreen" "$WEG_URL"
download_kext "AppleALC" "$ALC_URL"

if [ "$WIFI_TYPE" == "intel" ]; then
    echo "Downloading Intel Wi-Fi & Bluetooth..."
    download_kext "AirportItlwm" "$ITLWM_URL"
    download_kext "IntelBluetooth" "$INTEL_BT_URL"
fi

# 3. Download ACPI (SSDTs)
echo "Downloading ACPI Tables for $PLATFORM..."
ACPI_DIR="$DEST_DIR/EFI/OC/ACPI"
DORTANIA_ACPI="https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled"

if [ "$PLATFORM" == "intel_12_plus" ]; then
    curl -L -o "$ACPI_DIR/SSDT-PLUG-ALT.aml" "$DORTANIA_ACPI/SSDT-PLUG-ALT.aml"
    curl -L -o "$ACPI_DIR/SSDT-AWAC.aml" "$DORTANIA_ACPI/SSDT-AWAC.aml"
    curl -L -o "$ACPI_DIR/SSDT-EC-USBX-DESKTOP.aml" "$DORTANIA_ACPI/SSDT-EC-USBX-DESKTOP.aml"
    curl -L -o "$ACPI_DIR/SSDT-RHUB.aml" "$DORTANIA_ACPI/SSDT-RHUB.aml"
elif [ "$PLATFORM" == "intel_10_11" ]; then
    curl -L -o "$ACPI_DIR/SSDT-PLUG.aml" "$DORTANIA_ACPI/SSDT-PLUG.aml"
    curl -L -o "$ACPI_DIR/SSDT-AWAC.aml" "$DORTANIA_ACPI/SSDT-AWAC.aml"
    curl -L -o "$ACPI_DIR/SSDT-EC-USBX-DESKTOP.aml" "$DORTANIA_ACPI/SSDT-EC-USBX-DESKTOP.aml"
    curl -L -o "$ACPI_DIR/SSDT-RHUB.aml" "$DORTANIA_ACPI/SSDT-RHUB.aml"
elif [ "$PLATFORM" == "amd" ]; then
    curl -L -o "$ACPI_DIR/SSDT-CPUR.aml" "https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-CPUR.aml" # CPUR usually safer for B550/X570
    curl -L -o "$ACPI_DIR/SSDT-EC-USBX-DESKTOP.aml" "$DORTANIA_ACPI/SSDT-EC-USBX-DESKTOP.aml"
fi

# 5. Cleanup Temp
rm -rf "$TEMP_DIR"

echo "EFI Folder Assembly Complete at $DEST_DIR"
