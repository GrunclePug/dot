return { -- Edit the filesystem like a buffer (replaces netrw)
  'stevearc/oil.nvim',
  lazy = false, -- needed so `nvim .` opens oil instead of netrw
  dependencies = { { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font } },
  opts = {
    default_file_explorer = true,
    view_options = { show_hidden = true },
  },
  config = function(_, opts)
    require('oil').setup(opts)
    vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Open parent directory' })
    -- netrw is disabled, so keep the old habit working: `:Explore` / `:Ex` open oil
    vim.api.nvim_create_user_command('Explore', 'Oil <args>', { nargs = '?', complete = 'dir' })
  end,
}
