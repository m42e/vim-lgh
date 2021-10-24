" vim-local-git-history

" Loading guard
if exists('g:lgh_loaded')
    finish
endif
let g:lgh_loaded = 1

" User variables
let g:lgh_base = get(g:, 'lgh_basedir', '~/.vim/githistory')
let g:lgh_verbose = get(g:, 'lgh_verbose', 0)
let g:lgh_fix_ownership = get(g:, 'lgh_fix_ownership', 1)


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

com! LGHistory call fzf#run({'source': lgh#file_history(expand("%:p:h"), expand("%:t")),
            \ 'sink': function('lgh#open_backup', [expand("%:p:h"), expand("%:t"), &ft]), 'down': '30%',
            \ 'options': '--multi --reverse --delimiter="\t" --no-preview --prompt "Saved History >>> "'})

com! LGHFix call lgh#commit_all_dangling()

augroup local-git-history
    autocmd!
    autocmd BufWritePost * call lgh#backup_file(expand("%:p:h"), expand("%:t"))
augroup END


