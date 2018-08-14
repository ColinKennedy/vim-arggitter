#!/usr/bin/env python
# -*- coding: utf-8 -*-

# IMPORT STANDARD LIBRARIES
import subprocess
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


def _get_unbraced_name(item):
    return item.lstrip('[').rstrip(']')


def _get_args(fake='__capture', strip=False):
    vim.command("let {fake} = Capture('args')".format(fake=fake))
    items = vim.eval(fake).split()

    if strip:
        return [_get_unbraced_name(item) for item in items]

    return items


def _get_current_absolute_path():
    return vim.eval("expand('%')")


def is_end_of_arg_list():
    try:
        last = _get_args()[-1].strip()
    except IndexError:
        return True

    return last.startswith('[') and last.endswith(']')


def is_start_of_arg_list():
    try:
        first = _get_args()[0].strip()
    except IndexError:
        return True

    return first.startswith('[') and first.endswith(']')


def get_arg_list_path():
    try:
        return vim.eval('g:arg_list_temp_file')
    except Exception:
        raise EnvironmentError('g:arg_list_temp_file must be defined')


def get_current_git_root():
    current_file = _get_current_absolute_path()
    return get_parent_git_root(current_file)


def get_parent_git_root(path):
    folders = _split_os_path_asunder(path)

    for index in reversed(range(len(folders))):
        subfolder = os.path.join(*folders[:index + 1])
        git_path = os.path.join(subfolder, '.git')

        if os.path.exists(git_path):
            return subfolder

    return ''


def get_unstaged_git_files(path):
    root = get_parent_git_root(path)
    command = 'git -C "{root}" diff --name-only'.format(root=root)
    result = subprocess.check_output([command], shell=True)
    return result.split()


def enter_arg_list():
    file_name = os.path.basename(_get_current_absolute_path())

    items = _get_args(strip=True)

    if file_name in items:
        entry = file_name
        go_to_first_line = False
    else:
        entry = items[0]
        go_to_first_line = True

    # Escape spaces in paths, just in case
    entry = entry.replace(' ', '\ ')

    vim.command('argdelete {entry}'.format(entry=entry))
    vim.command('argedit {entry}'.format(entry=entry))

    if go_to_first_line:
        vim.command('normal! gg')


def save_arg_list():
    path = get_arg_list_path()

    with open(path, 'w') as file_:
        file_.write('\n'.join(_get_args()))


def override_arg_list():
    root = get_current_git_root()
    unstaged_files = [os.path.join(root, path) for path in get_unstaged_git_files(root)]
    vim.command('argadd {files}'.format(files=' '.join(unstaged_files)))


def restore_arg_list():
    path = get_arg_list_path()

    with open(path, 'r') as file_:
        lines = []
        for line in file_.readlines():
            lines.append(_get_unbraced_name(line))

    vim.command('argadd {items}'.format(items=' '.join(lines)))
