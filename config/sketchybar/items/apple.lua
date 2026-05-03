local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

sbar.add("item", "apple.padding", {
  position = "left",
  width = 2,
  background = { drawing = false },
})

sbar.add("item", "apple", {
  position = "left",
  icon = {
    string = icons.apple,
    font = {
      family = settings.font.text,
      style = settings.font.style_map.Black,
      size = 18.0,
    },
    color = colors.with_alpha(colors.white, 0.9),
    padding_left = 8,
    padding_right = 8,
  },
  label = { drawing = false },
  background = {
    color = colors.with_alpha(colors.purple, 0.28),
    border_color = colors.with_alpha(colors.lavender, 0.18),
  },
  click_script = "open -a 'System Settings'",
})
