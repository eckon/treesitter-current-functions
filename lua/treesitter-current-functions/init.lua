local ts_utils = require 'nvim-treesitter.ts_utils'
local parsers = require 'nvim-treesitter.parsers'

local M = {}

local function get_root()
  local parser = parsers.get_parser()
  return parser:parse()[1]:root()
end

local function get_named_node(parent, named)
  for node, name in parent:iter_children() do
    if name == named then
      return node
    end
  end
end

local function get_function_node_parameter_string(function_node)
  local parameter_node = get_named_node(function_node, "parameters")

  if parameter_node == nil then
    return ""
  end

  local parameter_content = ""

  -- get content of all nods and concat them into one string
  -- TODO: add logic to add spaces after ":" "," etc.
  for node in parameter_node:iter_children() do
    local node_content = ts_utils.get_node_text(node)[1]
    parameter_content = parameter_content .. node_content .. " "
  end

  return parameter_content
end

local function get_node_information(node)
  local function_name_node = get_named_node(node, "name")
  local function_name = ts_utils.get_node_text(function_name_node)[1]
  -- as fallback in case named node does not exist
  local line_content = ts_utils.get_node_text(node)[1]
  -- return line content in case we have no name (happens if there is no named node)
  function_name = function_name or line_content

  -- zero indexed
  local row, _, _ = node:start()
  local line_number = row + 1

  return { line_number, function_name }
end

local function get_function_list_of_parent(parent)
  local content = {}

  for tsnode in parent:iter_children() do
    -- standard ways of declaring/defining functions
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

    -- some functions might have the information in their parent (assigned variables)
    local is_parent_dependend_function =
      tsnode:type() == "function_definition" or
      tsnode:type() == "arrow_function"

    if is_parent_dependend_function then
      -- we want to name of the variable that it was assigned to -> parent
      -- if it has valuable information
      local parent_has_information =
        tsnode:parent():type() == "variable_declarator" or
        tsnode:parent():type() == "variable_declaration"

      if parent_has_information then
        local info = get_node_information(tsnode:parent())
        table.insert(content, info)
      end
    end

    -- these structures might include functions (arrow function, variable as function, classes, etc)
    local is_simple_recursive_strucute =
      tsnode:type() == "export_statement" or
      tsnode:type() == "variable_declarator" or
      tsnode:type() == "variable_declaration" or
      tsnode:type() == "lexical_declaration"

    if is_simple_recursive_strucute then
      local info = get_function_list_of_parent(tsnode)

      for _, node_information in ipairs(info) do
        table.insert(content, node_information)
      end
    end

    -- structure that most likely have multiple functions internally
    local is_complex_recursive_structure =
      tsnode:type() == "class_declaration" or
      tsnode:type() == "namespace_declaration"

    if is_complex_recursive_structure then
      local structure_name_node = get_named_node(tsnode, "name")
      local structure_name = ts_utils.get_node_text(structure_name_node)[1]

      -- body this might contain functions (methods)
      local body = get_named_node(tsnode, "body")
      local info = get_function_list_of_parent(body)

      for _, node_information in ipairs(info) do
        -- append structure name infront of methods (or other structures)
        node_information[2] = structure_name .. " > " .. node_information[2]
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

  -- sort content, it could have different order in some edge cases
  table.sort(content, function(a, b) return a[1] < b[1] end)

  return content
end

return M
