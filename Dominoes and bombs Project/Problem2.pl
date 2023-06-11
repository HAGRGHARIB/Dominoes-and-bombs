searchInformed(InitialState,Row,Column):-
    append([[InitialState,null,0,x,0]],[],Open),
    calculateH(InitialState,InitialState,0,0,MaxDominos,Row,Column),
    search(Open,[],[],Result,MaxDominos,Row,Column),
    (Result \= [];MaxDominos = 0),
    !,
    write("Search is complete!"),
    nl,
    write("Max Dominos : "),
    write(MaxDominos),
    nl,
    write("------------------------"),
    nl,
    printSolution(Result,Column).
%---------------------------------------
search(Open,_,Result,Result,_,_,_):-
    Open = [],
    !.

search(Open, Closed,Result,List,MaxDominos,Row,Column):-
    getBestState(Open, CurrentNode, TmpOpen),
    CurrentNode = [_,_,_,H,F],
    (F = MaxDominos,H = 0),
    !,
    append([CurrentNode],Result,NewResult),
    append(Closed, [CurrentNode], NewClosed),
search(TmpOpen, NewClosed,NewResult,List,MaxDominos,Row,Column).
%DFS
search(Open, Closed,Result,List,MaxDominos,Row,Column):-
    getBestState(Open, CurrentNode, TmpOpen),
    CurrentNode = [_,_,_,H,F],
    ((F = 0,H = x);(F = MaxDominos)),
    !,
    getAllValidChildren(CurrentNode,TmpOpen,Closed,Children,Row,Column),
    addChildren(Children, TmpOpen, NewOpen),
    append(Closed, [CurrentNode], NewClosed),
    search(NewOpen,NewClosed,Result,List,MaxDominos,Row,Column).

search(Open, Closed,Result,List,MaxDominos,Row,Column):-
    getBestState(Open, CurrentNode, TmpOpen),
    append(Closed, [CurrentNode], NewClosed),
    search(TmpOpen,NewClosed,Result,List,MaxDominos,Row,Column).
%---------------------------------------
findMaxF([X], X):- !.

findMaxF([Head|T], Max):-
    findMaxF(T, TmpMax),
    Head = [_,_,_,_,HeadF],
    TmpMax = [_,_,_,_,TmpF],
    (TmpF > HeadF -> Max = TmpMax ; Max = Head).
%---------------------------------------
getBestState(Open, BestChild, Rest):-
    findMaxF(Open, BestChild),
    delete(Open, BestChild, Rest).
%----------------------------------------
getNextState([State,_,G,_,_],Open,Closed,[Next,State,NewG,NewH,NewF],Row,Column):-
    fill(State, Next, FillCost,Row,Column),
    calculateH(Next,Next,0,0,NewH,Row,Column),
    NewG is G + FillCost,
    NewF is NewG + NewH,
    ( not(member([Next,_,_,_,_], Open)) ;
   memberButBetter(Next,Open,NewF) ),
    ( not(member([Next,_,_,_,_],Closed));
   memberButBetter(Next,Closed,NewF)).
%----------------------------------------
memberButBetter(Next, List, NewF):-
    findall(F, member([Next,_,_,_,F], List), Numbers),
    max_list(Numbers, MaxOldF),
    MaxOldF < NewF.
%---------------------------------------
addChildren(Children, Open, NewOpen):-
    append(Open, Children, NewOpen).
%----------------------------------------
getState([CurrentNode|Rest], CurrentNode, Rest).
%----------------------------------------
getAllValidChildren(Node, Open, Closed, Children,Row,Column):-
    findall(Next,getNextState(Node,Open,Closed,Next,Row,Column),
Children).
%----------------------------------------
printSolution([],_).

printSolution([[State,_,_,_,_]|T],Column):-
     printBoard(State,Column),
     nl,
     printSolution(T,Column).
%------------------------------------
calculateH(_,[],_,Hvalue,NewHvalue,_,_):-
    NewHvalue is Hvalue//2,
    !.

calculateH(State,[_|T],Index,Hvalue,Num,Row,Column):-
    nth0(Index, State, FirstElement),
    FirstElement \= #,
    !,
    NewIndex is Index +1,
    calculateH(State,T,NewIndex, Hvalue,Num,Row,Column).

calculateH(State,[_|T],Index, Hvalue,Num,Row,Column):-
    NewIndex is Index +1,
    nth0(Index, State, FirstElement),
    FirstElement = #,
    ((
    NewNum is Column-1,
    not(NewNum is Index mod Column),
    NIndex is Index + 1
    );(
    Index < Row*Column-Column,
    NIndex is Index + Column
    );(
     Index > Column-1,
     NIndex is Index - Column
    );(
     not(0 is Index mod Column),
     NIndex is Index - 1
    )),
    nth0(NIndex, State, SecondElement),
    SecondElement = #,
    NewHvalue is Hvalue+1,
    calculateH(State,T,NewIndex,NewHvalue,Num,Row,Column).

calculateH(State,[_|T],Index, Hvalue,Num,Row,Column):-
     NewIndex is Index +1,
     calculateH(State,T,NewIndex,Hvalue,Num,Row,Column).
%------------------------------------

fill(State, Next,1,Row,Column):-
    fillHorizontally(State, Next,Column);
    fillVertically(State, Next,Row,Column).

fillHorizontally(State, Next,Column):-
    nth0(EmptyTileIndex, State, #),
    NewNum is Column-1,
    not(NewNum is EmptyTileIndex mod Column),
    NewIndex is EmptyTileIndex + 1,
    nth0(NewIndex, State, SecondElement),
    SecondElement = #,
    Element is EmptyTileIndex+1,
    substitute(Element,EmptyTileIndex,0,State, TmpList1),
    substitute(Element,NewIndex,0, TmpList1,Next).

fillVertically(State, Next,Row,Column):-
    nth0(EmptyTileIndex, State, #),
    EmptyTileIndex < Row*Column-Column,
    NewIndex is EmptyTileIndex + Column,
    nth0(NewIndex, State, SecondElement),
    SecondElement = #,
    Element is EmptyTileIndex +1,
    substitute(Element,EmptyTileIndex,0,State, TmpList1),
    substitute(Element,NewIndex,0, TmpList1,Next).
%---------------------------------------------------------
substitute(Element,Count,Count, [_|T],[Element|T]):- !.

substitute(Element,Index,Count, [H|T],[H|NewT]):-
    NewCount is Count +1,
    substitute(Element,Index,NewCount,T,NewT).
%----------------------------------------------------------
printBoard([],_):-
    write("-------------------------"),!.
printBoard([H|T],Column):-
    length(T, N),
    write(H),
    (0 is N mod Column -> nl ;(H = bom -> write('    ');write('           '))),
    printBoard(T,Column).
