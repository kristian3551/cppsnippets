# cppsnippets
A simple Vim plugin for common C++ tasks

## Supported functions
1. :GenFunc
When function declaration `foo(var1, var2, ..., varn)`, but `foo` is not defined in the file,  then calling :GenFunc when cursor is on `foo` (the name of the function), a function `foo` is defined in the file with right types of parameters:
```
int main() {
int var1 = 5;
pair<int, int> var2 = {2, 3};
vector<int> var3;

foo(var1, var2, var3);
}
```
---------------->
```
void foo(int var1, pair<int, int> var2, vector<int> var3) {

}

int main() {
int var1 = 5;
pair<int, int> var2 = {2, 3};
vector<int> var3;

foo(var1, var2, var3);
}
```
*default key binding for GenFunc is `g!`, but it can be changed through a variable called `g:gen_func_mapping`*
2. :Input   
When variables are defined on a single row like for example `unsigned int m = 10, n = 5, p, q = 15;` then *:Input* command inserts `scanf` statement with all variables on the row:
```
unsigned long long m = 10, n = 5, p, q = 15;
```
--------------->
```
unsigned long long m = 10, n = 5, p, q = 15;
scanf("%llu %llu %llu %llu %llu", %m, %n, %p, %q);
```
*You can select many rows in visual mode and use the same command to insert individual `scanf` statements for each of the selected rows. Default key binding is `gI`, but it can be changed through a variable called `g:input_mapping`. YOU CAN'T USE THIS COMMAND IN SITUATIONS LIKE `int p; unsigned q;`. YOU CAN USE IT ONLY WHEN VARIABLES OF SAME TYPE ARE DEFINED!!!*
3. :Init [library names]   
Initialize file with template libraries and a `main` function. 
`:Init {lib1} {lib2} ... {libn}`
--------------->
```
#include <iostream>
#include <vector>
#include <algorithm>
#include <{lib1}>
...
#include <{libn}>
using namespace std;

int main() {

}
```
3. :Fore {collectionName} {varName: default is 'x'}? {options: 'p?m?'}?
- p: stands for 'print' - adds print statement
- m: stands for 'modify' - adds & symbol next to variable name
`:Fore arr obj pm`
--------------->
```
for(auto& obj : arr) {
    cout << obj << " ";
}
std::cout << endl;
```
4. :Import {lib1} ... {libn}   
Includes lib1 ... libn in file
5. :Binary {lowerBound} {upperBound} {leftVarName: default is 'left'} {rightVarName: default is 'right'}? {functionName: default is OK}
Inserts *binary search* snippet where the cursor is positioned.
6. :For {lowerBound} {upperBound} {options: 'r' or 'f'}? {step: default is 1}   
If there are no arguments passed, a simple
```
for(initialization; condition; step) {

}
```
is inserted.
If 'r' is passed as an option, the for loop iterates backwards.
7. :Bfs | :Dijkstra | :UnionFind {graphName} {startVertex}   
Inserts a snippet for the algorithm. :UnionFind is a snippet for all of the functions needed for the UnionFind data structure.
