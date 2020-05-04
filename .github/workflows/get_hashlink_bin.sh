#!/bin/bash
set -x
set -e

TARGET="$1"
VERSION="$2"
VERSION_TAG="$3"

case "$TARGET" in
    # "windows-x86")
    #     PLATFORM="windows-x86"
    #     EXTENSION=".zip"
    #     ;;
    "windows-x64")
        PLATFORM="windows-x64"
        PACKAGE_PLATFORM="win"
        EXTENSION=".zip"
        ;;
    # "ubuntu")
    #     PLATFORM="linux-x64"
    #     EXTENSION=".tar.bz2"
    #     ;;
    # "macos")
    #     PLATFORM="macos-x64"
    #     EXTENSION=".tar.bz2"
    #     ;;
    *)
        echo "Unknown target"
        exit 1
        ;;
esac

PACKAGE_NAME="hl-${VERSION}-${PACKAGE_PLATFORM}"
FILENAME="hl-${VERSION}-${PACKAGE_PLATFORM}${EXTENSION}"

curl --connect-timeout 60 --location --silent --show-error \
    --retry 5 --remote-name \
    "https://github.com/HaxeFoundation/hashlink/releases/download/${VERSION_TAG}/hl-${VERSION}-${PACKAGE_PLATFORM}${EXTENSION}"

case "$EXTENSION" in
    ".zip")
        7z x "$FILENAME"
        ;;
    ".tar.bz2")
        tar --extract -f "$FILENAME"
        ;;
    *)
        echo "Unknown extension"
        exit 1
        ;;
esac

case "$PLATFORM" in
    "windows-x86"|"windows-x64")
        mv $PACKAGE_NAME c:/hl
        ;;
    *)
        echo "unsupported"
        exit 1
        ;;
esac
