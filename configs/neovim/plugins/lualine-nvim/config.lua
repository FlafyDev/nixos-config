local modules = require('lualine_require').lazy_require { notices = 'lualine.utils.notices' }

require('lualine').setup {
  options = {
    theme = 'tokyonight',
    -- component_separators = '|',
    component_separators = ' ',
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = {
      { 'mode', separator = { left = '' }, right_padding = 2 },
    },
    lualine_b = { 'branch', },
    lualine_c = { 'diff', },
    lualine_x = { 'diagnostics', },
    lualine_y = { 'filetype', 'progress', },
    lualine_z = {
      { 'location', separator = { right = '' }, left_padding = 2 },
    },
  },
  -- inactive_sections = {
  --   lualine_a = { 'filename' },
  --   lualine_b = {},
  --   lualine_c = {},
  --   lualine_x = {},
  --   lualine_y = {},
  --   lualine_z = { 'location' },
  -- },
  tabline = {},
  extensions = {},
}
