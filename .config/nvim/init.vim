" VIM config (NeoVIM)

set nocompatible
filetype plugin on

" check if vim-plug exists; if not, install
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
    silent !curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source ~/.config/nvim/init.vim | CocInstall coc-python
endif

" all plugins
call plug#begin("~/.vim/plugged")

    Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'} " python syntax highlight
    Plug 'jiangmiao/auto-pairs' " insert or delete brackets, quotes in pairs
    Plug 'neoclide/coc.nvim', {'branch': 'release'} " completion
    Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' } " PEP8 indentation rules
    Plug 'tomasiser/vim-code-dark' " colorscheme
    Plug 'mg979/vim-visual-multi', {'branch': 'master'} " multi-cursor support
    Plug 'frazrepo/vim-rainbow' " rainbow colored brackets
    Plug 'tpope/vim-commentary' " comments
    Plug 'preservim/tagbar' " find tags in current file
    Plug 'nathanaelkane/vim-indent-guides' " indentation level guides

call plug#end()

set encoding=UTF-8
set noerrorbells " no sound
if (has("termguicolors")) " terminal colors
    set termguicolors
endif
set cursorline " highlight current line
set number " line numbers
set laststatus=2 " always show status bar
set noswapfile " remove swap files
autocmd TermOpen * setlocal nonu " no linenumbers for terminal
set splitright
set splitbelow

" autoload init.vim on save
autocmd BufWritePost init.vim source .config/nvim/init.vim

" always insert mode except netrw, tagbar (reduces one click)
augroup InsBuffer
    autocmd!
    autocmd BufEnter * if &ft != '' && &ft != 'netrw' && &ft != 'tagbar' | startinsert | endif
    autocmd BufEnter * if &buftype == 'terminal' | startinsert | endif
augroup END

" use spaces instead of tabs
set expandtab
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" autoremove trailing spaces on save
function! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun
autocmd BufWritePre * :call CleanExtraSpaces()

" netrw

let g:netrw_banner = 0 " remove top banner
let g:netrw_liststyle = 3 " tree view
set autochdir " change directory to current buffer
" ignore files
let g:netrw_list_hide = '^\.\.\=/\=$,.git,__pycache__,venv,*\.o,*\.pyc,.*\.swp'

" open netrw on startup
autocmd VimEnter * if expand("%") == "" | :Ex | endif

" keybindings

" <ctrl-s>, <ctrl-z>, <ctrl-v>, <ctrl-c>, etc..
" don't judge :')
source $VIMRUNTIME/mswin.vim
behave mswin
map! <C-s> <Esc>:update<CR>

" <ctrl-r> (redo)
map <C-r> <Esc>:redo<CR>
map! <C-r> <Esc>:redo<CR>

" <ctrl-w> (close)
" will not save
map <C-w> <Esc>:q!<CR>
map! <C-w> <Esc>:q!<CR>
tmap <C-w> <Esc>:q!<CR>

" always open empty buffers with netrw

" <ctrl-t> (open new tab)
map <C-t> <Esc>:tabe %:h<CR>
map! <C-t> <Esc>:tabe %:h<CR>
tmap <C-t> <Esc>:tabnew<CR>:Ex . <CR>

" <ctrl-g> (vertical split)
" not intuitive but mehh
map <C-g> <Esc>:vsplit %:h<CR>
map! <C-g> <Esc>:vsplit %:h<CR>
tmap <C-g> <Esc>:vsplit<CR>:Ex . <CR>

" <ctrl-e> (netrw explorer)
map <C-e> <Esc>:Ex %:h<CR>
map! <C-e> <Esc>:Ex %:h<CR>
tmap <C-e> <Esc>:Ex . <CR>

" <ctrl-arrow> (switch between tabs)
map <C-Left> <Esc>:tabprevious<CR>
map <C-Right> <Esc>:tabnext<CR>
map! <C-Left> <Esc>:tabprevious<CR>
map! <C-Right> <Esc>:tabnext<CR>
tmap <C-Left> <Esc>:tabprevious<CR>
tmap <C-Right> <Esc>:tabnext<CR>

" <ctrl-shift-arrow> (switch between splits)
map <C-S-Left> <Esc>:wincmd h<CR>
map <C-S-Right> <Esc>:wincmd l<CR>
map! <C-S-Left> <Esc>:wincmd h<CR>
map! <C-S-Right> <Esc>:wincmd l<CR>
tmap <C-S-Left> <Esc>:wincmd h<CR>
tmap <C-S-Right> <Esc>:wincmd l<CR>

" <ctrl-q> (open terminal)
" again not so intuitive
map <C-q> <Esc>:tab ter<CR>i
" <esc> (exit terminal insert mode)
tnoremap <Esc> <C-\><C-n>

" <tab> and <shift-tab> (indentation)
" <shift-tab> works only on selected text
vnoremap <tab> >gv
vnoremap <s-tab> <gv

" quick access to .zshrc, init.vim, bash_aliases
command! Vimrc :find ~/.config/nvim/init.vim
cnoreabbrev vimrc Vimrc
command! Zshrc :find ~/.zshrc
cnoreabbrev zshrc Zshrc
command! Alias :find ~/.bash_aliases
cnoreabbrev alias Alias

" <ctrl-n> (nvidia-smi)
" my fav :P
nnoremap <silent> <C-n> <Esc>:!nvidia-smi<CR>

" <ctrl-/> comment/uncomment
" works only on selected text
map <C-_> gc
map! <C-_> gc

" <ctrl-pg-up/down> - relocate tabs
map <C-PageUp> <Esc>:tabm +1<CR>
map <C-PageDown> <Esc>:tabm -1<CR>
map! <C-PageUp> <Esc>:tabm +1<CR>
map! <C-PageDown> <Esc>:tabm -1<CR>
tmap <C-PageUp> <Esc>:tabm +1<CR>
tmap <C-PageDown> <Esc>:tabm -1<CR>

" plugin related

" <ctrl-d> - multi select
let g:VM_maps = {}
let g:VM_maps['Find Under'] = '<C-d>'
let g:VM_maps['Find Subword Under'] = '<C-d>'

" rainbow brackets: always
let g:rainbow_active = 1

" coc config <tab> - autocomplete and navigate to next complete item
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction
inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" :<SID>check_back_space() ? "\<Tab>" :coc#refresh()

" <F8> - toggle tagbar
autocmd BufEnter * if &ft != '' && &ft != 'netrw' && &ft != 'tagbar' | :call tagbar#autoopen(0) | endif
let g:tagbar_width=25

" indent guides
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1

" change how vim looks

" colorscheme
set background=dark
colorscheme codedark

" tab colors
highlight TabLineFill guifg=Black guibg=#EBCB8B
highlight TabLine guifg=Black guibg=#D08770
highlight TabLineSel guifg=Black guibg=#BF616A
highlight CursorLine guifg=none guibg=#002943
highlight CursorLineNr gui=bold guifg=DarkRed guibg=#BF616A
