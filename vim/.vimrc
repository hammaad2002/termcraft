set relativenumber

augroup explorer
    autocmd!
    autocmd FileType netrw setlocal relativenumber number
augroup END

vnoremap <leader>tc :w !xclip -i -selection clipboard<CR>
