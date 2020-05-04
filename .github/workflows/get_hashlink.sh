#!/bin/bash
set -x
set -e

TARGET="$1"
VERSION="$2"

case "$TARGET" in
    "windows-x86")
        PLATFORM="windows-x86"
        ;;
    "windows-x64")
        PLATFORM="windows-x64"
        ;;
    "ubuntu")
        PLATFORM="linux-x64"
        ;;
    "macos")
        PLATFORM="macos-x64"
        ;;
    *)
        echo "Unknown target"
        exit 1
        ;;
esac

PACKAGE_NAME="hashlink-${VERSION}"
FILENAME="hashlink-${VERSION}.tar.gz"

curl --connect-timeout 60 --location --silent --show-error \
    --retry 5 --output $FILENAME  \
    "https://github.com/HaxeFoundation/hashlink/archive/${VERSION}.tar.gz"

tar --extract -f "$FILENAME"

case "$PLATFORM" in
    "windows-x86"|"windows-x64")
        case $PLATFORM in
            "windows-x86")
                BUILD_PLATFORM=Win32
                ;;
            "windows-x64")
                BUILD_PLATFORM=x64
                ;;
        esac
        cd "$PACKAGE_NAME"
        # This doesn't work anymore :(
        msbuild.exe hl.sln \
            /p:Configuration=Release \
            /p:Platform=$BUILD_PLATFORM \
            /p:WindowsTargetPlatformVersion=10.0 \
            /p:PlatformToolset=v142
        mkdir -p c:/hl/
        cp -a Release/. c:/hl/
        echo "::add-path::c:/hl/"
        ;;
    "macos-x64")
        cd "$PACKAGE_NAME"
        brew bundle
        make
        sudo make install
        ;;
    *)
        cd "$PACKAGE_NAME"
        sudo apt update
        sudo apt install --yes libpng-dev libturbojpeg0-dev  libvorbis-dev libopenal-dev libsdl2-dev libmbedtls-dev libuv1-dev
        make
        sudo make install
        ;;
esac
