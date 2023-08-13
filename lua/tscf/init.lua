---@alias node unknown
local parsers = require("nvim-treesitter.parsers")

local M = {}

---To check if a specific file type is opened in the current buffer
---@param filetype string
---@return boolean
local function is_file_type(filetype)
  local bufnr = vim.fn.bufnr()
  local ft = vim.fn.getbufvar(bufnr, '&filetype')
  return filetype == ft
end

---Wrapper to get treesitter root parser
---@return node|nil
local function get_root()
  local parser = parsers.get_parser()
  if parser == nil then
    return nil
  end

  return parser:parse()[1]:root()
end

---Return node of "parent" that has given "named" as name in nested node
---@param parent node
---@param named string
---@return node|nil
local function get_named_node(parent, named)
  for node, name in parent:iter_children() do
    if name == named then
      return node
    end

    -- some languages have deeply nested structures
    -- in "declarator" parts can exist as well
    if name == "declarator" then
      local named_node = get_named_node(node, named)
      if named_node ~= nil then
        return named_node
      end

      -- when we are the furthest in the recursion and have an identifier, this can also be a function
      if node:type() == "identifier" then
        return node
      end

      return nil
    end
  end
end

---Return node of "parent" that has given "typed" as type in nested node
---@param parent node
---@param typed string
---@return node|nil
local function get_typed_node(parent, typed)
  for node, name in parent:iter_children() do
    if node:type() == typed then
      return node
    end

    -- some languages have deeply nested structures
    -- in "declarator" parts can exist as well
    if name == "declarator" then
      local typed_node = get_typed_node(node, typed)
      if typed_node ~= nil then
        return typed_node
      end

      return nil
    end
  end
end

---Get node information and construct a useable table out of it
---@param node node
---@return NodeInformation|nil
local function get_node_information(node)

  -- can be that some nodes have a not yet supported structure
  -- instead of crashing just ignore the node
  local function_name_node = get_named_node(node, "name")

  -- cpp has som edge cases where a "name" named node won't be found
  if is_file_type('cpp') and function_name_node == nil then
    -- Operator overloads
    function_name_node = get_typed_node(node, "operator_name")
    if function_name_node == nil then
      -- Reference return types
      local fd_node = get_typed_node(node, "function_declarator")
      function_name_node = get_named_node(fd_node, "identifier")
    end
  end

  if function_name_node == nil then
    return nil
  end

  local function_name = vim.treesitter.get_node_text(function_name_node, 0)
  local class_name = ""

  -- for C++ methods declared in a class or struct, the name of the class or
  -- struct will be shown in the display as it is a possibility the function
  -- names are identical
  local class_name_node = nil
  if is_file_type('cpp') then
    class_name_node = get_named_node(node, "scope")
  end
  if class_name_node ~= nil then
    local is_class_name = class_name_node:type() == "namespace_identifier"
        or class_name_node:type() == "template_type"
    if is_class_name then
        class_name = vim.treesitter.get_node_text(class_name_node, 0) .. '::'
    end
  end

  -- as fallback in case named node does not exist
  local line_content = vim.treesitter.get_node_text(node, 0)

  -- return line content in case we have no name (happens if there is no named node)
  function_name = function_name or line_content

  -- zero indexed
  local row, _, _ = node:start()
  local line_number = row + 1

  ---@class NodeInformation
  ---@field line_number number
  ---@field function_name string
  return { line_number = line_number, function_name = class_name .. function_name }
end

