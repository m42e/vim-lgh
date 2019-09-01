fun! lgh#get_base_dir()
  return fnamemodify(expand(get(b:, 'lgh_dir', g:lgh_base)), ":p")
endfun

fun! lgh#make_dir(...)
  let dir2create = get(a:, 1, lgh#get_base_dir())
  if !isdirectory(dir2create)
    if g:lgh_verbose == 1
      echom "Make dir ".dir2create
    endif
    call mkdir(dir2create, "p")
  endif
endfun

fun! lgh#build_git_command(...)
  let git_cmd = get(g:, 'lgh_git_command', 'git') 
  return git_cmd . ' --work-tree ' . lgh#get_base_dir()  . ' --git-dir ' . lgh#get_base_dir() . '/.git ' . join(a:000)  
endfun

fun! lgh#git_command(...)
  let s:git_log = system(call ('lgh#build_git_command',a:000), 'silent!')
endfun

fun! lgh#init_git()
  if !isdirectory(lgh#get_base_dir() . '/.git')
    call lgh#git_command('init')
  endif
endfun

fun! lgh#make_backup_dir(...)
  call lgh#make_dir()
  call lgh#init_git()
  if a:0 == 1
    call lgh#make_dir(lgh#get_base_dir() . a:1)
  endif
endfun

fun! lgh#backup_file(dirname, filename)
  let backuppath = lgh#get_base_dir() . a:dirname . '/'. a:filename
  call lgh#make_backup_dir(a:dirname)
  silent exec 'write! '.backuppath
  call lgh#git_command('add', backuppath)
  call lgh#git_command('diff-index', '--quiet', 'HEAD', '--', backuppath)
  if v:shell_error != 0
    call lgh#git_command('commit', '-m', '"Backup '.a:dirname . '/'. a:filename.'"', backuppath)
  endif
  redraw
endfun

fun! lgh#file_history(dirname, filename)
    let backuppath = lgh#get_base_dir() . a:dirname . '/'. a:filename
    call lgh#git_command('log', '--format="%ar	%ad		%h"', '--', backuppath)
    let log = split(s:git_log, '\n')
    return log[2:]
endfun

fun! lgh#open_backup(dirname, filename, filetype, entry)
    let entry = split(a:entry, '\t')
    let commit = entry[-1]
    let relpath = a:dirname[1:] . '/'. a:filename
		if get(g:, 'lgh_diff', 1)
			diffthis
		endif
    exe 'vnew | r! '.lgh#build_git_command('show', commit.':'.relpath)
		exe 'normal! 1Gdd'
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=".a:filetype." | file ".a:filename." [".entry[1]."]"
		if get(g:, 'lgh_diff', 1)
			diffthis
		endif
endfun

