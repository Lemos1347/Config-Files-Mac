local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local battery = sbar.add("item", "widgets.battery", {
  position = "right",
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
    drawing = false,
  },
  click_script = settings.config_dir .. "/plugins/open_menu_extra.sh aldente",
})

local function parse_percent(value)
  return tonumber(tostring(value or ""):match("[-%d%.]+"))
end

local function battery_style(charge, state)
  state = tostring(state or ""):lower()

  if state:find("full") then
    return icons.battery.full, colors.green
  elseif state:find("charging") and not state:find("discharging") then
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

local function update(env)
  local charge = parse_percent(env.BATTERY_PERCENTAGE)
  if not charge then
    return
  end

  local rounded = math.floor(charge + 0.5)
  local icon, color = battery_style(rounded, env.BATTERY_STATE)

  battery:set({
    icon = {
      string = icon,
      color = color,
    },
    label = { string = rounded .. "%" },
  })
end

battery:subscribe("system_stats", update)
