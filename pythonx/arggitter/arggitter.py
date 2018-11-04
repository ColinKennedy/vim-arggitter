#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''The main module which is used to control the user's arg-list.'''

# IMPORT STANDARD LIBRARIES
import os

# IMPORT THIRD-PARTY LIBRARIES
import vim

# IMPORT LOCAL LIBRARIES
from . import arg_list
from . import filer


def _esc(path):
    '''str: Clean the given file/folder path so that Vim can understand it.'''
    return path.replace(' ', '\ ')


def enter_arg_list():
    '''Edit the file which is focused_arg in the arg-list.

    Any time an arg-list is created, one file is given focus (e.g. it gets "[]"s
    added around its name).

    This function will change the user's current buffer to the focused_arg arg-list item.

    '''
    file_name = filer.get_current_absolute_path()

    for item in arg_list.get_args():
        if arg_list.is_focused(item):
            item = arg_list.get_unfocused_name(item)
            vim.command('edit {item}'.format(item=item))
            break

    items = arg_list.get_args(strip=True)
    go_to_first_line = file_name not in items

    if go_to_first_line:
        vim.command('normal! gg')


def save_arg_list():
    '''Gather the current arg-list and save it to a temporary file.'''
    args = ', '.join(('"{item}"'.format(item=item) for item in arg_list.get_args()))
    vim.command('let g:arggitter_temp_arg_list = [{args}]'.format(args=args))


def override_arg_list():
    '''Get all unstaged files in the current git repository and add it to the arg-list.

    When a user runs this function, two scenarios can occur:
    1. The user's current file buffer is not in the arg-list.
    2. The user's current file buffer is in the arg-list.

    In scenario #1, the user's current file buffer is added as the first item to
    the user's arg-list and the arg-list will focus onto this file.
    In scenario #2, the current file buffer is completely ignored and whatever
    the arg-list's file file path is given focus, instead.

    '''
    def _allow_submodules():
        try:
            return bool(int(vim.eval('g:arggitter_allow_submodules')))
        except Exception:
            return False

    root = filer.get_current_git_root()
    current_file = filer.get_current_absolute_path()
    unstaged_files = (
        _esc(os.path.join(root, path))
        for path in filer.get_unstaged_git_files(root, allow_submodules=_allow_submodules()))
    unstaged_files = filer.sort_items(unstaged_files, [current_file])

    arg_list.add_to_arg_list(unstaged_files)


def restore_arg_list():
    '''Read the user's saved arg-list and apply it to the current session.'''
    path = filer.get_arg_list_path()

    args = vim.eval('g:arggitter_temp_arg_list')

    unfocused_args = []

    focused_arg = ''

    for arg in args:
        if arg.startswith('[') and arg.endswith(']'):
            arg = arg[1:-1]
            focused_arg = arg

        unfocused_args.append(arg)

    arg_list.add_to_arg_list(unfocused_args)

    if focused_arg:
        arg_list.set_focus_to(focused_arg)
