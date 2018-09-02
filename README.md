This plug-in is a tool that lets you change your Vim context into a
"git-commit" terminal. It's similar to `git add -p` but, instead of moving in a
CLI, you stay right in Vim.

On its own, it's not very powerful but it can intergrate into other plug-ins,
such as vim-submode.

Requires:
	github.com/ColinKennedy/vim-submode
	Git 2.13 for a submodule check function


Setup:
	Add this line to your `.vimrc`

```vim
call arggitter#arggitter#create_git_submode()
```

Reference:
	https://stackoverflow.com/questions/7359204/git-command-line-know-if-in-submodule
