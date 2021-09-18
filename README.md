# Information

Plugin returns all functions of the current file.
This can be used to pipe it into fzf, telescope or anything else to quickly navigate to it.


# Usage

Add `:lua require("treesitter-selection").get_current_functions()` as a mapping


# Development
```lua
-- lua package.loaded['treesitter-selection'] = nil; require("treesitter-selection").get_current_functions()
-- help ts_utils
-- help treesitter
--
-- local function get_line_information(node)
--   local bufnr = vim.fn.bufnr()
--   local start_row = node:start()
--   local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
--   return line
-- end
```
