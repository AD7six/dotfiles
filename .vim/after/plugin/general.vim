"
" General things that should be done at the very end, to override plugin
" settings
"
set errorformat=%m\ in\ %f\ on\ line\ %l
" " Insert <Tab> or complete identifier
" " if the cursor is after a keyword character
" function MyTabOrComplete()
" 	let col = col('.')-1
" 	if !col || getline('.')[col-1] !~ '\k'
" 		return "\<tab>"
" 	else
" 		return "\<C-N>"
" 	endif
" endfunction
"
" inoremap <Tab> <C-R>=MyTabOrComplete()<CR>

"
" Customize taglist settings
if exists('loaded_taglist')
	let Tlist_Auto_Open = 1
	let Tlist_Process_File_Always = 1
	let Tlist_Show_Menu = 1
	let Tlist_Sort_Type = 'name'
	let Tlist_Enable_Fold_Column = 0
	let Tlist_File_Fold_Auto_Close = 0
	let Tlist_Show_One_File = 1
	let Tlist_Ctags_Cmd = "/usr/bin/ctags-exuberant"
	let Tlist_Exit_OnlyWindow = 1
	let Tlist_Inc_Winwidth = 1
	let Tlist_Max_Submenu_Items = 15
	let tlist_php_settings = 'php;c:class;d:constant;f:function'

	map <F8> to toggle taglist window
	nmap <silent> <F8> :TlistToggle<CR>
endif

" vim: set fdm=marker:

nmap <silent> <F7> :NERDTreeToggle<CR>

"
map <F5> [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

:nnoremap <Esc>P P'[v']=
:nnoremap <Esc>p p'[v']=