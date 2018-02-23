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
	functionset { print("program -> functionset"); };
functionset:
	function functionset { print("functionset -> function functionset"); } 
	| { print("functionset -> Epsilon"); };
function: //not sure if having a non-terminal named function and a terminal name FUNCTION causes an issue.
	FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarationset END_PARAMS BEGIN_LOCALS declarationset END_LOCALS BEGIN_BODY statementset END_BODY { print("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarationset END_PARAMS BEGIN_LOCALS declarationset END_LOCALS BEGIN_BODY statementset END_BODY"); };
declarationset:
	declaration SEMICOLON declarationset {print("declarationset -> declaration SEMICOLON declarationset");} 
	| {print("declarationset -> Epsilon");};
statementset:
	statement SEMICOLON statementset {print("statementset -> statement SEMICOLON statementset");} 
	| statement SEMICOLON {print("statementset -> statement SEMICOLON");};
declaration:
	identifierset SEMICOLON INTEGER {print("declaration -> identifierset SEMICOLON INTEGER");} 
	| identifierset COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {print("declaration -> identifierset COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER");};
identifierset:
	IDENT COMMA identifierset {print("identifierset -> IDENT COMMA identifierset");} 
	| IDENT {print("identifierset -> IDENT");};
statement:
	varstatement {print("statement -> varstatement");}
	| ifstatement {print("statement -> ifstatement");}
	| whilestatement {print("statement -> whilestatement");}
	| dostatement {print("statement -> dostatement");}
	| foreachstatement {print("statement -> foreachstatement");}
	| readstatement {print("statement -> readstatement");}
	| writestatement {print("statement -> writestatement");}
	| continuestatement {print("statement -> continuestatement");}
	| returnstatement{print("statement -> returnstatement");};
varstatement:
	var ASSIGN expression {print("varstatement -> var ASSIGN expression");} 
	| { /*if ($1 != ":=") yyerror(":= expected"); else yyerror("invalid assignment");*/};
ifstatement:
	IF bool-expr THEN statementset ifstatementelse {print("ifstatement -> IF bool-expr THEN statementset ifstatementelse");};
ifstatementelse:
	ELSE statementset ENDIF {print("ifstatementelse -> ELSE statementset ENDIF");} 	
	| ENDIF {print("ifstatementelse -> ENDIF");};
whilestatement:
	WHILE bool-expr BEGINLOOP statementset ENDLOOP {print("whilestatement -> WHILE bool-expr BEGINLOOP statementset ENDLOOP");};
dostatement:
	DO BEGINLOOP statementset ENDLOOP WHILE bool-expr {print("dostatement -> DO BEGINLOOP statementset ENDLOOP WHILE bool-expr");};
foreachstatement:
	FOREACH IDENT IN IDENT BEGINLOOP statementset ENDLOOP {print("foreachstatement -> FOREACH IDENT IN IDENT BEGINLOOP statementset ENDLOOP");};
readstatement:
	varset {print("readstatement -> varset");};
writestatement:
	varset {print("writestatement -> varset");};
continuestatement:
	CONTINUE {print("continuestatement -> CONTINUE");};
returnstatement:
	RETURN expression {print("returnstatement -> RETURN expression");};
varset:
	var COMMA varset {print("varset -> var COMMA varset");} 
	| var {print("varset -> var COMMA varset");};
bool-expr:
	relation-and-expr relation-and-exprset {print("bool-expr -> relation-and-expr relation-and-exprset");};
relation-and-exprset:
	OR relation-and-expr relation-and-exprset {print("relation-and-exprset -> OR relation-and-expr relation-and-exprset");} 
	| {print("relation-and-exprset -> Epsilon");};
relation-and-expr:
	relation-expr relation-exprset {print("relation-and-expr -> relation-expr relation-exprset");};
relation-exprset:
	AND relation-expr relation-exprset {print("relation-exprset -> AND relation-expr relation-exprset");} 
	| {print("relation-exprset -> Epsilon");};
relation-expr:
	NOT expression comp expression {print("relation-expr -> NOT expression comp expression");}
	| NOT TRUE {print("relation-expr -> NOT TRUE");}
	| NOT FALSE {print("relation-expr -> NOT FALSE");}
	| NOT L_PAREN bool-expr R_PAREN {print("relation-expr -> NOT L_PAREN bool-expr R_PAREN");}
	| expression comp expression {print("relation-expr -> expression comp expression");}
	| TRUE {print("relation-expr -> TRUE");}
	| FALSE {print("relation-expr -> FALSE");}
	| L_PAREN bool-expr R_PAREN {print("relation-expr -> L_PAREN bool-expr R_PAREN");};
comp:
	EQ {print("comp -> EQ");} 
	| NEQ {print("comp -> NEQ");} 
	| LT {print("comp -> LT");} 
	| GT {print("comp -> GT");} 
	| LTE {print("comp -> LTE");} 
	| GTE {print("comp -> GTE");};
expression:
	multiplicative-expr multiplicative-exprset {print("expression -> multiplicative-expr multiplicative-exprset");};	
multiplicative-exprset:
	addorsub multiplicative-expr multiplicative-exprset {print("multiplicative-exprset -> addorsub multiplicative-expr multiplicative-exprset");} | {print("multiplicative-exprset -> Epsilon");};
addorsub:
	ADD {print("addorsub -> ADD");} 
	| SUB {print("addorsub -> SUB");};
multiplicative-expr:
	term termset {print("multiplicative-expr -> term termset");};
termset:
	multordivormod term termset {print("termset -> multordivormod term termset");} 
	| {print("termset -> multordivormod term termset");};
multordivormod:
	MULT {print("multordivormod -> MULT");} 
	| DIV {print("multordivormod -> DIV");} 
	| MOD {print("multordivormod -> MOD");};
term:
	termoption1 {print("term -> termoption1");} 
	| termoption2 {print("term -> termoption2");};
termoption1:
	SUB var {print("termoption1 -> SUB var");} 
	| SUB NUMBER {print("termoption1 -> SUB NUMBER");} 
	| SUB L_PAREN expression R_PAREN {print("termoption1 -> SUB L_PAREN expression R_PAREN");} 
	| var {print("termoption1 -> var");} 
	| NUMBER {print("termoption1 -> NUMBER");} 
	| L_PAREN expression R_PAREN {print("termoption1 -> L_PAREN expression R_PAREN");};
termoption2:
	IDENT L_PAREN R_PAREN {print("termoption2 -> IDENT L_PAREN R_PAREN");} 
	| IDENT L_PAREN expressionset R_PAREN {print("termoption2 -> IDENT L_PAREN expressionset R_PAREN");};
expressionset:
	expression COMMA expressionset {print("expressionset -> expression COMMA expressionset");} 
	| expression {print("expressionset -> expression");};
var:
	IDENT {print("var -> IDENT");} 
	| IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {print("var -> IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET");};
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


