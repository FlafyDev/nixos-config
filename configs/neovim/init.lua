function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function hl(group, arg)
  vim.api.nvim_set_hl(0, group, arg)
end

function hl_con(contains, arg)
  local highlights = vim.fn.execute("highlight")
  -- print(highlights)

  for line in highlights:gmatch("[^\n]+") do
    local highlight = line:match("(%w+)")
    -- print(highlight)
    if (highlight:match(contains)) then
      -- print("found: " .. highlight)
      hl(line:match("(%w+)"), arg)
    end
  end
end

vim.g.mapleader = ' '

map("n", "<leader>n", ":NvimTreeToggle<CR>")

map("n", "<leader>f", ":Telescope find_files<CR>")
map("n", "<leader>p", ":Telescope oldfiles<CR>")
map("n", "<leader>s", ":Telescope live_grep<CR>")
map("n", "<leader>h", ":Telescope file_browser<CR>")

map("v", "<leader>r", ":SnipRun<CR>")
map("n", "<leader>r", ":SnipClose<CR>")
map("n", "<esc>", ":w!<CR>")

-- map("n", "<C-d>", "<C-d>zz")
-- map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

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
vim.g.transparent_enabled = true;
-- vim.g.neovide_floating_blur_amount_x = 2.0;
-- vim.g.neovide_floating_blur_amount_y = 2.0;
-- vim.g.neovide_floating_opacity = 0.3;

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    hl_con("Float", { background = nil })
    hl_con("TruncateLine", { foreground = "#7aa2f7" })
    hl('LineNr', { foreground = "#FFFFFF" });
    hl('LineNrAbove', { foreground = "#@activeBorder@" });
    hl('LineNrBelow', { foreground = "#@activeBorder@" });
    hl('FloatBorder', { foreground = "#@activeBorder@" });
    hl('LspFloatWinBorder', { foreground = "#@activeBorder@" });
  end,
})

require('tokyonight').setup({
  style = "night",
  on_colors = function(colors)
    colors.bg = nil
    colors.bg_dark = nil
    colors.bg_statusline = nil
    colors.border = "#@activeBorder@"
  end
})


vim.cmd('set fillchars+=vert:\\ " ');
vim.cmd('set nowrap');
vim.cmd('colorscheme tokyonight-night');
vim.cmd('set termguicolors');
vim.cmd('set clipboard+=unnamedplus');
vim.cmd('set signcolumn=yes');
-- vim.cmd('TransparentEnable');


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

-- vim.cmd('highlight VertSplit cterm=NONE');
-- vim.cmd('highlight StatusLine cterm=NONE');
-- vim.cmd('highlight StatusLineNC cterm=NONE');
-- vim.cmd('highlight SignColumn ctermbg=NONE');
-- vim.cmd('highlight NvimTreeNormal guibg=NONE guifg=NONE');
-- vim.cmd('highlight NvimTreeNormalNC guibg=NONE guifg=NONE');

local notify = vim.notify
vim.notify = function(msg, ...)
  if msg:match("warning: multiple different client offset_encodings") then
    return
  end

  notify(msg, ...)
end
