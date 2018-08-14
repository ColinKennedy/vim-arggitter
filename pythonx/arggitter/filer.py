#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''A module of file/folder path functions for git and vim.'''

# IMPORT STANDARD LIBRARIES
import subprocess
import functools
import sys
import os

# IMPORT THIRD-PARTY LIBRARIES
import vim


def _split_os_path_asunder(path):
    '''Split up a path, even if it is in Windows and has a letter drive.

    Args:
        path (str): The path to split up into parts.

    Returns:
        list[str]: The split path.

    '''
    drive, path = os.path.splitdrive(path)
    paths = _split_path_asunder(path)
    if drive:
        return [drive] + paths
    return paths


def _split_path_asunder(path):
    r'''Split a path up into individual folders.

    This function is OS-independent but does not take into account Windows
    drive letters. For that, check out _split_os_path_asunder.

    Reference:
        http://www.stackoverflow.com/questions/4579908.

    Note:
        If this method is used on Windows paths, it's recommended to
        os.path.splitdrive() before running this method on some path, to
        handle edge cases where driver letters have different meanings
        (example: c:path versus c:\path)

    Args:
        path (str): The path to split up into parts.

    Returns:
        list[str]: The split path.

    '''
    parts = []
    while True:
        newpath, tail = os.path.split(path)
        if newpath == path:
            assert not tail
            if path:
                parts.append(path)
            break
        parts.append(tail)
        path = newpath
    parts.reverse()
    return parts


def get_arg_list_path():
    '''Get the path to where the user's stored arg-list is.

    Raises:
        EnvironmentError: If the user doesn't have "g:arg_list_temp_file" defined.

    Returns:
        str: The absolute path to some temporary file.

    '''
    try:
        return vim.eval('g:arg_list_temp_file')
    except Exception:
        raise EnvironmentError('g:arg_list_temp_file must be defined')


def get_current_absolute_path():
    '''str: The absolute path to the user's current file.'''
    return vim.eval("expand('%')")


def get_current_git_root():
    '''Find the absolute path to the git repository.

    Note:
        This assumes that the user's buffer is inside of a git repository.

    Returns:
        str: The full path to the git repository, if found.

    '''
    current_file = get_current_absolute_path()
    return get_parent_git_root(current_file)


def get_parent_git_root(path):
    '''Find the closest parent git repository to a given file path.

    Args:
        path (str): The absolute path to a git repository.

    Returns:
        str: The absolute path to a git repository, if found.

    '''
    folders = _split_os_path_asunder(path)

    for index in reversed(range(len(folders))):
        subfolder = os.path.join(*folders[:index + 1])
        git_path = os.path.join(subfolder, '.git')

        if os.path.exists(git_path):
            return subfolder

    return ''


def get_unstaged_git_files(path):
    '''Find the unstaged files in a git repository.

    Args:
        path (str): The absolute path to some git repository.

    Returns:
        list[str]: The found files. Each file's path is relative to `path`.

    '''
    root = get_parent_git_root(path)
    command = 'git -C "{root}" diff --name-only'.format(root=root)
    result = subprocess.check_output([command], shell=True)
    return result.splitlines()


def sort_by_items(special_items, item):
    '''Sort the current item alphabetically while looking at another list of items.

    Args:
        special_items (set[str]): The items to search for.
        item (str): The item to get a sort value for.

    Returns:
        tuple[int, tuple[int, int]]:
            The first index is whether or not `item` is in `special_items`.
            If it is, then `item` is separated into a different sorting group.
            The second instead, tuple[int, int], is the `item` sort value.

    '''
    def _get_total(item):
        total = []
        for position, character in enumerate(item):
            total.append((position, ord(character)))

        return tuple(total)

    if item in special_items:
        # Making the first value a huge negative number effectively puts that
        # item to the front of a sort
        #
        return (-1 * sys.maxint, _get_total(item))
    return (0, _get_total(item))


def sort_items(items, special_items):
    '''Sort some items alphabetically and based on if it exists in `special_items`.

    Args:
        items (iter[str]):
            The item to sort.
        special_items (set[str]):
            The items to check against `items`.
            If an element of `items` is in `special_items` then it will be sorted
            before the items that are not.

    Returns:
        list[str]: The sorted items.

    '''
    return sorted(items, key=functools.partial(sort_by_items, special_items))
