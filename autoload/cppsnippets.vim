let g:scanf_types = {'int': '%d', 'float': '%f', 'double': '%lf', 'long int': '%li','long': '%l', 'long long int': '%lli', 'long long': '%ll', 'unsigned long long': '%llu', 'unsigned long': '%lu', 'unsigned long int': '%lu', 'signed char': '%c', 'unsigned char': '%c', 'char': '%c', 'unsigned int': '%u', 'unsigned': '%u', 'short': '%hd', 'short int': '%hd', 'unsigned short': '%su', 'long double': '%Lf'}
let g:type_keywords = ['unsigned', 'double', 'long', 'int', 'char', 'float', 'short', 'signed']

function! cppsnippets#GenFunc()
    let func_name = expand('<cword>')
    let [temp, rest] = split(getline('.'), func_name)
    " find params
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
    let params_raw = rest[1:end - 1]
    let vars_raw = []
    let curr = []
    let balance = 0
    for chr in params_raw
        if chr == '('
            let balance += 1
            call add(curr, chr)
        elseif chr == ')'
            let balance -= 1
            call add(curr, chr)
        elseif chr == ',' && balance == 0
            call add(vars_raw, trim(join(curr, "")))
            let curr = []
        else
            call add(curr, chr)
        endif
    endfor
    call add(vars_raw, trim(join(curr, "")))
    let vars = []
    for var_name in vars_raw
        let tokens = split(var_name, "(")
        if len(tokens) > 0
            let var_name = tokens[0]
            call add(vars, var_name) 
        endif
    endfor
    " find var types
    let params = []
    for var_name in vars
        let var_type_regex = "[a-zA-Z<>_][a-zA-Z<> _]*"
        let var_regex = "[a-zA-Z_][a-zA-Z_]*"
        normal! gg
        echomsg var_name
        let temp = search($"{var_type_regex} *{var_name} *= *") || search($"{var_type_regex} {var_name} *;") || search($"{var_type_regex} {var_name}\[[0-9]*\]") || search($"{var_type_regex} {var_name}\(.*\) *;")
        if temp != 0
            let tokens = split(trim(getline('.')), " ")    
            echomsg tokens
            let var_type = []
            for token in tokens
                let idx = match(token, $"{var_name}")
                if token != '' && idx == -1
                    call add(var_type, token)
                elseif token != '' 
                    break
                endif
            endfor
            let isArray = match(getline('.'), $"{var_name}\[[0-9]*\]") != -1
            let var_type = join(var_type, " ")
            let param = $"{var_type} {var_name}" .. (isArray ? "[]" : "")
            echomsg param
            call add(params, param)
            continue
        endif
        " let temp = search($"{var_type_regex} \({var_regex}\( = .*, \|, \)\)*{var_name}\(, {var_regex}\)*;")
    endfor
    " write in buffer
    call search("int main")
    normal! O
    normal! O
    exe "normal! o\nvoid " .. func_name .. "("

    for param in params
        exe "normal! a" .. param .. ", "
    endfor 
    if len(params) > 0
        exe "normal! xxa) {\n\n}"
    else
        exe "normal! a) {\n\n}"
    endif
    normal! 2k
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
    if len(a:000) == 0
        exe "normal! ofor(declaration; condition; step) {\n\n}" 
        normal! 2kfdviw
        return
    endif

    if len(a:000) == 1 || len(a:000) > 5
        echo "Invalid arguments"
        return
    endif

    let start = a:000[0]
    let end = a:000[1]
    let options = ''
    let var_name = 'i'
    let step = 1

    if len(a:000) >= 3
        let options = a:000[2]
        if options == "r"
            let step = -1
        endif
    endif

    if len(a:000) >= 4
        if matchstr(a:000[3], "[^-0-9]")
            echo "Error! Invalid step!"
            return
        endif
        let step = str2nr(a:000[3])
    endif
    if len(a:000) >= 5
        let var_name = a:000[4]
    endif

    let for_cycle = ''
    let for_cycle = "for(int " .. var_name .. " = " .. start .. "; " .. var_name .. " " .. (options == 'r' ? ">= " : "< ") ..  end .. "; "

    if step == 1
        let for_cycle = for_cycle .. var_name .. "++"
    elseif step == -1
        let for_cycle = for_cycle .. var_name .. "--"
    elseif step < 0
        let for_cycle = for_cycle .. var_name .. "-=" .. -step
    else
        let for_cycle = for_cycle .. var_name .. "+=" .. step
    endif

    let for_cycle = for_cycle .. ") {\n\n}"
    exe "normal! o" .. for_cycle
    normal! 2k3w
