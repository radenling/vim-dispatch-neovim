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

Foreground builds run as jobs in neovim. There is currently no visual indicator
for when a job is running. When a foreground job fails, it will open the
quickfix window, just like the other dispatch handlers.

Background builds work like foreground builds but without opening the quickfix
window afterwards. Use `:Copen` to open the quickfix window for background
builds.

`:Start` and `:Start!` uses vim tabs and the built-in terminal emulator.

## Todo

* Add statusline indicator for when a job is running
* Test on other platforms than linux

[dispatch]: https://github.com/tpope/vim-dispatch
