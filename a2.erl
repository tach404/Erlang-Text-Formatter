-module(a2).
-author("ta288").
-export([punct/1,wsp/1,get_word/1,drop_word/1,drop_wsp/1,words/1,get_line/2,drop_line/2,lines/1,check/1]).
-export([text/0,show_line/1,print_line/1,show_doc/1,print_doc/1,test/0]).
-export([replicate/2,show_line_right/1,print_line_right/1,show_doc_right/1,print_doc_right/1,test_right/0]).

%% Is a character punctuation?
-spec punct(integer()) -> boolean().
punct(Ch) -> lists:member(Ch,"\'\"\.\,\ \;\:\!\?\`\(\)").

%% Is a character whitespace?
-spec wsp(integer()) -> boolean().
wsp(Ch) -> lists:member(Ch,"\ \t\n").

-spec get_word(string()) -> string().
get_word([]) -> []; % Return empty list
get_word([S|St]) -> % Put string into a list, with a head and tail
	case wsp(S) of % If head has whitespace
		true -> []; % Return an empty array
		false -> [S | get_word(St)] % Put the head in the list
		% Call the function again with tail as new head.
	end.

-spec drop_word(string()) -> string().
drop_word([]) -> [];
drop_word([S|St]) ->
	case wsp(S) of %If head is whitespace
		true -> [S|St]; %Return the whitespace, as well as the tail
		false -> drop_word(St) %If it isn't, iterate through.
	end.

-spec drop_wsp(string()) -> string().
drop_wsp([]) -> [];
drop_wsp([S|St]) ->
	case wsp(S) of %If head has whitespace
		true -> St; %Just return the tail
		false -> drop_wsp(St) %If not, iterate through
	end.

-spec words(string()) -> list(string()).
words([]) -> [];
words([S|St]) ->
	case wsp(S) of
		true ->  words(drop_wsp([S|St])); %If there is whitespace
		%call words with the same parameter, but drop the whitespace.
		%therefore resulting in false case next time round.
		false -> [get_word([S|St]) | words(drop_word([S|St]))] %If there is whitespace
		%call get_word to print it in the list, then call words with the same parameter,
		%but drop the word you just printed.
	end.

-define(LINELEN,40).
-spec get_line(list(string()),integer()) -> list(string()).
get_line([],_) -> []; % If list empty return an empty string.
get_line([S|St],N) -> 
	L = length(S)+1, case N-L < 0 of %Get the length of string plus spacing(+1)
	%if N-L is greater than 0
		true -> []; %Return empty list
		false -> [S | get_line(St,N-L)] %Add s to list, take away length from N.
	end.
	% N acts as a count for the line length. Takeaway the length of the word
	% and iterate through.

%% Partner function of get_line: drops a line word of words.
-spec drop_line(list(string()),integer()) -> list(string()).
drop_line([],_) -> [];
drop_line([S|St],N) -> 
	L = length(S)+1, case N-L < 0 of
		true -> [S | drop_line(St,N-L)];
		false -> drop_line(St,N-L)
	end.

%% Repeatedly apply get_line and drop_line to turn
%% a list of words into a list of lines i.e. 
%% a list of list of words.
-spec lines(list(string())) -> list(list(string())).
lines([]) -> [];
lines([S|St]) -> [get_line([S|St],?LINELEN) | lines(drop_line([S|St], ?LINELEN))].

%% Checking that all words no longer than ?LINELEN.
-spec check(list(string())) -> boolean().
check([]) -> true;
check([S|St]) -> 
	L = length(S)+1, case L < ?LINELEN of
		true -> check(St);
		false -> false
	end.

%% Showing and printing lines and documents. 

%% Join words, interspersed with spaces, and newline at the end.
-spec show_line(list(string())) -> string().
show_line([W]) -> W ++ "\n";
show_line([W|Ws]) -> W ++ " " ++ show_line(Ws).

%% As for show_line, but padded with spaces at the start to make
%% the length of the line equal to ?LISTLEN.
%% May use the replicate function.
-define(LISTLEN, 40). %Not sure if you wanted us to make a new LISTLEN or
%If it was just a typo, however i just created a new one.
-spec show_line_right(list(string())) -> string().
show_line_right([]) -> [];
show_line_right([S|St]) -> 
	L = ?LISTLEN - length(show_line([S|St])),
	show_line([replicate(L," ") | [S|St]]).

%% Build a list out of replicated copies of an item.
%% e.g. replicate(5,3) = [3,3,3,3,3].
-spec replicate(integer(),T) -> list(T).
replicate(0,_) -> []; %If 0, print an empty list. Stopping the duplication
replicate(N,X) -> [X | replicate(N-1, X)].%Put X in the list, call the method again, with -1.
%When Keep calling the method until N is 0.

%% Print out a line, i.e. resolve the layout.11
-spec print_line(list(string())) -> ok.
print_line(X) -> io:format(show_line(X)).

%% As for print-line, but right-aligned.
-spec print_line_right(list(string())) -> ok.
print_line_right(X) -> io:format(show_line_right(X)).

%% Show a whole doc, i.e. list of lines.
-spec show_doc(list(list(string()))) -> string().
show_doc(Ls) ->
    lists:concat(lists:map(fun show_line/1, Ls)).

%% Show a whole doc, i.e. list of lines, right aligned.
-spec show_doc_right(list(list(string()))) -> string().
show_doc_right(Ls) -> 
		lists:concat(lists:map(fun show_line_right/1, Ls)).


%% Print a doc.
-spec print_doc(list(list(string()))) -> ok.
print_doc(X) -> io:format(show_doc(X)).

%% Print a doc, right-aligned.
-spec print_doc_right(list(list(string()))) -> ok.
print_doc_right(X) -> io:format(show_doc_right(X)).

%% Test cases

text() -> "When riding at night, make sure your headlight beam is aiming slightly " ++
          "downwards so oncoming traffic can " ++
          "see you without being dazzled. Be sure not to dip it too much, " ++
          "though, as youll still want to see the road around 20 metres ahead of you if riding at speed.".

test() -> print_doc(lines(words(text()))).
test_right() -> print_doc_right(lines(words(text()))).

%% Expected outputs

%% 1> a2:test().
%% When riding at night, make sure your
%% headlight beam is aiming slightly
%% downwards so oncoming traffic can see
%% you without being dazzled. Be sure not
%% to dip it too much, though, as youâ€™ll
%% still want to see the road around 20
%% metres ahead of you if riding at speed.
%% ok

%% 2> a2:test_right().
%%     When riding at night, make sure your
%%        headlight beam is aiming slightly
%%    downwards so oncoming traffic can see
%%   you without being dazzled. Be sure not
%%    to dip it too much, though, as youâ€™ll
%%     still want to see the road around 20
%%  metres ahead of you if riding at speed.
%% ok