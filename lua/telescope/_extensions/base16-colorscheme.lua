local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  error('This plugins requires nvim-telescope/telescope.nvim')
end

local actions      = require'telescope.actions'
local action_state = require'telescope.actions.state'
local finders      = require'telescope.finders'
local pickers      = require'telescope.pickers'
local action_set   = require'telescope.actions.set'

local conf = require('telescope.config').values

local function select(opts)
  local base16 = require('base16-colorscheme')
  local colorschemes = vim.list_extend(opts.colorschemes or {}, base16.available_colorschemes())

  table.sort(colorschemes, function(a, b)
    return a > b
  end)

  pickers.new(opts,{
    prompt = 'Change Base16 Colorscheme',
    finder = finders.new_table {
      results = colorschemes
    },
    -- TODO: better preview?
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()

        actions.close(prompt_bufnr)
        base16.setup(selection.value)
      end)

      action_set.shift_selection:enhance {
        post = function()
          local selection = action_state.get_selected_entry()
          base16.setup(selection.value, false)
        end
      }

      actions.close:enhance {
        post = function()
          base16.setup(vim.g.colors_name)
        end
      }

      return true
    end
  }):find()
end

return require('telescope').register_extension {
  exports = {
    select = select
  }
}
