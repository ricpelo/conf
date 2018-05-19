" vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'iCyMind/NeoSolarized'
Plug 'scrooloose/nerdtree'
Plug 'von-forks/vim-bracketed-paste'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-startify'
Plug 'ntpeters/vim-better-whitespace'
Plug 'godlygeek/tabular'
Plug 'lifepillar/pgsql.vim'
call plug#end()

" Powerline
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
set laststatus=2

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

" Opciones generales
set number
set cursorline
set lazyredraw

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

" vim-gitgutter
set updatetime=1000
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
