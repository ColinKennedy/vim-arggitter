let g:arggitter_mode_name = get(g:, 'arggitter_mode_name', 'ARGGITTER')

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
    let l:enter_mapping = get(g:, 'arggitter_enter_mapping', 'gm')
    let l:exit_mapping = get(g:, 'arggitter_exit_mapping', '<ESC>')

    call submode#enter_with(g:arggitter_mode_name, 'n', '', l:enter_mapping, '<ESC>:call arggitter#utility#enter()<CR>')
    call submode#leave_with(g:arggitter_mode_name, 'n', '', l:exit_mapping, '<ESC>:call arggitter#utility#exit()<CR>')

    if get(g:, 'arggitter_use_git_mappings', 0) == 0
        let l:stage_hunk_mapping = get(g:, 'arggitter_stage_hunk_mapping', 'aa')
        let l:stage_file_mapping = get(g:, 'arggitter_stage_file_mapping', 'aG')
        let l:next_hunk_mapping = get(g:, 'arggitter_next_hunk_mapping', 'nn')
        let l:next_file_mapping = get(g:, 'arggitter_next_file_mapping', 'nG')

        if l:stage_hunk_mapping != ""
            call submode#map(g:arggitter_mode_name, 'n', '', l:stage_hunk_mapping, '<ESC>:GitGutterStageHunk<CR>:call arggitter#arggitter#next_hunk()<CR>zz')
        endif

        if l:stage_file_mapping != ""
            call submode#map(g:arggitter_mode_name, 'n', '', l:stage_file_mapping, '<ESC>:call arggitter#arggitter#stage_hunks_in_file()<CR>zz')
        endif

        if l:next_hunk_mapping != ""
            call submode#map(g:arggitter_mode_name, 'n', '', l:next_hunk_mapping, '<ESC>:call arggitter#arggitter#next_hunk()<CR>zz')
        endif

        if l:next_file_mapping != ""
            call submode#map(g:arggitter_mode_name, 'n', '', l:next_file_mapping, '<ESC>:call arggitter#arggitter#next_file()<CR>zz')
        endif

        call submode#map(g:arggitter_mode_name, 'n', '', 'N', '<ESC>:call arggitter#arggitter#previous_hunk()<CR>zz')
        call submode#map(g:arggitter_mode_name, 'n', '', 'u', '<ESC>:GitGutterUndoHunk<CR>gm')

        " A couple hotkeys to make it easier to look around, in ARGGITTER mode
        call submode#map(g:arggitter_mode_name, 'n', '', 'gg', '<ESC>gg')
        call submode#map(g:arggitter_mode_name, 'n', '', 'G', '<ESC>G')
        call submode#map(g:arggitter_mode_name, 'n', '', 'zt', '<ESC>zt')
        call submode#map(g:arggitter_mode_name, 'n', '', 'zb', '<ESC>zb')
    else
        call submode#map(g:arggitter_mode_name, 'n', '', 'y', '<ESC>:GitGutterStageHunk<CR>:call arggitter#arggitter#next_hunk()<CR>zz')
        call submode#map(g:arggitter_mode_name, 'n', '', 'n', '<ESC>:call arggitter#arggitter#next_hunk()<CR>zz')
        call submode#leave_with(g:arggitter_mode_name, 'n', '', 'q', '<ESC>:call arggitter#utility#exit()<CR>')
        call submode#map(g:arggitter_mode_name, 'n', '', 'a', '<ESC>:GitGutterStageHunksInFile<CR>:call arggitter#arggitter#next_hunk()<CR>zz')
        call submode#map(g:arggitter_mode_name, 'n', '', 'd', '<ESC>:call arggitter#arggitter#next_file()<CR>zz')
    endif

    if get(g:, 'arggitter_use_git_mappings', 0) == 0 && exists('g:loaded_fugitive')
        let l:blame_mapping = get(g:, 'arggitter_fugitive_blame_mapping', 'b')
        let l:commit_mapping = get(g:, 'arggitter_fugitive_commit_mapping', 'c')
        let l:status_mapping = get(g:, 'arggitter_fugitive_status_mapping', 's')
        let l:write_mapping = get(g:, 'arggitter_fugitive_write_mapping', 'w')
        let l:log_qf_mapping = get(g:, 'argitter_fugitive_log_qf_mapping', 'l')
        let l:log_summary_mapping = get(g:, 'argitter_fugitive_log_summary_mapping', 'i')

        " If the user has vim-fugitive installed, add mappings for it
        if l:blame_mapping != ""
            call submode#map(g:arggitter_mode_name, 'n', '', l:blame_mapping, '<ESC>:Gblame<CR>')
        endif

        if l:commit_mapping != ""
            call submode#map(g:arggitter_mode_name, 'n', '', l:commit_mapping, '<ESC>:Gcommit<CR>')
        endif

        if l:status_mapping != ""
            call submode#map(g:arggitter_mode_name, 'n', '', l:status_mapping, '<ESC>:Gstatus<CR>')
        endif

        if l:write_mapping != ""
            call submode#map(g:arggitter_mode_name, 'n', '', l:write_mapping, '<ESC>:Gwrite<CR>')
        endif

        if l:log_qf_mapping != ""
            " This will show the log messages for your current file, in a QuickFix
            call submode#map(g:arggitter_mode_name, 'n', '', l:log_qf_mapping, '<ESC>:Glog<CR>')
        endif

        if l:log_summary_mapping != ""
            " This will load the file into a summary+tree, instead of a QuickFix
            call submode#map(g:arggitter_mode_name, 'n', '', l:log_summary_mapping, '<ESC>:Glog -- %<CR>')
        endif
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
    else if get(g:, 'arggitter_auto_exit', '0') == '1'
        execute "normal \<Plug>(submode-leave:" . g:arggitter_mode_name . ")"
    endif
endfunction


" Go to the next hunk in the current file or skip to the next file in the user's arg list.
function! arggitter#arggitter#next_hunk()
    if s:IsLastHunk() && arggitter#utility#is_end_of_arg_list()
        if get(g:, 'arggitter_auto_exit', '0') == '1'
            execute "normal \<Plug>(submode-leave:" . g:arggitter_mode_name . ")"
        endif

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

        if get(g:, 'arggitter_auto_exit', '0') == '1'
            execute "normal \<Plug>(submode-leave:" . g:arggitter_mode_name . ")"
        endif

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
