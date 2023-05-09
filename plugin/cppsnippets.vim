if exists("g:cppsnippets")
    finish
endif

command! GenFunc call cppsnippets#GenFunc()
command! -nargs=* Fore call cppsnippets#Fore(<f-args>)
command! -nargs=* For call cppsnippets#For(<f-args>)
command! -nargs=* Init call cppsnippets#Init(<f-args>)
command! Input call cppsnippets#Input()

if !exists("g:gen_func_mapping")
    let g:gen_func_mapping = 'g!'
endif

if !exists("g:input_mapping")
    let g:input_mapping = 'gI'
endif

exe "nnoremap " .. g:gen_func_mapping .. " :GenFunc<cr>"

exe "nnoremap " .. g:input_mapping .. " :Input<cr>"

let g:cppsnippets = 'alright'
