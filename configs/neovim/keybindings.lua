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