#!/usr/bin/env bash

set -euo pipefail

target="${1:-}"

click_menu_extra() {
  local process_name="$1"
  local mode="$2"

  /usr/bin/osascript - "$process_name" "$mode" <<'APPLESCRIPT'
on lowerText(valueText)
  try
    return do shell script "/bin/echo " & quoted form of valueText & " | /usr/bin/tr '[:upper:]' '[:lower:]'"
  on error
    return ""
  end try
end lowerText

on fieldText(itemRef, fieldName)
  try
    if fieldName is "name" then return name of itemRef as text
    if fieldName is "description" then return description of itemRef as text
    if fieldName is "value" then return value of itemRef as text
  end try
  return ""
end fieldText

on attributeText(itemRef, attributeName)
  try
    tell application "System Events" to set attributeValue to value of attribute attributeName of itemRef
    if attributeValue is missing value then return ""
    return attributeValue as text
  end try
  return ""
end attributeText

on itemMatches(itemRef, mode)
  set haystack to lowerText((my fieldText(itemRef, "name")) & " " & (my fieldText(itemRef, "description")) & " " & (my fieldText(itemRef, "value")) & " " & (my attributeText(itemRef, "AXDescription")) & " " & (my attributeText(itemRef, "AXHelp")) & " " & (my attributeText(itemRef, "AXValue")))

  if mode is "stats-cpu" then
    return haystack contains "cpu" or haystack contains "processor"
  else if mode is "stats-ram" then
    return haystack contains "ram" or haystack contains "memory"
  else if mode is "calendar" then
    return haystack contains ":" or haystack contains "clock" or haystack contains "date"
  end if
end itemMatches

on clickFirstMatching(processName, mode)
  tell application "System Events"
    tell process processName
      repeat with itemRef in menu bar items of menu bar 1
        if my itemMatches(itemRef, mode) then
          click itemRef
          return true
        end if
      end repeat

    end tell
  end tell
  return false
end clickFirstMatching

on run argv
  set processName to item 1 of argv
  set mode to item 2 of argv
  set matched to clickFirstMatching(processName, mode)
  if matched is false then error "No matching menu extra for " & mode
end run
APPLESCRIPT
}

case "$target" in
  aldente)
    /usr/bin/open -b com.apphousekitchen.aldente-pro || /usr/bin/open -a AlDente
    ;;
  stats-cpu)
    click_menu_extra "Stats" "stats-cpu" || /usr/bin/open -b eu.exelban.Stats || /usr/bin/open -a Stats
    ;;
  stats-ram)
    click_menu_extra "Stats" "stats-ram" || /usr/bin/open -b eu.exelban.Stats || /usr/bin/open -a Stats
    ;;
  calendar)
    click_menu_extra "ControlCenter" "calendar" || /usr/bin/open -a Calendar
    ;;
  *)
    exit 64
    ;;
esac
