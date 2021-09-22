if exists('g:loaded_tscf')
  finish
endif

let g:loaded_tscf = 1

" quick debugging (resets the lua cache)
" lua package.loaded['tscf'] = nil
" lua package.loaded['tscf.selector.telescope'] = nil

" general execution of the plugin
function! tscf#select_function(...) abort
  let argument_count = a:0
  let call_fzf = exists('g:loaded_fzf_vim')
  let call_telescope = exists('g:loaded_telescope')

  " overwrite flag for selector in case we got selector arguments
  if argument_count >= 1
    let selector = a:1
    let call_fzf = call_fzf && selector == "fzf"
    let call_telescope = call_telescope && selector == "telescope"
  end

  if call_fzf
    call tscf#selector#fzf#init()
    return
  end

  if call_telescope
    lua require("tscf.selector.telescope").init()
    return
  end

  " if user passed value in argument and nothing was run to this point, then
  " call itself recursively to go back to the default behaviour
  if argument_count >= 1
    echo "Your chosen selector \"" . selector . "\" was not found --- fallback to selector independent call"
    call tscf#select_function()
    return
  end

  echo "No selector was found (fzf, telescope)"
  echo "Install one (:help tscf-installation) or add your own selector (:help tscf-development)"
endfunction

" mappings
command! GetCurrentFunctions call tscf#select_function()
