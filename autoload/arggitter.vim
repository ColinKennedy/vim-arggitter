if !exists('g:arg_list_temp_file')
    let g:arg_list_temp_file = '/tmp/arg_list.txt'
endif


" TODO: Add a plug-in guard
" TODO: Remove 'reload' statements
"
" TODO: See if I can place this into the Python module, instead
"
function! Capture(excmd) abort  " from tpope's scriptease.vim
    try
        redir => out
        exe 'silent! '.a:excmd
    finally
        redir END
    endtry

    return out
endfunction


function! arggitter#is_start_of_arg_list()
python << EOF
import arggitter
reload(arggitter)

if arggitter.is_start_of_arg_list():
    value = 1
else:
    value = 0

vim.command('let l:is_end = {value}'.format(value=value))
EOF

    return l:is_end
endfunction


function! arggitter#is_end_of_arg_list()
python << EOF
import arggitter
reload(arggitter)

if arggitter.is_end_of_arg_list():
    value = 1
else:
    value = 0

vim.command('let l:is_end = {value}'.format(value=value))
EOF

    return l:is_end
endfunction


function! arggitter#enter()
    call s:SaveArgList()
    call s:ClearArgList()
    call s:OverrideArgList()
python << EOF
import arggitter
reload(arggitter)
arggitter.enter_arg_list()
EOF
endfunction


function! arggitter#exit()
    call s:ClearArgList()
    call s:RestoreArgList()
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:ClearArgList()
    %argdelete
endfunction


function! s:OverrideArgList()
python << EOF
import arggitter
reload(arggitter)
arggitter.override_arg_list()
EOF
endfunction


function! s:RestoreArgList()
python << EOF
import arggitter
reload(arggitter)
arggitter.restore_arg_list()
EOF
endfunction


function! s:SaveArgList()
python << EOF
import arggitter
reload(arggitter)
arggitter.save_arg_list()
EOF
endfunction
