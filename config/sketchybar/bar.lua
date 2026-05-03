local colors = require("colors")

sbar.bar({
  position = "top",
  display = "all",
  height = 34,
  margin = 3,
  y_offset = 2,
  corner_radius = 17,
  padding_left = 6,
  padding_right = 6,
  color = colors.transparent,
  border_width = 0,
  blur_radius = 0,
  topmost = false,
  sticky = true,
  shadow = false,
})
