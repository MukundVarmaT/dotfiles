"  __     __  ______  __       __         ______    ______   __    __  ________  ______   ______
" /  |   /  |/      |/  \     /  |       /      \  /      \ /  \  /  |/        |/      | /      \
" $$ |   $$ |$$$$$$/ $$  \   /$$ |      /$$$$$$  |/$$$$$$  |$$  \ $$ |$$$$$$$$/ $$$$$$/ /$$$$$$  |
" $$ |   $$ |  $$ |  $$$  \ /$$$ |      $$ |  $$/ $$ |  $$ |$$$  \$$ |$$ |__      $$ |  $$ | _$$/
" $$  \ /$$/   $$ |  $$$$  /$$$$ |      $$ |      $$ |  $$ |$$$$  $$ |$$    |     $$ |  $$ |/    |
"  $$  /$$/    $$ |  $$ $$ $$/$$ |      $$ |   __ $$ |  $$ |$$ $$ $$ |$$$$$/      $$ |  $$ |$$$$ |
"   $$ $$/    _$$ |_ $$ |$$$/ $$ |      $$ \__/  |$$ \__$$ |$$ |$$$$ |$$ |       _$$ |_ $$ \__$$ |
"    $$$/    / $$   |$$ | $/  $$ |      $$    $$/ $$    $$/ $$ | $$$ |$$ |      / $$   |$$    $$/
"     $/     $$$$$$/ $$/      $$/        $$$$$$/   $$$$$$/  $$/   $$/ $$/       $$$$$$/  $$$$$$/

" => required stuff
set nocompatible

" => if vimplug does not exist => install and setup neovim
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
    silent !curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source ~/.config/nvim/init.vim
    autocmd VimEnter * CocInstall coc-pyright
endif

" => all plugins
call plug#begin("~/.vim/plugged")

Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}
Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }
Plug 'tomasiser/vim-code-dark'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'frazrepo/vim-rainbow'
Plug 'tpope/vim-commentary'
Plug 'preservim/tagbar'
Plug 'nathanaelkane/vim-indent-guides'

call plug#end()

filetype plugin indent on
syntax on
set noswapfile
set laststatus=2 " always show status line
set encoding=UTF-8
if (has("termguicolors")) " terminal colors
    set termguicolors
endif
set number " show line numbers
" autoload vimrc on save
autocmd BufWritePost init.vim source .config/nvim/init.vim
" always open file in insert mode except if netrw
augroup InsBuffer
    autocmd!
    autocmd BufEnter * if &ft != '' && &ft != 'netrw' && &ft != 'tagbar' | startinsert | endif
    autocmd BufEnter * if &buftype == 'terminal' | startinsert | endif
augroup END

" => tabs, spaces, indents

set expandtab " use spaces instead of tabs
set smarttab
" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4
" clear unwanted spaces on save
function! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun
autocmd BufWritePre * :call CleanExtraSpaces()

" => netrw

" remove top banner
let g:netrw_banner = 0
" tree view
let g:netrw_liststyle = 3
" don't display certain files
let g:netrw_list_hide='__pycache__/*'
" open netrw on startup if empty buffer
augroup InitNetrw
    autocmd!
    autocmd VimEnter * if expand("%") == "" | :Ex | endif
augroup END

" => keybindings

" don't judge i like ctrl-s, ctrl-z, etc..
source $VIMRUNTIME/mswin.vim
behave mswin
map! <C-s> <Esc>:update<CR>
map <C-r> <Esc>:redo<CR>
map! <C-r> <Esc>:redo<CR>

" ctrl-w - close (need not save)
map <C-w> <Esc>:q!<CR>
map! <C-w> <Esc>:q!<CR>
:tmap <C-w> <Esc>:q!<CR>

" ctrl-t - new tabs with netrw
map <C-t> <Esc>:tabe %:h<CR>
map! <C-t> <Esc>:tabe %:h<CR>
:tmap <C-t> <Esc>:tabnew<CR>:Ex . <CR>

" ctrl-g - vertical split with netrw (not intuitive but meh)
map <C-g> <Esc>:vsplit %:h<CR>
map! <C-g> <Esc>:vsplit %:h<CR>
:tmap <C-g> <Esc>:vsplit<CR>:Ex . <CR>

" ctrl-e - open netrw explorer on current buffer
map <C-e> <Esc>:Ex %:h<CR>
map! <C-e> <Esc>:Ex %:h<CR>
:tmap <C-e> <Esc>:Ex . <CR>

" when switching between tabs or splits enter in insert mode
" ctrl-<arrow> - switch between tabs
map <C-Left> <Esc>:tabprevious<CR>
map <C-Right> <Esc>:tabnext<CR>
map! <C-Left> <Esc>:tabprevious<CR>
map! <C-Right> <Esc>:tabnext<CR>
:tmap <C-Left> <Esc>:tabprevious<CR>
:tmap <C-Right> <Esc>:tabnext<CR>

" ctrl-shift-<arrow> - switch between splits
map <C-S-Left> <Esc>:wincmd h<CR>
map <C-S-Right> <Esc>:wincmd l<CR>
map! <C-S-Left> <Esc>:wincmd h<CR>
map! <C-S-Right> <Esc>:wincmd l<CR>
:tmap <C-S-Left> <Esc>:wincmd h<CR>
:tmap <C-S-Right> <Esc>:wincmd l<CR>

" ctrl-q - open terminal in current buffer (again not soo intuitive)
map <C-q> <Esc>:tab ter<CR>i
" esc - to escape from terminal insert mode
:tnoremap <Esc> <C-\><C-n>

" tab and shift-tab to indentation (shift-tab works only on selected text)
vnoremap <tab> >gv
vnoremap <s-tab> <gv

" quick remaps to open .zshrc or init.vim
command! Vimrc :find ~/.config/nvim/init.vim
cnoreabbrev vimrc Vimrc
command! Zshrc :find ~/.zshrc
cnoreabbrev zshrc Zshrc
command! Alias :find ~/.bash_aliases
cnoreabbrev alias Alias

" ctrl-n - nvidia-smi(my fav)
nnoremap <silent> <C-n> <Esc>:!nvidia-smi<CR>

" comment/uncomment
map <C-_> gc
map! <C-_> gc

" ctrl-<pg-up/down> - relocate tabs
map <C-PageUp> <Esc>:tabm +1<CR>
map <C-PageDown> <Esc>:tabm -1<CR>
map! <C-PageUp> <Esc>:tabm +1<CR>
map! <C-PageDown> <Esc>:tabm -1<CR>
:tmap <C-PageUp> <Esc>:tabm +1<CR>
:tmap <C-PageDown> <Esc>:tabm -1<CR>

" => plugin related

" ctrl-d - multi select
let g:VM_maps = {}
let g:VM_maps['Find Under'] = '<C-d>'
let g:VM_maps['Find Subword Under'] = '<C-d>'

" rainbow brackets - always
let g:rainbow_active = 1

" coc config
call coc#config('python', {'pythonPath': split(execute('!which python3'), '\n')[-1]})
" tab to autocomplete and move to the next
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction
inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" :<SID>check_back_space() ? "\<Tab>" :coc#refresh()

" tag bar remap to F8
nmap <F8> :TagbarToggle<CR>

" indent guides
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1

" => change how vim looks

" colorscheme
set background=dark
colorscheme codedark

" tab colors
:hi TabLineFill guifg=Black guibg=#EBCB8B
:hi TabLine guifg=Black guibg=#D08770
:hi TabLineSel guifg=Black guibg=#BF616A
