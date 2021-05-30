if !has('pythonx')
    silent !echo 'Python is not installed. This plug-in requires Python to run. Exitting.'

    finish
endif

if system('git') !~ '\C[-C'  " If there is not `git -C` option
    silent !echo 'Git is too old to run arggitter.'

    finish
endif

if get(g:, 'arggitter_loaded', '0') == '1'
    finish
endif

let g:arggitter_highlight_lines = get(g:, 'arggitter_highlight_lines', 1)


call arggitter#arggitter#create_git_submode()

" This function + autocmd fixes an issue where, if you swap buffers,
" gitgutter's highlighted lines will stick around even though you've
" already exitted the submode. It's basically a fix to get around a bug
" in vim-submode.
"
function! s:FixToggle()
  if g:gitgutter_highlight_lines && submode#current() != "ARGGITTER"
    call gitgutter#highlight#line_disable()
  endif
endfunction

autocmd! BufEnter *.* call s:FixToggle()


let g:arggitter_loaded = '1'
