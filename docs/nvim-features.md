# Neovim Features

Lista completa de funcionalidades configuradas em `modules/dotfiles/nvim/`.

Gerado em 2026-06-17.

---

## 📦 Gerenciador de Plugins
- **lazy.nvim** — carregamento lazy de plugins

## 🎨 Interface / UI
- **Gruvbox** — colorscheme dark
- **Lualine** — statusline customizada (tema próprio `ugoline`) com:
  - Modo atual com cor por modo (Normal, Insert, Visual, Command, Replace, Terminal…)
  - Nome do arquivo com status (modificado, readonly)
  - Branch Git e diff (adições/modificações/remoções)
  - Cliente LSP ativo
  - Diagnósticos (erros, warnings, info)
  - Filetype, fileformat, encoding, location (linha/coluna)
- **mini.animate** — animações suaves de scroll (150ms), resize e cursor (exceto scroll com mouse)

## 🌳 Treesitter (Syntax Highlighting + Parsing)
- **nvim-treesitter** — parsers instalados: `bash`, `c`, `cpp`, `css`, `go`, `html`, `javascript`, `json`, `lua`, `markdown`, `nix`, `python`, `regex`, `rust`, `tsx`, `typescript`, `vim`, `vimdoc`, `yaml`
- **Folding** via Treesitter (`foldmethod=expr`)
- **Indentação** via Treesitter
- **Seleção incremental** (`<C-space>` expande região sintática, `<bs>` reduz)
- **Textobjects** comentados (mini.ai supre)
- **Queries customizadas para Blade** (Laravel) — highlights, folds, injections (PHP dentro das directives)

## 🔍 Busca / Navegação
- **Telescope.nvim** com:
  - `find_files` (inclui hidden), `live_grep`, `grep_string`
  - `buffers`, `oldfiles`, `help_tags`, `keymaps`
  - `diagnostics`, `resume`
  - `current_buffer_fuzzy_find`
  - `live_grep` em open files
  - `find_files` no diretório de config do Neovim
  - Extensões: `fzf-native` (performance), `ui-select`, `telescope-luasnip`

## 🧠 LSP (Language Server Protocol)
- **nvim-lspconfig** com servidores configurados:
  - **nixd** — Nix (com `nixpkgs-fmt` para formatting)
  - **lua_ls** — Lua (LuaJIT, diagnostics globals `vim`, hints habilitados)
  - **phpactor** — PHP (com PHPStan)
  - **gopls** — Go (unusedparams, shadow, staticcheck, gofumpt, hints)
  - **rust_analyzer** — Rust (clippy, proc macros, inlay hints completos)
  - **ts_ls** — TypeScript/JavaScript (inlay hints)
  - **html** — HTML
  - **cssls** — CSS/SCSS/Less (validação, lint)
  - **tailwindcss** — Tailwind (classRegex para `cva()` e `cx()`)
  - **pyright** — Python (type checking, workspace diagnostics)
- **Inlay hints** — toggle com `<leader>th`
- **Code lens** — run com `<leader>cl`, auto-refresh
- **Document highlight** — destaca referências ao cursor (CursorHold)
- **Keymaps LSP**: goto definition (`gd`), references (`gr`), implementation (`gI`), declaration (`gD`), type definition (`<leader>D`), rename (`<leader>rn`), code action (`<leader>ca`), hover (`K`), signature help (`<leader>K`), document/workspace symbols

## ✍️ Autocompletar / Snippets
- **nvim-cmp** — engine de completions
  - Sources: `nvim_lsp`, `luasnip`, `path`, `neorg`
  - Mappings: `<C-n>`/`<C-p>` navegação, `<Tab>` aceita, `<S-Tab>` navega reversa, `<C-Space>` força completa
- **LuaSnip** — snippets com expansão e navegação entre placeholders (`<C-l>`/`<C-h>`)
- **friendly-snippets** — coleção de snippets VSCode

## �� Edição / Formatação
- **conform.nvim** — formatting:
  - Format on save (exceto C/C++)
  - Formatters: `stylua` (Lua), `autopep8` (Python), `php_cs_fixer` (PHP), `blade-formatter` (Blade), `nixpkgs_fmt` (Nix), `prettierd` (JS), `html_beautify` (HTML), `yamlfix` (YAML)
  - Comando `:Format` com suporte a range
  - Keymap `<leader>bf` para formatar buffer manualmente
