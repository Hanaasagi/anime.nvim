local health = vim.health or require "health"
local _M = {}

_M.check = function()
  health.report_error("a test message")
end

return _M

