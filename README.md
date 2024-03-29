# treesitter-current-functions

treesitter-current-functions (also `tscf`) is a neovim plugin that builds on top of treesitter to

* show all functions or function-like structures in the current buffer
  * while trying to be language agnostic
* open a selection tool (`telescope`, `fzf`, etc.)

to quickly jump to the wanted function location


## Example
Examples might be outdated, please reference `docs` for more information like `commands` etc.

### telescope with code preview
![Example Usage of tscf with preview in telescope](https://user-images.githubusercontent.com/40291209/260157636-13649dd4-2155-4c32-bf2a-bcaf56387426.gif)


## Disclaimer

The repo is my first try at a plugin for `vim`/`lua`/`treesitter`.
It can happen that a call will jump to an incorrect location or that it can not find all possible functions,
but as it will only jump, nothing too critical (like deleting text) should be happening even in the worst case.

Not all languages are tested (by far) and not all ways of declaring functions are implemented, but it might still work with not tested languages, if the treesitter structure is similar to others.

Fuzzy finders might break, depending on which ones are used and tested (I will most likely only test one that I am using at the time).

The plugin was tested with neovim version 0.8.3 and up, but can possibly work with earlier versions as well (depends on the given neovim treesitter apis, which are still experimental and change a lot).


## Install & Setup

* Install this repo with your favourite plugin manager
  * `Plug 'eckon/treesitter-current-functions'`
* Install [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
* Install one Selection tool
  * [telescope](https://github.com/nvim-telescope/telescope.nvim) (recommended)
    * this will most likely be more supported as I use telescope currently
  * [fzf](https://github.com/junegunn/fzf.vim)

An example (via [lazy](https://github.com/folke/lazy.nvim)) could look something like:
```lua
{
  "eckon/treesitter-current-functions",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-telescope/telescope.nvim" },
},
```

Quickly call the plugin, without any mappings:
```vim
:GetCurrentFunctions
```

The plugin does not add any mappings by itself.
As an example following map could be added to your `init.vim`:
```vim
nmap <Leader>cf <CMD>GetCurrentFunctions<CR>
```

## Information

For more information see
* `:help treesitter-current-functions`
* `:help tscf`
* `:help tscf-installation`
* `:help tscf-usage`

Some information about development of the plugin can be found [here](./DEVELOPMENT.md).
