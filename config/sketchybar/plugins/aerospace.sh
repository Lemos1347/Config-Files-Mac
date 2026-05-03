#!/usr/bin/env bash

# Active SketchyBar plugin for AeroSpace workspace focus state.

SKETCHYBAR_BIN="${SKETCHYBAR_BIN:-/run/current-system/sw/bin/sketchybar}"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  "$SKETCHYBAR_BIN" --set "$NAME" \
    background.drawing=on \
    label.color=0xfff4dbd6
else
  "$SKETCHYBAR_BIN" --set "$NAME" \
    background.drawing=off \
    label.color=0xffcad3f5
fi
