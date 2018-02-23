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
	functionset { printf("program -> functionset\n "); };
functionset:
	function functionset { printf("functionset -> function functionset\n"); } 
	| { printf("functionset -> Epsilon\n "); };
function: //not sure if having a non-terminal named function and a terminal name FUNCTION causes an issue.
	FUNCTION ident SEMICOLON BEGIN_PARAMS declarationset END_PARAMS BEGIN_LOCALS declarationset END_LOCALS BEGIN_BODY statementset END_BODY { printf("function -> FUNCTION ident SEMICOLON BEGIN_PARAMS declarationset END_PARAMS BEGIN_LOCALS declarationset END_LOCALS BEGIN_BODY statementset END_BODY\n "); };
ident:
	IDENT {printf("ident -> IDENT %s \n", $1);};
declarationset:
	declaration SEMICOLON declarationset {printf("declarationset -> declaration SEMICOLON declarationset \n");} 
	| {printf("declarationset -> Epsilon \n");};
statementset:
	statement SEMICOLON statementset {printf("statementset -> statement SEMICOLON statementset \n");} 
	| statement SEMICOLON {printf("statementset -> statement SEMICOLON \n");};
declaration:
	identifierset COLON INTEGER {printf("declaration -> identifierset COLON INTEGER \n");} 
	| identifierset COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifierset COLON ARRAY L_SQUARE_BRACKET NUMBER %d R_SQUARE_BRACKET OF INTEGER \n", $5);};
identifierset:
	ident COMMA identifierset {printf("identifierset -> ident COMMA identifierset \n");} 
	| ident {printf("identifierset -> ident \n");};
statement:
	varstatement {printf("statement -> varstatement \n");}
	| ifstatement {printf("statement -> ifstatement \n");}
	| whilestatement {printf("statement -> whilestatement \n");}
	| dostatement {printf("statement -> dostatement \n");}
	| foreachstatement {printf("statement -> foreachstatement \n");}
	| readstatement {printf("statement -> readstatement \n");}
	| writestatement {printf("statement -> writestatement \n");}
	| continuestatement {printf("statement -> continuestatement \n");}
	| returnstatement{printf("statement -> returnstatement \n");};
varstatement:
	var ASSIGN expression {printf("varstatement -> var ASSIGN expression \n");};
ifstatement:
	IF bool-expr THEN statementset ifstatementelse {printf("ifstatement -> IF bool-expr THEN statementset ifstatementelse \n");};
ifstatementelse:
	ELSE statementset ENDIF {printf("ifstatementelse -> ELSE statementset ENDIF \n");} 	
	| ENDIF {printf("ifstatementelse -> ENDIF \n");};
whilestatement:
	WHILE bool-expr BEGINLOOP statementset ENDLOOP {printf("whilestatement -> WHILE bool-expr BEGINLOOP statementset ENDLOOP \n");};
dostatement:
	DO BEGINLOOP statementset ENDLOOP WHILE bool-expr {printf("dostatement -> DO BEGINLOOP statementset ENDLOOP WHILE bool-expr \n");};
foreachstatement:
	FOREACH ident IN ident BEGINLOOP statementset ENDLOOP {printf("foreachstatement -> FOREACH ident IN ident BEGINLOOP statementset ENDLOOP \n");};
readstatement:
	READ varset {printf("readstatement -> varset \n");};
writestatement:
	WRITE varset {printf("writestatement -> varset \n");};
continuestatement:
	CONTINUE {printf("continuestatement -> CONTINUE \n");};
returnstatement:
	RETURN expression {printf("returnstatement -> RETURN expression \n");};
varset:
	var COMMA varset {printf("varset -> var COMMA varset \n");} 
	| var {printf("varset -> var COMMA varset \n");};
bool-expr:
	relation-and-expr relation-and-exprset {printf("bool-expr -> relation-and-expr relation-and-exprset \n");};
relation-and-exprset:
	OR relation-and-expr relation-and-exprset {printf("relation-and-exprset -> OR relation-and-expr relation-and-exprset \n");} 
	| {printf("relation-and-exprset -> Epsilon \n");};
relation-and-expr:
	relation-expr relation-exprset {printf("relation-and-expr -> relation-expr relation-exprset \n");};
relation-exprset:
	AND relation-expr relation-exprset {printf("relation-exprset -> AND relation-expr relation-exprset \n");} 
	| {printf("relation-exprset -> Epsilon \n");};
relation-expr:
	NOT expression comp expression {printf("relation-expr -> NOT expression comp expression \n");}
	| NOT TRUE {printf("relation-expr -> NOT TRUE \n");}
	| NOT FALSE {printf("relation-expr -> NOT FALSE \n");}
	| NOT L_PAREN bool-expr R_PAREN {printf("relation-expr -> NOT L_PAREN bool-expr R_PAREN \n");}
	| expression comp expression {printf("relation-expr -> expression comp expression \n");} 
	| TRUE {printf("relation-expr -> TRUE \n");}
	| FALSE {printf("relation-expr -> FALSE \n");}
	| L_PAREN bool-expr R_PAREN {printf("relation-expr -> L_PAREN bool-expr R_PAREN \n");};
comp:
	EQ {printf("comp -> EQ \n");} 
	| NEQ {printf("comp -> NEQ \n");} 
	| LT {printf("comp -> LT \n");} 
	| GT {printf("comp -> GT \n");} 
	| LTE {printf("comp -> LTE \n");} 
	| GTE {printf("comp -> GTE \n");};
expression:
	multiplicative-expr multiplicative-exprset {printf("expression -> multiplicative-expr multiplicative-exprset \n");};	
multiplicative-exprset:
	addorsub multiplicative-expr multiplicative-exprset {printf("multiplicative-exprset -> addorsub multiplicative-expr multiplicative-exprset \n");} 
	| {printf("multiplicative-exprset -> Epsilon \n");};
addorsub:
	ADD {printf("addorsub -> ADD \n");} 
	| SUB {printf("addorsub -> SUB \n");};
multiplicative-expr:
	term termset {printf("multiplicative-expr -> term termset \n");};
termset:
	multordivormod term termset {printf("termset -> multordivormod term termset \n");} 
	| {printf("termset -> multordivormod term termset \n");};
multordivormod:
	MULT {printf("multordivormod -> MULT \n");} 
	| DIV {printf("multordivormod -> DIV \n");} 
	| MOD {printf("multordivormod -> MOD \n");};
term:
	termoption1 {printf("term -> termoption1 \n");} 
	| termoption2 {printf("term -> termoption2 \n");};
termoption1:
	SUB var {printf("termoption1 -> SUB var \n");} 
	| SUB NUMBER {printf("termoption1 -> SUB NUMBER %d \n", $2);} 
	| SUB L_PAREN expression R_PAREN {printf("termoption1 -> SUB L_PAREN expression R_PAREN \n");} 
	| var {printf("termoption1 -> var \n");} 
	| NUMBER {printf("termoption1 -> NUMBER %d \n", $1);} 
	| L_PAREN expression R_PAREN {printf("termoption1 -> L_PAREN expression R_PAREN \n");};
termoption2:
	ident L_PAREN R_PAREN {printf("termoption2 -> ident L_PAREN R_PAREN \n");} 
	| ident L_PAREN expressionset R_PAREN {printf("termoption2 -> ident L_PAREN expressionset R_PAREN \n");};
expressionset:
	expression COMMA expressionset {printf("expressionset -> expression COMMA expressionset \n");} 
	| expression {printf("expressionset -> expression \n");};
var:
	ident {printf("var -> ident \n");} 
	| ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET \n");};
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



