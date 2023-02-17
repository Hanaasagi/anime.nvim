local _M = {}

function _M.is_win()
  return package.config:sub(1, 1) == '\\'
end

function _M.get_path_separator()
  if _M.is_win() then
    return '\\'
  end
  return '/'
end

function _M.script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  if _M.is_win() then
    str = str:gsub('/', '\\')
  end
  return str:match('(.*' .. _M.get_path_separator() .. ')')
end

-- function _M.is_supported_sixel()
--   -- Hush-a Mandara Ni Pari
-- os.execute("stty -echo")
--
-- -- Send Device Attributes
-- local f = io.popen([[echo -ne "\e[c" > /dev/tty]])
-- local reply = f:read('*a')
-- f:close()
--
-- local hassixel = false
--
-- for code in reply:gmatch("[^;?]*") do
--     if code == "4" then
--         hassixel = true
--         break
--     end
-- end
-- print("#reply", #reply, reply,"hassixel", hassixel)
--
-- end

function _M.check_compatibility(t)
  local script_path = _M.script_path()
  -- local command = "bash " .. script_path .. "check.sh >/dev/null"
  -- local command = [[bash -c "echo $$; sleep 10"]]
  -- local exit_code = os.execute(command)
  -- local exit_code = vim.fn.system(command)
  -- print(exit_code)
  -- if not exit_code and exit_code % 512 == 0 then
  --   return true
  -- end

  --[[ ffi=require"ffi"
  ffi.cdef"int fileno(struct FILE* stream);" ]]

  -- local tty = io.open("/dev/tty", "rb")
  -- local tty_r_fd = ffi.C.fileno(tty)
  -- local tty_r_fd = tty:fileno()
  -- local tty2 = io.open("/dev/tty", "wb")
  -- local tty_w_fd = ffi.C.fileno(tty2)
  -- local tty_w_fd = tty:fileno()

  local uv = vim.loop
  local stdout = vim.loop.new_pipe()
  local stderr = vim.loop.new_pipe()
  local stdin = vim.loop.new_pipe()
  local handle = uv.spawn( -- "stty -echo && bash check.sh || stty echo",
  -- "bash",
  "script", {
    args = {
      -- "check.sh"
      "-q",
      "-e",
      "-c",
      "bash check.sh > /dev/null",
      "/dev/null",
    },
    cwd = script_path,
    -- stdio={nil, nil, nil},
    -- stdio = { stdin, stdout, stderr}
    -- stdio = { tty_r_fd, tty_w_fd, tty_w_fd}
    stdio = { 0, 1, 2 },
  }, function(code, signal)
    print("Process exited with code", code, signal)

    local file = io.open("/tmp/anime-supported", "r")
    local code = file:read("*a")
    file:close()
    if string.sub(code, 1, 1) == "0" then
      t.is_compatible = true
    else
      t.is_compatible = false
    end
    print("is_compatible", t.is_compatible)
  end)
  -- print("checking ...")
  return false
end

return _M
