if exists('g:loaded_dispatch_neovim')
	finish
endif

let g:loaded_dispatch_neovim = 1

if has('nvim')
	augroup dispatch-neovim
		autocmd!
		autocmd VimEnter *
			\ if index(get(g:, 'dispatch_handlers', ['neovim']), 'neovim') < 0 |
			\	call insert(g:dispatch_handlers, 'neovim', 0) |
			\ endif
	augroup END
endif
