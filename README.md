# Information

Neovim plugin that builds on top of treesitter to:
* Show all functions in the current buffer
* Open a fuzzy finder or any other selection tool to jump to that function line

This plugin was intended to just return a table with needed information about the current file.
Meaning that it is easily possible to add whatever plugin that can handle text input (fzf, telescope, manual, etc.).


# Disclaimer

The plugin is by far not done and not tested, I am just starting with lua, vimscript and treesitter, which is why it will break,
not work as expected or show wrong results.

Not all languages are tested (by far) and not all ways of declaring functions are implemented.
I mainly added ways that I most likely will face.

The plugin should not be able to do destructive work, the only things that can happen is, that it shows wrong information or jump to wrong places.


# Usage

## Example

![Example Usage of treesitter-current-functions](./treesitter-current-functions-example.gif)


## Install

* Install this repo with your favourite plugin manager
  * Example vim-plug: `Plug 'eckon/treesitter-current-functions'`
* [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
* Something to handle output (like fzf)
  * Currently only fzf is supported
  * In general the output can be used by other software as well, just a wrapper needs to be added (look at plugin folder)

Either use the map or run the command
```vim
nmap <Leader>foo <Plug>TreesitterCurrentFunctions

nnoremap <Leader>foo <CMD>GetCurrentFunctions<CR>
```


## Usage for other tools

See plugin folder

Add `:lua require("treesitter-current-functions").get_current_functions()` as a mapping

Get content like `echo luaeval('require("treesitter-current-functions").get_current_functions()')`

It returns tables with the structure:
> `{{ "line_number", "function_name" }, ...}`

When calling it into vim via `luaeval` this will return in the current structure:
> `[[ "line_number", "function_name" ], ...]`


# Development

For removing cached lua code, run `lua package.loaded['treesitter-current-functions'] = nil`

For removing cached vim code, comment out the `finish` part in the plugin file.

Both can be just added to the vim file in folder (meaning the lua part added and the finish part commented out).
After that the plugin can be easily update with a place where is sources it being sources.

Example:
* in init.vim: the plugin is installed via direct path
* then run `:so ~/.config/nvim/init.vim | GetCurrentFunctions`

```lua
-- lua package.loaded['treesitter-current-functions'] = nil; require("treesitter-current-functions").get_current_functions()
-- help ts_utils
-- help treesitter

-- similar to ts_utils.get_node_text
-- will return the name of the node itself
local function get_node_content(node)
  local bufnr = vim.fn.bufnr()
  local start_row, start_column, end_row, end_column = node:range()
  local full_line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
  local content = full_line:sub(start_column, end_column)

  return content
end

-- debugging function for quick print of table
local function table_print(table)
  for index, value in ipairs(table) do
    print(index, value)
    for key, v in ipairs(value) do
      print(key, v)
    end
  end
end
```
