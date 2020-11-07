" vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-endwise'
Plug 'iCyMind/NeoSolarized'
Plug 'scrooloose/nerdtree'
Plug 'von-forks/vim-bracketed-paste'
Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-startify'
Plug 'ntpeters/vim-better-whitespace'
Plug 'godlygeek/tabular'
Plug 'lifepillar/pgsql.vim'
Plug 'ivalkeen/vim-simpledb'
Plug 'easymotion/vim-easymotion'
Plug 'vim-voom/VOoM'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'mg979/vim-visual-multi'
call plug#end()

" Colores
set termguicolors
set t_8f=[38;2;%lu;%lu;%lum
set t_8b=[48;2;%lu;%lu;%lum
set background=light
try
  colorscheme NeoSolarized
catch /^Vim\%((\a\+)\)\=:E185/
  " No hacer nada si no está instalado
endtry
" Mejor resaltado de paréntesis
highlight! MatchParen cterm=NONE,bold gui=NONE,bold ctermbg=NONE guibg=NONE

" Airline
let g:airline_theme='solarized'
let g:airline_powerline_fonts = 1

" Opciones generales
set number                      " Display line numbers on the left side
set cursorline                  " Highlight current line
set colorcolumn=81              " Display text width column
set laststatus=2                " Always display the status line
set ttyfast                     " More characters will be sent to the screen for redrawing
set ttimeout                    " Time waited for key press(es) to complete. It makes for...
set ttimeoutlen=50              " ... a faster key response
set backspace=indent,eol,start  " Make backspace behave properly in insert mode
set showcmd                     " Display incomplete commands
set wildmenu                    " A better menu in command mode
set wildmode=longest:full,full

" Espacios, tabulaciones e indentaciones
set tabstop=4 shiftwidth=4      " Un tabulador son cuatro espacios
set expandtab                   " Usa espacios, no tabuladores

" Unir líneas
if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j          " Borra carácter comentario al unir líneas comentadas
endif
set nojoinspaces                " Usa un solo espacio tras "." al unir líneas, no dos

" Búsquedas
set hlsearch                    " Resalta ajustes
set incsearch                   " Búsqueda incremental
set ignorecase                  " Las búsquedas no distinguen mayúsculas...
set smartcase                   " ... a menos que contengan al menos una mayúscula
nnoremap <CR> :nohlsearch<cr>   " Borra el búfer de búsqueda al pusar Entrar

" Recuerda la última posición cuando se vuelve a abrir un archivo
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" vim-gitgutter
set updatetime=500
if exists('&signcolumn')  " Vim 7.4.2201
  set signcolumn=yes
else
  let g:gitgutter_sign_column_always = 1
endif
let g:gitgutter_async = 0

" NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let g:NERDTreeWinPos = "right"
" NERDTree y Startify juntos
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | Startify | NERDTree | wincmd w | endif

" pgsql.vim
let g:sql_type_default = 'pgsql'

" (vim-simpledb) Ejecuta sentencias SQL con Ctrl-q en lugar de Enter
let g:simpledb_use_default_keybindings = 0
vnoremap <buffer> <c-q> :SimpleDBExecuteSql<cr>
nnoremap <buffer> <c-q> m':SimpleDBExecuteSql <cr>g`'
nnoremap <buffer> <leader><c-q> m':'{,'}SimpleDBExecuteSql<cr>g`'

" Opciones para gvim
if has('gui_running')
  set guifont=LiterationMono\ Nerd\ Font\ Book\ 14
endif
