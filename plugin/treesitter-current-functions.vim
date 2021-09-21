if exists('g:loaded_treesitter_current_functions')
  finish
endif

let g:loaded_treesitter_current_functions = 1

" quick debugging (resets the lua cache)
" lua package.loaded['treesitter-current-functions'] = nil
" lua package.loaded['treesitter-current-functions.selector.telescope'] = nil


" FZF implementation
function! s:function_sink(line) abort
  let parts = split(a:line, ':\t')

  " jump to the given line
  execute 'normal ' . parts[0] . 'G'

  " realign cursor in view
  normal zz_
endfunction

function! s:current_functions_with_fzf() abort
  let output = luaeval('require("treesitter-current-functions").get_current_functions_formatted()')

  " check if there is any function in current buffer, if not notify user
  if output == []
    echo 'No function found in the current buffer'
    return
  endif

  call fzf#run(fzf#wrap({
    \ 'source': output,
    \ 'options': ['--prompt', 'Functions> ', '--layout=reverse-list'],
    \ 'sink': function('s:function_sink'),
    \ }))
endfunction


" general execution of the plugin
function! g:Get_current_functions() abort
  let fzf_exists = exists('g:loaded_fzf_vim')
  let telescope_exists = exists('g:loaded_telescope')

  if fzf_exists
    call s:current_functions_with_fzf()
  elseif telescope_exists
    lua require("treesitter-current-functions.selector.telescope").init()
  else
    echo "No fuzzy finder was found (fzf, telescope)"
    echo "Add your own (see plugin folder) or add an issue to add others"
  endif
endfunction


" Maps/Commands for end user
nnoremap <silent> <Plug>TreesitterCurrentFunctions
      \ :<c-u>call g:Get_current_functions()<CR>

command! GetCurrentFunctions call g:Get_current_functions()
