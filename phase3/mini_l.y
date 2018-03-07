/* mini_l syntax parser
   Written by Ryan Gray and Salman Azmi
   CS152 WINTER 18 */
%{
 #include <stdio.h>
 #include <stdlib.h>
 #include <unordered_map>
 #include <stack>
 #include <vector>
 #include <string>
 #include <iostream>
 #include <sstream>
 #include <fstream>
 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 FILE * yyin;

 unordered_map<string, string> symbolTable; //key, value e.g. __label__0, myProgramLabel
%}

%union{
  double dval;
  char* cval;
  struct {
  	? code;
  	? place;
  	? type;
} terminalParams;

%error-verbose
%start program
%token SUB ADD MULT DIV MOD GT LT GTE LTE EQ NEQ L_PAREN R_PAREN ASSIGN COLON SEMICOLON NOT AND OR 
%token L_SQUARE_BRACKET R_SQUARE_BRACKET COMMA BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY FUNCTION
%token INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE RETURN
%token <dval> NUMBER
%token <cval> IDENT

%left BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY FUNCTION 
%left INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE RETURN
%left MOD GT LT GTE LTE EQ NEQ
%left NOT AND OR TRUE FALSE
%left SUB ADD
%left MULT DIV
%left L_PAREN R_PAREN
%left L_SQUARE_BRACKET R_SQUARE_BRACKET
%left ASSIGN COMMA COLON SEMICOLON

%type <terminalParams> program functionset functionname function declarationset statementset declaration
%type <terminalParams> identifierset statement varstatement ifstatement ifstatementelse whilestatement
%type <terminalParams> dostatement foreachstatement readstatement writestatement continuestatement returnstatement
%type <terminalParams> varset bool-expr relation-and-exprset relation-and-expr relation-exprset
%type <terminalParams> relation-expr comp expression multiplicative-exprset addorsub multiplicative-expr
%type <terminalParams> termset multordivormod term termoption1 termoption2 expressionset var

%% 
program:	
	functionset {};
functionset:
	functionname function functionset {} 
	| {};
functionname: //not sure if having a non-terminal named function and a terminal name FUNCTION causes an issue.
	FUNCTION ident SEMICOLON { printf("func "); };
function:
	BEGIN_PARAMS declarationset END_PARAMS BEGIN_LOCALS declarationset END_LOCALS BEGIN_BODY statementset END_BODY { printf("endfunc\n"); };
//ident:
//	IDENT {printf("%s", $1);};
declarationset:
	declaration SEMICOLON declarationset {} 
	| {};
statementset:
	statement SEMICOLON statementset {} 
	| statement SEMICOLON {};
declaration:
	identifierset COLON INTEGER {} 
	| identifierset COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {};
identifierset:
	IDENT COMMA identifierset {} 
	| IDENT {};
statement:
	varstatement {}
	| ifstatement {}
	| whilestatement {}
	| dostatement {}
	| foreachstatement {}
	| readstatement {}
	| writestatement {}
	| continuestatement {}
	| returnstatement{};
varstatement:
	var ASSIGN expression {};
ifstatement:
	IF bool-expr THEN statementset ifstatementelse {};
ifstatementelse:
	ELSE statementset ENDIF {} 	
	| ENDIF {};
whilestatement:
	WHILE bool-expr BEGINLOOP statementset ENDLOOP {};
dostatement:
	DO BEGINLOOP statementset ENDLOOP WHILE bool-expr {};
foreachstatement:
	FOREACH IDENT IN IDENT BEGINLOOP statementset ENDLOOP {};
readstatement:
	READ varset {};
writestatement:
	WRITE varset {};
continuestatement:
	CONTINUE {};
returnstatement:
	RETURN expression {};
varset:
	var COMMA varset {} 
	| var {};
bool-expr:
	relation-and-expr relation-and-exprset {};
relation-and-exprset:
	OR relation-and-expr relation-and-exprset {} 
	| {};
relation-and-expr:
	relation-expr relation-exprset {};
relation-exprset:
	AND relation-expr relation-exprset {} 
	| {};
relation-expr:
	NOT expression comp expression {}
	| NOT TRUE {}
	| NOT FALSE {}
	| NOT L_PAREN bool-expr R_PAREN {}
	| expression comp expression {} 
	| TRUE {}
	| FALSE {}
	| L_PAREN bool-expr R_PAREN {};
comp:
	EQ {} 
	| NEQ {} 
	| LT {} 
	| GT {} 
	| LTE {} 
	| GTE {};
expression:
	multiplicative-expr multiplicative-exprset {};	
multiplicative-exprset:
	addorsub multiplicative-expr multiplicative-exprset {} 
	| {};
addorsub:
	ADD {} 
	| SUB {};
multiplicative-expr:
	term termset {};
termset:
	multordivormod term termset {} 
	| {};
multordivormod:
	MULT {} 
	| DIV {} 
	| MOD {};
term:
	termoption1 {} 
	| termoption2 {};
termoption1:
	SUB var {} 
	| SUB NUMBER {} 
	| SUB L_PAREN expression R_PAREN {} 
	| var {} 
	| NUMBER {} 
	| L_PAREN expression R_PAREN {};
termoption2:
	IDENT L_PAREN R_PAREN {} 
	| IDENT L_PAREN expressionset R_PAREN {};
expressionset:
	expression COMMA expressionset {} 
	| expression {};
var:
	IDENT {} 
	| IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {};
%%

//we need a string library to make this stuff easier
//and avoid using char array pointers as strings

static int tempCount = 0;
type newtemp() //type is of type symbol table entry point
{
	//create a new temp variabel name like:
	// "__temp__" + tempCount++ + "\0";
	//insert into symbol table
	//keep looping on creation and symbol table
	//insertion until it is unique and succeeds
}

static int labelCount = 0;
string* newlabel()
{
	string* label = "__label__" + string(labelCount++);
	return label;
}

bool symboltableinsert(string key, string value) 
{
	//check if symbol already exists
	//if so throw duplicate variable error and return false
	//otherwise insert into table and return true
}

type findsymbol(string key) 
{
	//iterate through symbol table
	//use find() or any helpful iterator method
	//return pointer to symbol entry
}

string gen(string instruction, string param1, string optionalParam2, string optionalParam3)
{
	string op = instruction + " " + param1;
	if (optionalParam2 != "")
		op += ", " + optionalParam2;
	if (optionalParam3 != "")
		op += ", " + optionalParam3;
	op += "\n ";
}

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}
