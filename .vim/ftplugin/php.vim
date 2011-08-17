"
" Settings for PHP filetype
"

" Reset to defaults
set expandtab&

" space indentation - not my choice but meh
set tabstop=4
set shiftwidth=4
set expandtab

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
