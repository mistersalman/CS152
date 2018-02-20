/* mini_l syntax parser
   Written by Ryan Gray and Salman Azmi
   CS152 WINTER 18 */
%{
 #include <stdio.h>
 #include <stdlib.h>
 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 FILE * yyin;
%}

%union{
  double dval;
  char* cval;
}

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


%% 
program:	
	functionset {};
functionset:
	function functionset {} | {};
function: //not sure if having a non-terminal named function and a terminal name FUNCTION causes an issue.
	FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarationset END_PARAMS BEGIN_LOCALS declarationset END_LOCALS BEGIN_BODY statementset END_BODY {};
declarationset:
	declaration SEMICOLON declarationset {} | {};
statementset:
	statement SEMICOLON statementset {} | statement SEMICOLON {};
declaration:
	identifierset SEMICOLON INTEGER {} 
	| identifierset COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {};
identifierset:
	IDENT COMMA identifierset {} | IDENT {};
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
	ELSE statementset ENDIF {} | ENDIF {};
whilestatement:
	WHILE bool-expr BEGINLOOP statementset ENDLOOP {};
dostatement:
	DO BEGINLOOP statementset ENDLOOP WHILE bool-expr {};
foreachstatement:
	FOREACH IDENT IN IDENT BEGINLOOP statementset ENDLOOP {};
readstatement:
	varset {};
writestatement:
	varset {};
continuestatement:
	CONTINUE {};
returnstatement:
	RETURN expression {};
varset:
	var COMMA varset {} | var {};
bool-expr:
	relation-and-expr relation-and-exprset {};
relation-and-exprset:
	OR relation-and-expr relation-and-exprset {} | {};
relation-and-expr:
	relation-expr relation-exprset {};
relation-exprset:
	AND relation-expr relation-exprset {} | {};
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
	EQ {} | NEQ {} | LT {} | GT {} | LTE {} | GTE {};
expression:
	multiplicative-expr multiplicative-exprset {};	
multiplicative-exprset:
	addorsub multiplicative-expr multiplicative-exprset {} | {};
addorsub:
	ADD {} | SUB {};
multiplcative-expr:
	term termset {};
termset:
	multordivormod term termset {} | {};
multordivormod:
	MULT {} | DIV {} | MOD {};
term:
	termoption1 {} | termoption2 {};
termoption1:
	SUB var {} | sub NUMBER {} | SUB L_PAREN expression R_PAREN {} | var {} | NUMBER {} | L_PAREN expression R_PAREN {};
termoption2:
	IDENT L_PAREN R_PAREN {} | IDENT L_PAREN expressionset R_PAREN {};
expressionset:
	expression COMMA expressionset {} | expression {};
var:
	IDENT {} | IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {};


/*line:		exp EQUAL END         { printf("\t%f\n", $1);}
			;

exp:		NUMBER                { $$ = $1; }
			| exp PLUS exp        { $$ = $1 + $3; }
			| exp MINUS exp       { $$ = $1 - $3; }
			| exp MULT exp        { $$ = $1 * $3; }
			| exp DIV exp         { if ($3==0) yyerror("divide by zero"); else $$ = $1 / $3; }
			| MINUS exp %prec UMINUS { $$ = -$2; }
			| L_PAREN exp R_PAREN { $$ = $2; }
			;*/
%%

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

