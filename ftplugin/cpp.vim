if exists("g:cppsnippets")
    finish
endif

command! -buffer GenFunc call cppsnippets#GenFunc()
command! -buffer -nargs=* Fore call cppsnippets#Fore(<f-args>)
command! -buffer -nargs=* For call cppsnippets#For(<f-args>)
command! -buffer -nargs=* Init call cppsnippets#Init(<f-args>)
command! -buffer Input call cppsnippets#Input()
command! -buffer -nargs=* Binary call cppsnippets#Binary(<f-args>)
command! -buffer -nargs=* Bfs call cppsnippets#bfs(<f-args>)
command! -buffer -nargs=* Import call cppsnippets#Import(<f-args>)
command! -buffer -range VisualInput call cppsnippets#VisualInput(<line1>, <line2>)

let g:cppsnippets = 'alright'
