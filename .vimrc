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

set nocompatible                " choose no compatibility with legacy vi
set encoding=utf-8
set showcmd                     " display incomplete commands
filetype plugin indent on       " load file type plugins + indentation

" Whitespace
set tabstop=4 shiftwidth=4      " a tab is two spaces (or set this to 4)
set expandtab                   " use spaces, not tabs (optional)

" Joining lines
if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j          " Delete comment char when joining commented lines
endif
set nojoinspaces                " Use only 1 space after "." when joining lines, not 2

" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

set number
set relativenumber
set cursorline
set scrolloff=3

" clear the search buffer when hitting return
:nnoremap <CR> :nohlsearch<cr>

" toggle the current fold
:nnoremap <Space> za

command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>

