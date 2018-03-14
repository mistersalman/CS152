/* mini_l syntax parser
   Written by Ryan Gray and Salman Azmi
   CS152 WINTER 18 */
%{
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
	functionname function functionset {} 
	| {};
functionname: //not sure if having a non-terminal named function and a terminal name FUNCTION causes an issue.
	FUNCTION ident SEMICOLON { };
function:
	BEGIN_PARAMS declarationset END_PARAMS BEGIN_LOCALS declarationset END_LOCALS BEGIN_BODY statementset END_BODY { };
ident:
	IDENT { };
declarationset:
	declaration SEMICOLON declarationset {} 
	| {};
declaration:
	identifierset COLON INTEGER {} 
	| identifierset COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {};
identifierset:
	ident { }
	| ident COMMA identifierset { };
statementset:
	statement SEMICOLON statementset {} 
	| statement SEMICOLON {};
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
	//this covers the case of dst = src and dst[index] = src but not dst = src[index]
	var ASSIGN expression {};
ifstatement:
	IF bool-expr THEN statementset ELSE statementset ENDIF {}
	| IF bool-expr THEN statementset ENDIF {} ;
whilestatement:
	WHILE bool-expr BEGINLOOP statementset ENDLOOP {};
dostatement:
	DO BEGINLOOP statementset ENDLOOP WHILE bool-expr {};
foreachstatement:
	FOREACH ident IN ident BEGINLOOP statementset ENDLOOP {};
continuestatement:
	CONTINUE {};
readstatement:
	READ varset { };
writestatement:
	WRITE varset { };
returnstatement:
	RETURN expression {};
varset:
	var {}
	| var COMMA varset {};
var:
	ident { } 
	| ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {};


bool-expr:
	relation-exprset {};
relation-exprset:
	relation-expr {} |
	relation-exprset andororornot relation-expr {};
andororornot:
	AND { }
	| OR {}
	| NOT {};
relation-expr:
	expression comp expression {} 
	| TRUE {}
	| FALSE {}
	| L_PAREN bool-expr R_PAREN { };
comp:
	EQ { } 
	| NEQ { } 
	| LT { } 
	| GT { } 
	| LTE { } 
	| GTE { };

expression:
	termset { };
expressionset:
	expression {}
	| expression COMMA expressionset {};
term:
	var { } 
	| NUMBER { } 
	| ident L_PAREN R_PAREN { } 
	| L_PAREN expression R_PAREN { }
	| ident L_PAREN expressionset R_PAREN { };
termset:
	term {}
	| termset multordivormodoraddorsub term {};
multordivormodoraddorsub:
	MULT {} 
	| DIV {} 
	| MOD {}
	| ADD {}
	| SUB {};

%%

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]); //cout << "Syntax: " + argv[0] + " filename" << endl;
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
   //cout << "** Line " + currLine + ", position " + currPos + ": " + msg << endl;
}
