if exists("g:cppsnippets")
    finish
endif

command! GenFunc call cppsnippets#GenFunc()
command! -nargs=* Fore call cppsnippets#Fore(<f-args>)
command! -nargs=* For call cppsnippets#For(<f-args>)
command! -nargs=* Init call cppsnippets#Init(<f-args>)
command! Input call cppsnippets#Input()

let g:cppsnippets = 'alright'
