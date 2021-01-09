syntax enable                                   " Enables syntax highlighting
set hidden                                      " Required to keep multiple buffers open 
set smarttab
set cindent
set tabstop=2
set shiftwidth=2
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set pumheight=10
set number relativenumber
set splitbelow
set splitright
set shiftwidth=2
set autoindent
set smartindent
set laststatus=0
set nobackup
set nowritebackup
set t_Co=256
set wrap
set linebreak

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

augroup quickfix_tab | au!
    au filetype qf nnoremap <buffer> <C-t> <C-w><CR><C-w>T
augroup END

" Auto source on changes
au! BufWritePost $MYVIMRC source %
