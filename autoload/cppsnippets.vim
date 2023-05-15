let g:var_type_regex = "\\(\\w\\+\\s*<.*>\\|\\(signed\\s\\+\\|unsigned\\s\\+\\)\\?\\(bool\\|char\\|int\\|double\\|float\\|unsigned\\|short\\|long\\s\\+long\\|long\\)\\|\\w\\+\\)"
let g:var_regex = "[a-zA-Z_][a-zA-Z0-9_]*"
let g:scanf_types = {'ULL': '%llu', 'int': '%d', 'float': '%f', 'double': '%lf', 'long int': '%li','long': '%l', 'long long int': '%lli', 'long long': '%ll', 'unsigned long long': '%llu', 'unsigned long': '%lu', 'unsigned long int': '%lu', 'signed char': '%c', 'unsigned char': '%c', 'char': '%c', 'unsigned int': '%u', 'unsigned': '%u', 'short': '%hd', 'short int': '%hd', 'unsigned short': '%su', 'long double': '%Lf'}
let g:type_keywords = ['unsigned', 'ULL', 'double', 'long', 'int', 'char', 'float', 'short', 'signed']
function! cppsnippets#findParams(rest)
    let rest = a:rest
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
    return vars
endfunction

function! cppsnippets#writeFuncInBuffer(func_name, params)
    let func_name = a:func_name
    let params = a:params
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
    normal! 2kviw
endfunction

function! cppsnippets#getParam(var_name)
    let var_name = a:var_name
    let line = getline('.')
    let type_search = matchstrpos(line, g:var_type_regex) 
    let var_type = type_search[0]
    let isArray = match(trim(line), $"{var_name}\\[[0-9]*\\]") != -1
    let param = $"{var_type} {var_name}" .. (isArray ? "[]" : "")
    return param
endfunction

function! cppsnippets#genFuncTests()
    let var_name = "arr"
    let initializing_regex = $"{g:var_type_regex}\\s\\+{var_name}\\s*=\\s*"
    let without_init_regex = $"{g:var_type_regex}\\s\\+{var_name}\\s*;"
    let array_regex = $"{g:var_type_regex}\\s\\+{var_name}\[[0-9a-zA-Z_]*\]"
    let constr_regex = $"{g:var_type_regex}\\s\\+{var_name}\\((.*)\\)\\?\\s*;"
    let chain_regex = $"{g:var_type_regex}\\s\\+\\({g:var_regex}\\(\\s*,\\s*\\|\\s*=.*,\\s*\\)\\)*{var_name}\\(\\(\\s*,\\s*\\|\\s*=.*,\\s*\\){g:var_regex}\\)*\\s*;"
    echomsg matchstrpos("int", g:var_type_regex)
    echomsg matchstrpos("double", g:var_type_regex)
    echomsg matchstrpos("unsigned", g:var_type_regex)
    echomsg matchstrpos("unsigned    long    long", g:var_type_regex)
    echomsg matchstrpos("vector  <int>", g:var_type_regex)
    echomsg matchstrpos("Person", g:var_type_regex)
    echomsg matchstrpos("SomeInt<int, int>", g:var_type_regex)
    echomsg "--------"
    echomsg matchstrpos("n", g:var_regex)
    echomsg matchstrpos("someVarName", g:var_regex)
    echomsg matchstrpos("arr3", g:var_regex)
    echomsg matchstrpos("this_is_a_name", g:var_regex)
    echomsg matchstrpos("r", g:var_regex)
    echomsg "--------"
    echomsg matchstrpos("int arr = 5", initializing_regex)
    echomsg matchstrpos("unsigned int arr = 5", initializing_regex)
    echomsg matchstrpos("short arr = 5", initializing_regex)
    echomsg matchstrpos("vector<int> arr = 5", initializing_regex)
    echomsg matchstrpos("int arr = 5", initializing_regex)
    echomsg "--------"
    echomsg matchstrpos("int     arr;", without_init_regex)
    echomsg matchstrpos("unsigned int      arr;", without_init_regex)
    echomsg matchstrpos("Person   arr   ;", without_init_regex)
    echomsg matchstrpos("vector<int> arr;", without_init_regex)
    echomsg matchstrpos("SomeInt<int, int> arr;", without_init_regex)
    echomsg "--------"
    echomsg matchstrpos("vector<int> arr(n)    ;", constr_regex)
    echomsg matchstrpos("Person arr(name, age);", constr_regex)
    echomsg matchstrpos("pair<int, int>    arr(n);", constr_regex)
    echomsg matchstrpos("Automaton arr(n, p, q, r);", constr_regex)
    echomsg matchstrpos("vector<int> arr();", constr_regex)
    echomsg "--------"
    echomsg matchstrpos("int arr[100];", array_regex)
    echomsg matchstrpos("unsigned int arr[10];", array_regex)
    echomsg matchstrpos("Person arr[];", array_regex)
    echomsg matchstrpos("vector<int> arr[1000000];", array_regex)
    echomsg matchstrpos("SomeInt<int, int> arr[n];", array_regex)
    echomsg matchstrpos("SomeInt<int, int> arr[length1];", array_regex)
    echomsg "--------"
    echomsg matchstrpos("int arr;", chain_regex)
    echomsg matchstrpos("int m, n, arr, q;", chain_regex)
    echomsg matchstrpos("long long m = 5, n = 10, q = 5000, arr;", chain_regex)
    echomsg matchstrpos("int arr;", chain_regex)
    echomsg matchstrpos("int m, n = 'asdasdasd', arr, q;", chain_regex)
    echomsg matchstrpos("int m, n, arr, q;", chain_regex)
