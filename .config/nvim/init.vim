"  __     __  ______  __       __         ______    ______   __    __  ________  ______   ______  
" /  |   /  |/      |/  \     /  |       /      \  /      \ /  \  /  |/        |/      | /      \ 
" $$ |   $$ |$$$$$$/ $$  \   /$$ |      /$$$$$$  |/$$$$$$  |$$  \ $$ |$$$$$$$$/ $$$$$$/ /$$$$$$  |
" $$ |   $$ |  $$ |  $$$  \ /$$$ |      $$ |  $$/ $$ |  $$ |$$$  \$$ |$$ |__      $$ |  $$ | _$$/ 
" $$  \ /$$/   $$ |  $$$$  /$$$$ |      $$ |      $$ |  $$ |$$$$  $$ |$$    |     $$ |  $$ |/    |
"  $$  /$$/    $$ |  $$ $$ $$/$$ |      $$ |   __ $$ |  $$ |$$ $$ $$ |$$$$$/      $$ |  $$ |$$$$ |
"   $$ $$/    _$$ |_ $$ |$$$/ $$ |      $$ \__/  |$$ \__$$ |$$ |$$$$ |$$ |       _$$ |_ $$ \__$$ |
"    $$$/    / $$   |$$ | $/  $$ |      $$    $$/ $$    $$/ $$ | $$$ |$$ |      / $$   |$$    $$/ 
"     $/     $$$$$$/ $$/      $$/        $$$$$$/   $$$$$$/  $$/   $$/ $$/       $$$$$$/  $$$$$$/  

" first things first
if (has("termguicolors"))
  set termguicolors
endif
set encoding=UTF-8
set nocompatible
filetype plugin on

" #########################
" PLUGINS
" #########################

call plug#begin("~/.vim/plugged")
Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins', 'for': 'python'}
Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }
Plug 'tomasiser/vim-code-dark'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'nathanaelkane/vim-indent-guides'
call plug#end() 

" #########################
" SET SOME DEFAULTS
" #########################

" always start in insert mode (reduces one keypress)
au BufRead,BufNewFile * startinsert

" Don't judge I like ctrl-s, ctrl-z, etc.....
source $VIMRUNTIME/mswin.vim
behave mswin  
" Make it work in insert mode as well
map! <C-S> <Esc>:update<CR>

" ctrl-w to close
map <C-w> <Esc>:q<CR>
map! <C-w> <Esc>:q<CR>
:tmap <C-w> <Esc>:q<CR>

" ctrl-t to open new tabs
map <C-t> <Esc>:tabnew<CR>:Ex . <CR>
map! <C-t> <Esc>:tabnew<CR>:Ex . <CR>
:tmap <C-t> <Esc>:tabnew<CR>:Ex . <CR>

" shift-v to open vertical split with netrw
map <S-v> <Esc>:vnew<CR>:Ex . <CR>
map! <S-v> <Esc>:vnew<CR>:Ex . <CR>
:tmap <S-v> <Esc>:vnew<CR>:Ex . <CR>

" switch tabs/splits with ctrl-<arrow>
map <C-Left> <Esc>:tabprevious<CR> \| <Esc>:wincmd h<CR>                                                                            
map <C-Right> <Esc>:tabnext<CR> \| <Esc>:wincmd l<CR>
map! <C-Left> <Esc>:tabprevious<CR> \| <Esc>:wincmd h<CR>                                                                            
map! <C-Right> <Esc>:tabnext<CR> \| <Esc>:wincmd l<CR>
:tmap <C-Left> <Esc>:tabprevious<CR> \| <Esc>:wincmd h<CR>                                                                            
:tmap <C-Right> <Esc>:tabnext<CR> \| <Esc>:wincmd l<CR>

" file manager - netrw
" remove top banner   
let g:netrw_banner = 0
" tree view   
let g:netrw_liststyle = 3
" don't display certain files
let g:netrw_list_hide='__pycache__/*'
let g:netrw_list_hide.=',' . '\(^\|\s\s\)\zs\.\S\+'
   
" ctrl-d for multi select
let g:VM_maps = {}   
let g:VM_maps['Find Under'] = '<C-d>'
let g:VM_maps['Find Subword Under'] = '<C-d>'
 
" indent guides lines TODO: rainbow
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1

" ctrl-q to open a new terminal (not soo intuitive but mehh)
map <C-q> <Esc>:tab ter<CR>
" exit insert mode from terminal
:tnoremap <Esc> <C-\><C-n>

" tab and shift-tab for selected block
vmap <Tab> >gv
vmap <S-Tab> <gv

call coc#config('python', {'pythonPath': split(execute('!which python3'), '\n')[-1]})

" #########################
" HELPERS
" #########################
nnoremap <silent> <C-n> <Esc>:!python3 ~/scripts/sys-monitor.py<CR>

" #########################
" MISCELLANEOUS
" #########################

" colorscheme
colorscheme codedark

" tab bar of vim
:hi TabLineFill guifg=Black guibg=#EBCB8B
:hi TabLine guifg=Black guibg=#D08770
:hi TabLineSel guifg=Black guibg=#BF616A
