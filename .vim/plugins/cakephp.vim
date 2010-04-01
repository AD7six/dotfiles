""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" cakephp.vim
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Authors:      Andy Dawson <andydawson76 AT yahoo DOT co DOT uk>
" Version:      2
" Licence:      http://www.opensource.org/licenses/mit-license.php
"               The MIT License
" URL:          http://thechaw.com/cakemate
"
"-----------------------------------------------------------------------------
"
" Section: Documentation
"
" Command Documentation
" By Default, the following commands are defined:
" 	:M - Open the model file
" 	:V - Open the view file
" 	:C - Open the controller file
" 	:D - Add doc blocks to the current buffer
" 	:F - Clean the current buffer (Apply code standards)
" 	:R - Regenerate all docs for the current file
" 	:L - Show the log

" Mapping Documentation
" By Default, the following mappings are defined (partial):
" 	<Ctrl+P> will document the current line
" 	<F9> will document the current buffer
" 	<F12> will document all open buffers
"

" Section: Plugin header
"
" loaded_cakephp is set to 1 when initialization begins, and 2 when it
" completes.

if (exists('debugger_running'))
	finish
endif
if exists('loaded_cakephp')
	call s:SetupBuffer()
	norm! zx
	finish
endif
let loaded_cakephp=1

" Section: Event group setup

augroup CakeCommand
augroup END

" Section: Script variables

let s:Projects = {}
let b:Root = ''
let s:Cake = ''
let s:Root = ''
let s:ConsoleLog = []
let s:CommandLog = []
let s:ConfigOpenCmd = 'tabe' "'sp'
let s:ConfigCleanOnWrite = 1

" Section: Utility functions
" These functions are not/should not be directly accessible

" Function: Console()
" Call the cake console editor shell with the passed args pass the results through s:Return
function s:Console(cmd, ...)
	let i = 1
	let l:command = ["cake editor", a:cmd]
	while i <= a:0
		if a:{i} != ""
			call add(l:command, shellescape(a:{i}))
		endif
		let i = i + 1
	endwhile
	let l:return = call('s:DirectConsole', l:command)
	return call('s:Return', l:return)
endfunction

" Function: DirectConsole()
" Directly make a system call, returning the response as a list of [line1, line2, ...]
" write the call to the log too
function s:DirectConsole(...)
	let cmd = join(a:000, ' ') . ' -q 1 -app ' . shellescape(b:Root)
	let s:ConsoleLog = s:ConsoleLog + [cmd]
	return split(substitute(system(cmd), s:junk, '', 'g'), '\n')
endfunction

" Function: Return()
" Parse the response and if necessary prompt the user to make a selection
" If only a single result is found, that is the selection.
" Expects EITHER to be called with
" 	(string, string, string, ...)
" OR
" 	('Display<tab>path', 'Display<tab>path', 'Display<tab>path', ...)
function s:Return(first, ...)
	if a:0 == 0
		if a:first =~ '\t'
			let [l:key, l:value] = split(a:first, "\t")
			return l:value
		else
			return a:first
		endif
	endif
	let l:list = ["Which one: ?"]
	let l:options = [a:first] + a:000
	let l:returns = ['Spacer']
	let i = 1
	for item in l:options
		if item =~ '.*\t.*'
			let [l:key, l:value; rest] = split(item, "\t")
			let l:value = substitute (l:value, b:Root . '/', '', "g")
			let item = l:key . ' (' . l:value . ')'
			call add(l:returns, l:value)
		else
			call add(l:returns, l:item)
		endif
		call add(l:list, i . ' ' . item)
		let i = i + 1
	endfor
	let l:selection = inputlist(l:list)
	if l:selection > 0
		return l:returns[l:selection]
	endif
	return ''
endfunction

