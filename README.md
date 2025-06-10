# Neovim Config

My personal neovim config. It's a minimalistic config with everything required to start using neovim for development, a few QoL and no more.

Fork your own version and clone it to `$HOME/.config/nvim` to use it.

Plugin imports are defined in `lua/plugins.available/` and enabled by symliking to `lua/plugins/`.

Check all custom remaps at [`lua/config/remap.lua`](./lua/config/remap.lua) and global settings at [`lua/config/settings.lua`](./lua/config/settings.lua)


## Workspace Feature

A "workspace" in this context is the root folder of a project you're working on, for example a Python package.

This feature is implemented to make working on a project feel more like an IDE like VS Code. When starting neovim, if passing a session file and the session file name is `.neovim/session`, it'll setup a few things:

- autocmds to save the session on several events, like opening/saving a buffer
- disable swapfile and backup
- enable a custom undo history that saves the history file to `.neovim/undo/...`
- automatically load the undo history on buffer open
- automatically close the NvimTree and undotree buffers when exiting, so they don't annoy you with an empty buffer when reloading the workspace
- if there's a file named `.neovim/rc.lua`, automatically source it
- change tab titles to make it easier to see which file you're editing when opening more than one file with the same name

How to use this feature:

- add a global gitignore rule for `.neovim`
- create `nvw` alias and use it at the root of a project
- create a `.neovim/rc.lua` file with project-specific initialization
- after opening the project, do a `<leader>br` to reload the current buffer to enable the LSP on it if necessary

Detailed instructions for each of the previous steps:


### Setup gitignore

First, set up your global `.gitignore` file:

```bash
# if you don't have a global gitignore in your config yet, execute this to add:
git config set --global core.excludesfile "$HOME/.gitignore"
```

Add this to `$HOME/.gitignore`:

```
.neovim
```

This is to prevent you from ever commiting your `.neovim` folder to any repository.


### Create alias

Add this alias to your shell:

```bash
# adapt to your shell if it's not bash
alias nvw='mkdir -p .neovim && (nvim -es -c ":mksession .neovim/session" || true) && (test -n "$_WINDOW_TITLE" || echo -ne "\033]0;$(basename $PWD@$HOSTNAME)\007") && nvim -S .neovim/session'
```

What this does:

1. Creates the `.neovim` dir if it doesn't exists
2. Saves a blank `.neovim/session` file to trigger the workspace when loading it
3. Sets the terminal window title to the current folder name. This is to make it easier, when working with several workspaces, to tell which one you're currently in, for example when using a tabbed terminal
4. Starts neovim loading the workspace

Now to start working on any project, go to the project root and run `nvw` in your terminal. You should now be able to pick up from where you left when last working on the project.


### Create the rc.lua file

In your workspace, create a file named `.neovim/rc.lua` with specific configuration for your project. For example, in a Python project you might have something like this:

```lua
local mu = require('myutils')

vim.lsp.enable('pylsp')
vim.lsp.enable('ruff')
vim.lsp.enable('basedpyright')

local remoteRoot = '/backend'
local python_dap = {
        mu.genAttachPython('service1', 5678, remoteRoot),
        mu.genAttachPython('service2', 5679, remoteRoot),
        mu.genAttachPython('service3', 5680, remoteRoot),
}
require('dap-python').setup('.venv/bin/python3')
require('dap').configurations.python = python_dap
```


### Load workspace

Now it's just cd'ing to the project directory and running `nvw`, then you should have the editor ready to go. If the open buffer doesn't have the LSP enabled on it, just use `<leader>br` to reload it and enable that.
