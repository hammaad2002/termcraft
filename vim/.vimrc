" Enabling relative number
set relativenumber

" For copying content to my clipboard instead of vim's buffer
vnoremap <leader>tc :w !xclip -i -selection clipboard<CR>

" For displaying the file's name which is currently open in vim editor
set laststatus=2
