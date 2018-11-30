" autoload/nuake.vim

" Window management {{{1
function! nuake#ToggleWindow() abort "{{{2
	let l:nuake_win_nr = bufwinnr(s:NuakeBufName())

	if l:nuake_win_nr != -1
		call s:CloseWindow()
	else
		call s:OpenWindow()
	endif
endfunction

function! s:OpenWindow() abort "{{{2
	let l:nuake_buf_nr = bufnr(s:NuakeBufName())

	execute  'silent keepalt botright ' . s:NuakeLook() . 'split'

	if l:nuake_buf_nr != -1
		execute  'buffer ' . l:nuake_buf_nr
	else
		execute  'terminal'
		call s:NuakeBufName()
	endif

	call s:InitWindow()
endfunction

function! s:InitWindow() abort "{{{2
	" Buffer-local options
	setlocal filetype=nuake
	setlocal bufhidden=hide
	setlocal noswapfile
	setlocal nobuflisted
	setlocal nomodified

	" Window-local options
	setlocal nolist
	setlocal nowrap
	setlocal winfixwidth
	setlocal winfixheight
	setlocal nospell
	setlocal nonumber
	setlocal norelativenumber
	setlocal nofoldenable
	setlocal foldcolumn=0
endfunction

function! s:CloseWindow() abort "{{{2
	let l:nuake_win_nr = bufwinnr(s:NuakeBufName())

	if winnr() == l:nuake_win_nr
		if winbufnr(2) != -1
			hide
		endif
	else
		let l:current_buf_nr = bufnr('%')
		exe l:nuake_win_nr . 'wincmd w'
		close

		let l:win_num = bufwinnr(l:current_buf_nr)
		if winnr() != l:win_num
			exe l:win_num . 'wincmd w'
		endif
	endif
endfunction

function! s:ResizeWindow() abort "{{{2
	let l:nuake_win_nr = bufwinnr(s:NuakeBufName())

	execute l:nuake_win_nr . 'resize ' . s:NuakeLook()
endfunction

function! s:LastStandingWindow() abort "{{{2
	let l:nuake_win_nr = bufwinnr(s:NuakeBufName())

	if winnr('$') < 2 && l:nuake_win_nr != -1
		if tabpagenr('$') < 2
			bdelete!
			quit
		else
			close
		endif
	endif
endfunction

" Helpers {{{1
function! s:NuakeBufName() abort "{{{2
	if g:nuake_per_tab == 0
		if !exists('s:nuake_buf_name')
			let s:nuake_buf_name = -1
		elseif exists('b:term_title') && s:nuake_buf_name == -1
			let s:nuake_buf_name = b:term_title
		endif
		return s:nuake_buf_name
	else
		if !exists('t:nuake_buf_name')
			let t:nuake_buf_name = -1
		elseif exists('b:term_title') && t:nuake_buf_name == -1
			let t:nuake_buf_name = b:term_title
		endif
		return t:nuake_buf_name
	endif
endfunction

function! s:NuakeLook() abort "{{{2
	let l:nuake_win_nr = bufwinnr(s:NuakeBufName())

	if g:nuake_position == 0
		let l:mode = ''
		let l:size = float2nr(g:nuake_size * floor(&lines - 2))
	else
		let l:mode = l:nuake_win_nr != -1 ? '' : 'vertical '
		let l:size = float2nr(g:nuake_size * floor(&columns))
	endif

	let l:nuake_look = l:mode . l:size

	return l:nuake_look
endfunction

" Autocomands {{{1
augroup nuake_start_insert
	autocmd!
	autocmd BufEnter term://* startinsert
augroup END

augroup nuake_last_standing_window
	autocmd!
	autocmd BufEnter * nested call s:LastStandingWindow()
augroup END

augroup nuake_tab_close
	if g:nuake_per_tab == 1
		autocmd!
		autocmd TabLeave * let s:temp_nuake_buf_nr = bufnr(s:NuakeBufName())
		autocmd TabClosed * execute 'bdelete! ' . s:temp_nuake_buf_nr
		autocmd TabClosed * unlet s:temp_nuake_buf_nr
	endif
augroup END

augroup nuake_resize_window
	autocmd!
	autocmd VimResized *
				\ if bufwinnr(s:NuakeBufName()) != -1 |
				\ call s:ResizeWindow() |
				\ redraw |
				\ endif
augroup END

" Modeline {{{1
" vim: ts=4 sw=4 sts=4 noet foldenable foldmethod=marker
