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
      size = 16.0,
    },
    color = colors.with_alpha(colors.white, 0.9),
    y_offset = -1,
    padding_left = 7,
    padding_right = 7,
  },
  label = { drawing = false },
  background = { drawing = false },
  click_script = "open -a 'System Settings'",
})
