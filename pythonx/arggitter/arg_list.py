#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''The module that queries and controls the user's arg-list.'''

# IMPORT THIRD-PARTY LIBRARIES
import vim


def is_focused(item):
    '''bool: If the given file from the arg-list is the user's current context.'''
    return item.startswith('[') and item.endswith(']')


def is_end_of_arg_list():
    '''bool: If the user is at the end of all the files listed in the arg-list.'''
    try:
        vim.command('next')
    except Exception:
        return True
    else:
        try:
            vim.command('previous')
        except Exception:
            pass

        return False


def is_start_of_arg_list():
    '''bool: If the user is at the start of all the files listed in the arg-list.'''
    try:
        vim.command('previous')
    except Exception:
        return True
    else:
        try:
            vim.command('next')
        except Exception:
            pass

        return False


def get_unfocused_name(item):
    '''str: Remove Vim's "[]" text around a file path.'''
    return item.lstrip('[\n\t ').rstrip(']\n\t ')


def get_args(strip=False, fake='__capture'):
    '''Get all items in the user's arg-list.

    Args:
        fake (`str`, optional):
            The variable which will be used to communicate between vimscript and Python.
            Default: "__capture".
        strip (`str`, optional):
            If True, remove the arg-list focus marker (e.g. "[foo]" will return as "foo").
            If False, keep the arg-list focus marker (e.g. "[foo]" will return as "[foo]").
            Default is False.

    Returns:
        list[str] or items:
            The file(s)/folder(s) in the user's arg-list.

    '''
    vim.command("let {fake} = Capture('args')".format(fake=fake))
    items = vim.eval(fake).split()

    if strip:
        return [get_unfocused_name(item) for item in items]

    return items


def add_to_arg_list(items):
    '''Add the given items into the user's arg-list.

    Args:
        items (iter[str]): The items to add.

    '''
    command = 'argadd {items}'.format(items=' '.join(items))
    vim.command(command)


def set_focus_to(arg):
    '''Set the arglist to point to the given arg.

    It's assumed that `arg` is an option in the user's current arglist.

    Args:
        arg (str): The file/buffer name to set focus onto.

    Raises:
        ValueError: If `arg` isn't in the current arglist.

    '''
    focused_arg_name = '[{arg}]'.format(arg=arg)
    args = get_args()

    if focused_arg_name in args:
        # The file is already focused. That means there is nothing left to do
        return

    try:
        destination = args.index(arg)
    except ValueError:
        raise ValueError('Arg "{arg}" was not found in arglist, "{args}".'
                         ''.format(arg=arg, args=args))

    source = 0
    for index, arg in enumerate(args):
        if is_focused(arg):
            source = index

    if source == destination:
        return

    command = 'next'
    diff = abs(destination - source)

    if destination < source:
        command = 'previous'

    vim.command('{diff}{command}'.format(diff=diff, command=command))
