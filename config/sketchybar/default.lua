local colors = require("colors")
local settings = require("settings")

sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map.Bold,
      size = 14.0,
    },
    color = colors.text,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map.Semibold,
      size = 12.0,
    },
    color = colors.text,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  background = {
    drawing = false,
  },
  padding_left = 2,
  padding_right = 2,
  scroll_texts = false,
})
