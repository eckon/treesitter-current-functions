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

local function get_named_node(parent, named)
  for node, name in parent:iter_children() do
    if name == named then
      return node
    end
  end
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

    -- standard ways of declaring/defining functions
    if is_simple_function then
      local info = get_node_information(tsnode)
      table.insert(content, info)
    end

    -- export might be used to export class/namespace/variables
    -- which include or are functions in itself
    if tsnode:type() == "export_statement" then
      local info = get_function_list_of_parent(tsnode)

      for _, node_information in ipairs(info) do
        table.insert(content, node_information)
      end
    end

    -- a lexical declartion can assign a function to a value
    if tsnode:type() == "lexical_declaration" then
      local child = tsnode:child(1)

      if child:type() == "variable_declarator" then
        local function_node = get_named_node(child, "value")

        if function_node:type() == "arrow_function" then
          local info = get_node_information(child)
          table.insert(content, info)
        end
      end
    end

    -- a class might have multiple functions
    if tsnode:type() == "class_declaration" then
      local class_name_node = get_named_node(tsnode, "name")
      local class_name = ts_utils.get_node_text(class_name_node)[1]

      -- get the class body of the class
      -- this might contain functions (methods)
      local body = get_named_node(tsnode, "body")
      local info = get_function_list_of_parent(body)

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
