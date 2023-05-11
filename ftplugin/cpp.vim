if exists("g:cppsnippets")
    finish
endif

command! GenFunc call cppsnippets#GenFunc()
command! -nargs=* Fore call cppsnippets#Fore(<f-args>)
command! -nargs=* For call cppsnippets#For(<f-args>)
command! -nargs=* Init call cppsnippets#Init(<f-args>)
command! Input call cppsnippets#Input()
command! -nargs=* Binary call cppsnippets#Binary(<f-args>)
command! -nargs=* Bfs call cppsnippets#bfs(<f-args>)
command! -nargs=* Import call cppsnippets#Import(<f-args>)

let g:cppsnippets = 'alright'
