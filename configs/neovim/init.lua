function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
      options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

vim.g.mapleader = ' '

map("n", "<leader>n", ":NvimTreeToggle<CR>")

map("n", "<leader>f", ":Telescope find_files<CR>")
map("n", "<leader>p", ":Telescope oldfiles<CR>")
map("n", "<leader>s", ":Telescope live_grep<CR>")
map("n", "<leader>N", ":Telescope file_browser<CR>")

map("v", "<leader>r", ":SnipRun<CR>")
map("n", "<leader>r", ":SnipClose<CR>")
map("n", "<esc>", ":w!<CR>")

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true;

vim.cmd('highlight LineNr ctermfg=grey');
vim.cmd('highlight VertSplit cterm=NONE');
vim.cmd('highlight StatusLine cterm=NONE');
vim.cmd('highlight StatusLineNC cterm=NONE');
vim.cmd('highlight SignColumn ctermbg=NONE');
vim.cmd('set fillchars+=vert:\\ " ');

