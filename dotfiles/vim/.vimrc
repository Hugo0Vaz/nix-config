syntax on

set noerrorbells
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set number relativenumber
set nu rnu
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch

set mouse=a

set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=lightgrey

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
        
    Plug 'morhetz/gruvbox'
    Plug 'scrooloose/nerdtree'
    Plug 'mhinz/vim-startify'
    Plug 'vim-latex/vim-latex'
    Plug 'vim-airline/vim-airline'
    Plug 'preservim/nerdtree'
    Plug 'ryanoasis/vim-devicons'

call plug#end()

colorscheme gruvbox
set background=dark

let mapleader="\<Space>"

" remaps =======================================================================
command! -nargs=0 Format :call CocAction('format')

" remaps de cópia e cola
inoremap <C-v> <ESC>"+pa
vnoremap <C-c> "+y

" coc diagnostic remaps
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" coc code navigation remaps
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" nerdtree remaps
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
