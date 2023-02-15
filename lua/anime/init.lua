local _M = {
  -- User config
  config = {},
  -- Image data array
  images = {},
  -- Internal state
  state = {
    -- Current displayed frame index
    index = 1,
  },
  -- Timer
  timer = nil,
}

local _DEFAULT_CONFIG = {
  -- Anime data path
  anime_dir = require("anime/utils").script_path() .. "../../static/",
  -- Where to start rendering
  -- `"topright"`, `"bottomright"` or a table `{col=0, row=0}`
  position = "bottomright",
  -- Control frame speed
  fps = {
    -- Dsipaly 16 frames per second
    base = 16,
    -- 8 frames per second in slow mode
    slow = 8,
    fast = 24,
    -- Or you can set a function that return fps
    -- If you set `handler`, `base`/`slow`/`fast` will take no effect
    -- handler = function() return 16 end
  },
}

local SCREEN = { topright = "topright", bottomright = "bottomright" }

SCREEN.get_pos = function(p)
  -- How many columns in window
  local m_cols = vim.api.nvim_get_option('columns')
  local m_rows = vim.api.nvim_get_option('lines')

  local img_width, img_height = _M.config.width, _M.config.height
  if p == SCREEN.topright then
    return { col = m_cols - math.floor(img_width / 18), row = 0 }
  elseif p == SCREEN.bottomright then
    local row = m_rows - vim.api.nvim_get_option('cmdheight')
    return { col = m_cols - math.floor(img_width / 18), row = row - math.floor(img_height / 18) }
  else
    -- TODO ensure table
    return p
  end
end

local SPEED_CONTROLLER = { state = { wordcount = -1 } }

SPEED_CONTROLLER.get_speed = function(fps)
  if fps.handler ~= nil then
    return fps.handler()
  end

  local prev_wcnt = SPEED_CONTROLLER.state.wordcount
  local cur_wcnt = vim.fn.wordcount().chars
  SPEED_CONTROLLER.state.wordcount = cur_wcnt

  if prev_wcnt == -1 then
    return 0
  end

  local diff = cur_wcnt
  if prev_wcnt ~= -1 then
    diff = math.abs(cur_wcnt - prev_wcnt)
  end

  -- Nothing changed
  if diff == 0 then
    return 0
  end

  -- Typing speed per minute
  local type_speed = (diff / (_M.config.duration * #_M.images)) * 1000 * 60
  if type_speed >= 200 then
    return fps.fast
  elseif type_speed <= 100 then
    return fps.slow
  else
    return fps.base
  end
end

-- FIXME: atomic
local is_running = false
local elapsed = {}
_M.render = function()
  -- Avoid running concurrently
  if is_running then
    return
  end
  is_running = true

  table.insert(elapsed, _M.config.duration)
  local elapsed_time = 0
  for _, v in pairs(elapsed) do
    elapsed_time = elapsed_time + v
  end

  -- Adjust fps every anime loop
  -- elapsed_time is a hard time limit to avoid that anime has two many frames
  if _M.state.index == 1 or elapsed_time >= 500 then
    local fps = SPEED_CONTROLLER.get_speed(_M.config.fps)
    -- Skip rendering
    if fps == 0 then
      is_running = false
      -- keep it timed out, but do not make array too big
      elapsed[#elapsed + 1] = nil
      return
    end

    -- truncate array
    for k, _ in pairs(elapsed) do
      elapsed[k] = nil
    end

    -- Refresh timer's duration
    local duration = math.floor(1000 / fps)
    if duration ~= _M.config.duration then
      _M.config.duration = duration
      vim.fn.timer_stop(_M.timer)
      _M.timer = vim.fn.timer_start(duration, _M.render, { ['repeat'] = -1 })
    end
  end

  local pos = SCREEN.get_pos(_M.config.position)
  local row = pos.row
  local col = pos.col

  local content = string.format("\x1b[s\x1b[%d;%dH%s\x1b[u", row, col, _M.images[(_M.state.index % #_M.images) + 1])

  -- Must be render in main loop
  vim.schedule(function()
    -- vim.api.nvim_command("silent !stty -echoctl")

    local tty = io.open('/dev/tty', 'wb')
    if not tty then
      print('Failed to open file')
      return
    end
    if not tty:write(content) then
      print('Failed to write to file')
      tty:close()
      return
    end
    tty:flush()
    tty:close()

    -- vim.api.nvim_command("silent !stty echoctl")
  end)

  _M.state.index = (_M.state.index % #_M.images) + 1
  is_running = false
end

_M.setup = function(config)
  config = vim.tbl_extend('force', _DEFAULT_CONFIG, config or {})
  _M.config = config
  _M.images = {}

  local files = vim.fn.split(vim.fn.glob(config.anime_dir .. "*.sixel"), "\n")
  if #files == 0 then
    return
  end

  table.sort(files)

  -- Load all images data
  for i = 1, #files do
    table.insert(_M.images, vim.fn.readfile(files[i], 'b')[1])
  end

  -- Guess width and height
  local image = _M.images[1]
  local part = vim.fn.split(image, '"')
  part = vim.fn.split(part[2], '#')
  config.width, config.height = string.match(part[1], "(%d+);(%d+)$")

  -- Start render loop
  config.duration = math.floor(1000 / config.fps.base)
  _M.timer = vim.fn.timer_start(config.duration, _M.render, { ['repeat'] = -1 })
end

return _M