endfunction

" --------------------  

function! cppsnippets#Import(...)
    normal! ma
    for lib in a:000
        exe "normal! ggo#include <" .. lib .. ">"
    endfor
    normal! `aj
endfunction

function! cppsnippets#Init(...)
    let libraries = copy(a:000)
    call extend(libraries, ["iostream", "vector", "algorithm"])
    call uniq(sort(libraries))

    normal! ggVGd

    for lib in libraries
        normal! G
        exe "normal! i#include <" .. lib .. ">"
        normal! o 
    endfor

    let std_str = 'using namespace std;'
    exe "normal! i" .. std_str
    normal! o
    exe "normal! a\n"
    exe "normal! iint main() {\n\n}"
    normal! ki  
endfunction

" --------------------  

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

" -------------------

function! cppsnippets#Binary(...)
    if len(a:000) < 2 || len(a:000) > 5
        echo "Error! Invalid arguments"
        return
    endif
    let left = a:000[0]
    let right = a:000[1]
    if str2nr(left) > str2nr(right)
        echo "Error! Invalid range!"
        return
    endif
    let var1 = 'left'
    let var2 = 'right'
    let func_name = 'OK'
    if len(a:000) >= 3
        let var1 = a:000[2]
    endif
    if len(a:000) >= 4
        let var2 = a:000[3]
    endif
    if len(a:000) >= 5
        let func_name = a:000[4]
    endif
    let var_type = ''
    let right_value = str2nr(right)
    if right_value >= -2147483648 && right_value <= 2147483647
        let var_type = 'int'
    elseif right_value >= 0 && right_value <= 2147483647 * 2
        let var_type = 'unsigned'
    else
        let var_type = 'long long'
    endif
    let binary = $"{var_type} {var1} = {left};\n{var_type} {var2} = {right};\n\nwhile({var1} <= {var2}) \{\n{var_type} mid \= {var1} \+ ({var2} \- {var1}) \/ 2;\n\nif({func_name}(mid)) \{\n\n\}\nelse \{\n\n\}\n\}\n" 
    exe "normal! o" .. binary
    normal! 7kfu
endfunction

" -------------------

function! cppsnippets#bfs(...)
    if len(a:000) < 2
        echo "Error! Invalid arguments!"
        return
    endif
    let graph = a:000[0]
    let start = a:000[1]
    let isVisited = 'isVisited'
    if len(a:000) >= 3
        let isVisited = a:000[2]
    endif
    normal! ma
    for lib in ['queue', 'vector']
        if !search("#include *<" .. lib .. ">")
            normal! gg
            exe "normal! o#include <" .. lib .. ">"
        endif
    endfor
    normal! `a
    let bfs = $"vector<bool> {isVisited}(graph.size(), false);\n{isVisited}[{start}] = true;\nqueue<int> q;\nq.push({start});\nwhile(!q.empty()) \{\nint curr = q.front();\nq.pop();\n\nfor(int adj:graph[curr]) \{\nif(!{isVisited}[adj]) \{\n{isVisited}[adj] = true;\nq.push(adj);\n\}\n\}\n\}\n"
    exe "normal! o" .. bfs
endfunction
