local lspconfig = require("lspconfig")
local saga = require("lspsaga")
local pid = vim.fn.getpid()

function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
      options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

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

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
-- vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
-- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

local lsp_formatting = function(bufnr)
    local filetype = vim.api.nvim_exec("echo &filetype",true)
    vim.lsp.buf.format({
        filter = function(client)
            if (filetype == "nix") then
              return client.name == "null-ls"
            end 
            return true
            -- apply whatever logic you want (in this example, we'll only use null-ls)
        end,
        bufnr = bufnr,
    })
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer

local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
              -- lsp_formatting(bufnr)
          end,
      })
  end

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  -- vim.keymap.set('n', '<leader>lgD', vim.lsp.buf.declaration, bufopts)
  -- vim.keymap.set('n', '<leader>lgd', vim.lsp.buf.definition, bufopts)
  -- vim.keymap.set('n', '<leader>lgi', vim.lsp.buf.implementation, bufopts)
  -- vim.keymap.set('n', '<leader>lgr', vim.lsp.buf.references, bufopts)
  -- vim.keymap.set('n', '<leader>lD', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>lf', lsp_formatting, bufopts)
  --
  -- vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  -- vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, bufopts)
  -- vim.keymap.set('n', 'L', vim.lsp.buf.code_action, bufopts)

  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  -- vim.keymap.set('n', '<space>lwa', vim.lsp.buf.add_workspace_folder, bufopts)
  -- vim.keymap.set('n', '<space>lwr', vim.lsp.buf.remove_workspace_folder, bufopts)
  -- vim.keymap.set('n', '<space>lwl', function()
  --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  -- end, bufopts)


  -- Code action
  map("n", "L", "<cmd>Lspsaga code_action<CR>", { silent = true })
  -- Outline
  map("n","<leader>o", "<cmd>Lspsaga outline<CR>",{ silent = true })
  -- Rename
  map("n", "<space>lr", "<cmd>Lspsaga rename<CR>", { silent = true })
  -- Hover Doc
  map("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })
  map("n", "<leader>K", "<cmd>Lspsaga hover_doc ++keep<CR>")

  -- Lsp finder find the symbol definition implement reference
  -- if there is no implement it will hide
  -- when you use action in finder like open vsplit then you can
  -- use <C-t> to jump back
  map("n", "<space>gh", "<cmd>Lspsaga lsp_finder<CR>", { silent = true })

  -- Peek Definition
  -- you can edit the definition file in this flaotwindow
  -- also support open/vsplit/etc operation check definition_action_keys
  -- support tagstack C-t jump back
  map("n", "<space>gD", "<cmd>Lspsaga peek_definition<CR>", { silent = true })
  map("n", "<space>gd", "<cmd>Lspsaga goto_definition<CR>", { silent = true })

  -- Show line diagnostics
  map("n", "<leader>e", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true })
  map("n", "<leader>E", "<cmd>Lspsaga show_buf_diagnostics<CR>", { silent = true })

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
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

-- local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())


lspconfig['tsserver'].setup {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
}

lspconfig['nil_ls'].setup {
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

lspconfig['cmake'].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {debounce_text_changes = 150}
}

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
    flags = {debounce_text_changes = 150}
}

require('flutter-tools').setup {
  lsp = {
    color = { -- show the derived colours for dart variables
      enabled = true, -- whether or not to highlight color variables at all, only supported on flutter >= 2.10
      background = false, -- highlight the background
      foreground = false, -- highlight the foreground
      virtual_text = true, -- show the highlight using virtual text
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
}

local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
  },
})

lspconfig['pyright'].setup{
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
}

lspconfig['omnisharp'].setup{
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
  cmd = { "OmniSharp", "--languageserver" , "--hostPID", tostring(pid)},
}

lspconfig['kotlin_language_server'].setup{
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
}



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
