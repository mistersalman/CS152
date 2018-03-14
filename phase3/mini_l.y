/* mini_l syntax parser
   Written by Ryan Gray and Salman Azmi
   CS152 WINTER 18 */
%{
 #include <stdio.h>
 #include <stdlib.h>
 #include <vector>
 #include <string>
 #include <iostream>
 #include <sstream>
 #include <fstream>
 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 FILE * yyin;
 using namespace std; //don't wanna add std:: to everything

 vector <string> symbolTable; //key, value e.g. __label__0
 vector <string> labelTable;
%}

%union{
  double dval;
  char* cval;
  struct {
		string type;
		string index;
		int place;
	} varParams;
	struct {
		int place;
	} exprParams;
  struct {
  	int place;
  	string type;
	string val;
	vector<string> valSet;
	vector<varParams> varSet;
	vector<exprParams> exprSet;

} terminalParams;
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
	FUNCTION ident SEMICOLON { cout << "func " << $2 << endl; };
function:
	BEGIN_PARAMS declarationset END_PARAMS BEGIN_LOCALS declarationset END_LOCALS BEGIN_BODY statementset END_BODY { cout << "endfunc" << endl; };
ident:
	IDENT { $$.val = string($1); };
declarationset:
	declaration SEMICOLON declarationset {} 
	| {};
declaration:
	identifierset COLON INTEGER {
		for (unsigned i = 0; i < $1.valSet->size(); i++)
		{
			cout << ". " + $1.valSet->at(i) << endl;
			string* temp = newtemp();
			symbolTable->push_back(temp);
			cout << ". " + temp << endl;
			cout << "= " + temp + ", " + $1.valSet->at(i) << endl;
		}
	} 
	| identifierset COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
		for (unsigned i = 0; i < $1.valSet->size(); i++)
		{
			cout << ".[] " + $1.valSet->at(i) + ", " + $5 << endl;
			string* temp = newtemp();
			symbolTable->push_back(temp);
			cout << ". " + temp << endl;
			cout << "= " + temp + ", " + $1.valSet->at(i) << endl;
		}
	};
identifierset:
	ident { 
		$$.valSet = new vector<string>();
		$$.valSet->push_back($1.val); 
		}
	| ident COMMA identifierset { 
		$$.valSet = $3.valSet;
		$$.valSet->push_back($1.val);
	 };
statementset:
	statement SEMICOLON statementset {} 
	| statement SEMICOLON {};
//pulled out foreach loops because I don't know how to implement ident in ident as a boolean expression
statement:
	varstatement {}
	| ifstatement {}
	| whilestatement {}
	| dostatement {}
	| readstatement {}
	| writestatement {}
	| continuestatement {}
	| returnstatement{};
varstatement:
	//this covers the case of dst = src and dst[index] = src but not dst = src[index]
	var ASSIGN expression {
		if ($1.type == "ARRAY")
			cout << "[]= " << symbolTable->at($1.place) << ", " << symbolTable->at($1.index) << ", " << symbolTable->at($3.place) << endl;
		else {
			cout << "= " << symbolTable->at($1.place) << ", " << symbolTable->at($3.place) << endl;
		}
	};
ifstatement:
	IF bool-expr THEN statementset ELSE statementset ENDIF {
		string label1 = newlabel();
		string label2 = newlabel();
		string label3 = newlabel();
		cout << "?:= " << label1 << ", " << symbolTable->at($2.place) << endl;
		cout << ":= " << label2 << endl;
		cout << ": " << label1 << endl;
		//cout << $4.code;
		cout << ":= " << label3;
		cout << ": " << label2;
		//cout << $6.code;
		cout << ": " << label3 << endl;

	}
	| IF bool-expr THEN statementset ENDIF {
		string label1 = newlabel();
		string label2 = newlabel();
		cout << "?:= " << label1 << ", " << symbolTable->at($2.place) << endl;
		cout << ":= " << label2 << endl;
		cout << ": " << label1 << endl;
		//cout << $4.code;
		cout << ": " << label2;
	} ;
whilestatement:
	WHILE bool-expr BEGINLOOP statementset ENDLOOP {
		string label1 = newlabel();
		string label2 = newlabel();
		string label3 = newlabel();
		labelTable->push_back(label3);
		cout << ": " << label1 << endl;
		cout << "?:= " << label2 << ", " << symbolTable->at($2.place) << endl;
		cout << ":= " << label3 << endl;
		cout << ": " << label2 << endl;
		//cout << $4.code << endl;
		cout << ": " << label1 << endl;
		cout << ": " << label3 << endl;		
	};
dostatement:
	DO BEGINLOOP statementset ENDLOOP WHILE bool-expr {
		string label1 = newlabel();
		string label2 = newlabel();
		labelTable->push_back(label2);
		cout << ": " << label1 << endl;
		//cout << $3.code;
		cout << "?:= " << label1 << ", " << symbolTable->at($6.place) << endl;
		cout << ": " << label2 << endl;
	};

continuestatement:
	CONTINUE {
		cout << ";= " << labelTable->at(labelTable->size() - 1) << endl;
		labelTable->pop_back();
	};
readstatement:
	READ varset {
		for (unsigned i = 0; i < $2.varSet.size(); i++)
		{
			if ($2.varSet->at(i).type == "ARRAY")
				cout << ".[]< " << symbolTable->at($2.varSet->at(i).place) << $2.varSet->at(i).index << endl;
			else
				cout << ".< " << symbolTable->at($2.varSet->at(i).place) << endl;
		}
	};
