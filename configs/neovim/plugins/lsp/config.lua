local lspconfig = require("lspconfig")
local null = require("null-ls")
local rust_tools = require("rust-tools")
local flutter_tools = require('flutter-tools')
local pid = vim.fn.getpid()
local cmp = require('cmp')
local nb = null.builtins

null.setup({
  sources = {
    nb.formatting.alejandra,
    nb.code_actions.statix,
    nb.diagnostics.deadnix,
    nb.diagnostics.statix,
    nb.completion.luasnip,
    nb.diagnostics.eslint,
  },
})

require("luasnip.loaders.from_vscode").lazy_load({
  paths = "@snippets@",
})


-- require("luasnip.loaders.from_vscode").lazy_load({
--   paths = "/mnt/general/repos/RobertBrunhage/flutter-riverpod-snippets",
-- })

local lsp_format = function(bufnr)
  local filetype = vim.api.nvim_exec("echo &filetype", true);
  vim.lsp.buf.format({
    filter = function(client)
      if (filetype == "nix") then return client.name == "null-ls" end
      return true
    end,
    bufnr = 0,
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

----------- Autocompletion -----------

-- vim.g.coq_settings = {
--   auto_start = true,
--   xdg = true,
--   display = {
--     preview = {
--       border = "rounded",
--     },
--   },
-- }
--
-- local coq = require "coq"

local capabilities = require('cmp_nvim_lsp').default_capabilities()

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
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
    -- { name = 'vsnip' }, -- For vsnip users.
    { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- -- Set configuration for specific filetype.
-- cmp.setup.filetype('gitcommit', {
--   sources = cmp.config.sources({
--     { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
--   }, {
--     { name = 'buffer' },
--   })
-- })
--
-- -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline({ '/', '?' }, {
--   mapping = cmp.mapping.preset.cmdline(),
--   sources = {
--     { name = 'buffer' }
--   }
-- })
--
-- -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline(':', {
--   mapping = cmp.mapping.preset.cmdline(),
--   sources = cmp.config.sources({
--     { name = 'path' }
--   }, {
--     { name = 'cmdline' }
--   })
-- })

----------- Languages -----------

local servers = {
  "nil_ls",                 -- Nix
  "tsserver",               -- Typescript
  "cmake",                  -- CMake
  "pyright",                -- Python
  "kotlin_language_server", -- Kotlin
  "lua_ls",                 -- Lua
};


for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
  })
end


-- C/C++
lspconfig["clangd"].setup { {
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
  capabilities = capabilities,
  flags = { debounce_text_changes = 150 }
} }


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
    capabilities = capabilities,
    flags = lsp_flags,
    settings = {
      showTodos = true,
      completeFunctionCalls = true,
      enableSnippets = true,
      updateImportsOnRename = true, -- Whether to update imports and other directives when files are renamed. Required for `FlutterRename` command.
    }
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
    capabilities = capabilities,
    flags = lsp_flags,
  },
})


-- CSharp
lspconfig['omnisharp'].setup {
  on_attach = on_attach,
  flags = lsp_flags,
  cmd = { "OmniSharp", "--languageserver", "--hostPID", tostring(pid) },
  capabilities = capabilities,
}
