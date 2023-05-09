function! cppsnippets#GenFunc()
    let func_name = expand('<cword>')
    let [temp, rest] = split(getline('.'), func_name)
    let balance = 1
    let end = 1
    for chr in rest[1:]
        if chr == '('
            let balance = balance + 1
        elseif chr == ')'
            let balance = balance - 1
        endif
        if balance == 0
            break
        endif
        let end+=1
    endfor
    let params = split(rest[1:end - 1], ",\s*")
    let vars = []
    for param in params
        let x = search(param .. " *=[^=]") || search(param .. " *(.*)") || search(param .. "\[[0-9]*\]")

        let line = getline(".")
        let var_type = split(trim(line), " ")[0]
        let isArray = 0
        if match(line, "\[") != -1
            let isArray = 1
        endif
        call add(vars, var_type .. " " .. (isArray ? param .. "[]" : param))
    endfor
    call search("int main")
    normal! O
    normal! O
    exe "normal! o\nvoid " .. func_name .. "("

    for param in vars
        exe "normal! a" .. param .. ", "
    endfor 
    exe "normal! xxa) {\n\n}"
    normal! 2kviw
endfunction

" --------------------  

function! cppsnippets#Fore(...)
    let objName = a:1
    let options = ""
    if len(a:000) >= 2
        let options = a:2
    endif
    exe "normal! ofor(auto" .. (match(options, "m") != -1 ? "& " : " ") .. "x in " .. objName .. ") {\n" .. (match(options, "p") != -1 ? "cout << x << \" \";" : "") .. "\n}\ncout << endl;\n"
    normal! 4-fxviw
endfunction

" --------------------  

function! cppsnippets#For(...)
    exe "normal! ofor(declaration; condition; step) {\n\n}" 
    normal! 2kfdviw
endfunction

" --------------------  

function! cppsnippets#Init(...)
    let libraries = copy(a:000)
    if len(libraries) == 0
        call extend(libraries, ["iostream", "vector", "algorithm"])
    endif
    normal! ggVGd
    for lib in libraries
        normal! G
        exe "normal! i#include <" .. lib .. ">"
        normal! o 
    endfor
    exe "normal! a\n"
    exe "normal! iint main() {\n\n}"
    normal! ki  
endfunction

" --------------------  
let g:scanf_types = {'int': '%d', 'float': '%f', 'double': '%lf', 'long int': '%li','long': '%l', 'long long int': '%lli', 'long long': '%ll', 'unsigned long long': '%llu', 'unsigned long': '%lu', 'unsigned long int': '%lu', 'signed char': '%c', 'unsigned char': '%c', 'char': '%c', 'unsigned int': '%u', 'unsigned': '%u', 'short': '%hd', 'short int': '%hd', 'unsigned short': '%su', 'long double': '%Lf'}
let g:type_keywords = ['unsigned', 'double', 'long', 'int', 'char', 'float', 'short', 'signed']

function! cppsnippets#Input()
    let line = getline('.')
    let vars_raw = split(trim(line)[:-2], "  *")
    let vars = [] 
    let vars_type = []
    let start = 0
    for raw in vars_raw
        if index(g:type_keywords, raw) != -1
            let start += 1
            call add(vars_type, raw)
        elseif 1
            break
        endif
    endfor
    let vars_type = join(vars_type, " ")
    if !has_key(g:scanf_types, vars_type)
        echo "There is no such type"
        return
    endif
    for raw in vars_raw[start:] 
        let curr_vars = split(raw, " *, *")
        for curr in curr_vars
            call add(vars, curr)
        endfor
    endfor
    let scanf_str = []
    let scanf_vars = []
    for curr in vars
        call add(scanf_str, g:scanf_types[vars_type])
        call add(scanf_vars, "&" .. curr)
    endfor
    let scanf_str = join(scanf_str, " ")
    let scanf_vars = join(scanf_vars, ", ")
    exe "normal! oscanf(\"" .. scanf_str .. "\", " .. scanf_vars .. ");"
    normal! ^
endfunction
