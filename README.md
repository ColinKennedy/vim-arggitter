The vim-arggitter Vim plugin brings `git add -p` to Vim.

For those you that like demos:

TODO add a demo


## Requirements
- Vim with Python compiled (2 or 3)
- [vim-submode](https://www.github.com/ColinKennedy/vim-submode)
- [Git 2.13+](https://github.com/git/git)


## Installation
- Install everything in [Requirements](#Requirements)
- Add vim-arggitter using either a [plugin manager](#Plugin-Manager-Installation)
  or [manually](#Manual-Installation)
- Define a mapping to enter ARGGITTER mode, if you want


### Plugin Manager Installation
I use [vim-plug](https://github.com/junegunn/vim-plug) to install
all of my plugins. The code to add it below looks like this:

```vim
Plug 'ColinKennedy/vim-arggitter'
```

However this plugin should work with any plugin manager.


### Manual Installation
Clone this repository:

```bash
git clone https://github.com/ColinKennedy/vim-arggitter
```

Move the files to their respective folders in your `~/.vim` directory
(or your `$HOME\vimfiles` directory if you're on Windows)


## Usage
- Open a buffer that is being tracked by a Git repository
- Press that mapping to enter ARGGITTER mode
- Press "a" to add hunks, "n" to skip. For a full list of mappings,
  check [Mappings](#Mappings)


## Mappings
By default, vim-arggitter uses mappings that are "vim-friendly".

|                 Mapping                    |               Description               |
|--------------------------------------------|-----------------------------------------|
| let g:arggitter_enter_mapping = 'gm'       | Go into ARGGITTER mode                  |
| let g:arggitter_exit_mapping = '<ESC>'     | Leave ARGITTER mode                     |
| let g:arggitter_auto_exit = '0'            | Leave ARGGITTER mode if no more hunks   |
|                                            |                                         |
| let g:arggitter_stage_hunk_mapping = 'aa'  | Stage the current hunk under the cursor |
| let g:arggitter_stage_file_mapping = 'aG'  | Stage all hunks on or below the cursor  |
| let g:arggitter_next_hunk_mapping = 'nn'   | Skip to the next hunk                   |
| let g:arggitter_next_file_mapping = 'nG'   | Skip to the next file                   |

If you want the same mappings as you'd use for `git add -p`, add this line
to your `~/.vimrc`:

```vim
let g:arggitter_use_git_mappings = 1
```

- Remove the "zz"s. People won't like those.
- return bool(int(vim.eval('g:arggitter_allow_submodules')))
- Add an option to restore buffers

Note:
    You can unset any mapping by adding `let g:arggitter_foo = ''` to your .vimrc


## Extensions
If you have [vim-fugitive](https://github.com/tpope/vim-fugitive) installed on
your user and `g:arggitter_use_git_mappings` is `0` then vim-arggitter adds
extra commands. They're not required for vim-arggitter to run but are nice to
have.


|  Command  |                      Mapping                       |                     Description                     |
|-----------|----------------------------------------------------|-----------------------------------------------------|
| Gblame    | let g:arggitter_fugitive_blame_mapping = 'b'       | Shows a blame side-bar                              |
| Gcommit   | let g:arggitter_fugitive_commit_mapping = 'c'      | Shows the repository's commits in a separate buffer |
| Gstatus   | let g:arggitter_fugitive_status_mapping = 's'      | Shows the repository's status in a separate buffer  |
| Gwrite    | let g:arggitter_fugitive_write_mapping = 'w'       | Commits the whole file to git                       |
| Glog      | let g:arggitter_fugitive_log_qf_mapping = 'l'      | Shows the commit logs as a QuickFix window          |
| Glog -- % | let g:arggitter_fugitive_log_summary_mapping = 'i' | Shows the commit logs as a summary tree             |


### Motivation
If I wanted to commit hunks of changes to git, I'd to leave Vim,
run `git add -p`, and then add the hunks, and commit them. Usually while
in the interactive window, I'll spot an error or something that I need to change.
So I'd have to press `q` to quit out of the interactive mode, open the bad file,
make the change, then leave Vim again and do `git add -p`. The worst is when
I have several hunks that I don't want to commit yet. I'd have to skip over them
again each time to get back to the hunk(s) that I actually wanted to commit
every time I needed to leave the interactive window. Having a separate window
open for git and one for Vim helped but it was still very annoying.

One day, I thought "Wouldn't be it nice if I could do all this directly within Vim?"
Thus, vim-arggitter was born.


## How Does It Work
When ARGGITTER mode is activated, the files with unstaged changes are loaded
into Vim's arglist. While in ARGGITTER mode, you can only move from the current
file to the next in the arglist. When the user exits, ARGGITTER returns the
user's old arglist, if needed.
