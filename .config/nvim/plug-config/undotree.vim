Plug 'mbbill/undotree'

if has("persistent_undo"){
  set undodir=$HOME/.config/nvim/undodir
  set undofile
}
nnoremap <C-z> :UndotreeToggle<CR>
