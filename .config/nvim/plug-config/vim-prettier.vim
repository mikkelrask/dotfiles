Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
map <space>p :Prettier<cr>
command! -nargs=0 Prettier :CocCommand prettier.formatFile
