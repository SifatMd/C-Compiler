%option noyywrap

%x Charstate
%x Stringstate

%{

#include<bits/stdc++.h>
#include "1405022.cpp"
#include "y.tab.h"

 
using namespace std;
extern FILE *errorfile;
extern FILE *logg;


extern int line_count;
extern int errors;
int var=0;
char st[500]; 

extern YYSTYPE yylval;
extern SymbolTable *table;
void yyerror(string s); 



void ExtraTask()
{
	int i, j;

	for(i=0,j=0;i<yyleng;i++){
		if(yytext[i]==10) line_count++;
		else if(yytext[i]!=92 && yytext[i]!=10){
				st[j] = yytext[i];
				j++;	
		}
		if(yytext[i]==92){
			if(yytext[i+1]=='t'){
				i++;
				st[j++]=' ';
			}
			else if(yytext[i+1]=='n'){
				i++;
				st[j++]='\n';
			}
			else if(yytext[i+1]=='f'){
				i++;
				st[j++]='\f';
			}
			else if(yytext[i+1]=='b'){
				i++;
				st[j++]='\b';
			}
			else if(yytext[i+1]=='r'){
				i++;
				st[j++]='\r';
			}
			else if(yytext[i+1]=='a'){
				i++;
				st[j++]='\a';
			}
			else if(yytext[i+1]=='v'){
				i++;
				st[j++]='\v';
			}


		}
	}
}




int currline;
SymbolInfo *f;
//SymbolTable MainTable;

%}

