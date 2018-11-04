The vim-arggitter Vim plugin brings `git add -p` to Vim.

For those you that like demos:

TODO add a demo


## Requirements
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
vim-arggitter uses mappings that are "vim-friendly". If you want the same mappings
as you'd use for `git add -p`, add this line to your `~/.vimrc`:

TODO Implement this:

```vim
```

### Motivation
While working in a repository, I'd to leave Vim, run `git add -p`, and then
add hunks of text and commit them. Usually while in the interactive window,
I'll spot an error or something that I need to change. So I'd have to press `q`
to quit out of the interactive mode, open the bad file, make the change, then
leave Vim again and do `git add -p`. The worst is when I have several hunks
that I don't want to commit yet. I'd have to skip over them again each time to
get back to the hunk(s) that I wanted to commit. Having a separate window open
for git and one for Vim helped but it was still very annoying.

I once thought "Wouldn't be it nice if I could do all this directly within Vim?"
Thus, vim-arggitter was born.


## Extensions
|  Command  |                      Mapping                       |                     Description                     |
|-----------|----------------------------------------------------|-----------------------------------------------------|
| Gblame    | let g:arggitter_fugitive_blame_mapping = 'b'       | Shows a blame side-bar                              |
| Gcommit   | let g:arggitter_fugitive_commit_mapping = 'c'      | Shows the repository's commits in a separate buffer |
| Gstatus   | let g:arggitter_fugitive_status_mapping = 's'      | Shows the repository's status in a separate buffer  |
| Gwrite    | let g:arggitter_fugitive_write_mapping = 'w'       | Commits the whole file to git                       |
| Glog      | let g:arggitter_fugitive_log_qf_mapping = 'l'      | Shows the commit logs as a QuickFix window          |
| Glog -- % | let g:arggitter_fugitive_log_summary_mapping = 'i' | Shows the commit logs as a summary tree             |



## Customization
"     This function relies on "g:arg_list_temp_file" to write to disk.


TODO
TODO Make sure that this plugin works in Windows for the temp file...
