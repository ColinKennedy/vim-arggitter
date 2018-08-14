" Enter it using 'gt' and exit it, using '<ESC>'
"     a = stage the current hunk
"     n = go to the next hunk (if needed, wrap to the beginning of the file)
"     N = go to the previous hunk
"     p = go to the previous hunk
"     u = undo (reset) hunk
"
"     c = Create a commit window
"     s = Show the repo-status
"     b = Run Git blame in a customized window
"     wa = Git add %:p:h
"     l = Shows the repository log
"
function! arggitter#arggitter#create_git_submode()
    call submode#enter_with('GIT', 'n', '', 'gm', '<ESC>:call arggitter#utility#enter()<CR>')
    call submode#leave_with('GIT', 'n', '', '<ESC>', '<ESC>:call arggitter#utility#exit()<CR>')
    call submode#map('GIT', 'n', '', 'a', '<ESC>:GitGutterStageHunk<CR>:call arggitter#arggitter#next_hunk()<CR>zz')
    call submode#map('GIT', 'n', '', 'n', '<ESC>:call arggitter#arggitter#next_hunk()<CR>zz')
    call submode#map('GIT', 'n', '', 'N', '<ESC>:call arggitter#arggitter#previous_hunk()<CR>zz')
    call submode#map('GIT', 'n', '', 'p', '<ESC>:call arggitter#arggitter#previous_hunk()<CR>zz')
    call submode#map('GIT', 'n', '', 'u', '<ESC>:GitGutterUndoHunk<CR>gm')

    call submode#map('GIT', 'n', '', 'b', '<ESC>:Gblame<CR>')
    call submode#map('GIT', 'n', '', 'c', '<ESC>:Gcommit<CR>')
    call submode#map('GIT', 'n', '', 's', '<ESC>:Gstatus<CR>')
    call submode#map('GIT', 'n', '', 'wa', '<ESC>:Gwrite<CR>')

    " This will show the log messages for your current file, in a QuickFix
    call submode#map('GIT', 'n', '', 'l', '<ESC>:Glog<CR>')
    " This will load the file into a summary+tree, instead of a QuickFix
    call submode#map('GIT', 'n', '', 'i', '<ESC>:Glog -- %<CR>')

    " A couple hotkeys to make it easier to look around, in GIT mode
    call submode#map('GIT', 'n', '', 'gg', '<ESC>gg')
    call submode#map('GIT', 'n', '', 'G', '<ESC>G')
    call submode#map('GIT', 'n', '', 'zt', '<ESC>zt')
    call submode#map('GIT', 'n', '', 'zb', '<ESC>zb')
endfunction


function! arggitter#arggitter#next_hunk()
    if s:IsLastHunk() && arggitter#utility#is_end_of_arg_list()
        return
    endif

    if s:IsLastHunk()
        next
        normal! 1G

        try
            GitGutterNextHunk
        catch
            return
        endtry

        return
    endif

    GitGutterNextHunk
endfunction


function! arggitter#arggitter#previous_hunk()
    if s:IsFirstHunk() && arggitter#utility#is_start_of_arg_list()
        return
    endif

    if s:IsFirstHunk()
        previous
        normal! G

        try
            GitGutterPrevHunk
        catch
            return
        endtry

        return
    endif

    GitGutterPrevHunk
endfunction


" Navigate through Vim's arg list for files with changes
"
" Reference: https://github.com/airblade/vim-gitgutter/blob/master/README.mkd
"
function! s:IsFirstHunk()
    let l:row = line('.')
    let l:column = col('.')

    try
        GitGutterPrevHunk
    catch
        return 1
    endtry

    let l:new_row = line('.')

    " Reset the cursor
    call cursor(l:row, l:column)

    return l:new_row == l:row
endfunction


function! s:IsLastHunk()
    let l:row = line('.')
    let l:column = col('.')

    try
        GitGutterNextHunk
    catch
        return 1
    endtry

    let l:new_row = line('.')

    " Reset the cursor
    call cursor(l:row, l:column)

    return l:new_row == l:row
endfunction
