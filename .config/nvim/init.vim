source $HOME/.config/nvim/vim-plug/plugins.vim
set number relativenumber
map <leader>n <cmd>CHADopen<cr>
map <leader>s :CocCommand fzf-preview.ProjectFiles<cr>
" Copy Paste
vnoremap <C-c> "*y :let @+=@*<CR>
map <C-v> "*P


" Pluins
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'shmargum/vim-sass-colors'
Plug 'christoomey/vim-tmux-navigator'
Plug 'kien/ctrlp.vim'
Plug 'ervandew/supertab'
Plug 'mattn/emmet-vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'kevinhwang91/rnvimr', {'do': 'make sync'}
source $HOME/.config/nvim/plug-config/ranger.vim
source $HOME/.config/nvim/plug-config/start-screen.vim
source $HOME/.config/nvim/plug-config/fzf.vim
Plug 'airblade/vim-rooter'
Plug 'mhinz/vim-startify'
Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': ':UpdateRemotePlugins'}
Plug 'easymotion/vim-easymotion'
Plug 'vim-syntastic/syntastic'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'vimwiki/vimwiki'
source $HOME/.config/nvim/mkdp.vim
call plug#end()

command! -nargs=0 Prettier :CocCommand prettier.formatFile

set smarttab
set cindent
set tabstop=2
set shiftwidth=2

let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-tsserver',
  \ 'coc-eslint', 
  \ 'coc-prettier', 
  \ 'coc-json', 
  \ ]


set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

augroup quickfix_tab | au!
    au filetype qf nnoremap <buffer> <C-t> <C-w><CR><C-w>T
augroup END
