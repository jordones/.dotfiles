set guicursor=i:hor20-iCursor-blinkwait300-blinkon200-blinkoff150
set scrolloff=8
set number
set relativenumber
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab 
set smartindent 

call plug#begin("~/.vim/plugged")
Plug 'zoomlogo/github-dimmed.vim'
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }

" LSP Support
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

" Autocompletion Plugins
Plug 'windwp/nvim-autopairs' " Autopairs, integrates with nvim-cmp
Plug 'hrsh7th/nvim-cmp' " Main completion engine
Plug 'hrsh7th/cmp-nvim-lsp' " LSP completion source
Plug 'hrsh7th/cmp-buffer' " Buffer completion source
Plug 'hrsh7th/cmp-path' " Path completion source

" Snippet Support
Plug 'L3MON4D3/LuaSnip' " Snippet engine
Plug 'saadparwaiz1/cmp_luasnip' " Bridge for nvim-cmp

call plug#end()

colorscheme github-dimmed 

" Remaps
let mapleader = " "
"n = mode (i, v, c, t)
"nore = no recursive execusion / avoid further remaps
"map = map command
"<leader>pv = left hand side
":Vex<CR> = what is executed
nnoremap <leader>pv :Vex<CR>
nnoremap <leader><CR> :so ~/.config/nvim/init.vim<CR>

" Telescope Mappings
nnoremap <leader>pf <cmd>lua require('telescope.builtin').find_files()<CR>
nnoremap <C-p> <cmd>lua require('telescope.builtin').git_files()<CR>
nnoremap <leader>pg <cmd>lua require('telescope.builtin').live_grep()<CR>
nnoremap <leader>pb <cmd>lua require('telescope.builtin').buffers()<CR>

nnoremap <C-j> :cprev<CR>
nnoremap <C-k> :cnext<CR>
nnoremap <C-E> :copen<CR>
vnoremap <leader>y "+y

nnoremap <leader>d <cmd>lua vim.diagnostic.open_float()<CR>
nnoremap [d <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap ]d <cmd>lua vim.diagnostic.goto_next()<CR>

" LSP Setup
lua <<EOF
-- Autopairs
require('nvim-autopairs').setup{}

-- nvim-cmp setup
local cmp = require'cmp'
local luasnip = require'luasnip'

-- Telescope setup
require('telescope').setup{}

-- Treesitter setup
require('nvim-treesitter.configs').setup {
  ensure_installed = { "lua", "vim", "vimdoc", "rust", "go", "typescript" }, -- Or "all"
  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time. 
    -- Set this to `false` if you only want tree-sitter syntax highlighting.
    -- You can also configure specific languages to have a different setting.
    additional_vim_regex_highlighting = false,
  },
}

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
})

-- LSP Server Setup
require'lspconfig'.gopls.setup{}
require'lspconfig'.rust_analyzer.setup{}
require'lspconfig'.ts_ls.setup{}
require'lspconfig'.lua_ls.setup {
  settings = {
    Lua = {
      workspace = {
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
          ['${3rd}/love2d/library'] = true,
        },
      },
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'love', 'vim' },
      },
    },
  },
}

-- Show diagnostic symbols in the sign column (gutter)
vim.opt.signcolumn = 'yes'

-- Configure how diagnostics are displayed
vim.diagnostic.config({
  -- Show diagnostics in virtual text (inline)
  virtual_text = true,
  -- Show a floating window when hovering over a diagnostic
  float = {
    focusable = false,
    source = "always", -- Or "if_many"
  },
})
EOF
