local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local ok, app_icons = pcall(require, "icon_map")
if not ok then
  app_icons = {}
end

local aerospace = settings.aerospace
local max_windows = settings.max_workspace_windows
local workspaces = {}
local current_workspace = nil
local current_window_id = nil

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function trim(value)
  return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function truncate(value, max_chars)
  value = trim(value)
  if #value <= max_chars then
    return value
  end
  return value:sub(1, max_chars - 1) .. "…"
end

local function split_lines(output)
  local lines = {}
  for line in tostring(output or ""):gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  return lines
end

local function parse_window_line(line)
  local app, title, window_id = line:match("([^\t]*)\t([^\t]*)\t([^\t]*)")
  app = trim(app)
  title = trim(title)

  if app == "" then
    app = "App"
  end
  if title == "" then
    title = app
  end

  return {
    app = app,
    title = title,
    window_id = trim(window_id),
  }
end

local function set_workspace_neutral(id)
  local refs = workspaces[id]
  if not refs then
    return
  end

  refs.label:set({
    icon = {
      color = colors.with_alpha(colors.white, 0.55),
    },
  })
  refs.bracket:set({
    background = {
      color = colors.with_alpha(colors.item.bg, 0.75),
      border_color = colors.with_alpha(colors.item.border, 0.7),
    },
  })
end

local function refresh_focus()
  local focused_workspace_output = io.popen(aerospace .. " list-workspaces --focused 2>/dev/null")
  if focused_workspace_output then
    local focused = focused_workspace_output:read("*l")
    focused_workspace_output:close()
    if focused and focused ~= "" then
      current_workspace = trim(focused)
    end
  end

  local focused_window_output = io.popen(aerospace .. " list-windows --focused --format '%{window-id}' 2>/dev/null")
  if focused_window_output then
    local focused = focused_window_output:read("*l")
    focused_window_output:close()
    current_window_id = focused and trim(focused) or nil
    if current_window_id == "" then
      current_window_id = nil
    end
  end
end

local function set_workspace_visible(id, visible)
  local refs = workspaces[id]
  if not refs then
    return
  end

  refs.label:set({ drawing = visible })
  refs.ellipsis:set({ drawing = false })
  refs.bracket:set({ drawing = visible })
  refs.padding:set({ drawing = visible })

  if not visible then
    for _, item in ipairs(refs.apps) do
      item:set({ drawing = false })
    end
  end
end

local function refresh_workspace(id)
  local refs = workspaces[id]
  if not refs then
    return
  end

  local command = aerospace
    .. " list-windows --workspace "
    .. shell_quote(id)
    .. " --format '%{app-name}\t%{window-title}\t%{window-id}'"

  sbar.exec(command, function(output)
    local windows = {}
    for _, line in ipairs(split_lines(output)) do
      table.insert(windows, parse_window_line(line))
    end

    local has_windows = #windows > 0
    set_workspace_visible(id, has_windows)
    set_workspace_neutral(id)

    if not has_windows then
      refs.window_count = 0
      return
    end

    for index, item in ipairs(refs.apps) do
      local window = windows[index]
      if window then
        local icon = app_icons[window.app] or app_icons.Default or ":default:"
        local focused = current_window_id ~= nil and window.window_id == current_window_id
        item:set({
          drawing = true,
          icon = {
            string = icon,
            color = colors.with_alpha(colors.white, focused and 0.96 or 0.62),
          },
          label = {
            string = truncate(window.title, index == 1 and 22 or 14),
            drawing = true,
            color = colors.with_alpha(colors.white, focused and 0.96 or 0.72),
          },
          background = { drawing = false },
        })
      else
        item:set({
          drawing = false,
          icon = { string = "" },
          label = { string = "", drawing = false },
          background = { drawing = false },
        })
      end
    end

    local overflow = #windows > max_windows
    refs.ellipsis:set({
      drawing = overflow,
      icon = { string = overflow and icons.ellipsis or "" },
    })
    refs.label:set({
      drawing = true,
      icon = {
        color = #windows > 0 and colors.with_alpha(colors.white, 0.55) or colors.with_alpha(colors.white, 0.42),
      },
    })

    refs.window_count = #windows
  end)
