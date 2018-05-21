" Add your own plugins
" Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" Plug '~/my-prototype-plugin'
" ...

Plug 'majutsushi/tagbar'
nnoremap <silent> <F8> :TagbarToggle<CR>

" Golang tagbar types
let g:tagbar_type_go = {
	\ 'ctagstype' : 'go',
	\ 'kinds'     : [
		\ 'p:package',
		\ 'i:imports:1',
		\ 'c:constants',
		\ 'v:variables',
		\ 't:types',
		\ 'n:interfaces',
		\ 'w:fields',
		\ 'e:embedded',
		\ 'm:methods',
		\ 'r:constructor',
		\ 'f:functions'
	\ ],
	\ 'sro' : '.',
	\ 'kind2scope' : {
		\ 't' : 'ctype',
		\ 'n' : 'ntype'
	\ },
	\ 'scope2kind' : {
		\ 'ctype' : 't',
		\ 'ntype' : 'n'
	\ },
	\ 'ctagsbin'  : 'gotags',
	\ 'ctagsargs' : '-sort -silent'
  \ }

Plug 'godoctor/godoctor.vim', { 'do': 'go get -u github.com/godoctor/godoctor' }
