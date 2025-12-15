-- Reserve a space in the gutter
vim.opt.signcolumn = 'yes'

local spell_words = {}
for word in io.open(vim.fn.stdpath('config') .. '/en.utf-8.add', 'r'):lines() do
    table.insert(spell_words, word)
end

vim.lsp.config('arduino_language_server', {
    cmd = {'arduino-language-server', '--cli', 'arduino-cli', '--cli-config', '$HOME/.arduino15/arduino-cli.yaml'},
    filetypes = {'arduino'},
    root_dir = require('lspconfig.util').root_pattern('sketch.yaml')
  }
)

-- From https://github.com/neovim/nvim-lspconfig/blob/master/lsp/ltex.lua
local language_id_mapping = {
  bib = 'bibtex',
  plaintex = 'tex',
  rnoweb = 'rsweave',
  rst = 'restructuredtext',
  tex = 'latex',
  pandoc = 'markdown',
  text = 'plaintext',
}

local filetypes = {
  'bib',
  'gitcommit',
  'markdown',
  'org',
  'plaintex',
  'rst',
  'rnoweb',
  'tex',
  'pandoc',
  'quarto',
  'rmd',
  'context',
  'html',
  'xhtml',
  'mail',
  'text',
}

local function get_language_id(_, filetype)
  local language_id = language_id_mapping[filetype]
  if language_id then
    return language_id
  else
    return filetype
  end
end
local enabled_ids = {}
do
  local enabled_keys = {}
  for _, ft in ipairs(filetypes) do
    local id = get_language_id({}, ft)
    if not enabled_keys[id] then
      enabled_keys[id] = true
      table.insert(enabled_ids, id)
    end
  end
end

vim.lsp.config('ltex-ls', {
  cmd = { 'ltex-ls' },
  filetypes = filetypes,
  root_markers = { '.git' },
  get_language_id = get_language_id,
  settings = {
    ltex = {
      language = 'en-US',
      enabled = true,
      dictionary = {
        ['en-US'] = spell_words,
      },
    },
  },
})

-- You'll find a list of language servers here:
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
-- These are example language servers. 
vim.lsp.enable('arduino_language_server')
vim.lsp.enable('clangd')
vim.lsp.enable('cssls')
vim.lsp.enable('dartls')
vim.lsp.enable('elixirls')
vim.lsp.enable('erlangls')
vim.lsp.enable('gleam')
vim.lsp.enable('glsl_analyzer')
vim.lsp.enable('html')
vim.lsp.enable('htmx')
vim.lsp.enable('kotlin_language_server')
vim.lsp.enable('jdtls')
vim.lsp.enable('lua_ls')
vim.lsp.enable('marksman')
vim.lsp.enable('matlab_ls')
vim.lsp.enable('pylsp')
vim.lsp.enable('svls')
vim.lsp.enable('ts_ls')
vim.lsp.enable('verible')
vim.lsp.enable('vhdl_ls')
vim.lsp.enable('zls')
vim.lsp.enable('ltex')

local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
    ['<Enter>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
    ['<Tab>'] = nil,
    ['<S-Tab>'] = nil,
  }),
})

-- Display errors and warnings at the end of the line
vim.diagnostic.config({
  virtual_text = {
  format = function(diagnostic)
    return string.format(" (%s) %s", diagnostic.severity == 1 and "E" or "W", diagnostic.message)
  end
  },
})
