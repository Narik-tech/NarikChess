#!/bin/sh
printf '\033c\033]0;%s\a' 5D Chess Godot
base_path="$(dirname "$(realpath "$0")")"
"$base_path/narikchess.x86_64" "$@"
