local ts_utils = require 'nvim-treesitter.ts_utils'
local parsers = require 'nvim-treesitter.parsers'

local M = {}

local function get_root()
  local parser = parsers.get_parser()
  return parser:parse()[1]:root()
end

local function get_node_information(node)
  local line_content = ts_utils.get_node_text(node)[1]
  local row, _, _ = node:start()
  -- zero indexed
  local line_number = row + 1

  return { line_number, line_content }
end

local function get_function_list_of_parent(parent)
  local content = {}

  for tsnode in parent:iter_children() do
    local is_simple_function =
      tsnode:type() == "function_declaration" or
      tsnode:type() == "function_definition" or
      tsnode:type() == "local_function" or
      tsnode:type() == "method_definition" or
      tsnode:type() == "method_declaration"

    if is_simple_function then
      local info = get_node_information(tsnode)
      table.insert(content, info)
    end

    if tsnode:type() == "export_statement" then
      local info = get_function_list_of_parent(tsnode)

      for _, node_information in ipairs(info) do
        table.insert(content, node_information)
      end
    end

    if tsnode:type() == "lexical_declaration" then
      local child = tsnode:child(1)

      if child:type() == "variable_declarator" then
        local function_node = child:child(2)

        if function_node:type() == "arrow_function" then
          local info = get_node_information(child)
          table.insert(content, info)
        end
      end
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
        node_information[2] = class_name .. " > " .. node_information[2]
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