" Function: Open()
" Open the file, or goto an already-open buffer
function s:Open(file)
	if strlen(a:file) > 0
		if bufnr(a:file) > 0
			let cmd = 'b ' . bufnr(a:file)
		else
			let cmd = s:ConfigOpenCmd . ' ' . a:file
		endif
		let s:CommandLog = s:CommandLog + [cmd]
		exe cmd
	endif
endfunction

" Function: DocPaste(start)
" Disable any other enhancements before generating doc blocks, and reset the
" paste function thereafter.
" Prevents (for example) ever increasing comment indentation
function s:DocPaste(start)
	if a:start == 1
		let &g:paste = 1
	else
		let &g:paste = 0
	endif
endfunc

" Function: BufferWritePre()
" EOL markers are not desired, change to binary mode before saving so one isn't added
function s:BufferWritePre()
	" set to binary and remove eol
	let b:save_bin = &bin
	let &l:bin = 1
	let &l:eol = 0
endfunction
" Function: BufferWritePost()
" Back to not-binary-mode

function s:BufferWritePost()
	let &l:bin = b:save_bin
	if (&ft == 'php')
		if !has_key(s:Projects, b:Root)
			let cmd = '!cd ' . shellescape(b:Root) . ' && nice -n20 cake autopilot -q -noclear >auto.log 2>auto.err &'
			let s:ConsoleLog = s:ConsoleLog + [cmd]
			:silent exe cmd
			let s:Projects[b:Root] = system('$!')
		endif
		" :call DocTags(expand("%:p")) "disabled it's too slow
	endif
endfunction

" Function: SetupBuffer()
" For each file that is opened, setup the buffer auto commands
function s:SetupBuffer()
	if (exists('b:CakeBufferSetup') && b:CakeBufferSetup)
		return
	endif
	if (expand("%:t") == 'acl.ini.php')
		return
	endif
	set makeprg=php\ -l\ %
	set errorformat=%m\ in\ %f\ on\ line\ %l
	compiler php

	if !exists("b:Root") || len(b:Root) == 0
		if !exists("s:junk") || len(s:junk) == 0
			let cmd = 'cake editor junk -q'
			let s:ConsoleLog = s:ConsoleLog + [cmd]
			let s:junk = system(cmd)

			let cmd = 'cake editor base CAKE -q'
			let s:ConsoleLog = s:ConsoleLog + [cmd]
			let l:Cake = split(substitute(system(cmd), s:junk, '', 'g'), '\n')
			silent! let [s:Cake; rest] = l:Cake
		endif

		let cmd = 'cake editor base -q 1 ' . shellescape(expand("%:p"))
		let s:ConsoleLog = s:ConsoleLog + [cmd]
		let l:Root = split(substitute(system(cmd), s:junk, '', 'g'), '\n')
		silent! let [b:Root; rest] = l:Root
		silent! :exe "set tags=" . b:Root . "/tags," . s:Cake . "/tags"
	endif
	"autocmd BufWinEnter * :let w:m1=matchadd('Search', '\%<101v.\%>97v', -1)
	"autocmd BufWinEnter * :let w:m2=matchadd('ErrorMsg', '\%>100v.\+', -1)
	autocmd BufNewFile * call s:SetupBuffer()
	autocmd BufReadPost * call s:SetupBuffer()
	autocmd BufWritePre * call s:BufferWritePre()
	autocmd BufWritePost * call s:BufferWritePost()
	call s:SetupCommands()
	call s:SetupMappings()
	call s:SetupMenu()
	norm! zx
	let b:CakeBufferSetup=1
endfunction

" Section: Public functions

" Function: Cake()
function Cake(...)
	let i = 1
	let l:command = ["cake"]
	while i <= a:0
		if a:{i} != ""
			call add(l:command, shellescape(a:{i}))
		endif
		let i = i + 1
	endwhile
	let l:return = call('s:DirectConsole', l:command)
	for item in l:return
		echom item
	endfor
endfunction

