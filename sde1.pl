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

table(book_result, [
[["A"], ["A"], ["B", "C"], ["B", "C"]],
[["C"], ["S", "A"], ["S", "B", "A"]],
[["C", "A"], ["C", "S", "A"]],
[["C", "B", "S", "A"]]
], ["test","b"]).

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

/*
decompositions/2
Prototype: decompositions(+N,-List_of_decomposition_sublists)
N is string length. This predicate is used for
forming list of decomposition sublists of form [j,k]
where [j,k] means a list of length j followed by a list of length k
i.e., the ’j+k’ decomposition in the CYK table formation.
Note: This is not cell j,k in the table
*/
decompositions(Length,List) :-
	EmptyList = [],
	decompositionsHelper(Length,Length,EmptyList,List).

% Helpers to make sure we can keep track of all the variables needed
% Our base case is when the left element of the decomposition is 1
decompositionsHelper(_, 1, NewList, OrigList) :-
	OrigList = NewList.

% Every other case is handled here
decompositionsHelper(Length,CurrentLength,DecompList,OrigList) :-
	% ensure we don't accidentally hit the base case
	CurrentLength > 1,

	% Determine the new decomposition element
	LeftNum is CurrentLength-1,
	RightNum is Length - LeftNum,
	Decompostion = [LeftNum,RightNum],

	% insert the new element into our list
	nth1(RightNum,NewDecompList,Decompostion,DecompList),
	% recursively call the function and add more decomposition until we hit the base case
	decompositionsHelper(Length,LeftNum,NewDecompList,OrigList).

/* 
first, product of one nonterminal (not a list)
and another cell (list) contents 
Prototype: one_product(+Nonterminal,+Cell,-Product)
*/
one_product(Nonterminal, CellList, Product) :-
	EmptyList = [],
	one_product_helper(Nonterminal, CellList, EmptyList, Product).

one_product_helper(_, [], NewProduct, OrigProduct) :-
	OrigProduct = NewProduct.

one_product_helper([], _, _, OrigProduct) :-
	OrigProduct = [].

one_product_helper(Nonterminal, CellList, NewProduct, OrigProduct) :-
	% separate the head from tail of Celllist
	nth1(1,CellList,SelectedElement,NewCellList),
	%combine the two items into one string like "AB" 
	string_concat(Nonterminal,SelectedElement,ElementProduct),
	%turn the string into a list list ["AB"] and insert it
	append(NewProduct, [ElementProduct], PassProduct),
	% recursively call this function until the celllist is empty
	one_product_helper(Nonterminal, NewCellList, PassProduct, OrigProduct).

/*
Used to produce the outer product of two lists
Prototype: cell_products(+Cell1,+Cell2,-Product)
 Either cell could be empty.
*/
cell_products(CellList1,CellList2,Product) :-
	EmptyList = [],
	cell_products_helper(CellList1,CellList2,EmptyList,Product).

% Base case where the first list is empty, meaning we are done with recursion
cell_products_helper([], _, NewProduct, OrigProduct) :-
	OrigProduct = NewProduct.

% If the user enters an empty second list set the output to an EmptyList
cell_products_helper(_, [], _, OrigProduct) :-
	OrigProduct = [].

cell_products_helper(CellList1,CellList2,NewProduct,OrigProduct) :-
	% separate the head form the tail of CellList1
	nth1(1,CellList1,SelectedElement,NewCellList1),
	% get the inner product of CellList1's head and CellList2
	one_product(SelectedElement,CellList2,InnerProduct),
	append(NewProduct,InnerProduct,PassProduct),
	cell_products_helper(NewCellList1,CellList2,PassProduct,OrigProduct).

/*
We treat forming 1st row as special case --
this corresponds to only one input string element per cell
so there are no RHS nonterminals in productions to consider.
This is defacto scanning.
Prototype: form_row1_cell(+StringElement,+ProductionsList,-Row1Cell)
*/
form_row1_cell(StringElement,ProductionsList,OrigRow1) :-
	EmptyList = [],
	form_row1_cell_helper(StringElement,ProductionsList,EmptyList,OrigRow1).

% base case where we are at the end of the production list, so set the list and exit
form_row1_cell_helper(_,[],NewRow1,OrigRow1) :-
	OrigRow1 = NewRow1.

form_row1_cell_helper(StringElement,[FirstProd|RemainProds],NewRow1,OrigRow1) :-
	% get the first element from the production you're examining
	nth1(1,FirstProd,NonTerminal),
	% get the second element to see if it matches string element
	nth1(2,FirstProd,PossiblyTerminal),
	% we determines whether our search element and current element are the same
	subtract([PossiblyTerminal],[StringElement],TestProd),
	% find out if it is a derivation, eg if the list is empty Nonterminal is a derivation 
	is_derivation(TestProd,[NonTerminal],IsDerivation),
	% append whatever the result ends up being
	append(NewRow1,IsDerivation,PassRow1),
	% recursively call this function until the production list is empty
	form_row1_cell_helper(StringElement,RemainProds,PassRow1,OrigRow1).

% is_derivation determines whether the NonTerminal being examined results
% in the element we are searching for.

% case where the difference is the empty set, meaning the NonTerminal 
% results in the element we are searching for so pass it back.
is_derivation([],NonTerminal,NonTerminal).
% case where the difference is not the empty set, meaning the NonTerminal
% does not result in our element so pass back an empty set.
is_derivation(_,_,[]).




