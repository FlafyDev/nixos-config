local lspconfig = require("lspconfig")
local cmp = require('cmp')
local null = require("null-ls")
local rust_tools = require("rust-tools")
local flutter_tools = require('flutter-tools')
local pid = vim.fn.getpid()
local nb = null.builtins

null.setup({
  sources = {
    nb.formatting.alejandra,
    nb.code_actions.statix,
    nb.diagnostics.deadnix,
    nb.diagnostics.statix,
    nb.diagnostics.eslint,
  },
})

local lsp_format = function(bufnr)
  local filetype = vim.api.nvim_exec("echo &filetype", true)
  vim.lsp.buf.format({
    filter = function(client)
      if (filetype == "nix") then
        return client.name == "null-ls"
      end
      return true
    end,
    bufnr = bufnr,
  })
end

local lsp_flags = {}
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  if client.supports_method("textDocument/formatting") then
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        lsp_format(bufnr)
      end,
    })
  end

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

  vim.g.code_action_menu_show_details = false
  vim.g.code_action_menu_show_diff = false
  vim.g.code_action_menu_show_action_kind = false
  vim.g.code_action_menu_window_border = 'rounded'

  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, {
      text = icon,
      texthl = hl,
      numhl = (type == "Error" or type == "Warn") and hl or "",
    })
  end

  vim.diagnostic.config({
    virtual_text = {
      prefix = '●',
    },
    signs = { active = signs },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  })

  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gh', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>lf', lsp_format, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', 'L', function()
    vim.cmd('CodeActionMenu')
  end, bufopts)

  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, bufopts)

  if vim.bo[bufnr].filetype == "dart" then
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

    vim.keymap.set('n', '<leader>lo', ':FlutterOutlineToggle<CR>', bufopts)
    vim.keymap.set('n', '<leader>ldr', ':FlutterRestart<CR>', bufopts)
    vim.keymap.set('n', '<leader>ldl', ':FlutterLogToggle<CR>', bufopts)
  end

  -- vim.keymap.set('n', '<leader>lgD', vim.lsp.buf.declaration, bufopts)
  -- vim.keymap.set('n', '<leader>lD', vim.lsp.buf.type_definition, bufopts)
end

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Nix
lspconfig['nil_ls'].setup {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
}


-- Typescript
lspconfig['tsserver'].setup {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
}


-- CMake
lspconfig['cmake'].setup {
  capabilities = capabilities,
  on_attach = on_attach,
  flags = { debounce_text_changes = 150 }
}


-- C/C++
lspconfig["clangd"].setup {
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--index",
    "--background-index",
    "--suggest-missing-includes",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders"
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true
  },
  on_attach = on_attach,
  flags = { debounce_text_changes = 150 }
}


-- Flutter
require("telescope").load_extension("flutter")
flutter_tools.setup {
  lsp = {
    color = {
                              -- show the derived colours for dart variables
      enabled = true,         -- whether or not to highlight color variables at all, only supported on flutter >= 2.10
      background = true,      -- highlight the background
      background_color = { r = 19, g = 17, b = 24 },
      foreground = false,     -- highlight the foreground
      virtual_text = false,   -- show the highlight using virtual text
      virtual_text_str = "■", -- the virtual text character to highlight
    },
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
  },
  debugger = {
    enabled = true,
    -- run_via_dap = true,
    register_configurations = function(_)
      require("dap").configurations.dart = {}
      require("dap.ext.vscode").load_launchjs()
    end,
  },
  widget_guides = {
    enabled = true,
  },
}


-- Rust
rust_tools.setup({
  server = {
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
  },
})


-- Python
lspconfig['pyright'].setup {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
}


-- CSharp
lspconfig['omnisharp'].setup {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
  cmd = { "OmniSharp", "--languageserver", "--hostPID", tostring(pid) },
}


-- Kotlin
lspconfig['kotlin_language_server'].setup {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
}


-- Lua
lspconfig['lua_ls'].setup {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
}


-- lspconfig['rnix'].setup {
--   on_attach = on_attach,
--   flags = lsp_flags,
--   capabilities = capabilities,
-- }

-- lspconfig['ccls'].setup {
--   on_attach = on_attach,
--   flags = lsp_flags,
--   capabilities = capabilities,
-- }
--
-- lspconfig['csharp_ls'].setup {
--   on_attach = on_attach,
--   flags = lsp_flags,
--   capabilities = capabilities,
-- }

