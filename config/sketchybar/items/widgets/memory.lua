local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local memory = sbar.add("item", "widgets.memory", {
  position = "right",
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
    drawing = false,
  },
  click_script = settings.config_dir .. "/plugins/open_menu_extra.sh stats-ram",
})

local function parse_percent(value)
  return tonumber(tostring(value or ""):match("[-%d%.]+"))
end

local function update(env)
  local used = parse_percent(env.RAM_USAGE)
  if not used then
    return
  end

  local rounded = math.floor(used + 0.5)
  local color = colors.cyan
  if rounded >= 90 then
    color = colors.red
  elseif rounded >= 80 then
    color = colors.orange
  elseif rounded >= 65 then
    color = colors.yellow
  end

  memory:set({
    icon = { color = color },
    label = { string = "RAM " .. rounded .. "%" },
  })
end

memory:subscribe("system_stats", update)