Digit[0-9]
Alphabet[a-zA-Z]
Sign [+-]
Alphanumeric[a-zA-Z0-9]
Everything2[!-~]{+}[ ]{-}[/]
Quote[']

Float {Digit}*("."{Digit}+)?((E|e)[+-]?{Digit}+)?

%%

[ \t\v]+ 	{}
[\n] 			{line_count++;}

<Charstate>"\\0"			{/*fprintf(token,"<CHAR_CONST, \0 >"); fprintf(logg, "Line no: %d Token <CONST_CHAR> lexeme '\\0' found\n\n",line_count);f = MainTable._LookUp2(yytext, "CONST_CHAR"); 
											if(f==0){
													MainTable._Insert(yytext,"CONST_CHAR");
													MainTable.PrintAllScopeTables();
												}*/
				SymbolInfo *s = new SymbolInfo(yytext, "CONST_CHAR");				
				yylval.sym = s;
				return CONST_CHAR;}



<Charstate>"\\t" 		{/*fprintf(token,"<CHAR_CONST, \t>"); fprintf(logg, "Line no: %d Token <CONST_CHAR> lexeme '\\t' found\n				\n",line_count);f = MainTable._LookUp2(yytext, "CONST_CHAR"); 
						if(f==0){
							MainTable._Insert(yytext,"CONST_CHAR");
							MainTable.PrintAllScopeTables();
							}*/
				SymbolInfo *s = new SymbolInfo(yytext, "CONST_CHAR");				
				yylval.sym = s;
				return CONST_CHAR;}

<Charstate>"\\a" 		{/*fprintf(token,"<CHAR_CONST, \a>"); fprintf(logg, "Line no: %d Token <CONST_CHAR> lexeme '\\a' found\n\n",line_count);f = MainTable._LookUp2(yytext, "CONST_CHAR"); 
											if(f==0){
													MainTable._Insert(yytext,"CONST_CHAR");
													MainTable.PrintAllScopeTables();
												}*/
				SymbolInfo *s = new SymbolInfo(yytext, "CONST_CHAR");				
				yylval.sym = s;
				return CONST_CHAR;}
<Charstate>"\\f" 		{/*fprintf(token,"<CHAR_CONST, \f>"); fprintf(logg, "Line no: %d Token <CONST_CHAR> lexeme '\\f' found\n\n",line_count);f = MainTable._LookUp2(yytext, "CONST_CHAR"); 
											if(f==0){
													MainTable._Insert(yytext,"CONST_CHAR");
													MainTable.PrintAllScopeTables();
												}*/
				SymbolInfo *s = new SymbolInfo(yytext, "CONST_CHAR");				
				yylval.sym = s;return CONST_CHAR;}




<Charstate>"\\r" 		{/*fprintf(token,"<CHAR_CONST, \r>"); fprintf(logg, "Line no: %d Token <CONST_CHAR> lexeme '\\r' found\n\n",line_count);f = MainTable._LookUp2(yytext, "CONST_CHAR"); 
											if(f==0){
													MainTable._Insert(yytext,"CONST_CHAR");
													MainTable.PrintAllScopeTables();
												}*/
				SymbolInfo *s = new SymbolInfo(yytext, "CONST_CHAR");				
				yylval.sym = s;
				return CONST_CHAR;}



<Charstate>"\\b" 		{/*fprintf(token,"<CHAR_CONST, \b>"); fprintf(logg, "Line no: %d Token <CONST_CHAR> lexeme '\\b' found\n\n",line_count);f = MainTable._LookUp2(yytext, "CONST_CHAR"); 
											if(f==0){
													MainTable._Insert(yytext,"CONST_CHAR");
													MainTable.PrintAllScopeTables();
												}*/
				SymbolInfo *s = new SymbolInfo(yytext, "CONST_CHAR");				
				yylval.sym = s;return CONST_CHAR;}



<Charstate>"\\v" 		{/*fprintf(token,"<CHAR_CONST, \v>"); fprintf(logg, "Line no: %d Token <CONST_CHAR> lexeme '\\v' found\n\n",line_count);f = MainTable._LookUp2(yytext, "CONST_CHAR"); 
											if(f==0){
													MainTable._Insert(yytext,"CONST_CHAR");
													MainTable.PrintAllScopeTables();
												}*/											    							  SymbolInfo *s = new SymbolInfo(yytext, "CONST_CHAR");				
						yylval.sym = s;return CONST_CHAR;}




<Charstate>"\\\\" 		{/*fprintf(token,"<CHAR_CONST, \\>"); fprintf(logg, "Line no: %d Token <CONST_CHAR> lexeme '\\' found\n\n",line_count);f = MainTable._LookUp2(yytext, "CONST_CHAR"); 
											if(f==0){
													MainTable._Insert(yytext,"CONST_CHAR");
													MainTable.PrintAllScopeTables();
												}*/
						SymbolInfo *s = new SymbolInfo(yytext, "CONST_CHAR");				
						yylval.sym = s;return CONST_CHAR;}
<Charstate>"\\n" 		{/*fprintf(token,"<CHAR_CONST, \n>"); fprintf(logg, "Line no: %d Token <CONST_CHAR> lexeme '\\n' found\n\n",line_count);f = MainTable._LookUp2(yytext, "CONST_CHAR"); 
											if(f==0){
													MainTable._Insert(yytext,"CONST_CHAR");
													MainTable.PrintAllScopeTables();
												}*/
						SymbolInfo *s = new SymbolInfo(yytext, "CONST_CHAR");				
						yylval.sym = s;return CONST_CHAR;}

<Charstate>"\\\""		{/*fprintf(token,"<CHAR_CONST, \\\">"); fprintf(logg, "Line no: %d Token <CONST_CHAR> lexeme '\\\"' found\n\n",line_count);f = MainTable._LookUp2(yytext, "CONST_CHAR"); 
											if(f==0){
													MainTable._Insert(yytext,"CONST_CHAR");
													MainTable.PrintAllScopeTables();
												}*/
						SymbolInfo *s = new SymbolInfo(yytext, "CONST_CHAR");				
						yylval.sym = s;return CONST_CHAR;}


<Charstate>{Alphanumeric}        	{/*fprintf(token,"<CHAR_CONST, %s>", yytext); fprintf(logg, "Line no: %d Token <CONST_CHAR> lexeme '%s' found\n\n",line_count, yytext);f = MainTable._LookUp2(yytext, "CONST_CHAR"); 
											if(f==0){
													MainTable._Insert(yytext,"CONST_CHAR");
													MainTable.PrintAllScopeTables();
												}*/
						SymbolInfo *s = new SymbolInfo(yytext, "CONST_CHAR");				
						yylval.sym = s;return CONST_CHAR;}




<Charstate>{Alphanumeric}+[ \n]	{fprintf(errorfile,"Error at Line %d: Unterminated character '%s\n",line_count,yytext );fprintf(logg,"Error at Line %d: Unterminated character '%s\n",line_count,yytext );BEGIN INITIAL;line_count++;errors++;}

<Charstate>{Alphanumeric}({Alphanumeric}|[ ])+	{fprintf(errorfile, "Error at Line %d: Multi character constant error '%s'\n\n", line_count, yytext);fprintf(logg, "Error at Line %d: Multi character constant error '%s'\n\n", line_count, yytext);errors++;}
<Charstate>"\\"			{fprintf(errorfile, "Error at line %d: Unterminated character '\\'\n\n", line_count);fprintf(logg, "Error at line %d: Unterminated character '\\'\n\n", line_count);errors++;}

<Charstate>['] 			{BEGIN INITIAL;}
<Charstate>[\n] 		{line_count++;}
"\'\n"				{fprintf(errorfile, "Error at line %d: Unterminated Character '\n\n", line_count);fprintf(logg, "Error at line %d: Unterminated Character '\n\n", line_count);line_count++;errors++;}


"\'\'"				{fprintf(errorfile, "Error at line %d: Empty character constant error ''\n\n", line_count);fprintf(logg, "Error at line %d: Empty character constant error ''\n\n", line_count);errors++;}



['] 				{BEGIN Charstate;}





"if"		{return IF;} 
"for"		{return FOR;} 
"do"		{return DO;} 
"int"		{SymbolInfo *s = new SymbolInfo(yytext, "Datatype");yylval.sym = s;return INT;} 
"float"		{SymbolInfo *s = new SymbolInfo(yytext, "Datatype");yylval.sym = s;return FLOAT;} 
"void"		{SymbolInfo *s = new SymbolInfo(yytext, "Datatype");yylval.sym = s;return VOID;} 

"switch"	{return SWITCH;} 
"default"	{return DEFAULT;} 
"else"		{return ELSE;} 
"while"		{return WHILE;} 

"break"		{return BREAK;} 
"char"	        {return CHAR;} 
"double"	{return DOUBLE;} 
"return"	{return RETURN;} 
"case"		{return CASE;} 
"continue"	{return CONTINUE;}
"println"	{return PRINTLN;}











[+-]		{SymbolInfo *s = new SymbolInfo(yytext, "ADDOP");yylval.sym = s; return ADDOP;} 
[*/%]{1} 		{SymbolInfo *s = new SymbolInfo(yytext, "MULOP");yylval.sym = s; return MULOP;} 
[+]{2}   {return INCOP;} 
[-]{2}	 {return DECOP;}
"<="|">="|"=="|"!="		{SymbolInfo *s = new SymbolInfo(yytext,"RELOP"); yylval.sym = s;  return RELOP;} 

[<|>]{1} 	{SymbolInfo *s = new SymbolInfo(yytext,"RELOP"); yylval.sym = s; return RELOP;} 

[=]{1}		{return ASSIGNOP;} 

[&&]{2}		{SymbolInfo *s = new SymbolInfo(yytext,"LOGICOP"); yylval.sym = s; return LOGICOP;} 
"||"		{SymbolInfo *s = new SymbolInfo(yytext,"LOGICOP"); yylval.sym = s; return LOGICOP;} 

[!]		{return NOT;} 
[(]		{return LPAREN;} 
[)]		{return RPAREN;} 
[{]		{return LCURL;} 
[}]		{return RCURL;} 

"["		{return LTHIRD;}
"]"		{return RTHIRD;}  
";"		{return SEMICOLON;} 
"," 		{return COMMA;} 
"printf"	{return PRINTLN;}

<Stringstate>["] {BEGIN INITIAL;}

["] 		 {BEGIN Stringstate;}


<Stringstate>(({Alphanumeric}*[ ]*)*(([\\][\n])?|[\\]?))*        { currline=line_count;
									for(i=0;i<yyleng;i++){
										if(yytext[i]==10) line_count++;		
									}
									fprintf(errorfile, "Error at Line %d:Unterminated String \"%s\n\n",currline, yytext );fprintf(logg, "Error at Line %d:Unterminated String \"%s\n\n",currline, yytext );BEGIN INITIAL; errors++;} 

<Stringstate>(({Alphanumeric}*[ ]*)*(([\\][\n])?|[\\]?))*"\""         { currline = line_count;    
						        ExtraTask();  /* fprintf(token,"<STRING, \"%s> ", st); 
							fprintf(logg, "Line no: %d Token <STRING> lexeme \"%s found\n\n", currline, 								yytext);*/BEGIN INITIAL;} 



<Stringstate>({Alphanumeric}*[ ]*)*[\n]			{fprintf(errorfile, "Error at Line %d: Unterminated string \"%s\n", line_count, 								yytext);fprintf(logg, "Error at Line %d: Unterminated string \"%s\n", line_count, 								yytext);
							for(i=0;i<yyleng;i++){
								if(yytext[i]==10) line_count++;
							}
							BEGIN INITIAL;errors++;}



{Digit}+	{/*fprintf(token,"<CONST_INT, %s> ",yytext); fprintf(logg, "Line no: %d Token <CONST_INT> lexeme %s was found\n\n", line_count,yytext);f = MainTable._LookUp2(yytext, "CONST_INT"); 
											if(f==0){
													MainTable._Insert(yytext,"CONST_INT");
													MainTable.PrintAllScopeTables();
												}*/
							SymbolInfo *s = new SymbolInfo(yytext, "CONST_INT");
							s->setInt(atoi(yytext));
							s->setDatatype("int");				
							yylval.sym = s;
							return CONST_INT;}


{Float}		{/*fprintf(token,"<CONST_FLOAT,%s> ",yytext); fprintf(logg, "Line no: %d Token <CONST_FLOAT> lexeme %s was found\n\n", line_count,yytext);f = MainTable._LookUp2(yytext, "CONST_FLOAT"); 
											if(f==0){
													MainTable._Insert(yytext,"CONST_FLOAT");
													MainTable.PrintAllScopeTables();
												}*/							SymbolInfo *s = new SymbolInfo(yytext, "CONST_FLOAT");	
							s->setFloat(atof(yytext));
							s->setDatatype("float");			
							yylval.sym = s;return CONST_FLOAT;}



({Digit}*"."*)*  			{fprintf(errorfile, "Error at Line %d: Too many decimal points %s\n\n", line_count, yytext);errors++; fprintf(logg, "Error at Line %d: Too many decimal points %s\n\n", line_count, yytext);errors++;}

{Digit}+("."{Digit}+)?((E|e)[+-]?({Digit}*"."?)*)?	{fprintf(errorfile, "Error at Line %d: Ill formed number %s\n\n", line_count, yytext);fprintf(logg, "Error at Line %d: Ill formed number %s\n\n", line_count, yytext);errors++;}



({Alphabet}|[_])+({Alphanumeric}*[_]*)*    	{/*fprintf(token,"<ID,%s> ", yytext); fprintf(logg, "Line no: %d Token <ID> lexeme %s found\n\n", line_count, yytext);f = MainTable._LookUp2(yytext, "ID"); 
											if(f==0){
													MainTable._Insert(yytext,"ID");
													MainTable.PrintAllScopeTables();
												}*/
						SymbolInfo *s = new SymbolInfo(yytext, "ID");				
						yylval.sym = s;
											return ID;}

{Digit}+({Alphanumeric}*[_]*)*			{fprintf(errorfile, "Error at Line %d: Invalid prefix on ID or invalid suffix on Number %s\n\n", line_count, yytext);fprintf(logg, "Error at Line %d: Invalid prefix on ID or invalid suffix on Number %s\n\n", line_count, yytext);errors++;}



"/*"({Everything2}*[\n]*)*		{fprintf(errorfile, "Error at line %d: Unterminated Comment %s\n\n", line_count, yytext);fprintf(logg, "Error at line %d: Unterminated Comment %s\n\n", line_count, yytext);for(i=0;i<yyleng;i++){
						if(yytext[i]==10) line_count++;					
					}errors++;}



"/*"({Everything2}*[\n]*)*"*/"		{/*fprintf(logg, "Line no: %d Token <COMMENT> lexeme %s found\n\n", line_count, yytext);*/
					for(i=0;i<yyleng;i++){
						if(yytext[i]==10) line_count++;					
					}}

"//"({Everything2}*(([\\][\n])?|[\\]?))*			{/*fprintf(logg, "Line no: %d Token <COMMENT> lexeme %s found\n\n", line_count, 									yytext);*/for(i=0;i<yyleng;i++){
										if(yytext[i]==10) line_count++;					
								}}

<<EOF>> 		{/*MainTable.PrintAllScopeTables();*/return 0;}
 		
<Charstate>. {fprintf(errorfile, "Error at line %d: Unrecognized character %s\n\n", line_count, yytext);fprintf(logg, "Error at line %d: Unrecognized character %s\n\n", line_count, yytext);errors++;}

. 	{printf("Mysterious character found\n");fprintf(errorfile, "Error at line %d: Unrecognized character %s\n\n", line_count, yytext);fprintf(logg, "Error at line %d: Unrecognized character %s\n\n", line_count, yytext);errors++;}

%%


/*int main(int argc, char* argv[]){
	if(argc!=2){
		printf("Please provide input file and try again\n");
		return 0;	
	}

	FILE *fin = fopen(argv[1], "r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	ScopeTable table(20);
	table.setId(1);
	MainTable.CreateScope(&table);

	token = fopen("token.txt","w");
	logg = fopen("log.txt","w");
	
	yyin = fin;
	yylex();

	
	fprintf(logg, "Total Lines: %d\n", line_count-1);
	fprintf(logg, "Total errors: %d\n", errors);


	fclose(yyin);
	fclose(token);
	fclose(logg);	
	return 0;
}*/










