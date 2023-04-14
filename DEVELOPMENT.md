# Development

## Extending/Adding selector

The [internal treesitter plugin](./lua/tscf/init.lua) will return data about the current buffer file in format of a table.
There are two functions that can be called, one of them is probably only needed (formatted one).

So how it works is: `User > Command > Selector (Fuzzy Finder) > Treesitter part`

The `Selector` can be exchanged by adding more edgecases to the `Command` (see [main file in plugin folder](./plugin/tscf.vim)).

The `Selector` internally calls the treesitter part, which is either
* `:lua require("tscf").get_current_functions()` or
* `:lua require("tscf").get_current_functions_formatted()`
both return the same information, but the formatted function already has the tables concatted into a table of strings.

Examples can be found for vimscript and lua in the following parts:
* [FZF (vimscript - autoload/tscf/selector)](./autoload/tscf/selector/fzf.vim)
* [Telescope (lua - lua/tscf/selector)](./lua/tscf/selector/telescope.lua)

In general the functions can be called like following, and return:
* vimscript: `luaeval('require("tscf").get_current_functions()')`
  * `[[ "line_number": 1, "function_name": "name" ], ...]`
* lua: `require("tscf").get_current_functions()`
  * `{{ "line_number": 1, "function_name": "name" }, ...}`
* formatted call (`get_current_functions_formatted`)
  * same call as in vimscript and lua examples
  * `["line_number:\t function_name", "123:\t foo"]` or `{"line_number:\t function_name", "123:\t foo"}`


## LSP

The lua code uses [EmmyLua Annotations](https://github.com/sumneko/lua-language-server/wiki/EmmyLua-Annotations)
from the [sumneko lua lsp](https://github.com/sumneko/lua-language-server)
to enable hover docs and generally improve the development environment/workflow.


## Vim Help

* Add data to the help file (in doc)
* Run `:helptag doc/` to regenerate tags


## Debugging

For better debugging, uncomment the `package.loaded` part and comment out the `finish` in the plugin folder

Afterwards resourcing the files or init.vim (with the plug install) will make it easy to develop

Example:
* in init.vim: the plugin is installed via direct path
* then run `:so ~/.config/nvim/init.vim | GetCurrentFunctions`


## Inspection of treesitter

Starting with neovim version 0.9 the `treesitter playground` is integrated into treesitter and can be opened via `:InspectTree`.

This will show what node is under the cursor and the general structure, and can help with implementing new ways of declaring functions,
or to update the handling of functions for other languages.


## Testing

* Install `nvim-treesitter` locally into the plugin (inside this plugin folder)
  * `git clone https://github.com/nvim-treesitter/nvim-treesitter`
  * install the parsers `nvim --headless --noplugin -u scripts/minimal_init.lua +"TSInstallSync all" -c "q"`
    * this will take some time (could also only install needed parsers)
    * see `./.github/workflows/test.yml` for an example
* or manually link it inside the `./scripts/minimal_init.lua` file
  * something like `vim.opt.runtimepath:append("/home/<name>/.local/share/nvim/<manager>/nvim-treesitter")`

Run `./scripts/run_tests.sh` to see if any outputs of the main functionality changed and if, what changed exactly.
This is similar to snapshot testing, to regenerate the snapshot, look into the given script.
