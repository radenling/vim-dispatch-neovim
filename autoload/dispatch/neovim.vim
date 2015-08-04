if exists('g:autoloaded_dispatch_neovim')
	finish
endif

let g:autoloaded_dispatch_neovim = 1

function! dispatch#neovim#handle(request) abort
	let action = a:request.action
	let cmd = a:request.command
	let bg = a:request.background
	if action ==# 'start'
		execute 'tabnew'
		let opts = { 'name': a:request.title }
		call termopen(cmd, opts)
		let pid = get(b:, 'terminal_job_pid', 0)
		call writefile([pid], a:request.file . '.pid')
		if bg
			execute 'tabprev'
		else
			execute 'startinsert'
		endif
		return 1
	elseif action ==# 'make'
		let opts = {
					\ 'on_stdout': function('s:BufferOutput'),
					\ 'on_stderr': function('s:BufferOutput'),
					\ 'on_exit': function('s:JobExit'),
					\ 'name': a:request.title,
					\ 'pty': 1,
					\ 'width': 80,
					\ 'height': 25,
					\ 'background': a:request.background,
					\ 'tempfile': a:request.file,
					\ 'output': ''
					\}
		let l:job_id = jobstart(cmd, opts)

		" There is currently no way to get the pid in neovim when using
		" jobstart. See: https://github.com/neovim/neovim/issues/557
		" Use job id as pid for now.
		call writefile([l:job_id], a:request.file.'.pid')
		call writefile([], a:request.file)
		return 1
	endif
endfunction

function! s:FindBufferByPID(pid) abort
	let bufcount = bufnr('$')
	for b in range(1, bufcount)
		if buflisted(b)
			if a:pid == getbufvar(b, 'terminal_job_pid', -1) + 0
				return b
			endif
		endif
	endfor
	return 0
endfunction

function! dispatch#neovim#activate(pid) abort
	let l:buf = s:FindBufferByPID(a:pid)
	if buf > 0
		for t in range(1, tabpagenr('$'))
			if index(tabpagebuflist(t), l:buf) != -1
				" When we find the buffer, switch to the right tab and window
				execute 'normal! '.t.'gt'
				execute bufwinnr(l:buf).'wincmd w'
				return 1
			endif
		endfor
	else
		" Program was not found among the buffers so nothing to activate
		return 0
	endif
endfunction

function! dispatch#neovim#running(pid) abort
	call system('ps -p ' . shellescape(a:pid))
	return !v:shell_error
endfunction

" Remove newlines and merge lines without newlines
function! s:FilterNewlines(lines, state) abort
	let l:lines = []
	for line in a:lines
		let l:line_without_newline = substitute(line, '\n\|\r', '', 'g')
		let a:state.output .= l:line_without_newline
		if line =~ '\n\|\r'
			call add(l:lines, a:state.output)
			let a:state.output = ''
		endif
	endfor
	return l:lines
endfunction

function! s:BufferOutput(job_id, data, event) abort
	let l:lines = a:data

	" Remove empty lines
	let l:lines = filter(l:lines, '!empty(v:val)')

	" Remove ANSI escape codes
	let l:lines = map(l:lines, 'substitute(v:val, ''\e\[[0-9;]*[a-zA-Z]'', "", "g")')

	" Remove newlines and merge partial lines
	let l:lines = s:FilterNewlines(l:lines, self)

	call writefile(l:lines, self.tempfile, "a")
endfunction

function! s:JobExit(job_id, data, event) abort
	call writefile([a:data], self.tempfile.'.complete')
	call dispatch#complete(self.tempfile)

	" Foreground builds use the results immediately so clean them up here
	if !self.background
		call delete(self.tempfile.'.complete')
		call delete(self.tempfile)
	endif
endfunction
