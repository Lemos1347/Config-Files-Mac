local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local cpu = sbar.add("item", "widgets.cpu", {
  position = "right",
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

local function parse_percent(value)
  return tonumber(tostring(value or ""):match("[-%d%.]+"))
end

local function update(env)
  local load = parse_percent(env.CPU_USAGE)
  if not load then
    return
  end

  local rounded = math.floor(load + 0.5)
  local color = colors.blue
  if rounded >= 80 then
    color = colors.red
  elseif rounded >= 60 then
    color = colors.orange
  elseif rounded >= 35 then
    color = colors.yellow
  end

  cpu:set({
    icon = { color = color },
    label = { string = "CPU " .. rounded .. "%" },
  })
end

cpu:subscribe("system_stats", update)
