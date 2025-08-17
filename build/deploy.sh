#!/bin/env bash

BUTLER="$HOME/dev/butler/butler"

GODOT="$HOME/dev/godot/Godot_v4.1.1-stable_linux.x86_64"

if [ ! -f $GODOT ]; then
	echo "Godot executable not found. Nothing has been changed."
	return 1
fi

read -p "This will delete all current builds. Are you sure you want to continue? [y/N] " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "Make backups and try again."
	return 1
fi

rm windows/*
rm linux/*
#rm macos/*
#rm -r web/*

VERSION=$( cat ../project.godot | grep config/version | sed 's/config\/version="//' | sed 's/"//' )

# mkdir web/${VERSION}

PROJECT_PATH=$( pwd )/../

$GODOT --headless --path $PROJECT_PATH --export-release "Windows" build/windows/blades.exe
$GODOT --headless --path $PROJECT_PATH --export-release "Linux" build/linux/blades.x86_64
# $GODOT --headless --path $PROJECT_PATH --export-release "macOS" build/macos/blades.zip
# $GODOT --headless --path $PROJECT_PATH --export-release "Web" build/web/${VERSION}/index.html

$BUTLER push windows/ scarzehd/five-nights-at-shithouse:windows --userversion $VERSION
$BUTLER push linux/ scarzehd/five-nights-at-shithouse:linux --userversion $VERSION
# butler push web/${VERSION}/ scarzehd/five-nights-at-shithouse:web --userversion $VERSION
# butler push macos/five-nights-at-shithouse-macos.zip scarzehd/five-nights-at-shithouse:macos --userversion $VERSION
