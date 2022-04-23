local parsers = require "nvim-treesitter.parsers"

local M = {}

local function get_root()
  local parser = parsers.get_parser()
  if parser == nil then
    return nil
  end

  return parser:parse()[1]:root()
end

local function get_named_node(parent, named)
  for node, name in parent:iter_children() do
    if name == named then
      return node
    end

    -- some languages have deeply nested structures
    -- in "declarator" parts can exist as well
    if name == "declarator" then
      return get_named_node(node, named)
    end
  end
end

local function get_node_information(node)
  local function_name_node = get_named_node(node, "name")

  -- can be that some nodes have a not yet supported structure
  -- instead of crashing just ignore the node
  if function_name_node == nil then
    return nil
  end

  local function_name = vim.treesitter.query.get_node_text(function_name_node, 0)

  -- as fallback in case named node does not exist
  local line_content = vim.treesitter.query.get_node_text(node, 0)

  -- return line content in case we have no name (happens if there is no named node)
  function_name = function_name or line_content

  -- zero indexed
  local row, _, _ = node:start()
  local line_number = row + 1

  return { line_number, function_name }
end

local function get_function_list_of_parent(parent)
  local content = {}

  if parent == nil then
    return content
  end

  for tsnode in parent:iter_children() do
    -- standard ways of declaring/defining functions
    local is_simple_function =
      tsnode:type() == "function_declaration" or
      tsnode:type() == "function_definition" or
      tsnode:type() == "local_function" or
      tsnode:type() == "method_definition" or
      tsnode:type() == "method_declaration" or
      tsnode:type() == "constructor_declaration"

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
    local is_simple_recursive_structure =
      tsnode:type() == "export_statement" or
      tsnode:type() == "variable_declarator" or
      tsnode:type() == "variable_declaration" or
      tsnode:type() == "lexical_declaration"

    if is_simple_recursive_structure then
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
      local structure_name = vim.treesitter.query.get_node_text(structure_name_node, 0)

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

local function get_max_line_number_length(output)
  local max_line_number_length = 0
  for _, node_information in ipairs(output) do
    local line_number = node_information[1]
    local current_line_number_length = string.len(line_number)

    if current_line_number_length >= max_line_number_length then
      max_line_number_length = current_line_number_length
    end
  end

  return max_line_number_length
end

M.get_current_functions = function()
  local root = get_root()
  if root == nil then
    print("No Tressitter-parser found in the current buffer")
    return {}
  end

  local ok, content = pcall(get_function_list_of_parent, root)
  if not ok then
    print("Something went wrong in the current buffer")
    print("Current buffer might have unsuported language or syntax")
    return {}
  end

  -- sort content, it could have different order in some edge cases
  table.sort(content, function(a, b) return a[1] < b[1] end)

  return content
end

M.get_current_functions_formatted = function()
  local res = {}
  local output = M.get_current_functions()

  local max_line_number_length = get_max_line_number_length(output)
  -- add 1 because we will add a ":" at the end of the number
  local line_number_formatting_string = "% " .. (max_line_number_length + 1) .. "d"

  -- every entry will be concatted into a string
  -- result: {"line_number:\t function", "123:\t foo", ...}
  for _, node_information in ipairs(output) do
    local line_number = node_information[1]
    local space_aligned_line_number = string.format(line_number_formatting_string, line_number)
    local function_name = node_information[2]
    local concatted_string = space_aligned_line_number .. ":\t" .. function_name
    table.insert(res, concatted_string)
  end

  return res
end

return M