end

local function refresh_all()
  for id, _ in pairs(workspaces) do
    refresh_workspace(id)
  end
end

local function focus_workspace(id)
  if not id or id == "" then
    return
  end
  current_workspace = id
  refresh_focus()
  refresh_all()
end

local function add_workspace(id)
  local group = {}
  local members = {}

  group.label = sbar.add("item", "space." .. id .. ".label", {
    position = "left",
    icon = {
      string = id,
      color = colors.with_alpha(colors.white, 0.55),
      font = {
        family = settings.font.numbers,
        style = settings.font.style_map.Bold,
        size = 12.0,
      },
      y_offset = -1,
      padding_left = 8,
      padding_right = 6,
    },
    label = { drawing = false },
    background = { drawing = false },
    click_script = aerospace .. " workspace " .. shell_quote(id),
  })
  table.insert(members, group.label.name)

  group.apps = {}
  for index = 1, max_windows do
    local app_item = sbar.add("item", "space." .. id .. ".app." .. index, {
      position = "left",
      drawing = false,
      icon = {
        string = "",
        font = {
          family = settings.font.app,
          style = settings.font.style_map.Regular,
          size = 16.0,
        },
        y_offset = -1,
        padding_left = index == 1 and 0 or 2,
        padding_right = 4,
      },
      label = {
        drawing = false,
        max_chars = 22,
        font = {
          family = settings.font.text,
          style = settings.font.style_map.Semibold,
          size = 11.0,
        },
        y_offset = -1,
        padding_left = 0,
        padding_right = 8,
      },
      background = {
        drawing = false,
        height = 22,
        corner_radius = 11,
      },
      click_script = aerospace .. " workspace " .. shell_quote(id),
    })
    table.insert(group.apps, app_item)
    table.insert(members, app_item.name)
  end

  group.ellipsis = sbar.add("item", "space." .. id .. ".ellipsis", {
    position = "left",
    drawing = false,
    icon = {
      string = icons.ellipsis,
      color = colors.with_alpha(colors.white, 0.58),
      y_offset = -1,
      padding_left = 0,
      padding_right = 8,
    },
    label = { drawing = false },
    background = { drawing = false },
    click_script = aerospace .. " workspace " .. shell_quote(id),
  })
  table.insert(members, group.ellipsis.name)

  group.bracket = sbar.add("bracket", "space." .. id .. ".bracket", members, {
    background = {
      color = colors.with_alpha(colors.item.bg, 0.75),
      border_color = colors.with_alpha(colors.item.border, 0.7),
      height = 28,
      corner_radius = 14,
      border_width = 1,
    },
  })

  group.padding = sbar.add("item", "space." .. id .. ".padding", {
    position = "left",
    width = 3,
    background = { drawing = false },
  })

  workspaces[id] = group
end

sbar.add("event", "aerospace_workspace_change")

local workspace_output = io.popen(aerospace .. " list-workspaces --all 2>/dev/null")
if workspace_output then
  for line in workspace_output:lines() do
    local id = trim(line)
    if id ~= "" then
      add_workspace(id)
    end
  end
  workspace_output:close()
end

if next(workspaces) == nil then
  for index = 1, 9 do
    add_workspace(tostring(index))
  end
end

refresh_focus()

for id, refs in pairs(workspaces) do
  set_workspace_neutral(id)
  set_workspace_visible(id, false)
end

local observer = sbar.add("item", "aerospace.observer", {
  drawing = false,
  updates = true,
  update_freq = 2,
})

observer:subscribe({ "forced", "routine", "system_woke" }, function()
  refresh_focus()
  refresh_all()
end)

observer:subscribe("aerospace_workspace_change", function(env)
  focus_workspace(env.FOCUSED_WORKSPACE or current_workspace)
end)

refresh_all()