endfunction

function! cppsnippets#GenFunc()
    " call cppsnippets#genFuncTests()
    let func_name = expand('<cword>')
    let [temp, rest] = split(getline('.'), func_name)
    " find params
    let vars = cppsnippets#findParams(rest)
    " find var types
    echomsg vars
    let params = []
    for var_name in vars
        normal! gg
        let initializing_regex = $"{g:var_type_regex}\\s\\+{var_name}\\s*=\\s*"
        let without_init_regex = $"{g:var_type_regex}\\s\\+{var_name}\\s*;"
        let array_regex = $"{g:var_type_regex}\\s\\+{var_name}\[[0-9a-zA-Z_]*\]"
        let constr_regex = $"{g:var_type_regex}\\s\\+{var_name}\\((.*)\\)\\?\\s*;"
    let chain_regex = $"{g:var_type_regex}\\s\\+\\({g:var_regex}\\(\\s*,\\s*\\|\\s*=.*,\\s*\\)\\)*{var_name}\\(\\s*=.*\\)\\?\\(\\(\\s*,\\s*\\|\\s*=.*,\\s*\\){g:var_regex}\\)*\\s*;"
        let temp = search(initializing_regex) 
            \ || search(without_init_regex) 
            \ || search(array_regex) 
            \ || search(constr_regex) 
            \ || search(chain_regex)
        if temp != 0
            let param = cppsnippets#getParam(var_name)
            call add(params, param)
            continue
        endif
    endfor
    " write in buffer
    call cppsnippets#writeFuncInBuffer(func_name, params)
endfunction

" --------------------  

function! cppsnippets#Fore(...)
    let objName = a:1
    let options = ""
    if len(a:000) >= 2
        let options = a:2
    endif

    let fore_snippet =<< trim eval EOF
    for(auto{(match(options, "m") != -1 ? "&" : "")} x : {objName}) {{
        {(match(options, "p") != -1 ? "std::cout << x << \" \";" : "")}
        }}
    std::cout << endl; 

    EOF
    exe "normal! o" .. join(fore_snippet, "\n")
    normal! V4k=
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
    let for_cycle = $"for(int {var_name} = {start}; {var_name} " .. (options == 'r' ? ">= " : "< ") .. $"{end}; "

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
    exe "normal! ousing ULL = unsigned long long;"
    normal! o
    exe "normal! a\n"
    exe "normal! iint main() {\n\n}"
    normal! ki  
endfunction

" --------------------  

