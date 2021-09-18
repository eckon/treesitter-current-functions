local ts_utils = require 'nvim-treesitter.ts_utils'
local parsers = require 'nvim-treesitter.parsers'

local M = {}

local function get_root()
  local bufnr = vim.fn.bufnr()
  local filetype = vim.bo[bufnr].filetype

  local parser = parsers.get_parser(bufnr or 0, filetype)
  return parser:parse()[1]:root()
end

local function get_node_information(node, name_index)
  local line_content = ts_utils.get_node_text(node)[1]
  local name_node = node:child(name_index)
  local name = ts_utils.get_node_text(name_node)[1]
  local row, _, _ = node:start()
  -- zero indexed
  row = row + 1

  return { row, name, line_content }
end

local function get_function_list_of_parent(parent)
  local content = {}

  for tsnode in parent:iter_children() do
    if tsnode:type() == "function_declaration" or tsnode:type() == "function_definition" then
      local info = get_node_information(tsnode, 1)
      table.insert(content, info)
    end


    if tsnode:type() == "local_function" then
      local info = get_node_information(tsnode, 2)
      table.insert(content, info)
    end

    if tsnode:type() == "method_definition" then
      local info = get_node_information(tsnode, 0)
      table.insert(content, info)
    end

    -- in case more functions might be inside of other structures
    if tsnode:type() == "class_declaration" then
      local class_name_node = tsnode:child(1)
      local class_name = ts_utils.get_node_text(class_name_node)[1]

      -- get the class body of the class
      -- this might contain functions (methods)
      local info = get_function_list_of_parent(tsnode:child(2))

      for _, node_information in ipairs(info) do
        -- append class infront of methods
        node_information[2] = class_name .. ": " .. node_information[2]
        table.insert(content, node_information)
      end
    end
  end

  return content
end

M.get_current_functions = function()
  local root = get_root()
  if root == nil then
    error("No Tressitter parser found")
  end

  local content = get_function_list_of_parent(root)

  return content
end

return M
