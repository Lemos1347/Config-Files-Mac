local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local cpu = sbar.add("item", "widgets.cpu", {
  position = "right",
  updates = true,
  update_freq = 5,
  icon = {
    string = icons.cpu,
    color = colors.blue,
    padding_left = 8,
    padding_right = 5,
  },
  label = {
    string = "CPU --%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map.Bold,
      size = 11.0,
    },
    padding_left = 0,
    padding_right = 8,
  },
  background = {
    drawing = false,
  },
  click_script = settings.config_dir .. "/plugins/open_menu_extra.sh stats-cpu",
})

local command = [[/usr/bin/top -l 1 -s 0 -n 0 | /usr/bin/awk -F'[:,%]+' '/CPU usage/ { printf "%d", $2 + $3 + 0.5 }']]

local function update()
  sbar.exec(command, function(output)
    local load = tonumber(output) or 0
    local color = colors.blue
    if load >= 80 then
      color = colors.red
    elseif load >= 60 then
      color = colors.orange
    elseif load >= 35 then
      color = colors.yellow
    end

    cpu:set({
      icon = { color = color },
      label = { string = "CPU " .. load .. "%" },
    })
  end)
end

cpu:subscribe({ "forced", "routine", "system_woke" }, update)
update()
