function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
      options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

vim.g.mapleader = ' '

map("n", "<leader>n", ":NvimTreeToggle<CR>")
map("n", "<leader>dn", ":FlutterOutlineToggle<CR>")

map("n", "<leader>f", ":Telescope find_files<CR>")
map("n", "<leader>p", ":Telescope oldfiles<CR>")
map("n", "<leader>s", ":Telescope live_grep<CR>")
map("n", "<leader>N", ":Telescope file_browser<CR>")

map("v", "<leader>r", ":SnipRun<CR>")
map("n", "<leader>r", ":SnipClose<CR>")
map("n", "<esc>", ":w!<CR>")

vim.opt.tabstop = 2;
vim.opt.shiftwidth = 2;
vim.opt.expandtab = true;
vim.opt.number = true;
vim.opt.relativenumber = true;
vim.opt.laststatus = 3;

vim.g.neovide_transparency = 0;
-- vim.g.neovide_cursor_vfx_mode = "torpedo";
vim.g.neovide_cursor_animation_length = 0.1;
vim.g.neovide_cursor_trail_size = 0.3;
vim.g.neovide_hide_mouse_when_typing = true;
-- vim.g.neovide_floating_blur_amount_x = 2.0;
-- vim.g.neovide_floating_blur_amount_y = 2.0;
-- vim.g.neovide_floating_opacity = 0.3;

vim.cmd('highlight LineNr guifg=#3b4261');
vim.cmd('highlight LineNrAbove guifg=#3b4261');
vim.cmd('highlight LineNrBelow guifg=#3b4261');

vim.cmd('set fillchars+=vert:\\ " ');
vim.cmd('set nowrap');
vim.cmd('colorscheme tokyonight');
vim.cmd('set termguicolors');
vim.cmd('set clipboard+=unnamedplus');
vim.g.transparent_enabled = true;

vim.api.nvim_create_user_command(
  'FlutterLogToggle',
  function(opts)
    local wins = vim.api.nvim_list_wins()

    for _, id in pairs(wins) do
      local bufnr = vim.api.nvim_win_get_buf(id)
      if vim.api.nvim_buf_get_name(bufnr):match '.*/([^/]+)$' == '__FLUTTER_DEV_LOG__' then
        return vim.api.nvim_win_close(id, true)
      end
    end

    pcall(function()
      vim.api.nvim_command 'belowright split + __FLUTTER_DEV_LOG__ | resize 15'
    end)
  end,
  { nargs = 0 }
)

-- vim.cmd('highlight LineNr ctermfg=grey');
-- vim.cmd('highlight VertSplit cterm=NONE');
-- vim.cmd('highlight StatusLine cterm=NONE');
-- vim.cmd('highlight StatusLineNC cterm=NONE');
-- vim.cmd('highlight SignColumn ctermbg=NONE');
-- vim.cmd('highlight NvimTreeNormal guibg=NONE guifg=NONE');
-- vim.cmd('highlight NvimTreeNormalNC guibg=NONE guifg=NONE');

