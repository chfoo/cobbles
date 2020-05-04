#!/bin/bash
set -x
set -e

if [ -d "cobbletext" ]; then
    echo "cobbletext directory already exists"
    exit 1
fi

TARGET="$1"
VERSION="$2"

case "$TARGET" in
    "windows-x86")
        PLATFORM="windows-x64"
        EXTENSION=".zip"
        ;;
    "windows-x64")
        PLATFORM="windows-x86"
        EXTENSION=".zip"
        ;;
    "ubuntu")
        PLATFORM="linux-x64"
        EXTENSION=".tar.bz2"
        ;;
    "macos")
        PLATFORM="macos-x64"
        EXTENSION=".tar.bz2"
        ;;
    *)
        echo "Unknown target"
        exit 1
        ;;
esac

PACKAGE_NAME="cobbletext-${VERSION}-${PLATFORM}"
FILENAME="cobbletext-${VERSION}-${PLATFORM}${EXTENSION}"

curl --connect-timeout 60 --location --no-progress-meter \
    --retry 5 --remote-name \
    "https://github.com/chfoo/cobbletext/releases/download/v${VERSION}/cobbletext-${VERSION}-${PLATFORM}${EXTENSION}"

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

mv $PACKAGE_NAME cobbletext
