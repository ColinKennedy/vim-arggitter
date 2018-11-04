if !exists('g:arg_list_temp_file')
    let g:arg_list_temp_file = '/tmp/arg_list.txt'
endif


function! Capture(excmd) abort  " from tpope's scriptease.vim
    try
        redir => out
        exe 'silent! '.a:excmd
    finally
        redir END
    endtry

    return out
endfunction


" bool: Find if the user has no more files to search through in the arg-list.
function! arggitter#utility#is_start_of_arg_list()
pythonx << EOF
from arggitter import arg_list

if arg_list.is_start_of_arg_list():
    value = 1
else:
    value = 0

vim.command('let l:is_end = {value}'.format(value=value))
EOF

    return l:is_end
endfunction


" bool: Find if the user has no more files to search through in the arg-list.
function! arggitter#utility#is_end_of_arg_list()
pythonx << EOF
from arggitter import arg_list

if arg_list.is_end_of_arg_list():
    value = 1
else:
    value = 0

vim.command('let l:is_end = {value}'.format(value=value))
EOF

    return l:is_end
endfunction


" Initialize 'ARGGITTER' mode by saving the user's arg-list and replacing it with our own.
function! arggitter#utility#enter()
    call s:SaveArgList()
    call s:ClearArgList()
    call s:OverrideArgList()
pythonx << EOF
from arggitter import arggitter
arggitter.enter_arg_list()
EOF
endfunction


" Change the arg-list back to the user's original arg-list.
function! arggitter#utility#exit()
    call s:ClearArgList()
    call s:RestoreArgList()
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Delete all items in the user's arg-list.
function! s:ClearArgList()
    %argdelete
endfunction


" Add all files with unstaged changes in the Git repository to Vim's arg-list.
"
" Note:
"     The repository that is searched for is relative to the user's current buffer.
"
function! s:OverrideArgList()
pythonx << EOF
from arggitter import arggitter
arggitter.override_arg_list()
EOF
endfunction


" Read the user's saved arg-list and apply it to the current session.
function! s:RestoreArgList()
pythonx << EOF
from arggitter import arggitter
arggitter.restore_arg_list()
EOF
endfunction


" Write the user's current arg-list to a temp file.
"
" Important:
"     This function relies on "g:arg_list_temp_file" to write to disk.
"
function! s:SaveArgList()
pythonx << EOF
from arggitter import arggitter
arggitter.save_arg_list()
EOF
endfunction
