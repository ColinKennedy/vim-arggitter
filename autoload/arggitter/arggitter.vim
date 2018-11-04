" Create a new mode in Vim that is similar to `git add -p`.
" Enter it using 'gm' and exit it, using '<ESC>'.
"
" Commands:
"      a = stage the current hunk
"      n = go to the next hunk (if needed, wrap to the beginning of the file)
"      N = go to the previous hunk
"      u = undo (reset) hunk
"
"      c = Create a commit window
"      s = Show the repo-status
"      b = Run Git blame in a customized window
"      w = Git add %:p:h
"      l = Shows the repository log
"
function! arggitter#arggitter#create_git_submode()
    call submode#enter_with('ARGGITTER', 'n', '', 'gm', '<ESC>:call arggitter#utility#enter()<CR>')

    if get(g:, 'arggitter_use_git_mappings', 0) == 0
        call submode#leave_with('ARGGITTER', 'n', '', '<ESC>', '<ESC>:call arggitter#utility#exit()<CR>')
        call submode#map('ARGGITTER', 'n', '', 'aa', '<ESC>:GitGutterStageHunk<CR>:call arggitter#arggitter#next_hunk()<CR>zz')
        call submode#map('ARGGITTER', 'n', '', 'aG', '<ESC>:call arggitter#arggitter#stage_hunks_in_file()<CR>zz')
        call submode#map('ARGGITTER', 'n', '', 'nn', '<ESC>:call arggitter#arggitter#next_hunk()<CR>zz')
        call submode#map('ARGGITTER', 'n', '', 'nG', '<ESC>:call arggitter#arggitter#next_file()<CR>zz')
        call submode#map('ARGGITTER', 'n', '', 'N', '<ESC>:call arggitter#arggitter#previous_hunk()<CR>zz')
        call submode#map('ARGGITTER', 'n', '', 'u', '<ESC>:GitGutterUndoHunk<CR>gm')

        " A couple hotkeys to make it easier to look around, in ARGGITTER mode
        call submode#map('ARGGITTER', 'n', '', 'gg', '<ESC>gg')
        call submode#map('ARGGITTER', 'n', '', 'G', '<ESC>G')
        call submode#map('ARGGITTER', 'n', '', 'zt', '<ESC>zt')
        call submode#map('ARGGITTER', 'n', '', 'zb', '<ESC>zb')
    else
        call submode#map('ARGGITTER', 'n', '', 'y', '<ESC>:GitGutterStageHunk<CR>:call arggitter#arggitter#next_hunk()<CR>zz')
        call submode#map('ARGGITTER', 'n', '', 'n', '<ESC>:call arggitter#arggitter#next_hunk()<CR>zz')
        call submode#leave_with('ARGGITTER', 'n', '', 'q', '<ESC>:call arggitter#utility#exit()<CR>')
        call submode#map('ARGGITTER', 'n', '', 'a', '<ESC>:GitGutterStageHunksInFile<CR>:call arggitter#arggitter#next_hunk()<CR>zz')
        call submode#map('ARGGITTER', 'n', '', 'd', '<ESC>:call arggitter#arggitter#next_file()<CR>zz')
    endif

    if get(g:, 'arggitter_use_git_mappings', 0) == 0 && exists('g:loaded_fugitive')
        " If the user has vim-fugitive installed, add mappings for it
        call submode#map('ARGGITTER', 'n', '', 'b', '<ESC>:Gblame<CR>')
        call submode#map('ARGGITTER', 'n', '', 'c', '<ESC>:Gcommit<CR>')
        call submode#map('ARGGITTER', 'n', '', 's', '<ESC>:Gstatus<CR>')
        call submode#map('ARGGITTER', 'n', '', 'w', '<ESC>:Gwrite<CR>')

        " This will show the log messages for your current file, in a QuickFix
        call submode#map('ARGGITTER', 'n', '', 'l', '<ESC>:Glog<CR>')
        " This will load the file into a summary+tree, instead of a QuickFix
        call submode#map('ARGGITTER', 'n', '', 'i', '<ESC>:Glog -- %<CR>')
    endif
endfunction


" Skip all of the hunks in this file and move onto the next one, if needed.
function! arggitter#arggitter#next_file()
    while !s:IsLastHunk()
        try
            GitGutterNextHunk
        catch
            return
        endtry
    endwhile

    if !arggitter#utility#is_end_of_arg_list()
        next
        normal! 1G
    endif
endfunction


" Go to the next hunk in the current file or skip to the next file in the user's arg list.
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


" Go to the previous hunk in the current file or skip to a previous file in the user's arg list.
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


" Stage every hunk in the current file from the current cursor position.
"
" Once done, move to the next file.
"
function! arggitter#arggitter#stage_hunks_in_file()
    while !s:IsLastHunk()
        GitGutterStageHunk

        try
            GitGutterNextHunk
        catch
        endtry
    endwhile

    if s:IsLastHunk() && arggitter#utility#is_end_of_arg_list()
        GitGutterStageHunk
        return
    endif

    if s:IsLastHunk()
        GitGutterStageHunk

        next

        normal! 1G

        try
            GitGutterNextHunk
        catch
            return
        endtry
    endif
endfunction


" Check if the user is at the first hunk in the current file.
" Reference: https://github.com/airblade/vim-gitgutter/blob/master/README.mkd
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


" Check if the user is at the last hunk in the current file.
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
