if !exists("g:gen_func_mapping")
    let g:gen_func_mapping = 'g!'
endif

if !exists("g:input_mapping")
    let g:input_mapping = 'gI'
endif

exe "nnoremap " .. g:gen_func_mapping .. " :GenFunc<cr>"

exe "nnoremap " .. g:input_mapping .. " :Input<cr>"

exe "vnoremap " .. g:input_mapping .. " :VisualInput<cr>"