" Function: ExplodePhp()
" For code that's not wrapped correctly, explode it (put each new array element on a new line)
" and then indent it. It's a lot easier to read/cleanup code that's been too-exploded
" than code that isn't wrapped/formatted/indented
function ExplodePhp() range
	let l:line = line('.')
	:delmarks yz
	:silent exe 'norm ' . a:firstline . 'G'
	:ky
	:silent exe 'norm ' . a:lastline . 'G'
	:kz

	"explode on any comma, or ()
	:silent 'y,'zs/\([,()]\)\( \?[^, ]\)/\1 \r\2/ge
	"for any closing bracket that isn't on its own line explode that too
	:silent 'y,'zs/\([\S]\))\(,?\)$/\1\r)\2/ge
	"For a closing bracket, with a  semicolon on the following line - clean up
	:silent 'y,'zs/)\s\r\s*;/);/e
	
	" indent	
	exe "norm ='y'z"
	:silent exe 'norm ' . l:line . 'G'
endfunction

" Function: FormatPhp()
" (Attempt to) autoformat php code according to various conventions
function FormatPhp() range
	let l:line = line('.')
	:delmarks yz
	:silent exe 'norm ' . a:firstline . 'G'
	:ky
	:silent exe 'norm ' . a:lastline . 'G'
	:kz

	""replace any double spaces with a single space
	":silent '<,'>s/ \{2,}/ /ge
	"remove trailing whitespace
	:silent 'y,'zs/\s\s*$//e
	" Lower case booleans please
	:silent 'y,'zs/TRUE/true/e
	:silent 'y,'zs/FALSE/false/e

	" auto correct lines which start with a { so the { is on the end of the
	" previous line
	:silent 'y,'zs/\n\s*{/ {/e
	" auto correct lines which start with 'else' prepending the else to the
	" previous line
	:silent 'y,'zs/}\s*\n\s*else/ else/e
	:silent 'y,'zs/\n\s*else/} else/e
	" add parenthesese to a trailing else or if
	:silent 'y,'zs/\(else|if\)\s*\n/\1 {\n/e
	" add parenthesese to what looks like an else with no parenthesese
	:silent 'y,'zs/^\(\s*\)\zselse\s*\([^{]\)/else {\n\t\1\2/e

	" correct whitespace around comas (parameters)
	:silent 'y,'zs/,\(\S\)\@=/, /ge
	" correct whitespace around assignments/comparisons x=y becomes x = y
	:silent 'y,'zs/\([^\.!=<>&+\- ]\)\([\.!<]\?==\?[=>&]\?\)\([^=<>& ]\)/\1 \2 \3/ge
	" correct whitespace around assignments/comparisons x= y becomes x = y
	:silent 'y,'zs/\([^\.!=<>&+\- ]\)\([\.!<]\?==\?[=>&]\?\)/\1 \2/ge
	" correct whitespace around assignments/comparisons x =y becomes x = y
	:silent 'y,'zs/\([\.!<]\?==\?[=>&]\?\)\([^=<>& ]\)/\1 \2/ge

	" put a blank line before comment blocks
	:silent 'y,'zs/\([\{\}\/;]\)\n\zs\/\*/\r\/\*/e
	" correct doc block headers
	:silent 'y,'zs/^\s*\/\*\*/\/\*\*/e
	" correct doc block contents/tail that is indented ( * or  */)
	:silent 'y,'zs/^\s*\*/ \*/e

	" auto correct deprecated methods
	:silent 'y,'zs/\W\zsam(/array_merge(/e


	'y,'z:call s:FormatComments()
	
	" indent	
	exe "norm ='y'z"

	:silent exe 'norm ' . l:line . 'G'
endfunction

" Function: ImplodePhp()
" combine lines of php code
" and then indent it. It's a lot easier to read/cleanup code that's been too-exploded
" than code that isn't wrapped/formatted/indented
function ImplodePhp() range
	let l:line = line('.')
	:delmarks yz
	:silent exe 'norm ' . a:firstline . 'G'
	:ky
	:silent exe 'norm ' . a:lastline . 'G'
	:kz

	"explode on any comma, or ()
	:silent 'y,'zs/\([,()]\)\( \?[^, ]\)/\1 \r\2/ge
	"for any closing bracket that isn't on its own line explode that too
	:silent 'y,'zs/\([\S]\))\(,?\)$/\1\r)\2/ge
	"For a closing bracket, with a  semicolon on the following line - clean up
	:silent 'y,'zs/)\s\r\s*;/);/e

	" indent	
	exe "norm ='y'z"

	:silent exe 'norm ' . l:line . 'G'
endfunction


" Function: Controller()
" Open the controller file that is associated with whatever is currently being edited
" If the function is known - search for and jump to it
function Controller()
	call s:Open(s:Console('path controller', expand("%:p")))
endfunction

" Function: Model()
" Open the model file that is associated with whatever is currently being edited.
function Model()
	call s:Open(s:Console('path model', expand("%:p")))
endfunction

" Function: View()
" Open the view file that is associated with whatever is currently being edited.
function View()
	call s:Open(s:Console('path view', expand("%:p")))
endfunction

" Function: DocSingle()
" Document a single line of code (does not check if doc block already exists)
" Enters paste mode before starting to ensure indentation is correct
" Skips doing anything if it doesn't look like a class, property or function declaration
function DocSingle(...)
	let l:default = ' -default '
	if a:0 == 1 && a:1 == 1
		let l:default = ''
	endif

	if (l:default == '' && line('.') > 1 && getline('.') !~ '^\s*\(final\|abstract\|static\|class\|function\|var\|public\|protected\|private\)')
		return
	endif
	let l:line = substitute(getline("."), '^\s', '', 'g')
	" Console balks on empty parameters
	if (l:line == '')
		let l:line = ' '
	endif
	call s:DocPaste(1)
	let l:doc = s:DirectConsole('cake editor doc ' . expand("%:p") . ' ' . shellescape(l:line) . ' ' . line(".") . l:default)
	if len(l:doc) == 0
		return
	endif
	call s:DocPaste(1)
	let l:first = 1
	for item in l:doc
		if l:first == 1
			if line('.') == 1
				let cmd = "norm! 0R" . item
			else
				let cmd = "norm! O" . item
			endif
		else
			let cmd = "norm! o" . item
		endif
		let s:CommandLog = s:CommandLog + [cmd]
		exe cmd
		let l:first = 0
	endfor
	call s:DocPaste(0)
endfunc

" Function: DocRange()
" Documents a whole range of code lines (does not add defualt doc block to unknown types of lines).
" For each line in the requested range, if it's not a doc block line already and is not preceeded by
" a doc blcok call DocSingle()
" If running for the whole file, check by starting from line 2 (to exclude the php tag line) if a file
" doc block (by looking for an @filesource tag and a class doc block (any line which includes class)
" exist before the first none-comment line. Generate missing doc blocks as appropriate
function DocRange() range
	call s:DocPaste(1)
	norm zR
	let l:line = a:firstline
	if l:line == 1
		let l:line = 2
	endif
	let l:endLine = a:lastline
	while l:line < (l:endLine)
		if (getline(l:line) !~ '^\s*$' && getline(l:line) !~ '^\s*/\?\*' && getline(l:line - 1) !~ '^\s*/\?\*' && getline(l:line - 2) !~ '^\s*/\?\*')
			exe "norm! " . l:line . "G$"
			call DocSingle(1)
			if line('.') != l:line
				" A doc block has been inserted
				" Adjust the line to run to (maintain the same effective endline)
				let l:diff = line('.') - l:line + 1
				let l:endLine += l:diff
			endif
			let l:line = line('.') + 1
		elseif (l:line > 2 && getline(l:line) =~ '^/\*' && getline(l:line - 1) !~ '^\s*$')
			exe "norm! " . l:line . "G$"
			exe "norm! O"
			let l:endLine += 1
			let l:line = line('.') + 1
		else
			let l:line = l:line + 1
		endif
	endwhile
	if a:firstline == 1
		let l:line = 2
		let l:headDocFound = 0
		let l:classDocFound = 0
		while l:line <= l:endLine
			if getline(l:line) !~ '^\s*$' && getline(l:line) !~ '^\s*/\?\*'
				break
			endif
			if getline(l:line) =~ '^.*@filesource'
				let l:headDocFound = 1
			elseif getline(l:line) =~ 'class'
				let l:classDocFound = 1
			endif
			let l:line = l:line + 1
		endwhile
		if l:headDocFound == 0
			norm gg
			call DocSingle(1)
		elseif l:classDocFound == 0
			exe "norm! " . l:line . "G$"
			call DocSingle(1)
		endif
	endif
	call s:DocPaste(0)
	" back to the first line
	exe "norm! " . a:firstline . 'G'
endfunc

" Function: DocDebug()
" Convenience function for dumping vars and seeing the console log
function DocDebug(...)
	if a:0 == 1 && type(a:1) == type([])
		return call('DocDebug', a:1)
	endif
	echom 'file ' . expand("%:p")
	echom 's:Projects '
	for [key, value] in items(s:Projects)
		echo key . ': ' . value
	endfor
	echom 'b:Root ' . b:Root
	echom 's:Cake ' . s:Cake
	echom 's:junk ' . s:junk
	echom 'Console Log:'
	for item in  s:ConsoleLog
		echom "\t" . item
	endfor
	echom 'Command Log:'
	for item in  s:CommandLog
		echom "\t" . item
	endfor
	if a:0
		echom ''
	endif
	for item in  a:000
		echom item
	endfor
endfunction

" Function: DocTags()
" Include the core (the 1), update the tags file
function DocTags(...)
	if a:0 == 0
		"call s:DirectConsole('cake editor tags', '"*"')
		let cmd = '!cake editor tags "*" -q 1 -app ' . shellescape(b:Root)
		let s:ConsoleLog = s:ConsoleLog + [cmd]
		:exe cmd
	else
		"call s:DirectConsole('cake editor tags', a:1)
		let cmd = '!cake editor tags ' . a:1 . ' -q 1 -app ' . shellescape(b:Root) . ' > /dev/null'
		let s:ConsoleLog = s:ConsoleLog + [cmd]
		:silent exe cmd
	endif
endfunction

" Function: SetupCommands()
" Setup default commands for each of the public methods
function s:SetupCommands()
	if !exists(":M")
		command -bar -narg=0 M call Model()
	endif
	if !exists(":V")
		command -bar -narg=0 V call View()
	endif
	if !exists(":C")
		command -bar -narg=0 C call Controller()
	endif
	if !exists(":D")
		command -nargs=0 D %call DocRange()
	endif
	if !exists(":R")
		command -nargs=0 R %call FormatPhp()
	endif
	if !exists(":L")
		command -bar -narg=0 L call DocDebug()
	endif
	if !exists(":Cake")
		command -bar -narg=0 Cake call Cake()
	endif
endfunction

" Function: SetupMappings()
" Setup mappings for each of the public methods
function s:SetupMappings()
	if !hasmapto('<Plug>Model')
		map <buffer> <unique> <Leader>m Model
	endif
	if !hasmapto('<Plug>View')
		map <buffer> <unique> <Leader>v View
	endif
	if !hasmapto('<Plug>Controller')
		map <buffer> <unique> <Leader>c Controller
	endif
	if !hasmapto('<Plug>DocSingle')
		map <buffer> <unique> <Leader>s DocSingle
	endif
	"if !hasmapto('<Plug>DocRange')
	"	map <buffer> <unique> <Leader>r <Plug>DocRange
	"	map <buffer> <unique> <Leader>a %<Plug>DocRange
	"endif
	nnoremap <buffer> <C-F> :%call FormatPhp()<CR>
	vnoremap <buffer> <C-F> :call FormatPhp()<CR>
	nnoremap <buffer> <C-X> :%call ExplodePhp()<CR>
	vnoremap <buffer> <C-X> :call ExplodePhp()<CR>
	inoremap <buffer> <C-P> <Esc>:call DocSingle()<CR>i
	nnoremap <buffer> <C-P> :call DocSingle()<CR>
	vnoremap <buffer> <C-P> :call DocRange()<CR>
	nnoremap <buffer> <F4> :call DocTags()<CR>
	nnoremap <buffer> <F9> :%call DocRange()<CR>
	nnoremap <buffer> <F12> :bufdo! :%call DocRange()<CR>
endfunction

" function SetupMenu()
" Setup standard menu items
" TODO Needs updating
function s:SetupMenu()
	noremenu <script> &Plugin.&CakePHP.Switch\ To\ &Model<Tab>:M :call Model()<CR>
	noremenu <script> &Plugin.&CakePHP.Switch\ To\ &View<Tab>:V :call View()<CR>
	noremenu <script> &Plugin.&CakePHP.Switch\ To\ &Controller<Tab>:C :call Controller()<CR>

	inoremenu <script> &Plugin.&CakePHP.Add\ &Doc\ Block<Tab>:D <Esc>:call DocSingle()<CR>i
	nnoremenu <script> &Plugin.&CakePHP.Add\ &Doc\ Block<Tab>:D :call DocSingle()<CR>
	nnoremenu <script> &Plugin.&CakePHP.Check\ Doc\ &Blocks<Tab>F9 :%call DocRange()<CR>
	vnoremenu <script> &Plugin.&CakePHP.Doc\ &Range<Tab><C-P> :call DocRange()<CR>
	nnoremenu <script> &Plugin.&CakePHP.Doc\ All\ &Tabs<Tab><F12> :bufdo! :%call DocRange()<CR>
endfunction

" Section: Plugin completion
call s:SetupBuffer()
let loaded_cakephp=2

" Section: Limbo
" Functions/code waiting to be either deleted, fixed or rewrittendif

" Function: ReprocessComments()
" Delete all existing comments, and rerun the DocRange function to regenerate them.
function s:ReprocessComments()
	:silent g@^\(/\| \)\*@de
	%:call DocRange()
endfunction

" Function: FormatComments()
" Correct whitespace around doc blocks
function s:FormatComments() range
	let l:line = line('.')
	:delmarks yz
	:silent exe 'norm ' . a:firstline . 'G'
	:ky
	:silent exe 'norm ' . a:lastline . 'G'
	:kz

  	   'y,'zs/\*\s*@copyright\s*/\* @copyright     /ge
	        'y,'zs/\*\s*@link\s*/\* @link          /ge
	     'y,'zs/\*\s*@package\s*/\* @package       /ge
	  'y,'zs/\*\s*@subpackage\s*/\* @subpackage    /ge
	       'y,'zs/\*\s*@since\s*/\* @since         /ge
	     'y,'zs/\*\s*@version\s*/\* @version       /ge
	  'y,'zs/\*\s*@modifiedBy\s*/\* @modifiedby    /ge
	  'y,'zs/\*\s*@modifiedby\s*/\* @modifiedby    /ge
	'y,'zs/\*\s*@lastModified\s*/\* @lastmodified  /ge
	'y,'zs/\*\s*@lastmodified\s*/\* @lastmodified  /ge
	     'y,'zs/\*\s*@license\s*/\* @license       /ge
 	        'y,'zs/\*\s*@uses\s*/\* @uses          /ge
 	      'y,'zs/\*\s*@author\s*/\* @author        /ge
	:silent exe 'norm ' . l:line . 'G'
endfunction

" Function: DeleteBlankLines()
" TODO doesn't work as a function call atm.
" Exactly what it says on the tin
function s:DeleteBlankLines()
	" :g/^\s\*$/d
	exe "norm :g/^\s\*$/d<CR>"
endfunction