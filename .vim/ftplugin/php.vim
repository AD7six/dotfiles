"
" Settings for PHP filetype
"

" Reset to defaults
set expandtab&

" Compact view
set shiftwidth=4
set tabstop=4

" ensure
set fileencoding=utf-8

" Set up automatic formatting
set formatoptions+=tcqlro

" Jump to matching bracket for 3/10th of a second (works with showmatch)
set matchtime=3
set showmatch

" Set maximum text width (for wrapping)
set textwidth=150

"
" Syntax options
"
" Enable folding of class/function blocks
let php_folding=1

" Do not use short tags to find PHP blocks
let php_noShortTags=1

" Highlighti SQL inside PHP strings
let php_sql_query=0

" Highlight Html in strings
let php_htmlInStrings=0

"
" Linting
"
" Use PHP syntax check when doing :make
set errorformat=%m\ in\ %f\ on\ line\ %l
set makeprg=php\ -l\ %

" Parse PHP error output
set errorformat=%m\ in\ %f\ on\ line\ %l

" Function to locate endpoints of a PHP block {{{
function! PhpBlockSelect(mode)
	let motion = "v"
	let line = getline(".")
	let pos = col(".")-1
	let end = col("$")-1

	if a:mode == 1
		if line[pos] == '?' && pos+1 < end && line[pos+1] == '>'
			let motion .= "l"
		elseif line[pos] == '>' && pos > 1 && line[pos-1] == '?'
			" do nothing
		else
			let motion .= "/?>/e\<CR>"
		endif
		let motion .= "o"
		if end > 0
			let motion .= "l"
		endif
		let motion .= "?<\\?php\\>\<CR>"
	else
		if line[pos] == '?' && pos+1 < end && line[pos+1] == '>'
			" do nothing
		elseif line[pos] == '>' && pos > 1 && line[pos-1] == '?'
			let motion .= "h?\\S\<CR>""
		else
			let motion .= "/?>/;?\\S\<CR>"
		endif
		let motion .= "o?<\\?php\\>\<CR>4l/\\S\<CR>"
	endif

	return motion
endfunction
" }}}

" Mappings to select full/inner PHP block
nmap <silent> <expr> vaP PhpBlockSelect(1)
nmap <silent> <expr> viP PhpBlockSelect(0)
" Mappings for operator mode to work on full/inner PHP block
omap <silent> aP :silent normal vaP<CR>
omap <silent> iP :silent normal viP<CR>

:map <F5> [I:let nr = input("Which on: ")
\ <Bar>exe "normal " . nr . "[\t"<CR>

:nnoremap <Esc>P P'[v']=
:nnoremap <Esc>p p'[v']=
