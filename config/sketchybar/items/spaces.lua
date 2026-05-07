local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local ok, app_icons = pcall(require, "icon_map")
if not ok then
  app_icons = {}
end

local aerospace = settings.aerospace
local max_windows = settings.max_workspace_windows
local workspace_refresh_interval = settings.workspace_refresh_interval or 10
local sort_workspace_windows_by_position = settings.sort_workspace_windows_by_position == true
local compact_workspace_label_monitors = settings.compact_workspace_label_monitors or {}
local workspaces = {}
local workspace_monitors = {}
local window_positions = {}
local current_workspace = nil
local current_window_id = nil
local refresh_in_flight = false
local refresh_again = false

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
  local app, title, window_id, monitor = line:match("^([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)$")
  if not app then
    return nil
  end

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
    monitor = trim(monitor),
  }
end

local function parse_workspace_window_line(line)
  local workspace, app, title, window_id, monitor =
    line:match("^([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)$")

  if not workspace then
    return nil, nil
  end

  local window = parse_window_line(table.concat({ app, title, window_id, monitor }, "\t"))
  return trim(workspace), window
end

local function parse_position_line(line)
  local window_id, x, y = line:match("^([^\t]*)\t([%-?%d%.]+)\t([%-?%d%.]+)$")
  if not window_id then
    return nil
  end

  return {
    window_id = trim(window_id),
    x = tonumber(x),
    y = tonumber(y),
  }
end

local function parse_workspace_monitor_line(line)
  local workspace, monitor = line:match("^([^\t]+)\t(.+)$")
  if not workspace or not monitor then
    return nil, nil
  end

  return trim(workspace), trim(monitor)
end

local function refresh_workspace_monitors()
  local command = aerospace .. " list-workspaces --all --format '%{workspace}\t%{monitor-name}' 2>/dev/null"
  local output = io.popen(command)
  if not output then
    return
  end

  local next_monitors = {}
  for line in output:lines() do
    local workspace, monitor = parse_workspace_monitor_line(line)
    if workspace and monitor then
      next_monitors[workspace] = monitor
    end
  end
  output:close()

  if next(next_monitors) ~= nil then
    workspace_monitors = next_monitors
  end
end

local function refresh_window_positions(callback)
  if not sort_workspace_windows_by_position then
    window_positions = {}
    callback()
    return
  end

  local command = "/bin/bash " .. shell_quote(settings.config_dir .. "/plugins/open_menu_extra.sh") .. " window-positions"
  sbar.exec(command, function(output)
    local next_positions = {}
    for _, line in ipairs(split_lines(output)) do
      local position = parse_position_line(line)
      if position and position.window_id ~= "" and position.x then
        next_positions[position.window_id] = position
      end
    end

    window_positions = next_positions
    callback()
  end)
end

local function attach_window_positions(windows)
  for index, window in ipairs(windows) do
    window.original_index = index

    local position = window_positions[window.window_id]
    if position then
      window.x = position.x
      window.y = position.y
    end
  end
end

local function sort_windows_by_position(windows)
  table.sort(windows, function(left, right)
    if left.x and right.x and left.x ~= right.x then
      return left.x < right.x
    end
    if left.y and right.y and left.y ~= right.y then
      return left.y < right.y
    end
    return (left.original_index or 0) < (right.original_index or 0)
  end)
end

local function workspace_uses_compact_labels(id, windows)
  local monitor = workspace_monitors[id]
  if not monitor or monitor == "" then
    for _, window in ipairs(windows or {}) do
      if window.monitor and window.monitor ~= "" then
        monitor = window.monitor
        break
      end
    end
  end

  return monitor ~= nil and compact_workspace_label_monitors[monitor] == true
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
      drawing = false,
    },
  })
end

local function refresh_focus(callback)
  current_window_id = nil

  local function done()
    if callback then
      callback()
    end
  end

  sbar.exec(
    aerospace .. " list-windows --focused --format '%{workspace}%{tab}%{window-id}' 2>/dev/null",
    function(focused)
      local first_line = tostring(focused or ""):match("[^\r\n]+") or ""
      local workspace, window_id = first_line:match("^([^\t]+)\t([^\t]+)$")
      if workspace and workspace ~= "" then
        current_workspace = trim(workspace)
      end
      current_window_id = window_id and trim(window_id) or nil
      if current_window_id == "" then
        current_window_id = nil
      end

      if current_workspace and current_workspace ~= "" then
        done()
        return
      end

      sbar.exec(aerospace .. " list-workspaces --focused 2>/dev/null", function(focused_workspace)
        local fallback = tostring(focused_workspace or ""):match("[^\r\n]+")
        if fallback and fallback ~= "" then
          current_workspace = trim(fallback)
        end
        done()
      end)
    end
  )
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

local function render_workspace(id, windows)
  local refs = workspaces[id]
  if not refs then
    return
  end

  windows = windows or {}
  attach_window_positions(windows)
  if sort_workspace_windows_by_position then
    sort_windows_by_position(windows)
  end

  local has_windows = #windows > 0
  set_workspace_visible(id, has_windows)
  set_workspace_neutral(id)

  if not has_windows then
    refs.window_count = 0
    return
  end

  local compact_labels = workspace_uses_compact_labels(id, windows)

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
          padding_right = compact_labels and 7 or 4,
        },
        label = {
          string = compact_labels and "" or truncate(window.title, index == 1 and 22 or 14),
          drawing = not compact_labels,
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
end

local function refresh_workspace_windows(callback)
  local command = aerospace
    .. " list-windows --all --format '%{workspace}%{tab}%{app-name}%{tab}%{window-title}%{tab}%{window-id}%{tab}%{monitor-name}'"

  sbar.exec(command, function(output)
    local windows_by_workspace = {}
    for id, _ in pairs(workspaces) do
      windows_by_workspace[id] = {}
    end

    for _, line in ipairs(split_lines(output)) do
      local workspace, window = parse_workspace_window_line(line)
      if workspace and window then
        windows_by_workspace[workspace] = windows_by_workspace[workspace] or {}
        table.insert(windows_by_workspace[workspace], window)
      end
    end

    for id, _ in pairs(workspaces) do
      render_workspace(id, windows_by_workspace[id] or {})
    end

    if callback then
      callback()
    end
  end)
end

local function refresh_all()
  if refresh_in_flight then
    refresh_again = true
    return
  end

  refresh_in_flight = true
  refresh_workspace_monitors()
  refresh_window_positions(function()
    refresh_workspace_windows(function()
      refresh_in_flight = false

      if refresh_again then
        refresh_again = false
        refresh_all()
      end
    end)
  end)
end

local function focus_workspace(id)
  if not id or id == "" then
    return
  end
  current_workspace = id
  refresh_focus(refresh_all)
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
      y_offset = 0,
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
          size = 15.0,
        },
        y_offset = 0,
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
        y_offset = 0,
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
      y_offset = 0,
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
      drawing = false,
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
sbar.add("event", "aerospace_focus_change")
sbar.add("event", "aerospace_windows_change")

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
  update_freq = workspace_refresh_interval,
})

observer:subscribe({ "forced", "routine", "system_woke" }, function()
  refresh_focus(refresh_all)
end)

observer:subscribe({
  "aerospace_focus_change",
  "aerospace_windows_change",
  "display_change",
}, function()
  refresh_focus(refresh_all)
end)

observer:subscribe("aerospace_workspace_change", function(env)
  focus_workspace(env.FOCUSED_WORKSPACE or current_workspace)
end)

refresh_all()
