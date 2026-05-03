local colors = require("colors")
local settings = require("settings")

local date = sbar.add("item", "widgets.date", {
  position = "right",
  updates = true,
  update_freq = 30,
  icon = { drawing = false },
  label = {
    string = os.date("%a %d %b %H:%M"),
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map.Bold,
      size = 11.0,
    },
    padding_left = 8,
    padding_right = 8,
  },
  background = {
    color = colors.with_alpha(colors.item.bg, 0.78),
    border_color = colors.with_alpha(colors.lavender, 0.22),
  },
  click_script = settings.config_dir .. "/plugins/open_menu_extra.sh calendar",
})

local function update()
  date:set({ label = { string = os.date("%a %d %b %H:%M") } })
end

date:subscribe({ "forced", "routine", "system_woke" }, update)
update()
