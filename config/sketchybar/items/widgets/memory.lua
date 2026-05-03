local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local memory = sbar.add("item", "widgets.memory", {
  position = "right",
  updates = true,
  update_freq = 10,
  icon = {
    string = icons.memory,
    color = colors.cyan,
    padding_left = 8,
    padding_right = 5,
  },
  label = {
    string = "RAM --%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map.Bold,
      size = 11.0,
    },
    padding_left = 0,
    padding_right = 8,
  },
  background = {
    color = colors.with_alpha(colors.item.bg, 0.78),
    border_color = colors.with_alpha(colors.cyan, 0.18),
  },
  click_script = settings.config_dir .. "/plugins/open_menu_extra.sh stats-ram",
})

local command = [[/usr/bin/memory_pressure | /usr/bin/awk '/System-wide memory free percentage:/ { gsub("%", "", $5); printf "%d", 100 - $5 }']]

local function update()
  sbar.exec(command, function(output)
    local used = tonumber(output) or 0
    local color = colors.cyan
    if used >= 85 then
      color = colors.red
    elseif used >= 70 then
      color = colors.orange
    elseif used >= 55 then
      color = colors.yellow
    end

    memory:set({
      icon = { color = color },
      label = { string = "RAM " .. used .. "%" },
      background = { border_color = colors.with_alpha(color, 0.26) },
    })
  end)
end

memory:subscribe({ "forced", "routine", "system_woke" }, update)
update()
