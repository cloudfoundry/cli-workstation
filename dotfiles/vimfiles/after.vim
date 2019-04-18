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

" Sometimes fuzzy find will segfault if the following variable is set.
" Unfortunately, we can't have a nice layout and never segfault :(
unlet g:fzf_layout

autocmd FileType go nnoremap gi :GoImplements<CR>

function! PasteGitAuthors()
  norm gg
  let l:pattern = '^#'
  let l:cursor = searchpos(l:pattern)[0]-1

  call append(l:cursor, '#')
  call append(l:cursor, '# Author Email: ' . $GIT_AUTHOR_EMAIL)
  call append(l:cursor, '# Author Name:  ' . $GIT_AUTHOR_NAME)
  norm gg
endfunction

autocmd FileType gitcommit call PasteGitAuthors()
