
/* definitions */

%{
#include<stdio.h>
#include"tokendef.h"

int scancol = 1;
int yycol = 1;
int scanlineno = 1;

char* yyerror;

void updateCol(); 
void countLines(); 
int processString(); 
%}

newline        \n
whitespace     [ \t]+
digit          [0-9]
integer        0|[1-9]{digit}*
character      \'([^\'\|\\[\\nt\'])\'
integerlead0   0{digit}+

/* String can contain any characters between the double quotes other than a newline or
// unescaped doublequotes.
*/
stringtext [\\].|[^\"\n]  
string \"{stringtext}*\"

/* multiline string has \n somewhere in the middle */
untermstring \"{stringtext}* 

/* If the end quote is found, one of the two regexes above will be matched. Otherwise,
// the string is unterminated.
*/
multlnstring \"{stringtext}*{newline}+({stringtext}|{newline})*\" 

commenttext [^*]|[*][^/] 
comment      \/\/.*
multlncomment \/\*({newline}|{commenttext})*\*\/
untermcomment \/\*({newline}|{commenttext})*
identifier      [a-zA-z][a-zA-Z0-9]*
illidentifier   [0-9]+[a-zA-Z][a-zA-Z0-9]*    
yylineno = 1;

%%

 /* rules */

 /* Keywords */;

"if"     {updateCol(); countLines(); return KWD_IF;}
"else"   {updateCol(); countLines(); return KWD_ELSE;}
"while"  {updateCol(); countLines(); return KWD_WHILE;}
"int"    {updateCol(); countLines(); return KWD_INT;}
"string" {updateCol(); countLines(); return KWD_STRING;}
"char"   {updateCol(); countLines(); return KWD_CHAR;}
"return" {updateCol(); countLines(); return KWD_RETURN;}
"void"   {updateCol(); countLines(); return KWD_VOID;}




 /* Operators */;

"+"   {updateCol(); countLines(); return OPER_ADD;}
"-"   {updateCol(); countLines(); return OPER_SUB;}
"*"   {updateCol(); countLines(); return OPER_MUL;}
"/"    {updateCol(); countLines(); return OPER_DIV;}
"%"    {updateCol(); countLines(); return OPER_MODULUS;}
"<"    {updateCol(); countLines(); return OPER_LT;}
">"    {updateCol(); countLines(); return OPER_GT;}
"<="   {updateCol(); countLines(); return OPER_LTE;}
">="   {updateCol(); countLines(); return OPER_GTE;}
"=="   {updateCol(); countLines(); return OPER_EQ;}
"!="   {updateCol(); countLines(); return OPER_NEQ;}
"="    {updateCol(); countLines(); return OPER_ASGN;}
"[" {updateCol(); countLines(); return LSQ_BRKT;}
"]"   {updateCol(); countLines(); return RSQ_BRKT;}
"{"   {updateCol(); countLines(); return LCRLY_BRKT;}
"}"   {updateCol(); countLines(); return RCRLY_BRKT;}
"("   {updateCol(); countLines(); return LPAREN;}
")"   {updateCol(); countLines(); return RPAREN;}
","    {updateCol(); countLines(); return COMMA;}
";"    {updateCol(); countLines(); return SEMICLN;}
"@"    {updateCol(); countLines(); return OPER_AT;}
"++" {updateCol(); countLines(); return OPER_INCREMENT;}
"--"   {updateCol(); countLines(); return OPER_DECREMENT;}
"&&"   {updateCol(); countLines(); return LOGICAL_AND;}
"||" {updateCol(); countLines(); return LOGICAL_OR;}
"!"    {updateCol(); countLines(); return LOGICAL_NOT;}

 

 /* Identifiers */;
{identifier}    {updateCol(); countLines(); return ID;}
{illidentifier} {updateCol(); countLines(); yyerror = "Illegal token"; return ERROR;}


 /* Constants */;
{integer}       {updateCol(); countLines(); return INTCONST;}
{integerlead0}  {updateCol(); countLines(); yyerror = "Illegal token"; return ERROR;}
{character}     {updateCol(); countLines(); return CHARCONST; }
{string}        {countLines(); return processString();}
{untermstring}  {updateCol(); countLines(); yyerror = "Unterminated string"; return ERROR;}
{multlnstring}  {updateCol(); countLines(); yyerror = "String spans multiple lines"; return ERROR;} // Catching a multi-line string and generating an error.

 /* Comments */;
{comment}       {updateCol(); countLines();}
{untermcomment} {updateCol(); countLines(); yyerror = "unterminated comment"; return ERROR;}
{multlncomment} {updateCol(); countLines();}

 /* Other */;
{newline}       {yycol = 1; scancol = 1; yylineno++; scanlineno = yylineno;   /* Skip new line */}
{whitespace}    {updateCol(); /* Skip whitespace */}
.               {return ERROR;}

%%

/* user routines */

void updateCol(){
	//Keep track of column number
	 yycol = scancol;
         scancol += yyleng;
}

void countLines(){
	//Count the number of lines
        yylineno = scanlineno;

}


int processString()
{
	int current_length = 0;
        int result = 0;
	int length =  yyleng;
	char buffer[length];
	int i = 0;
	int j = 0;
	while (i < length) {

		if (yytext[i] == '\\') {
			if(yytext[i+1] == 't'){
				buffer[j] = '\t';
				i = i + 2;
				j += 1;
			}
			else if (yytext[i+1] == 'n') {
				buffer[j] = '\n';
				i += 2;
				j += 1;
			} 
			else if (yytext[i+1] == '\\') {
				buffer[j] = '\\';
			        i += 2;
				j += 1;
			}
			else if (yytext[i+1] == '"') {
				buffer[j] = '"';
				i += 2;
				j += 1;
			}
			else {
				yyerror = "Unrecognized escape character in String";
				result = 1;
                                current_length = i+1;
				goto end;
			}
		}
		else {
			buffer[j] = yytext[i];
			i++;
			j++;
		}


	}
	end: strcpy(yytext, buffer);
        if (result == 1){
                scancol += current_length;
                yyleng = length - current_length;
                updateCol();
                return ERROR;
        }
        else {
                yyleng = length;
                updateCol();
                return STRCONST;
        }


}



