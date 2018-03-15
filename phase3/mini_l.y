/* mini_l syntax parser
   Written by Ryan Gray and Salman Azmi
   CS152 WINTER 18 */
%{
 #include <vector>
 #include <string>
 #include <stdio.h>
 #include <stdlib.h>
 #include <iostream>
 using namespace std; //don't wanna add std:: to everything
 void yyerror(const char *msg);
 extern "C" int yyparse (void);
 extern "C" int yylex(void);
 extern int currLine;
 extern int currPos;
 FILE * yyin;
 struct varParams {
	string type;
	string index;
	int place;
	};
 struct exprParams {
	int place;
	};
 struct terminalParams {
  	int place;
  	string type;
	string val;
	string index;
	vector<string>* valSet;
	vector<varParams>* varSet;
	vector<exprParams>* exprSet;
	};
 vector <string>* symbolTable; 
 vector <string>* labelTable;
 vector <string>* functionTable;
 vector <string>* variableTable;
 vector <string>* keywordTable;
 
 static int tempCount = -1;
string newtemp()
{
	tempCount++;
	return "__temp__" + tempCount;
}

static int labelCount = -1;
string newlabel()
{
	labelCount++;
	return "__label__" + labelCount;
}

bool findVariable(string val) 
{
	for(int i = 0; i < variableTable->size(); i++)
	{
		if(variableTable->at(i).compare(val) == 0)
		{
			return 1;
		}
	}
	return 0;
}

bool findFunction(string val)
{
	for(int i = 0; i < functionTable->size(); i++)
	{
		if(functionTable->at(i).compare(val) == 0)

{
			return 1;
		}
	}
	return 0;
}

bool findKeyword(string val)
{
	for(int i = 0; i < keywordTable->size(); i++)
	{
		if(keywordTable->at(i).compare(val) == 0)
		{
			return 1;
		}
	}
	return 0;
}

%}

%language "c++"
%define api.value.type variant



%error-verbose
%start program
%token SUB ADD MULT DIV MOD GT LT GTE LTE EQ NEQ L_PAREN R_PAREN ASSIGN COLON SEMICOLON NOT AND OR 
%token L_SQUARE_BRACKET R_SQUARE_BRACKET COMMA BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY FUNCTION
%token INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE RETURN
%token <double> NUMBER
%token <char*> IDENT

%left BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY FUNCTION 
%left INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE RETURN
%left MOD GT LT GTE LTE EQ NEQ NOT AND OR TRUE FALSE SUB ADD MULT DIV L_PAREN R_PAREN
%left L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN COMMA COLON SEMICOLON

%type <terminalParams> program functionset functionname function ident declarationset declaration identifierset statementset statement varstatement ifstatement whilestatement dostatement continuestatement readstatement writestatement  returnstatement varset var bool-expr relation-exprset andororornot relation-expr comp expression expressionset term termset multordivormodoraddorsub

%% 
program:	
	functionset { 
		if (!findFunction("main"))
			yyerror("Main function has not been defined.");			
	};
functionset:
	functionname function functionset {} 
	| {};
functionname: //not sure if having a non-terminal named function and a terminal name FUNCTION causes an issue.
	FUNCTION ident SEMICOLON { 
		functionTable->push_back($2.val);
		keywordTable->push_back("beginparams"); keywordTable->push_back("endParams"); keywordTable->push_back("beginlocals"); 
		keywordTable->push_back("endlocals"); keywordTable->push_back("beginbody"); keywordTable->push_back("endbody"); 
		keywordTable->push_back("function"); keywordTable->push_back("integer"); keywordTable->push_back("array"); 
		keywordTable->push_back("of"); keywordTable->push_back("if"); keywordTable->push_back("then");
		keywordTable->push_back("endif"); keywordTable->push_back("else"); keywordTable->push_back("while"); 
		keywordTable->push_back("do"); keywordTable->push_back("foreach"); keywordTable->push_back("in"); 
		keywordTable->push_back("beginloop"); keywordTable->push_back("endloop"); keywordTable->push_back("continue"); 
		keywordTable->push_back("read"); keywordTable->push_back("write"); keywordTable->push_back("true");
		keywordTable->push_back("false"); keywordTable->push_back("return"); 
		cout << "func " << $2.val << endl; 
	};
function:
	BEGIN_PARAMS declarationset END_PARAMS BEGIN_LOCALS declarationset END_LOCALS BEGIN_BODY statementset END_BODY { 
	
	cout << "endfunc" << endl; 
	};
ident:
	IDENT { $$.val = string($1); };
declarationset:
	declaration SEMICOLON declarationset {} 
	| {};