- **Comment.nvim** — toggle comments
- **nvim-autopairs** — fecha pares automaticamente (`(`, `{`, `[`, `"`, `'`, etc.)
- **mini.ai** — textobjects melhorados (`va)`, `ci'`, `yiq`, etc., com `n_lines=500`)
- **mini.surround** — surround (`sa`, `sd`, `sr`)
- **indent-blankline.nvim** — guias de indentação visíveis

## 📂 Arquivos / Buffer
- **neo-tree.nvim** — file tree lateral (`<leader>n`):
  - Segue arquivo atual automaticamente
  - File watcher via libuv
  - Dotfiles e gitignored visíveis
  - Hijack do netrw
- **oil.nvim** — editor de diretório como buffer (`<leader>bo`)
- **scratch.nvim** — buffer scratch (`<leader>bs` normal, `<leader>bS` split)
- **vim-sleuth** — detecção automática de indentação do arquivo

## 🐙 Git
- **gitsigns.nvim** — signs de Git na gutter:
  - Navegação por hunks (`]h`, `[h`, `]H`, `[H`)
  - Stage/reset hunks (`<leader>ghs`/`<leader>ghr`)
  - Stage/reset buffer (`<leader>gbs`/`<leader>ghR`)
  - Blame (`<leader>glb` linha, `<leader>glB` buffer)
  - Diff (`<leader>ghd`/`<leader>ghD`)
  - Preview inline (`<leader>ghp`), select hunk (`ih`/`ah`)
- **lazygit.nvim** — terminal Git TUI (`<leader>gl`)
- **diffview.nvim** — visualizador de diffs

## 🚨 Diagnóstico / Troubleshooting
- **trouble.nvim** — painel de diagnósticos, symbols, LSP, loclist, quickfix:
  - `<leader>xx` diagnostics, `<leader>xX` buffer diagnostics
  - `<leader>cs` symbols, `<leader>cS` LSP references
  - `<leader>xL` loclist, `<leader>xQ` quickfix
  - Navegação `[q`/`]q` integrada com quickfix tradicional
- **todo-comments.nvim** — destaca comentários TODO/FIX/FIXME/etc:
  - Navegação `]t`/`[t`
  - Integração com Telescope (`<leader>st`, `<leader>sT`) e Trouble (`<leader>xt`, `<leader>xT`)
- **Diagnósticos LSP na statusline** (lualine)

## ⌨️ Keymaps / Mnemônicos
- **which-key.nvim** — popup de ajuda com grupos:
  - `[C]ode`, `[D]ocument`, `[R]ename`, `[S]earch`, `[W]orkspace`, `[G]it`, `[B]uffer`, `[T]oggle`
- **Navegação**: `<C-h/j/k/l>` entre janelas, `]d`/`[d` diagnósticos, `<leader>bn/bp/bd` buffers
- **Toggle wrap**: `<leader>tw`
- **Unhighlight search**: `<Esc>` em normal mode
- **Setas desabilitadas** em normal mode (força uso de `hjkl`)
- **Terminal**: `<Esc><Esc>` sai do modo terminal

## ⚙️ Opções Gerais
- `number` + `relativenumber`, mouse habilitado, clipboard integrado
- `undofile` (undo persistente), `ignorecase` + `smartcase`
- `signcolumn=yes`, `cursorline`, `colorcolumn=80`
- `scrolloff=10`, `updatetime=250`, `timeoutlen=300`
- Splits abrem à direita e abaixo
- Tab/indent: 4 espaços (`tabstop`/`shiftwidth`/`expandtab`)
- Listchars visíveis (tabs `» `, trailing `·`)
- `inccommand=split` (preview de substituições)
- Highlight ao yank (TextYankPost)

## 🧩 Filetypes Customizados / Suporte extra
- **Alpha-nvim** — dashboard inicial (tema startify)
- **Filetypes**: `.blade.php` → `blade`, `.templ` → `templ`, `_SCRATCH_` → `markdown`
- **Bash** registrado como `sh` no Treesitter
