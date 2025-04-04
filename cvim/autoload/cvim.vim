if exists('g:loaded_cvim') && g:loaded_cvim
    fini
en
let g:loaded_cvim = 1

fu! cvim#init()
    if filereadable(g:vimhome . '/cvimrc.vim')
        exec 'source ' . fnameescape(g:vimhome . '/cvimrc.vim')
    endif

    let s:rootpath = cvim#utils#findroot(getcwd(), '.cvim', 40)
    if type(s:rootpath) != v:t_list || empty(s:rootpath)
        retu
    en

    let root = s:rootpath[1]

    if !isdirectory(root . '/.cvim')
        echom 'CVimrc: Path [' . root . '/.cvim] not a directory. Please remove it first and run :CVNew.'
        retu
    en

    let g:cvimroot = root

    if filereadable(g:cvimroot . '/.cvim/cvimrc.vim')
        exec 'source ' . g:cvimroot . '/.cvim/cvimrc.vim'
    en
endf

fu! cvim#EditGlobal()
    if filereadable(g:vimhome . '/cvimrc.vim')
        exec 'new ' . g:vimhome . '/cvimrc.vim'
    else
        let confirm = input('Config file [' . g:vimhome . "/cvimrc.vim] not found.\n"
                    \ . 'Would you like to create new one? (y/n):') ==? 'y'
        if !confirm
            retu
        en
        call filecopy(g:cvimrc . '/cvimrc.vim', g:vimhome . '/cvimrc.vim')
        exec 'new ' . g:vimhome . '/cvimrc.vim'
    en
endf

fu! cvim#Edit()
    if !exists('g:cvimroot')
        echom 'Cvim root .cvim not found. Please run :CVNew first.'
        retu
    en

    if !isdirectory(g:cvimroot . '/.cvim')
        echom 'Path [' . g:cvimroot . '/.cvim] not a directory. Please remove it and run :CVNew.'
        retu
    en

    if filereadable(g:cvimroot . '/.cvim/cvimrc.vim')
        exec 'new ' . g:cvimroot . '/.cvim/cvimrc.vim'
    else
        let confirm = input('Config file [' . g:cvimroot . "/.cvim/cvimrc.vim] not found.\n"
                    \ . 'Would you like to create new one? (y/n):') ==? 'y'
        if !confirm
            retu
        en
        call filecopy(g:cvimrc . '/cvimrc.vim', g:cvimroot . '/.cvim/cvimrc.vim')
        exec 'new ' . g:cvimroot . '/.cvim/cvimrc.vim'
    en
endf

fu! cvim#New()
    let cwd = getcwd()

    if exists('g:cvimroot')
        echom 'CVimRoot [' . g:cvimroot . '] already exists.'
        retu
    en

    if isdirectory(cwd . '/.cvim')
        let g:cvimroot = cwd
        echom 'CVimRoot [' . g:cvimroot . '] already exists.'
        retu
    en

    if filereadable(cwd . '/.cvim')
        echom 'Path [' . cwd . '/.cvim] not a directory. Please remove it first.'
        retu
    en

    let g:cvimroot = cwd
    call mkdir(g:cvimroot . '/.cvim')
    call filecopy(g:cvimrc . '/rgconf', g:cvimroot . '/.cvim/rgconf')
    call filecopy(g:cvimrc . '/cvimrc.vim', g:cvimroot . '/.cvim/cvimrc.vim')
    exec 'new ' . g:cvimroot . '/.cvim/rgconf'
    exec 'vsplit ' . g:cvimroot . '/.cvim/cvimrc.vim'
endf

fu! cvim#files()
    if exists('g:cvimroot')
        let dir = g:cvimroot
    else
        let dir = getcwd()
    en
    call fzf#vim#files(dir, fzf#vim#with_preview())
endf

fu! cvim#curfiles()
    let dir = getcwd()
    call fzf#vim#files(dir, fzf#vim#with_preview())
endf

fu! cvim#grep()
    let pattern = input('Input pattern:')

    if strlen(pattern) <= 0
        let pattern = getreg('/')
    en

    let pattern = cvim#utils#magicPattern2Perl(pattern)

    let rg_opts = " --column --line-number --no-heading --color=always --smart-case -- "

    if exists('g:cvimroot')
        let rgconf = g:cvimroot . '/.cvim/rgconf'
        call fzf#vim#grep("( cd " . shellescape(g:cvimroot) . " && env RIPGREP_CONFIG_PATH=" . shellescape(rgconf) . " rg " . rg_opts . shellescape(pattern) . " )", fzf#vim#with_preview())
    else
        call fzf#vim#grep("rg " . rg_opts . shellescape(pattern), fzf#vim#with_preview())
    en
endf

fu! cvim#curgrep()
    let pattern = input('Input pattern:')

    if strlen(pattern) <= 0
        let pattern = getreg('/')
    en

    let pattern = cvim#utils#magicPattern2Perl(pattern)

    let rg_opts = " --column --line-number --no-heading --color=always --smart-case -- "

    call fzf#vim#grep("rg " . rg_opts . shellescape(pattern), fzf#vim#with_preview())
endf
