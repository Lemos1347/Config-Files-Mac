local colors = {
  transparent = 0x00000000,
  black = 0xff11111b,
  white = 0xffcad3f5,
  text = 0xffcad3f5,
  muted = 0xff8aadf4,
  grey = 0xff6e738d,
  red = 0xffed8796,
  orange = 0xfff5a97f,
  yellow = 0xffeed49f,
  green = 0xffa6da95,
  blue = 0xff8aadf4,
  cyan = 0xff91d7e3,
  purple = 0xff8b5cf6,
  lavender = 0xffb7bdf8,
  navy = 0xff181926,

  bar = {
    bg = 0xee17143f,
    border = 0xff2a2667,
  },
  item = {
    bg = 0x552a2766,
    active = 0xaa3a33a3,
    border = 0x553d387e,
  },
}

function colors.with_alpha(color, alpha)
  if alpha > 1.0 or alpha < 0.0 then
    return color
  end

  return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

return colors
