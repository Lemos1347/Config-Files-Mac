local settings = require("settings")

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local command = table.concat({
  "/usr/bin/killall stats_provider >/dev/null 2>&1 || true;",
  shell_quote(settings.stats_provider),
  "--cpu usage",
  "--memory ram_usage",
  "--battery percentage state",
  "--interval " .. tostring(settings.stats_update_interval or 5),
  "--no-units",
  ">/private/tmp/sketchybar-stats-provider.log 2>&1 &",
}, " ")

sbar.exec(command)
