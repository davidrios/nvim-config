local Path = require('plenary.path')

local M = {}

function M.copy_rc_file(rc_file, name)
  local rc_template = Path:new(vim.fn.stdpath('config') .. '/lua/workspace-templates/' .. name .. '/rc.lua')
  rc_file:write(rc_template:read(), "w")
  return true
end

function M.make_basic_setup(name)
  local function setup(rc_file)
    return M.copy_rc_file(rc_file, name)
  end

  return setup
end

return M
