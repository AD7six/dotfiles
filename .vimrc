" My vimrc file. mostly from the example for a vimrc file. by Bram Moolenaar
"
call pathogen#runtime_append_all_bundles()

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=100         " keep 100 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set incsearch           " do incremental searching

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
	syntax on
	set hlsearch
endif

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
	au!
	" For all text files set 'textwidth' to 78 characters.
	"autocmd FileType text setlocal textwidth=78
	" When editing a file, always jump to the last known cursor position.
	" Don't do it when the position is invalid or when inside an event handler
	" (happens when dropping a file on gvim).
	autocmd BufReadPost *
		\ if line("'\"") > 0 && line("'\"") <= line("$") |
		\ 	exe "normal g`\"" |
		\ endif
augroup END

if &diff
	:nmap < :diffg<cr>
	:nmap > :diffpu<cr>
endif
au BufReadPost quickfix  setlocal modifiable
	\ | silent exe 'g/^/s//\=line(".")." "/'
	\ | setlocal nomodifiable

noremap <silent> <Leader>w :call ToggleWrap()<CR>
function ToggleWrap()
  if &wrap
    echo "Wrap OFF"
    setlocal nowrap
    set virtualedit=all
    silent! nunmap <buffer> k
    silent! nunmap <buffer> j
    silent! nunmap <buffer> <Up>
    silent! nunmap <buffer> <Down>
    silent! nunmap <buffer> <Home>
    silent! nunmap <buffer> <End>
    silent! iunmap <buffer> <Up>
    silent! iunmap <buffer> <Down>
    silent! iunmap <buffer> <Home>
    silent! iunmap <buffer> <End>
  else
    echo "Wrap ON"
    setlocal wrap linebreak nolist
    set virtualedit=
    setlocal display+=lastline
    noremap  <buffer> <silent> k gk
    noremap  <buffer> <silent> j gj
    noremap  <buffer> <silent> <Up>   gk
    noremap  <buffer> <silent> <Down> gj
    noremap  <buffer> <silent> <Home> g<Home>
    noremap  <buffer> <silent> <End>  g<End>
    inoremap <buffer> <silent> <Up>   <C-o>gk
    inoremap <buffer> <silent> <Down> <C-o>gj
    inoremap <buffer> <silent> <Home> <C-o>g<Home>
    inoremap <buffer> <silent> <End>  <C-o>g<End>
  endif
endfunction

set incsearch
set wildignore=*~,*.bak

set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L
set laststatus=2
set number

set tabstop=4
set shiftwidth=4
set shiftround
set smarttab

" http://www.catonmat.net/blog/top-ten-one-liners-from-commandlinefu-explained/
:nmap :suw :w !sudo tee %

:filetype plugin indent on
map <C-B> :make<CR>

" swap files (.swp) in a common location
" // means use the file's full path
set dir=~/.vim/_swap//

" backup files (~) in a common location if possible
set backup
set backupdir=~/.vim/_backup/,~/tmp,.

" turn on undo files, put them in a common location
set undofile
set undodir=~/.vim/_undo/

" Enable mouse on CLI
"set mouse=a

" Make NERD tree easily accessible
nmap <silent> <F7> :NERDTreeToggle<CR>
nmap <C-p> :call PhpDocSingle()<CR>
nmap <C-y> :TagbarToggle<CR>

" Since it applies to all file types I use - strip trailing whitespace on
" write automatically
autocmd BufWritePre * :%s/\s\+$//e

" Stuff with a username or password goes in here
" Also things that are global but too embarassing to appear in this file
source ~/.vimprivate

" :noremap :wq :au! syntastic<cr>:wq
