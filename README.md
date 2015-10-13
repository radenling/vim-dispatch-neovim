# dispatch-neovim

Add support for neovim's terminal emulator and job control to
[dispatch.vim][dispatch].

## Usage

_Note: This plugin depends on [dispatch.vim][dispatch] and you need to have that
plugin installed for this plugin to work_

When you have installed dispatch-neovim and start up neovim, it will insert
itself as the first handler in dispatch's list of handlers. If it can't detect
neovim it will not do anything.

### Notes

Foreground builds run in a small terminal window at the bottom of the current
tab. If the foreground job fails, the quickfix window will open showing the
errors.

Background builds will run as jobs in neovim, which means that they won't open a
terminal window, nor will they open the quickfix window afterwards. Use `:Copen`
to open the quickfix window for background builds.

`:Start` and `:Start!` uses vim tabs and the built-in terminal emulator.

## Todo

* Test on other platforms than linux

[dispatch]: https://github.com/tpope/vim-dispatch
