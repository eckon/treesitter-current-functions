local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local config = require("telescope.config")
local actions = require("telescope.actions")
local state = require("telescope.actions.state")

local M = {}

local function jump_to_selected_line(prompt_bufnr)
  local chosen = state.get_selected_entry(prompt_bufnr)

  actions.close(prompt_bufnr)

  -- is a string that has a :\t infront of the line number
  -- example: "1:\n foo"
  local chosen_line = chosen[1]

  -- parsing breaks with spaces in number, so remove all spaces of the line
  -- works because we can ignore everything after the number here
  -- example: "  1:\n foo"
  local chosen_line_without_spaces = string.gsub(chosen_line, "%s+", "")

  -- get the first numbers, which should be the line number
  local line_number = string.match(chosen_line_without_spaces, "%d*")

  -- jump to the line number
  vim.cmd("normal! " .. line_number .. "G")
  -- realign cursor in view
  vim.cmd("normal! zz_")
end

M.init = function()
  local output = require("tscf").get_current_functions_formatted()

  local length = 0
  for _ in pairs(output) do
    length = length + 1
  end

  -- notify user in case we have no functions in the current buffer and exit
  if length <= 0 then
    print("No function found in the current buffer")
    return
  end

  pickers
    .new({}, {
      prompt_title = "Functions",
      finder = finders.new_table({
        results = output,
      }),
      sorter = config.values.generic_sorter({}),
      attach_mappings = function(_, map)
        map("i", "<CR>", jump_to_selected_line)
        map("n", "<CR>", jump_to_selected_line)
        return true
      end,
    })
    :find()
end

return M
