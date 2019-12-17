" Called after everything just before setting a default colorscheme
" Configure you own bindings or other preferences. e.g.:

" set nonumber " No line numbers
" let g:gitgutter_signs = 0 " No git gutter signs
" let g:SignatureEnabledAtStartup = 0 " Do not show marks
" nmap s :MultipleCursorsFind
" colorscheme hybrid
" let g:lightline['colorscheme'] = 'wombat'
" ...

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
unlet! g:fzf_layout

augroup go
  autocmd FileType go nnoremap gi :GoImplements<CR>
  autocmd FileType go nnoremap gr :GoReferrers<CR>
  autocmd FileType go nnoremap <LocalLeader>i :GoImplements<CR>
  autocmd FileType go nnoremap <LocalLeader>r :GoReferrers<CR>
augroup END

nnoremap <LocalLeader>t :TagbarOpen fc<CR>
nnoremap <LocalLeader>u :UndotreeToggle<CR>
nnoremap <LocalLeader>f :CtrlSF<CR>

function! PasteGitAuthors()
  norm gg
  let l:pattern = '^#'
  let l:cursor = searchpos(l:pattern)[0]-1

  call append(l:cursor, '#')
  call append(l:cursor, '# Author Email: ' . $GIT_AUTHOR_EMAIL)
  call append(l:cursor, '# Author Name:  ' . $GIT_AUTHOR_NAME)
  norm gg
endfunction

augroup gitcommit
  autocmd FileType gitcommit call PasteGitAuthors()
  autocmd FileType gitcommit set spell
augroup END

function! CFCLIIntegrationTransform(cmd) abort
  if getcwd() =~# 'cli' && a:cmd =~# 'integration'
    return 'make build && '.a:cmd
  endif

  return a:cmd
endfunction

let g:test#custom_transformations = { 'cfcli': function('CFCLIIntegrationTransform') }
let g:test#transformation = 'cfcli'

let g:go_build_tags = 'V7'
