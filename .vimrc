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