---Get all functions of the given "parent" node concatted into a table
---@param parent node
---@return NodeInformation[]
local function get_function_list_of_parent(parent)
  ---@type NodeInformation[]
  local content = {}

  if parent == nil then
    return content
  end

  for tsnode in parent:iter_children() do
    -- standard ways of declaring/defining functions
    local is_simple_function = tsnode:type() == "function_declaration"
      or tsnode:type() == "function_definition"
      or tsnode:type() == "local_function"
      or tsnode:type() == "method_definition"
      or tsnode:type() == "method_declaration"
      or tsnode:type() == "constructor_declaration"

    if is_simple_function then
      local info = get_node_information(tsnode)
      table.insert(content, info)
    end

    -- some functions might have the information in their parent (assigned variables)
    local is_parent_dependend_function = tsnode:type() == "function_definition" or tsnode:type() == "arrow_function"

    if is_parent_dependend_function then
      -- we want to name of the variable that it was assigned to -> parent
      -- if it has valuable information
      local parent_has_information = tsnode:parent():type() == "variable_declarator"
        or tsnode:parent():type() == "variable_declaration"

      if parent_has_information then
        local info = get_node_information(tsnode:parent())
        table.insert(content, info)
      end
    end

    -- these structures might include functions (arrow function, variable as function, classes, etc)
    local is_simple_recursive_structure = tsnode:type() == "export_statement"
      or tsnode:type() == "variable_declarator"
      or tsnode:type() == "variable_declaration"
      or tsnode:type() == "lexical_declaration"
      or tsnode:type() == "template_declaration"
      or tsnode:type() == "preproc_ifdef"
      or tsnode:type() == "preproc_if"
      or tsnode:type() == "preproc_else"

    if is_simple_recursive_structure then
      local info = get_function_list_of_parent(tsnode)

      for _, node_information in ipairs(info) do
        table.insert(content, node_information)
      end
    end

    -- structure that most likely have multiple functions internally
    local is_complex_recursive_structure = tsnode:type() == "class_declaration"
      or tsnode:type() == "namespace_declaration"

    if is_complex_recursive_structure then
      local structure_name_node = get_named_node(tsnode, "name")
      local structure_name = vim.treesitter.get_node_text(structure_name_node, 0)

      -- body this might contain functions (methods)
      local body = get_named_node(tsnode, "body")
      local info = get_function_list_of_parent(body)

      for _, node_information in ipairs(info) do
        -- append structure name infront of methods (or other structures)
        node_information.function_name = structure_name .. " > " .. node_information.function_name
        table.insert(content, node_information)
      end
    end
  end

  return content
end

---Get biggest line number to align numbers evenly in rows
---@param info NodeInformation[]
---@return number
local function get_max_line_number_length(info)
  local max_line_number_length = 0
  for _, node_information in ipairs(info) do
    -- diagnostic is incorrect - probably version mismatch
    ---@diagnostic disable-next-line: param-type-mismatch
    local current_line_number_length = string.len(node_information.line_number)

    if current_line_number_length >= max_line_number_length then
      max_line_number_length = current_line_number_length
    end
  end

  return max_line_number_length
end

---Global endpoint to get all functions of the current buffer
---structured into a table of multiple table informations
---@return NodeInformation[]
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
  table.sort(content, function(a, b)
    return a.line_number < b.line_number
  end)

  return content
end

---Global endpoint to get all functions of the current buffer
---structured into a table of formatted strings for easy usage of a selector
---@alias FormattedInformation string[]
---@return FormattedInformation # example {"line_number:\t function", "123:\t foo", ...}
M.get_current_functions_formatted = function()
  ---@type FormattedInformation
  local res = {}
  local output = M.get_current_functions()

  local max_line_number_length = get_max_line_number_length(output)
  -- add 1 because we will add a ":" at the end of the number
  local line_number_formatting_string = "% " .. (max_line_number_length + 1) .. "d"

  -- every entry will be concatted into a string
  -- result: {"line_number:\t function", "123:\t foo", ...}
  for _, node_information in ipairs(output) do
    local space_aligned_line_number = string.format(line_number_formatting_string, node_information.line_number)
    local concatted_string = space_aligned_line_number .. ":\t" .. node_information.function_name

    table.insert(res, concatted_string)
  end

  return res
end

return M
