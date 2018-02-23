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
	functionset { printf("program -> functionset"); };
functionset:
	function functionset { printf("functionset -> function functionset"); } 
	| { printf("functionset -> Epsilon"); };
function: //not sure if having a non-terminal named function and a terminal name FUNCTION causes an issue.
	FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarationset END_PARAMS BEGIN_LOCALS declarationset END_LOCALS BEGIN_BODY statementset END_BODY { printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarationset END_PARAMS BEGIN_LOCALS declarationset END_LOCALS BEGIN_BODY statementset END_BODY"); };
declarationset:
	declaration SEMICOLON declarationset {printf("declarationset -> declaration SEMICOLON declarationset");} 
	| {printf("declarationset -> Epsilon");};
statementset:
	statement SEMICOLON statementset {printf("statementset -> statement SEMICOLON statementset");} 
	| statement SEMICOLON {printf("statementset -> statement SEMICOLON");};
declaration:
	identifierset COLON INTEGER {printf("declaration -> identifierset SEMICOLON INTEGER");} 
	| identifierset COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifierset COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER");};
identifierset:
	IDENT COMMA identifierset {printf("identifierset -> IDENT COMMA identifierset");} 
	| IDENT {printf("identifierset -> IDENT");};
statement:
	varstatement {printf("statement -> varstatement");}
	| ifstatement {printf("statement -> ifstatement");}
	| whilestatement {printf("statement -> whilestatement");}
	| dostatement {printf("statement -> dostatement");}
	| foreachstatement {printf("statement -> foreachstatement");}
	| readstatement {printf("statement -> readstatement");}
	| writestatement {printf("statement -> writestatement");}
	| continuestatement {printf("statement -> continuestatement");}
	| returnstatement{printf("statement -> returnstatement");};
varstatement:
	var ASSIGN expression {printf("varstatement -> var ASSIGN expression");};
ifstatement:
	IF bool-expr THEN statementset ifstatementelse {printf("ifstatement -> IF bool-expr THEN statementset ifstatementelse");};
ifstatementelse:
	ELSE statementset ENDIF {printf("ifstatementelse -> ELSE statementset ENDIF");} 	
	| ENDIF {printf("ifstatementelse -> ENDIF");};
whilestatement:
	WHILE bool-expr BEGINLOOP statementset ENDLOOP {printf("whilestatement -> WHILE bool-expr BEGINLOOP statementset ENDLOOP");};
dostatement:
	DO BEGINLOOP statementset ENDLOOP WHILE bool-expr {printf("dostatement -> DO BEGINLOOP statementset ENDLOOP WHILE bool-expr");};
foreachstatement:
	FOREACH IDENT IN IDENT BEGINLOOP statementset ENDLOOP {printf("foreachstatement -> FOREACH IDENT IN IDENT BEGINLOOP statementset ENDLOOP");};
readstatement:
	READ varset {printf("readstatement -> varset");};
writestatement:
	WRITE varset {printf("writestatement -> varset");};
continuestatement:
	CONTINUE {printf("continuestatement -> CONTINUE");};
returnstatement:
	RETURN expression {printf("returnstatement -> RETURN expression");};
varset:
	var COMMA varset {printf("varset -> var COMMA varset");} 
	| var {printf("varset -> var COMMA varset");};
bool-expr:
	relation-and-expr relation-and-exprset {printf("bool-expr -> relation-and-expr relation-and-exprset");};
relation-and-exprset:
	OR relation-and-expr relation-and-exprset {printf("relation-and-exprset -> OR relation-and-expr relation-and-exprset");} 
	| {printf("relation-and-exprset -> Epsilon");};
relation-and-expr:
	relation-expr relation-exprset {printf("relation-and-expr -> relation-expr relation-exprset");};
relation-exprset:
	AND relation-expr relation-exprset {printf("relation-exprset -> AND relation-expr relation-exprset");} 
	| {printf("relation-exprset -> Epsilon");};
relation-expr:
	NOT expression comp expression {printf("relation-expr -> NOT expression comp expression");}
	| NOT TRUE {printf("relation-expr -> NOT TRUE");}
	| NOT FALSE {printf("relation-expr -> NOT FALSE");}
	| NOT L_PAREN bool-expr R_PAREN {printf("relation-expr -> NOT L_PAREN bool-expr R_PAREN");}
	| expression comp expression {printf("relation-expr -> expression comp expression");}	| TRUE {printf("relation-expr -> TRUE");}
	| FALSE {printf("relation-expr -> FALSE");}
	| L_PAREN bool-expr R_PAREN {printf("relation-expr -> L_PAREN bool-expr R_PAREN");};
comp:
	EQ {printf("comp -> EQ");} 
	| NEQ {printf("comp -> NEQ");} 
	| LT {printf("comp -> LT");} 
	| GT {printf("comp -> GT");} 
	| LTE {printf("comp -> LTE");} 
	| GTE {printf("comp -> GTE");};
expression:
	multiplicative-expr multiplicative-exprset {printf("expression -> multiplicative-expr multiplicative-exprset");};	
multiplicative-exprset:
	addorsub multiplicative-expr multiplicative-exprset {printf("multiplicative-exprset -> addorsub multiplicative-expr multiplicative-exprset");} | {printf("multiplicative-exprset -> Epsilon");};
addorsub:
	ADD {printf("addorsub -> ADD");} 
	| SUB {printf("addorsub -> SUB");};
multiplicative-expr:
	term termset {printf("multiplicative-expr -> term termset");};
termset:
	multordivormod term termset {printf("termset -> multordivormod term termset");} 
	| {printf("termset -> multordivormod term termset");};
multordivormod:
	MULT {printf("multordivormod -> MULT");} 
	| DIV {printf("multordivormod -> DIV");} 
	| MOD {printf("multordivormod -> MOD");};
term:
	termoption1 {printf("term -> termoption1");} 
	| termoption2 {printf("term -> termoption2");};
termoption1:
	SUB var {printf("termoption1 -> SUB var");} 
	| SUB NUMBER {printf("termoption1 -> SUB NUMBER");} 
	| SUB L_PAREN expression R_PAREN {printf("termoption1 -> SUB L_PAREN expression R_PAREN");} 
	| var {printf("termoption1 -> var");} 
	| NUMBER {printf("termoption1 -> NUMBER");} 
	| L_PAREN expression R_PAREN {printf("termoption1 -> L_PAREN expression R_PAREN");};
termoption2:
	IDENT L_PAREN R_PAREN {printf("termoption2 -> IDENT L_PAREN R_PAREN");} 
	| IDENT L_PAREN expressionset R_PAREN {printf("termoption2 -> IDENT L_PAREN expressionset R_PAREN");};
expressionset:
	expression COMMA expressionset {printf("expressionset -> expression COMMA expressionset");} 
	| expression {printf("expressionset -> expression");};
var:
	IDENT {printf("var -> IDENT");} 
	| IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET");};
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



