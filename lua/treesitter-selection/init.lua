local ts_utils = require 'nvim-treesitter.ts_utils'
local parsers = require 'nvim-treesitter.parsers'

local M = {}

-- lua package.loaded['treesitter-selection'] = nil; require("treesitter-selection").select()
-- help ts_utils
-- help treesitter

local function get_root()
  local bufnr = vim.fn.bufnr()
  local filetype = vim.bo[bufnr].filetype

  local parser = parsers.get_parser(bufnr or 0, filetype)
  return parser:parse()[1]:root()
end

local function get_class_body(parent)
  for tsnode in parent:iter_children() do
    if tsnode:type() == "class_body" then
      return tsnode
    end
  end
end

local function iterate_over_parent(parent)
  for tsnode in parent:iter_children() do
    if tsnode:type() == "function_declaration" then
      -- here we have a function and it will be added to the retun table
      print("function")
    end

    if tsnode:type() == "method_definition" then
      -- almsot the same as functoin do the same
      print("method")
    end

    if tsnode:type() == "class_declaration" then
      -- class can have multiple methods (functions) iterate them as well
      print("class")
      local body = get_class_body(tsnode)
      iterate_over_parent(body)
    end
  end
end

M.select = function()
  -- get all nodes, get all functions recursively output them to fzf

  local root = get_root()
  if root == nil then
    error("No Tressitter parser found")
  end

  print(root:child_count())

  -- we have the root and iterate over them
  iterate_over_parent(root)

end

return M
