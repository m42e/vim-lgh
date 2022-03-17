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

let hasluafzf = luaeval("pcall(require,'fzf-lua')")
if hasluafzf
lua << ENDL
function _G.open_backup(selected, opts)
	vim.fn['lgh#open_backup'](vim.fn.expand("%:p:h"), vim.fn.expand("%:t"), vim.bo.filetype, selected[1])
end
ENDL

com! LGHistory lua require('fzf-lua').git_files({
		\ cmd = 'git log --format="%ar%x09%ad%x09%h" -- ' .. vim.g.lgh_base .. '/' .. vim.fn.hostname() ..  '/' .. vim.fn.expand("%:p:h") .. '/' ..  vim.fn.expand("%:t"),
		\ cwd = vim.g.lgh_base,
		\ prompt = "Saved History >>> ",
		\ previewer = false,
		\ actions = {
		\   ["default"]= open_backup,
		\ } } )
else
com! LGHistory call fzf#run({'source': lgh#file_history(expand("%:p:h"), expand("%:t")),
            \ 'sink': function('lgh#open_backup', [expand("%:p:h"), expand("%:t"), &ft]), 'down': '30%',
            \ 'options': '--multi --reverse --delimiter="\t" --no-preview --prompt "Saved History >>> "'})

endif


com! LGHFix call lgh#commit_all_dangling()

augroup local-git-history
    autocmd!
    autocmd BufWritePost * call lgh#backup_file(expand("%:p:h"), expand("%:t"))
augroup END


