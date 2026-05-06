return {
  config_dir = os.getenv("CONFIG_DIR") or (os.getenv("HOME") .. "/.config/sketchybar"),
  aerospace = os.getenv("AEROSPACE_BIN") or "/opt/homebrew/bin/aerospace",
  paddings = 4,
  group_paddings = 5,
  max_workspace_windows = 4,
  workspace_refresh_interval = 10,
  sort_workspace_windows_by_position = false,
  stats_provider = os.getenv("STATS_PROVIDER_BIN") or "/run/current-system/sw/bin/stats_provider",
  stats_update_interval = 5,
  compact_workspace_label_monitors = {
    ["Built-in Retina Display"] = true,
  },

  font = {
    text = "JetBrainsMono Nerd Font",
    numbers = "JetBrainsMono Nerd Font",
    app = "sketchybar-app-font",
    style_map = {
      Regular = "Regular",
      Semibold = "SemiBold",
      Bold = "Bold",
      Heavy = "ExtraBold",
      Black = "ExtraBold",
    },
  },
}
