if exists('g:loaded_tscf')
  finish
endif

let g:loaded_tscf = 1

" quick debugging (resets the lua cache)
" lua package.loaded['tscf'] = nil
" lua package.loaded['tscf.selector.telescope'] = nil

" general execution of the plugin
function! tscf#select_function(...) abort
  let fzf_exists = exists('g:loaded_fzf_vim')
  let telescope_exists = exists('g:loaded_telescope')

  if fzf_exists
    call tscf#selector#fzf#init()
  elseif telescope_exists
    lua require("tscf.selector.telescope").init()
  else
    echo "No fuzzy finder was found (fzf, telescope)"
    echo "Add your own (see plugin folder) or add an issue to add others"
  endif
endfunction

" mappings
command! GetCurrentFunctions call tscf#select_function()
