" Plugins
source $HOME/.config/nvim/vim-plug/plugins.vim                              " vim-plug installs all the other plugins
source $HOME/.config/nvim/plug-config/coc.vim                               " Conquerer of completion - code completion
source $HOME/.config/nvim/plug-config/vim-prettier.vim                      " Use <space>p to prettify current buffer
source $HOME/.config/nvim/plug-config/indentline.vim                        " Shows indentation indicators
source $HOME/.config/nvim/plug-config/ranger.vim                            " uses ranger as a filemanager inside vim - <space>r
source $HOME/.config/nvim/plug-config/start-screen.vim                      " The welcome screen that lets you pick last opened buffers
source $HOME/.config/nvim/plug-config/fzf.vim                               " Fuzzy finder functionality with <leader>s
source $HOME/.config/nvim/plug-config/mkdp.vim                              " Markdown live preview. Perfect for writing README's.
source $HOME/.config/nvim/plug-config/vim-which-key.vim
source $HOME/.config/nvim/plug-config/vim-colorizer.vim                     " Shows hex colors in the color of their value
source $HOME/.config/nvim/plug-config/air-line.vim                          " Status bar and tab bar
source $HOME/.config/nvim/plug-config/sneak.vim
source $HOME/.config/nvim/plug-config/sxhkd.vim
source $HOME/.config/nvim/plug-config/vim-bujo.vim
source $HOME/.config/nvim/plug-config/goyo.vim                              " 'No distract'-mode for vim - press Enter
source $HOME/.config/nvim/plug-config/i3-vim-syntax.vim
Plug 'mhinz/vim-signify'                                                    " Git gutter, but better (i've heard)
Plug 'tpope/vim-fugitive'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'shmargum/vim-sass-colors'
Plug 'christoomey/vim-tmux-navigator'
Plug 'kien/ctrlp.vim'
Plug 'mattn/emmet-vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'kevinhwang91/rnvimr', {'do': 'make sync'}
Plug 'airblade/vim-rooter'                                                  " Set current work directory to same as the file opened.
Plug 'mhinz/vim-startify'
Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': ':UpdateRemotePlugins'}
Plug 'vim-syntastic/syntastic'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'vimwiki/vimwiki'
Plug 'justinmk/vim-sneak'

Plug 'joshdick/onedark.vim'

call plug#end()

" Automatically install missing plugins on startup
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif
