# Vim Local Git History

## What this plugin does

This plugin saves the file worked on in a git repository every time you save.

## Why? Don't you know undo?

Yes, I do know undo, and yes I know persistent undo, too. But there are times, when you replace a file on disk, either by yourself or a git checkout (--force) or you evil twin deletes a file. And here undo does not help.

## How to use it?

Install it, feel saver. If you want to see the history of a file type

```
:LGHistory
```

And then you get an fzf window with all the dates when the file has been stored.

## Todos

- Search for files where you don't have the exact filename
- Allowing diff mode
- Handling of more edge use cases.

## Installation                                         

[fzf-vim](https://github.com/junegunn/fzf.vim) is required.
Use [vim-plug](https://github.com/junegunn/vim-plug) or any other Vim plugin manager.

With vim-plug:

```
Plug 'm42e/vim-lgh'
```

## Options

You can set the backup directory:

```
let g:lgh_basedir = '~/.vim/githistory'
```

You can also set a basedir for a file indivually, either manually or by 
autocmds:

```
autocmd BufEnter *.py let b:lgh_dir = '~/my_python_githistory'
```

You can specify not to use diff as default:

```
let g:lgh_diff = 0
```

See the history by:

```
:LGHistory
```


## Inspirations

- [vim-historic](https://github.com/serby/vim-historic) Which also handles a local history in git. But uses some shell script and I try to avoid that. To at least have a possibility that it may work on windows
- [vim-localhistory](https://github.com/mg979/vim-localhistory) I saw he is using fzf for handling the history files. I really liked the idea, because I thought about how to make vim-historic better but thinking of that I was afraid. vim-localhistory gave me the hint into the right direction.

