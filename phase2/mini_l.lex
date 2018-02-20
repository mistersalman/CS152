   /* cs152-winter18 */
   /* A flex scanner specification for the calculator language */
   /* Written by Sal n Ryan */

%{   
   #include "y.tab.h"
   int currLine = 1, currPos = 1;
%}

DIGIT    [0-9]
ID    [A-Za-z]([A-Za-z0-9_]*[A-Za-z0-9])* 
   
%%

"-"            {currPos += yyleng; return SUB;}
"+"            {currPos += yyleng; return ADD;}
"*"            {currPos += yyleng; return MULT;}
"/"            {currPos += yyleng; return DIV;}
"%"            {currPos += yyleng; return MOD;}
">"            {currPos += yyleng; return GT;}
"<"            {currPos += yyleng; return LT;}
">="           {currPos += yyleng; return GTE;}
"<="           {currPos += yyleng; return LTE;}
"=="           {currPos += yyleng; return EQ;}
"<>"           {currPos += yyleng; return NEQ;}
"("            {currPos += yyleng; return L_PAREN;}
")"            {currPos += yyleng; return R_PAREN;}
":="           {currPos += yyleng; return ASSIGN;}
":"            {currPos += yyleng; return COLON;}
";"            {currPos += yyleng; return SEMICOLON;}
"not"          {currPos += yyleng; return NOT;}
"and"          {currPos += yyleng; return AND;}
"or"           {currPos += yyleng; return OR;}
"["            {currPos += yyleng; return L_SQUARE_BRACKET;}
"]"            {currPos += yyleng; return R_SQUARE_BRACKET;}
","            {currPos += yyleng; return COMMA;}
"beginparams"  {currPos += yyleng; return BEGIN_PARAMS;}
"endparams"    {currPos += yyleng; return END_PARAMS;}
"beginlocals"  {currPos += yyleng; return BEGIN_LOCALS;}
"endlocals"    {currPos += yyleng; return END_LOCALS;}
"beginbody"    {currPos += yyleng; return BEGIN_BODY;}
"endbody"      {currPos += yyleng; return END_BODY;}
"function"     {currPos += yyleng; return FUNCTION;}
"integer"	   {currPos += yyleng; return INTEGER;}
"array"	      {currPos += yyleng; return ARRAY;}
"of"	         {currPos += yyleng; return OF;}
"if"	         {currPos += yyleng; return IF;}
"then"	      {currPos += yyleng; return THEN;}
"endif"	      {currPos += yyleng; return ENDIF;}
"else"	      {currPos += yyleng; return ELSE;}
"while"	      {currPos += yyleng; return WHILE;}
"do"	         {currPos += yyleng; return DO;}
"foreach"	   {currPos += yyleng; return FOREACH;}
"in"	         {currPos += yyleng; return IN;}
"beginloop"	   {currPos += yyleng; return BEGINLOOP;}
"endloop"	   {currPos += yyleng; return ENDLOOP;}
"continue"	   {currPos += yyleng; return CONTINUE;}
"read"	      {currPos += yyleng; return READ;}
"write"	      {currPos += yyleng; return WRITE;}
"true"	      {currPos += yyleng; return TRUE;}
"false"	      {currPos += yyleng; return FALSE;}
"return"	      {currPos += yyleng; return RETURN;}

(\.{DIGIT}+)|({DIGIT}+(\.{DIGIT}*)?([eE][+-]?[0-9]+)?)   {currPos += yyleng; yylval.dval = atof(yytext); return number;}

{ID}    {currPos += yyleng; yylval.cval = yytext; return IDENT;}

{ID}[_]+  {printf("Error at line %d, column %d: IDENT cannot end with underscore \"%s\n", currLine, currPos, yytext); exit(0);}

[0-9_]+{ID}*  {printf("Error at line %d, column %d: IDENT cannot start with number or underscore. \"%s\n", currLine, currPos, yytext); exit(0);}

[ \t]+         {/* ignore spaces */ currPos += yyleng;}

"\n"           {currLine++; currPos = 1;}

[#][#].*[\n]     {currLine++; currPos = 1;}

.              {printf("Error at line %d, column %d: unrecognized symbol \"%s\n", currLine, currPos, yytext); exit(0);}

%%

