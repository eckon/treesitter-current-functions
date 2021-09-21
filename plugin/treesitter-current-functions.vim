if exists('g:loaded_treesitter_current_functions')
  finish
endif

" quick debugging (resets the lua cache)
" lua package.loaded['treesitter-current-functions'] = nil

function! s:function_sink(line) abort
  let parts = split(a:line, ':\t')

  " jump to the given line
  execute 'normal ' . parts[0] . 'G'

  " realign cursor in view
  normal zz_
endfunction

function! s:function_lines() abort
  let res = []
  let output = luaeval('require("treesitter-current-functions").get_current_functions()')

  for node_information in output
    let line_number = node_information[0]
    let function_name = node_information[1]
    call extend(res, [line_number . ":\t" . function_name])
  endfor

  return res
endfunction

function! g:Get_current_functions() abort
  call fzf#run(fzf#wrap({
    \ 'source': s:function_lines(),
    \ 'options': ['--prompt', 'Functions> ', '--layout=reverse-list'],
    \ 'sink': function('s:function_sink'),
    \ }))
endfunction

nnoremap <silent> <Plug>TreesitterCurrentFunctions
      \ :<c-u>call g:Get_current_functions()<CR>

command! GetCurrentFunctions call g:Get_current_functions()

let g:loaded_treesitter_current_functions = 1