-- lspconfig['dartls'].setup{
--   on_attach = on_attach,
--   flags = lsp_flags,
--   capabilities = capabilities,
-- }

-- lspconfig['rust_analyzer'].setup{
--     on_attach = on_attach,
--     flags = lsp_flags,
--     -- Server-specific settings...
--     settings = {
--       ["rust-analyzer"] = {}
--     }
-- }
--
-- saga.setup({
--   ui = {
--     -- currently only round theme
--     theme = 'round',
--     -- this option only work in neovim 0.9
--     title = true,
--     -- border type can be single,double,rounded,solid,shadow.
--     border = 'solid',
--     winblend = 0,
--     expand = '',
--     collapse = '',
--     preview = ' ',
--     code_action = '💡',
--     diagnostic = '🐞',
--     incoming = ' ',
--     outgoing = ' ',
--     colors = {
--       --float window normal background color
--       normal_bg = 'NONE',
--       --title background color
--       title_bg = '#afd700',
--       red = '#e95678',
--       magenta = '#b33076',
--       orange = '#FF8700',
--       yellow = '#f7bb3b',
--       green = '#afd700',
--       cyan = '#36d0e0',
--       blue = '#61afef',
--       purple = '#CBA6F7',
--       white = '#d1d4cf',
--       black = '#1c1c19',
--     },
--     kind = {},
--   },
-- })
-- vim.keymap.set('n', '<space>lwa', vim.lsp.buf.add_workspace_folder, bufopts)
-- vim.keymap.set('n', '<space>lwr', vim.lsp.buf.remove_workspace_folder, bufopts)
-- vim.keymap.set('n', '<space>lwl', function()
--   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
-- end, bufopts)


-- Code action
-- map("n", "L", "<cmd>Lspsaga code_action<CR>", { silent = true })
-- -- Outline
-- map("n","<leader>o", "<cmd>Lspsaga outline<CR>",{ silent = true })
-- -- Rename
-- map("n", "<space>lr", "<cmd>Lspsaga rename<CR>", { silent = true })
-- -- Hover Doc
-- map("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })
-- map("n", "<leader>K", "<cmd>Lspsaga hover_doc ++keep<CR>")
--
-- -- Lsp finder find the symbol definition implement reference
-- -- if there is no implement it will hide
-- -- when you use action in finder like open vsplit then you can
-- -- use <C-t> to jump back
-- map("n", "<space>gh", "<cmd>Lspsaga lsp_finder<CR>", { silent = true })
--
-- -- Peek Definition
-- -- you can edit the definition file in this flaotwindow
-- -- also support open/vsplit/etc operation check definition_action_keys
-- -- support tagstack C-t jump back
-- map("n", "<space>gD", "<cmd>Lspsaga peek_definition<CR>", { silent = true })
-- map("n", "<space>gd", "<cmd>Lspsaga goto_definition<CR>", { silent = true })
--
-- -- Show line diagnostics
-- map("n", "<leader>e", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true })
-- map("n", "<leader>E", "<cmd>Lspsaga show_buf_diagnostics<CR>", { silent = true })

-- Show cursor diagnostic
-- map("n", "<leader>lcd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true })

-- Diagnsotic jump can use `<c-o>` to jump back
-- map("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true })
-- map("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true })
--
-- -- Only jump to error
-- map("n", "<leader>[e", function()
--   require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
-- end, { silent = true })

-- map("n", "<leader>]e", function()
--   require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
-- end, { silent = true })

-- -- Float terminal
-- map("n", "F", "<cmd>Lspsaga open_floaterm<CR>", { silent = true })
-- -- if you want pass somc cli command into terminal you can do like this
-- -- open lazygit in lspsaga float terminal
-- map("n", "F", "<cmd>Lspsaga open_floaterm lazygit<CR>", { silent = true })
-- -- close floaterm
-- map("t", "F", [[<C-\><C-n><cmd>Lspsaga close_floaterm<CR>]], { silent = true })
-- saga.init_lsp_saga({
--   code_action_lightbulb = {
--     enable = true,
--     enable_in_insert = true,
--     cache_code_action = true,
--     sign = false,
--     update_time = 150,
--     sign_priority = 20,
--     virtual_text = true,
--   },
-- })
-- local saga = require("lspsaga")
