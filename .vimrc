execute pathogen#infect()
syntax on
filetype plugin indent on

python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup
set laststatus=2
set t_Co=256

let g:solarized_termcolors=256
set background=dark
colorscheme solarized
highlight Normal ctermbg=NONE guibg=Black
highlight NonText ctermbg=NONE guibg=Black
set guifont=Liberation\ Mono\ for\ Powerline\ 13

set nocompatible                " choose no compatibility with legacy vi
set encoding=utf-8
set showcmd                     " display incomplete commands

" Whitespace
set tabstop=4 shiftwidth=4      " a tab is two spaces (or set this to 4)
set expandtab                   " use spaces, not tabs (optional)

" Joining lines
if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j          " Delete comment char when joining commented lines
endif
set nojoinspaces                " Use only 1 space after "." when joining lines, not 2

" Indicator chars
set listchars=tab:▸\ ,trail:•,extends:❯,precedes:❮
set showbreak=↪
set list

" Avoid showing trailing whitespace when in insert mode
au InsertEnter * :set listchars-=trail:•
au InsertLeave * :set listchars+=trail:•

" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

set wrap
set wrapmargin=2
set textwidth=80
set colorcolumn=80
set autoindent
set smartindent

set number
set relativenumber
set cursorline
set scrolloff=3

" make Python follow PEP8 ( http://www.python.org/dev/peps/pep-0008/ )
au FileType python setl softtabstop=4 tabstop=4 shiftwidth=4 textwidth=79

" Treat JSON files like JavaScript
au BufNewFile,BufRead *.json setf javascript

" Some file types use real tabs
au FileType {make,gitconfig} set noexpandtab

" clear the search buffer when hitting return
:nnoremap <CR> :nohlsearch<cr>

" toggle the current fold
:nnoremap <Space> za

command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

" NOTICE: Really useful!

" In visual mode when you press * or # to search for the current selection
vnoremap <silent> * :call VisualSelection('f')<CR>
vnoremap <silent> # :call VisualSelection('b')<CR>

" When you press gv you vimgrep after the selected text
vnoremap <silent> gv :call VisualSelection('gv')<CR>

" Some useful keys for vimgrep
map <leader>g :vimgrep // **/*.<left><left><left><left><left><left><left>
map <leader><space> :vimgrep // <C-R>%<C-A><right><right><right><right><right><right><right><right><right>

" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call VisualSelection('replace')<CR>

" Bash like keys for the command line
cnoremap <C-A>        <Home>
cnoremap <C-E>        <End>
cnoremap <C-K>        <C-U>

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

