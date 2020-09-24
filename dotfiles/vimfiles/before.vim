" Called before everything, even before loading plugins
" Do things that need to happen very early such as:
" let g:fzf_command_prefix = 'Fuzzy'
" ...

let g:onedark_termcolors=256

if (has("autocmd"))
  augroup colorextend
    autocmd!
    " autocmd ColorScheme * call onedark#extend_highlight("Function", { "gui": "bold" })
    " autocmd ColorScheme * call onedark#extend_highlight("Statement", { "fg": { "cterm": 128 } })
    " autocmd ColorScheme * call onedark#extend_highlight("Identifier", { "fg": { "gui": "#b042f4" } })
  augroup END
endif

autocmd BufRead pipeline.yml set includeexpr=substitute(v:fname,'^cli-ci/','','')

" Enable autosave
let g:autosave = 1
