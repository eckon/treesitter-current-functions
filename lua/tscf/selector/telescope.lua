local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local config = require("telescope.config")
local actions = require("telescope.actions")
local state = require("telescope.actions.state")

local M = {}

-- currently the row is formatted ugly that it works for machine and human
-- as it is used for the human to select and the machine to parse
local function jump_to_selected_line(line)
  -- parsing breaks with spaces in number, so remove all spaces of the line
  -- works because we can ignore everything after the number here
  -- example: "  1:\n foo"
  local chosen_line_without_spaces = string.gsub(line, "%s+", "")

  -- get the first numbers, which should be the line number
  local line_number = string.match(chosen_line_without_spaces, "%d*")

  -- jump to the line number
  vim.cmd("normal! " .. line_number .. "G")
  -- realign cursor in view
  vim.cmd("normal! zz_")
end

M.init = function()
  local output = require("tscf").get_current_functions_formatted()
  local current_path = vim.fn.expand("%")

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
      previewer = previewers.new_buffer_previewer({
        title = "Preview",
        define_preview = function(self, entry)
          config.values.buffer_previewer_maker(current_path, self.state.bufnr, {
            -- jump to the line number in the preview
            callback = function(bufnr)
              vim.api.nvim_buf_call(bufnr, function()
                vim.api.nvim_win_set_option(0, "cursorline", true)
                jump_to_selected_line(entry[1])
              end)
            end,
          })
        end,
      }),
      sorter = config.values.generic_sorter({}),
      -- TODO: use `make_entry` instead (change the complete returned value to include filename etc. as well)
      -- it seems like `h: make_entry` could help as it defines what is shown and done
      -- resulting in the result not needing to be human and machine readable
      -- then the data can be only a table and the jump function does not need to parse anything
      attach_mappings = function(_, map)
        map("i", "<CR>", function(bufnr)
          actions.close(bufnr)

          local chosen = state.get_selected_entry()
          jump_to_selected_line(chosen[1])
        end)

        map("n", "<CR>", function(bufnr)
          actions.close(bufnr)

          local chosen = state.get_selected_entry()
          jump_to_selected_line(chosen[1])
        end)

        return true
      end,
    })
    :find()
end

return M
