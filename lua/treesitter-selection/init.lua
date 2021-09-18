local ts_utils = require 'nvim-treesitter.ts_utils'
local parsers = require 'nvim-treesitter.parsers'

local M = {}

-- lua package.loaded['treesitter-selection'] = nil; require("treesitter-selection").select()
-- help ts_utils
-- help treesitter
--
-- local function get_line_information(node)
--   local bufnr = vim.fn.bufnr()
--   local start_row = node:start()
--   local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
--   return line
-- end

local function get_root()
  local bufnr = vim.fn.bufnr()
  local filetype = vim.bo[bufnr].filetype

  local parser = parsers.get_parser(bufnr or 0, filetype)
  return parser:parse()[1]:root()
end

local function iterate_over_parent(parent)
  for tsnode in parent:iter_children() do
    local is_function = tsnode:type() == "function_declaration" or
      tsnode:type() == "function_definition" or
      tsnode:type() == "local_function"

    if is_function then
      local line = ts_utils.get_node_text(tsnode)[1]
      local name_node = tsnode:child(1)
      local name = ts_utils.get_node_text(name_node)[1]
      print(name, line)
    end

    if tsnode:type() == "method_definition" then
      local line = ts_utils.get_node_text(tsnode)[1]
      local name_node = tsnode:child(0)
      local name = ts_utils.get_node_text(name_node)[1]
      print(name, line)
    end

    -- in case more functions might be inside of other structures
    if tsnode:type() == "class_declaration" then
      local class_name_node = tsnode:child(1)
      local class_name = ts_utils.get_node_text(class_name_node)[1]
      print(class_name)
      -- get the class body of the class
      -- this might contain functions (methods)
      iterate_over_parent(tsnode:child(2))
    end
  end
end

M.select = function()
  local root = get_root()
  if root == nil then
    error("No Tressitter parser found")
  end

  iterate_over_parent(root)
end

return M
