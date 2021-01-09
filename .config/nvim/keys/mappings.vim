map <leader>n <cmd>CHADopen<cr>                        		" File navigation in the left side
map <leader>f :CocCommand fzf-preview.ProjectFiles<cr> 		" Fuzzy finder in your current directory
nnoremap <silent> <leader> :WhichKey '<leader>'<CR> 			" Opens \"Which key\" as a menu in the bottom

" Copy Paste
vnoremap <C-c> "*y :let @+=@*<CR>
map <C-v> "*P
map gs 						:below wincmd f<CR> 										" If triggered above a filename, the file will open in a horizonatal split
map gv 						:vertical wincmd f<CR> 									" If triggered above a filename, the file will open in a vertical split
nnoremap <Tab> 		:bnext<CR> 															" Tab cycles through open buffers in NORMAL mode
nnoremap <S-Tab> 	:bprevious<CR> 													" Shift+Tab cycles (ccw) through open buffers in NORMAL mode
map <Leader> <Plug>(easymotion-prefix)uses 								" <leader><leader>s to activate easy motion
nnoremap <C-q> 		:wq!<CR>

" resize windows
nnoremap <M-j> 		:resize -2<CR>
nnoremap <M-k> 		:resize +2<CR>
nnoremap <M-h> 		:vertical resize -2<CR>
nnoremap <M-l> 		:vertical resize +2<CR>

" Easy CAPS
inoremap <c-u> 		<ESC>viwUI
nnoremap <c-u> 		viwUI<ESC>

" Easy Save
nnoremap <C-s> 		:w<CR>

" Better tabbing
vnoremap < <gv
vnoremap > >gv
