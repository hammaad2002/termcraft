" Enabling relative number
set relativenumber

" For copying content to my clipboard instead of vim's buffer
vnoremap <leader>tc :w !xclip -i -selection clipboard<CR>

" For displaying the file's name which is currently open in vim editor
set laststatus=2

" DOWNLOADING VIM PLUG (VIM'S PLUGIN MANAGER) IF IT HAS NOT BEEN DOWNLOADED
" ALREADY
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
	  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif

"VIM PLUGINS SHOULD BE DEFINE IN THIS SECTION
call plug#begin('~/.vim/plugged')
" ***************************************************************
" ***************************************************************
" ***************************************************************

Plug 'preservim/nerdtree'

" ***************************************************************
" ***************************************************************
" ***************************************************************
" End the plugin section
call plug#end()

" NERDTree config start
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
" NERDTree config end 
