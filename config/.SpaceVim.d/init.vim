"=============================================================================
" dark_powered.vim --- Dark powered mode of SpaceVim
" Copyright (c) 2016-2017 Wang Shidong & Contributors
" Author: Wang Shidong < wsdjeg at 163.com >
" URL: https://spacevim.org
" License: GPLv3
"=============================================================================


" SpaceVim Options: {{{
let g:spacevim_enable_debug = 1
let g:spacevim_realtime_leader_guide = 1
let g:spacevim_enable_tabline_filetype_icon = 0
let g:spacevim_enable_statusline_display_mode = 0
let g:spacevim_enable_os_fileformat_icon = 0
let g:spacevim_buffer_index_type = 1
let g:spacevim_enable_vimfiler_welcome = 1
let g:spacevim_disabled_plugins = ['fcitx.vim']
let g:spacevim_custom_plugins = [
  \ ['ryanoasis/vim-devicons'],
  \ ]
let g:spacevim_default_indent = 4
" }}}

" SpaceVim Layers: {{{
call SpaceVim#layers#load('colorscheme')
call SpaceVim#layers#load('ui')
call SpaceVim#layers#load('lang#markdown')
call SpaceVim#layers#load('VersionControl')
call SpaceVim#layers#load('git')
call SpaceVim#layers#load('github')
" }}}

set termguicolors
let g:spacevim_colorscheme = 'NeoSolarized'
let g:spacevim_colorscheme_bg = 'light'

autocmd! ColorScheme * highlight MatchParen cterm=bold ctermbg=NONE ctermfg=magenta guibg=NONE guifg=magenta
