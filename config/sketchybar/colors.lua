local colors = {
  transparent = 0x00000000,
  black = 0xff1d1d1f,
  white = 0xfff5f5f7,
  text = 0xfff5f5f7,
  muted = 0xffa1a1a6,
  grey = 0xff86868b,
  red = 0xffff453a,
  orange = 0xffff9f0a,
  yellow = 0xffffd60a,
  green = 0xff32d74b,
  blue = 0xffb0b0b5,
  cyan = 0xffc7c7cc,
  purple = 0xff636366,
  lavender = 0xffd2d2d7,
  navy = 0xff1c1c1e,

  bar = {
    bg = 0xcc2c2c2e,
    border = 0xcc48484a,
  },
  item = {
    bg = 0x443a3a3c,
    active = 0x88636366,
    border = 0x44767680,
  },
}

function colors.with_alpha(color, alpha)
  if alpha > 1.0 or alpha < 0.0 then
    return color
  end

  return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

return colors