function! cppsnippets#Input()
    let line = getline('.')
    let vars_raw = split(trim(line)[:-2], "\\s\\+")
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
    let vars_raw = join(vars_raw[start:], " ")
    let vars = split(vars_raw, "\\(\\s*=\\s*[a-zA-Z_0-9]\\+\\)\\?\\s*,\\s*")
    let vars[len(vars) - 1] = trim(split(vars[len(vars) - 1], "=")[0])
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

function! cppsnippets#VisualInput(line1, line2)
    let index_to_input = a:line1
    for idx in range(a:line1, a:line2)
        exe "normal! " .. index_to_input .."gg"
        exe "Input"
        let index_to_input += 2
    endfor
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
    let binary_snippet =<< trim eval EOF
{var_type} {var1} = {left};
{var_type} {var2} = {right};
while({var1} <= {var2}) {{
    {var_type} mid = {var1} + ({var2} - {var1}) / 2;
    if({func_name}(mid)) {{
        
    }}
    else {{

    }}
}}

EOF

    exe "normal! o" .. join(binary_snippet, "\n")
    " format all snippet lines
    normal! V11k=
    " move the cursor to the function name
    normal! 4jfO

endfunction

" -------------------
function! cppsnippets#bfsSnippet(graph, start, isVisited)
    let graph = a:graph
    let start = a:start
    let isVisited = a:isVisited
    let bfs_snippet =<< trim eval EOF
    vector<bool> {isVisited}({graph}.size(), false);
{isVisited}[{start}] = true;

queue<int> q;
q.push({start});

while(!q.empty()) {{
    int curr = q.front();
    q.pop();

    for(int adj:graph[curr]) {{
        if(!{isVisited}[adj]) {{
            {isVisited}[adj] = true;
            q.push(adj);
        }}
    }}
}}

EOF
return join(bfs_snippet, "\n")
endfunction

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
    let snippet = cppsnippets#bfsSnippet(graph, start, isVisited)
    exe "normal! o" .. snippet
    normal! V17k=
endfunction

function! cppsnippets#dijkstra(...)
    if len(a:000) != 2
        echomsg "Invalid arguments"
        return
    endif
    let graph = a:000[0]
    let start = a:000[1]
    normal! ma
    for lib in ['queue', 'vector']
        if !search("#include *<" .. lib .. ">")
            normal! gg
            exe "normal! o#include <" .. lib .. ">"
        endif
    endfor
    normal! `a

    let dijkstra_snippet =<< trim eval EOF
        vector<int> dists = vector<int>({graph}.size(), INT16_MAX);
        dists[0] = 0;
        priority_queue<pair<int, int>, vector<pair<int, int>>, greater<pair<int, int>>> q;
        q.push({{0, 0}});
        while(!q.empty()) {{
           int curr = q.top().second;
           int dist = q.top().first;
           q.pop();
           for(auto edge:{graph}[curr]) {{
                int weight = edge.second;
                int adj = edge.first;
                if(dist + weight < dists[adj]) {{
                    dists[adj] = dist + weight;
                    q.push({{dist + weight, adj}});
                }}
           }}
        }}

EOF

exe "normal! o" .. join(dijkstra_snippet, "\n")
normal! V17k=

endfunction

function! cppsnippets#unionFind(...)
    normal! mb
    let name = 'components'
    if len(a:000) == 1
        let name = a:000[0]
    endif
    normal! ma
    for lib in ['vector']
        if !search("#include *<" .. lib .. ">")
            normal! gg
            exe "normal! o#include <" .. lib .. ">"
        endif
    endfor
    normal! `a
    let unionfind_snippet =<< trim eval EOF
    int getLeader(vector<int>& {name}, int a) {{
        if({name}[a] == a) return a;
        return getLeader({name}, {name}[a]);
    }}

    bool areInSameComponent(vector<int>& {name}, int a, int b) {{
        return getLeader({name}, a) == getLeader({name}, b);
    }}
    void unite(vector<int>& {name}, int a, int b) {{
        int la = getLeader({name}, a);
        int lb = b;
        while(lb != {name}[lb]) {{
            {name}[lb] = la;
            lb = {name}[lb];
        }}
        {name}[lb] = la;
    }}

EOF

call search("int main")
normal! O
exe "normal! i" .. join(unionfind_snippet, "\n")
normal! V16k=
normal! `b

endfunction
