local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local battery = sbar.add("item", "widgets.battery", {
  position = "right",
  updates = true,
  update_freq = 30,
  icon = {
    string = icons.battery.full,
    color = colors.green,
    font = {
      family = settings.font.text,
      style = settings.font.style_map.Regular,
      size = 17.0,
    },
    padding_left = 8,
    padding_right = 5,
  },
  label = {
    string = "--%",
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
    border_color = colors.with_alpha(colors.green, 0.18),
  },
  click_script = settings.config_dir .. "/plugins/open_menu_extra.sh aldente",
})

local function battery_style(charge, charging)
  if charging then
    return icons.battery.charging, colors.green
  elseif charge >= 80 then
    return icons.battery.full, colors.green
  elseif charge >= 60 then
    return icons.battery.high, colors.green
  elseif charge >= 40 then
    return icons.battery.medium, colors.yellow
  elseif charge >= 20 then
    return icons.battery.low, colors.orange
  else
    return icons.battery.empty, colors.red
  end
end

local function update()
  sbar.exec("pmset -g batt", function(output)
    local charge = tonumber(tostring(output):match("(%d+)%%")) or 0
    local charging = tostring(output):find("AC Power") ~= nil
    local icon, color = battery_style(charge, charging)

    battery:set({
      icon = {
        string = icon,
        color = color,
      },
      label = { string = charge .. "%" },
      background = { border_color = colors.with_alpha(color, 0.26) },
    })
  end)
end

battery:subscribe({ "forced", "routine", "power_source_change", "system_woke" }, update)
update()
