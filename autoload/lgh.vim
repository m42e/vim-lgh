fun! lgh#get_base_dir()
  let basedir = fnamemodify(expand(get(b:, 'lgh_dir', g:lgh_base)), ":p")
  if basedir !~ '.*/$'
      let basedir = basedir . '/'
  endif
  return basedir
endfun

fun! lgh#make_dir(directory)
  if !isdirectory(a:directory)
    call mkdir(a:directory, "p")
  endif
endfun

fun! lgh#build_git_command(...)
  let git_cmd = get(g:, 'lgh_git_command', 'git')
  return git_cmd . ' --work-tree ' . lgh#get_base_dir()  . ' --git-dir ' . lgh#get_base_dir() . '.git ' . join(a:000)  . ';'
endfun

fun! lgh#build_git_command_list(...)
  let git_cmd = get(g:, 'lgh_git_command', 'git')
  return [git_cmd, '--work-tree', lgh#get_base_dir(), '--git-dir', lgh#get_base_dir() . '.git']+ a:000 
endfun

fun! lgh#git_command(...)
  let s:git_log = system(call ('lgh#build_git_command',a:000), 'silent!')
endfun

fun! lgh#init_git()
  if !isdirectory(lgh#get_base_dir() . '.git')
    call lgh#git_command('init')
    call lgh#git_command('config', '--local', 'user.email', 'local-history-git@noemail.com')
    call lgh#git_command('config', '--local', 'user.name', 'local-history-git')
  endif
endfun

fun! lgh#make_backup_dir(dirname)
  call lgh#make_dir(a:dirname)
  call lgh#init_git()
endfun

fun! lgh#log(what, value)
    if get(g:, 'lgh_verbose', 0) != 0
        echo a:what.": ".a:value
    endif
endfun

fun! lgh#do_commit_history(error, dirname, filename)
  if a:error != 0
    let backupdir = lgh#get_base_dir() . hostname() . '/' . a:dirname
    let backuppath = backupdir . '/' . a:filename
    let callbacks = { 'on_exit': {jobid, error, event -> lgh#log("Saved Backup to ", backupdir)}} 
    call jobstart(lgh#build_git_command_list('commit', '-m', '"Backup '.a:dirname . '/'. a:filename.'"', backuppath), callbacks)
  endif
endfun

fun! lgh#commit_to_history(dirname, filename)
  let backupdir = lgh#get_base_dir() . hostname() . '/' . a:dirname
  let backuppath = backupdir . '/' . a:filename
  let callbacks = { 'on_exit': {jobid, error, event -> lgh#do_commit_history(error, a:dirname, a:filename)} }
  call jobstart(['bash', '-c', lgh#build_git_command('add', backuppath).lgh#build_git_command('diff-index', '--quiet', 'HEAD', '--', backuppath)], callbacks)
endfun

fun! lgh#backup_file(dirname, filename)
  let x = system("[[ \"$USERNAME\" == `who | awk '{print $1}' | head -n 1` ]]")
  if v:shell_error != 0
    echomsg "you are not acting as yourself, no backup will be taken"
    return
  endif
  let backupdir = lgh#get_base_dir() . hostname() . '/' . a:dirname
  let backuppath = backupdir . '/' . a:filename
  call lgh#make_backup_dir(backupdir)
  let callbacks = { 'on_exit': {jobid, error, event -> lgh#commit_to_history(a:dirname, a:filename)} }
  call jobstart(['cp', fnameescape(resolve(expand("%:p"))), fnameescape(backuppath)], callbacks)
endfun

fun! lgh#file_history(dirname, filename)
    let backuppath = lgh#get_base_dir() . hostname() . '/' . a:dirname . '/' . a:filename
    call lgh#git_command('log', '--format="%ar%x09%ad%x09%h"', '--', backuppath)
    let log = split(s:git_log, '\n')
    return log
endfun

fun! lgh#open_backup(dirname, filename, filetype, entry)
    let entry = split(a:entry, '\t')
    let commit = entry[-1]
    let relpath = hostname() . '/' . a:dirname[1:] . '/'. a:filename
		if get(g:, 'lgh_diff', 1)
			diffthis
		endif
    exe 'vnew | r! '.lgh#git_command('show', commit.':'.relpath)
		exe 'normal! 1Gdd'
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=".a:filetype." | file ".a:filename." [".entry[1]."]"
		if get(g:, 'lgh_diff', 1)
			diffthis
		endif
endfun

