if !has('pythonx')
    echo 'Python is not installed. This plug-in requires Python to run. Exitting.'
    finish
endif

if system('git') !~ '\C[-C'  " If there is not `git -C` option
    echo 'Git is too old to run arggitter.'
    finish
endif

if get(g:, 'arggitter_loaded', '0') == '1'
    finish
endif


call arggitter#arggitter#create_git_submode()


let g:arggitter_loaded = '1'
