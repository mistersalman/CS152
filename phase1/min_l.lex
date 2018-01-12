   /* cs152-winter18 */
   /* A flex scanner specification for the calculator language */
   /* Written by Sal n Ryan */

%{   
   int currLine = 1, currPos = 1;
%}

DIGIT    [0-9]
   
%%

"-"            {printf("SUB\n"); currPos += yyleng; }
"+"            {printf("PLUS\n"); currPos += yyleng; }
"*"            {printf("MULT\n"); currPos += yyleng; }
"/"            {printf("DIV\n"); currPos += yyleng; }
"%"            {printf("MOD\n"); currPos += yyleng; }
">"            {printf("GT\n"); currPos += yyleng; }
"<"            {printf("LT\n"); currPos += yyleng; }
">="           {printf("GTE\n"); currPos += yyleng; }
"<="           {printf("LTE\n"); currPos += yyleng; }
"=="           {printf("EQUAL\n"); currPos += yyleng; }
"<>"           {printf("NOT EQUAL\n"); currPos += yyleng; }
"("            {printf("L_PAREN\n"); currPos += yyleng; }
")"            {printf("R_PAREN\n"); currPos += yyleng; }
":="           {printf("ASSIGN\n"); currPos += yyLeng; }
":"           {printf("COLON\n"); currPos += yyLeng; }
";"           {printf("SEMI-COLON\n"); currPos += yyLeng; }
"not"          {printf("LOGICAL NOT\n"); currPos += yyLeng; }
"and"          {printf("LOGICAL AND\n"); currPos += yyLeng; }
"or"          {printf("LOGICAL OR\n"); currPos += yyLeng; }
"["            {printf("L_SQUARE_BRACKET\n"); currPos += yyleng; }
"]"            {printf("R_SQUARE_BRACKET\n"); currPos += yyleng; }

(\.{DIGIT}+)|({DIGIT}+(\.{DIGIT}*)?([eE][+-]?[0-9]+)?)   {printf("NUMBER %s\n", yytext); currPos += yyleng;}

[ \t]+         {/* ignore spaces */ currPos += yyleng;}

"\n"           {currLine++; currPos = 1;}

.              {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

%%

int main(int argc, char ** argv)
{
   if(argc >= 2)
   {
      yyin = fopen(argv[1], "r");
      if(yyin == NULL)
      {
         yyin = stdin;
      }
   }
   else
   {
      yyin = stdin;
   }
   
   yylex();
}

