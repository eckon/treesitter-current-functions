vim.opt.runtimepath:append(".")
-- for using the already existing plugin (from the users installation)
-- vim.opt.runtimepath:append("/home/<user>/.local/share/nvim/<manager>/nvim-treesitter")
-- for using a newly cloned installation
vim.opt.runtimepath:append("./nvim-treesitter")

vim.cmd([[runtime! plugin/tscf.vim]])
vim.cmd([[runtime! plugin/nvim-treesitter.lua]])
