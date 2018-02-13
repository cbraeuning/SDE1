%% Collin Braeuning - cbraeun
%% SDE1	- CYK Parse Tables

/* 
named production *set* as arity-2 predicate: productions/2
Prototype: productions(+Name,-Data). 
*/
productions(book, [["S","AB"],["S","BB"],["A","CC"],["A","AB"],["A","a"],
["B","BB"],["B","CA"],["B","b"],["C","BA"],["C","AA"],["C","b"]]).

/* 
string to parse: astring/2
Prototype: astring(+Name, -Data)
*/
astring(bookstring,["a", "a", "b", "b"]).

/*
table/2
Prototype: table(+Name,-Data)
*/
table(sample_table4,[
[["11"],["21"],["31"],["41"]],
[["12"],["22"],["32"]],
[["13"],["23"]],
[["14"]]
]).

table(book_result, [
[["A"], ["A"], ["B", "C"], ["B", "C"]],
[["C"], ["S", "A"], ["S", "B", "A"]],
[["C", "A"], ["C", "S", "A"]],
[["C", "B", "S", "A"]]
]).

/*
get_table_values_cell/3
Prototype: get_table_values_cell([+Col,+Row],+Table,-ContentsL)
list of [i,j] used as first argument
for table indices i: element, j: length (both >=1)
*/
get_table_values_cell([Col,Row],Table,ContentsL) :-
	% ensure that indices are valid
	Col >= 1,
	Row >= 1,
	nth1(Row,Table,TempRow),
	nth1(Col,TempRow,ContentsL).