declaration:
	identifierset COLON INTEGER {
		for (unsigned i = 0; i < $1.valSet->size(); i++)
		{
			if (findVariable($1.valSet->at(i))) //also needs to check if variable is same name as mini-l program itself
				yyerror("Variable is multiply-defined.");
			if (findKeyword($1.valSet->at(i)))
				yyerror("Declared a variable the same name as a reserved keyword.");
			variableTable->push_back($1.valSet->at(i));
			cout << ". " << $1.valSet->at(i) << endl;
			string temp = newtemp();
			symbolTable->push_back(temp);
			cout << ". " << temp << endl;
			cout << "= " << temp << ", " << $1.valSet->at(i) << endl;
		}
	} 
	| identifierset COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
		for (unsigned i = 0; i < $1.valSet->size(); i++)
		{
			if ($5 < 1)
				yyerror("Declared an array of size <= 0");
			if (findVariable($1.valSet->at(i))) //also needs to check if variable is same name as mini-l program itself
				yyerror("Variable is multiply-defined.");
			if (findKeyword($1.valSet->at(i)))
				yyerror("Declared a variable the same name as a reserved keyword.");
			variableTable->push_back($1.valSet->at(i));
			cout << ".[] " << $1.valSet->at(i) << ", " << $5 << endl;
			string temp = newtemp();
			symbolTable->push_back(temp);
			cout << ". " << temp << endl;
			cout << "= " << temp << ", " << $1.valSet->at(i) << endl;
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
			cout << "[]= " << symbolTable->at($1.place) << ", " << $1.index << ", " << symbolTable->at($3.place) << endl;
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
		if (labelTable->size() < 1)
			yyerror("continue statement not within a loop.");
		cout << ";= " << labelTable->at(labelTable->size() - 1) << endl;
		labelTable->pop_back();
	};
readstatement:
	READ varset {
		for (unsigned i = 0; i < $2.varSet->size(); i++)
		{
			if ($2.varSet->at(i).type == "ARRAY")
				cout << ".[]< " << symbolTable->at($2.varSet->at(i).place) << $2.varSet->at(i).index << endl;
			else
				cout << ".< " << symbolTable->at($2.varSet->at(i).place) << endl;
		}
	};
writestatement:
	WRITE varset {
		for (unsigned i = 0; i < $2.varSet->size(); i++)
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
		if (!findVariable($1.val))
			yyerror("Using a variable not previously declared.");
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1;
		$$.type = "VALUE";
		$$.index = "";
		cout << ". " << temp << endl;
	} 
	| ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
		if (!findVariable($1.val))
			yyerror("Using a variable not previously declared.");
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1;
		$$.type = "ARRAY";
		$$.index = symbolTable->at($3.place);
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
		if ($2.val == "!")
			cout << $2.val << temp << symbolTable->at($1.place) << ", " << symbolTable->at($3.place) << endl;
		else
			cout << $2.val << " " << temp << ", " << symbolTable->at($1.place) << ", " << symbolTable->at($3.place) << endl;
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
		cout << ". " << temp << endl;
		cout << $2.val << " " << temp << ", " << symbolTable->at($1.place) << ", " << symbolTable->at($1.place) << endl; 
	} 
	| TRUE {
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1; 
		cout << ". " << temp << endl;
		cout << "= " << temp << ", " << "true"; 
		}
	| FALSE {
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1; 
		cout << ". " << temp << endl;
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
		cout << ". " << temp << endl;
		cout << "= " << temp << ", " << $1.val << endl;
	 } 
	| NUMBER { 
		string temp = newtemp();
		symbolTable->push_back(temp);
		$$.place = symbolTable->size() - 1;	
		cout << ". " << temp << endl;
		cout << "= " << temp << ", " << $1 << endl;
	} 
	| ident L_PAREN R_PAREN { 
		if (!findFunction($1.val))
			yyerror("Calling a function not previously defined.");
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
		if (!findFunction($1.val))
			yyerror("Calling a function not previously defined.");
		for (unsigned i = 0; i < $3.exprSet->size(); i++)
		{
			cout << "param " << symbolTable->at($3.exprSet->at(i).place) << endl;
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
		cout << $2.val << " " << temp << ", " << symbolTable->at($1.place) << ", " << symbolTable->at($3.place) << endl;
	};
multordivormodoraddorsub:
	MULT {$$.val = string("*");} 
	| DIV {$$.val = string("/");} 	| MOD {$$.val = string("%");}
	| ADD {$$.val = string("+");}
	| SUB {$$.val = string("-");};

%%

//we need a string library to make this stuff easier
//and avoid using char array pointers as strings



int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         cout << "Syntax: " << argv[0] << " filename" << endl;
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}

void yyerror(const char *msg) {
   cout << "** Line " << currLine << ", position " << currPos << ": " << msg << endl;
}
