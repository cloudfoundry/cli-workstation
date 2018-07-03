" Called after everything just before setting a default colorscheme
" Configure you own bindings or other preferences. e.g.:

" set nonumber " No line numbers
" let g:gitgutter_signs = 0 " No git gutter signs
" let g:SignatureEnabledAtStartup = 0 " Do not show marks
" nmap s :MultipleCursorsFind
" colorscheme hybrid
" let g:lightline['colorscheme'] = 'wombat'
" ...

" Word Wrapping
set wrap
set linebreak
set nolist  " list disables linebreak

" Set up GoGuru to root of CLI
autocmd BufRead ~/go/src/code.cloudfoundry.org/cli/**/*.go
      \ silent
      \ :GoGuruScope code.cloudfoundry.org/cli

" Bind buffer next/previous
nnoremap <silent> <localleader>x :bn<CR>
nnoremap <silent> <localleader>z :bp<CR>

" Enable toggling for autopairs
let g:AutoPairsShortcutToggle = '<M-t>'

