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

return _M
