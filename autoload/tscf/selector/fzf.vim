function! s:function_sink(line) abort
  let parts = split(a:line, ':\t')
  let line_number_without_spaces = trim(parts[0])

  " jump to the given line
  execute 'normal ' . line_number_without_spaces . 'G'

  " realign cursor in view
  normal zz_
endfunction

function! tscf#selector#fzf#init() abort
  let output = luaeval('require("tscf").get_current_functions_formatted()')

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
