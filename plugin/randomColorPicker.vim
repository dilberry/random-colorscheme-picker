" This program is free software. It comes without any warranty, to
" the extent permitted by applicable law. You can redistribute it
" and/or modify it under the terms of the Do What The Fuck You Want
" To Public License, Version 2, as published by Sam Hocevar. See
" http://sam.zoy.org/wtfpl/copying for more details. */

let g:colorscheme_file_path=""
let g:colorscheme_file=""
let rnd = localtime() % 0x10000

function! s:InitCS()
	if exists("g:CSLOVES_STR")
		let g:csloves=eval(g:CSLOVES_STR)
	else
		let g:csloves=[]
	endif
	if exists("g:CSHATES_STR")
		let g:cshates=eval(g:CSHATES_STR)
	else
		let g:cshates=[]
	endif
	call s:PickCS()
	if (exists('g:loaded_lightline') && g:loaded_lightline)
		" This initialisation causes an error in airlines colourscheme
		" change detection
		call lightline#colorscheme()
	endif
endfunction

function! s:ExitCS()
	if exists("g:csloves")
		let g:CSLOVES_STR=string(g:csloves)
	else
		unlet! g:CSLOVES_STR
	endif
	if exists("g:cshates")
		let g:CSHATES_STR=string(g:cshates)
	else
		unlet! g:CSHATES_STR
	endif
endfunction

function! s:PickCS()
	if len(g:csloves) > 0
		let g:colorscheme_file=g:csloves[0]
		call s:ApplyCS()
		return
	endif

	let arr=split(globpath(&rtp, 'colors/*.vim'), "\n")

	while 1
		let rand=s:ChooseRandomCS(len(arr))
		let g:colorscheme_file_path=arr[rand]
		let g:colorscheme_file=split(g:colorscheme_file_path, "\\")[-1][:-5]
		if index(g:cshates, g:colorscheme_file) == -1
			break
		endif
	endwhile
	" colorscheme is /path/to/colorscheme_file.vim
	" convert to colorscheme_file
	call s:ApplyCS()
endfunction

function! s:RandomCS()
	let g:rnd = (g:rnd * 31421 + 6927) % 0x10000
	return g:rnd
endfun

function! s:ChooseRandomCS(n) " 0 n within
	return (s:RandomCS() * a:n) / 0x10000
endfun

function! s:ApplyCS()
	let cmd="colorscheme ".g:colorscheme_file
	silent execute cmd
	redrawstatus
	call s:ShowCS()
endfunction

function! s:LoveCS()
	call add(g:csloves, g:colorscheme_file)
endfunction

function! s:HateCS()
	let g:csloves=[]
	call add(g:cshates, g:colorscheme_file)
	call s:PickCS()
endfunction

function! s:BackCS()
	let g:cshates=[]
	redrawstatus
	echo "you've got all the previously hated colorschemes back"
endfunction

function! s:ShowCS()
	echo "using colorscheme: ".g:colorscheme_file
endfunction

set vi^=!
autocmd VimEnter * call s:InitCS()
autocmd VimLeavePre * call s:ExitCS()

command! LoveCS call s:LoveCS()
command! HateCS call s:HateCS()
command! ShowCS call s:ShowCS()
command! PickCS call s:PickCS()
command! BackCS call s:BackCS()