writestatement:
	WRITE varset {
		for (unsigned i = 0; i < $2.varSet.size(); i++)
		{
			if ($2.varSet->at(i).type == "ARRAY")
				cout << ".[]< " << symbolTable->at($2.varSet->at(i).place) << $2.varSet->at(i).index << endl;
			else
				cout << ".< " << symbolTable->at($2.varSet->at(i).place) << endl;
		}
	};
returnstatement:
	RETURN expression { 
		cout << "ret " << symbolTable->at($2.place) << endl;
	};
varset:
	var {
		$$.varSet = new vector<varParams>();
		varParams var;
		var.place = $1.place;
		var.type = $1.type;
		var.index = $1.index;
		$$.varSet->push_back(var);
	}
	| var COMMA varset {
		varParams var;
		var.place = $1.place;
		var.type = $1.type;
		var.index = $1.index;
		$$.varSet->push_back(var);
	};
var:
	ident { 
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1;
		$$.type = "VALUE";
		$$.index = "";
		cout << ". " << temp << endl;
	} 
	| ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1;
		$$.type = "ARRAY"
		$$.index = symbolTable->at($3.place)
		cout << ". " << temp << endl;
	};


bool-expr:
	relation-exprset {$$.place = $1.place;};
relation-exprset:
	relation-expr {$$.place = $1.place;} |
	relation-exprset andororornot relation-expr {
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1;
		cout << ". " + temp << endl;
		if ($2val == "!")
			cout << $2.val << temp << symbolTable->at($1.place) << ", " << symbolTable->at($3.place) << endl;
		else
			cout << $2.val + " " + temp + ", " + symbolTable->at($1.place) + ", " symbolTable->at($3.place) << endl;
	};
andororornot:
	AND {$$.val = string("&&"); }
	| OR {$$.val = string("||");}
	| NOT {$$.val = string("!");};
relation-expr:
	expression comp expression {
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1;
		cout << ". " + temp << endl;
		cout << $2.val << " " << temp << ", " << symbolTable->at($1.place) << ", " << symbolTable->at($1.place) << endl; 
	} 
	| TRUE {
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1; 
		cout << ". " + temp << endl;
		cout << "= " << temp << ", " << "true"; 
		}
	| FALSE {
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1; 
		cout << ". " + temp << endl;
		cout << "= " << temp << ", " << "false"; }
	| L_PAREN bool-expr R_PAREN { $$.place = $2.place; };
comp:
	EQ { $$.val = string("==" ); } 
	| NEQ { $$.val = string("!=" ); } 
	| LT { $$.val = string("<" ); } 
	| GT { $$.val = string(">" ); } 
	| LTE { $$.val = string("<=" ); } 
	| GTE { $$.val = string(">=" ); };

expression:
	termset { 
		$$.place = $1.place; 
	};
expressionset:
	expression {
		$$.exprSet = new vector<exprParams>();
		exprParams expr;
		expr.place = $1.place;
		$$.exprSet->push_back(expr);
	}
	| expression COMMA expressionset {
		exprParams expr;
		expr.place = $1.place;
		$$.exprSet->push_back(expr);		
	};
term:
	var { 
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1;
		cout << ". " + temp << endl;
		cout << "= " + temp + ", " + $1.val << endl;
	 } 
	| NUMBER { 
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1;	
		cout << ". " + temp << endl;
		cout << "= " + temp + ", " + $1 << endl;
	} 
	| ident L_PAREN R_PAREN { 
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1;	
		cout << ". " << temp << endl;
		cout << "call " << $1.val << ", " << temp << endl;
	 } 
	| L_PAREN expression R_PAREN { 
		$$.place = $2.place; 
		}
	| ident L_PAREN expressionset R_PAREN { 
		for (unsigned i = 0; i < $3.exprSet.size(); i++)
		{
			cout << "param " << symbolTable->at($3.experSet->at(i).place) << endl;
		}
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1;	
		cout << ". " << temp << endl;
		cout << "call " << $1.val << ", " << temp << endl;
	 };
termset:
	term {$$.place = $1.place;}
	| termset multordivormodoraddorsub term {
		string temp = newtemp();		
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1;
		cout << ". " + temp << endl;
		cout << $2.val + " " + temp + ", " + symbolTable->at($1.place) + ", " symbolTable->at($3.place) << endl;
	};
multordivormodoraddorsub:
	MULT {$$.val = string("*");} 
	| DIV {$$.val = string("/");} 
	| MOD {$$.val = string("%");}
	| ADD {$$.val = string("+");}
	| SUB {$$.val = string("-");};

%%

//we need a string library to make this stuff easier
//and avoid using char array pointers as strings

static int tempCount = -1;
string newtemp() //type is of type symbol table entry point
{
	//create a new temp variabel name like:
	// "__temp__" + tempCount++ + "\0";
	//insert into symbol table
	//keep looping on creation and symbol table
	//insertion until it is unique and succeeds
	tempCount++;
	return "__temp__" + tempCount;
}

static int labelCount = 0;
string* newlabel()
{
	string* label = "__label__" + string(labelCount++);
	return label;
}

/*bool symboltableinsert(string key, string value) 
{
	//check if symbol already exists
	//if so throw duplicate variable error and return false
	//otherwise insert into table and return true
}*/

int findsymbol(string key) 
{
	//iterate through symbol table
	//use find() or any helpful iterator method
	//return pointer to symbol entry
	for(int i = 0; i < symbolTable.size(); i++)
	{
		if(symbolTable->at(i).compare(key) == 0)
		{
			return i;
		}
	}
	-1;	
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
         /*printf("syntax: %s filename\n", argv[0]);*/ cout << "Syntax: " + argv[0] + " filename" << endl;
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}

void yyerror(const char *msg) {
   /*printf("** Line %d, position %d: %s\n", currLine, currPos, msg);*/
   cout << "** Line " + currLine + ", position " + currPos + ": " + msg << endl;
}
