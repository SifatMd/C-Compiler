%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<string>
#include "1405022.cpp"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

SymbolTable *table;
 

FILE *logg;
FILE *errorfile; 
FILE *symtabfile;

int line_count=1;
int errors=0;
int globalid;
int p, q, r, i, j;
string valuetype;
string valuetypeofFunction;
int arrsize=0;
bool markerForArrayInsert=false;




SymbolInfo *extra;

void yyerror(string s)
{
	fprintf(errorfile, "Error at line %d: %s\n\n", line_count, s.c_str());
	fprintf(logg, "Error at line %d: %s\n\n", line_count, s.c_str());
	 
	//cout<<s<<endl;
}

void warningmsg(string s){
	//loggs<<s<<endl;
	fprintf(logg, "Warning msg at line %d: %s\n\n", line_count, s.c_str());	
	cout<<s<<endl;
}



SymbolInfo* do_addition(SymbolInfo *s1, SymbolInfo *s2, SymbolInfo *s3){
	SymbolInfo *s = new SymbolInfo();
	if(s1->getDatatype()=="float" || s3->getDatatype()=="float") s->setDatatype("float");
	else s->setDatatype("int");
	string sign = s2->getName();
	int a, b;float x, y;

	a=s1->getInt();b=s3->getInt();
	x=s1->getFloat();y=s3->getFloat();
	 
	if(sign=="+"){
		if(s1->getDatatype()=="float" && s3->getDatatype()=="float") s->setFloat(x+y);
		else if(s1->getDatatype()=="float" && s3->getDatatype()=="int")	s->setFloat(x+b);
		else if(s1->getDatatype()=="int" && s3->getDatatype()=="float") s->setFloat(a+y);
		else {s->setInt(a+b);
			/*printf("val: %d %d\n",a, b);*/}
	}
	else if(sign=="-"){
		if(s1->getDatatype()=="float" && s3->getDatatype()=="float") s->setFloat(x-y);
		else if(s1->getDatatype()=="float" && s3->getDatatype()=="int")	s->setFloat(x-b);
		else if(s1->getDatatype()=="int" && s3->getDatatype()=="float") s->setFloat(a-y);
		else s->setInt(a-b);
	}
	return s;
}



SymbolInfo* do_multiplication(SymbolInfo *s1, SymbolInfo *s2, SymbolInfo *s3){
	SymbolInfo *s = new SymbolInfo();
	string sign = s2->getName();
	if(sign=="%"){
		if(s1->getDatatype()=="float" || s3->getDatatype()=="float"){
			yyerror("NonInteger operand on modulus operator");
			errors++;
		}
		else {
		s->setDatatype("int");
		//printf("in handle_mulop %d %d\n",s1->getInt(), s3->getInt() );
		if(s3->getInt()==0) {yyerror("Invalid Operation: Modulus operator by 0");errors++;}
		else s->setInt((s1->getInt())%(s3->getInt()));
		//printf("in handle_mulop %d %d %d\n",s1->getInt(), s3->getInt(), s->getInt() );
			 }
		
	}
	else if(sign=="*" || sign=="/"){
		if(s1->getDatatype() == "float" || s3->getDatatype() == "float") s->setDatatype("float");	
		else s->setDatatype("int");
		if(sign == "*")
		{
		
			if(s1->getDatatype() == "int" && s3->getDatatype() == "int") s->setInt(s1->getInt() * s3->getInt());
			else if(s1->getDatatype() == "int" && s3->getDatatype() == "float") s->setFloat(s1->getInt() * s3->getFloat());
			else if(s1->getDatatype() == "float" && s3->getDatatype() == "int") s->setFloat(s1->getFloat() * s3->getInt());
			else if(s1->getDatatype() == "float" && s3->getDatatype() == "float") s->setFloat(s1->getFloat() * s3->getFloat());
		}
		
		else if(sign=="/")
		{
			if(s1->getDatatype() == "int" && s3->getDatatype() == "int") {if(s3->getInt()==0){yyerror("Invalid Operation: Division by zero");errors++;} else s->setInt(s1->getInt() / s3->getInt());}


			else if(s1->getDatatype() == "int" && s3->getDatatype() == "float") {if(s3->getFloat()==0){yyerror("Invalid Operation: Division by zero");errors++;} else s->setFloat(s1->getInt() / s3->getFloat());}


			else if(s1->getDatatype() == "float" && s3->getDatatype() == "int") {if(s3->getInt()==0){yyerror("Invalid Operation: Division by zero");errors++;} else s->setFloat(s1->getFloat() / s3->getInt());}


			else if(s1->getDatatype() == "float" && s3->getDatatype() == "float") {if(s3->getFloat()==0){yyerror("Invalid Operation: Division by zero");errors++;} else s->setFloat(s1->getFloat() / s3->getFloat());}
		}	
	}
	return s;
	
}


SymbolInfo* insertInTable(SymbolInfo *s1){
	
	string x = s1->getName();
	if(table->_LookUpThisTable(x)!=0) {
		yyerror("Multiple Declaration of "+ s1->getName());
		errors++;
		return NULL;	
	}
	else{
		s1->setDatatype(valuetype);
		if(valuetype=="int") s1->setInt(-1);
		else if(valuetype=="float") s1->setFloat(-1.0);
		//printf("%s %s %s\n", s1->getName().c_str(), s1->getType().c_str(), s1->getDatatype().c_str()); 
		return table->_Insert2(s1);
	}
}


SymbolInfo* handle_assignment(SymbolInfo *s1, SymbolInfo *s3){ 	
	 

	SymbolInfo *s2=table->_LookUp(s1->getName());
	if(s2==0){yyerror("Variable not declared");errors++;return NULL;}
	else{
	//printf("in handle_assign %d\n", s3->getInt());
	//if(s3->getType()=="ID") s3 = table->_LookUp(s3->getName());
	if(s2->isArray==true){
		//printf("handleassign:entered in array block\n");
		if(s1->posInArray<0 && s1->posInArray>=s1->sizeOfArray){yyerror("Arraysize Out Of Bounds"); errors++;return NULL;} 

		if(s1->getDatatype()!=s3->getDatatype()) {yyerror("Type mismatch");errors++;}

		if(s3->getDatatype()=="float" && s1->getDatatype()=="int") {
			warningmsg("Casting of non-float into float may cause data loss");
		}

		if(markerForArrayInsert==true){
			if(s1->getDatatype()=="int" && s3->getDatatype()=="int") {s2->setIntInArray(s3->getInt(),s1->posInArray);}
			else if(s1->getDatatype()=="int" && s3->getDatatype()=="float") s2->setIntInArray(s3->getFloat(), s1->posInArray);
			else if(s1->getDatatype()=="float" && s3->getDatatype()=="int") s2->setFloatInArray(s3->getInt(), s1->posInArray);
			else if(s1->getDatatype()=="float" && s3->getDatatype()=="float") s2->setFloatInArray(s3->getFloat(), s1->posInArray);
		}  
		markerForArrayInsert=false;
		return s2;	
	}
	else{
		if(s2->getDatatype()!=s3->getDatatype()) {yyerror("Type mismatch");/*printf("handle_assign h%s l%s\n",s1->getDatatype().c_str(), s3->getDatatype().c_str());*/ errors++;}

		if(s3->getDatatype()=="float" && s2->getDatatype()=="int") {
			warningmsg("Casting of non-float into float may cause data loss");
		}
		if(s2->getDatatype()=="int" && s3->getDatatype()=="int") {s2->setInt(s3->getInt()); }
		else if(s2->getDatatype()=="int" && s3->getDatatype()=="float") s2->setInt(s3->getFloat());
		else if(s2->getDatatype()=="float" && s3->getDatatype()=="int") s2->setFloat(s3->getInt());
		else if(s2->getDatatype()=="float" && s3->getDatatype()=="float") s2->setFloat(s3->getFloat()); 
		return s2;
	}
	}
	
}








SymbolInfo* handle_logic_operation(SymbolInfo *s1, SymbolInfo *s2, SymbolInfo *s3){
	SymbolInfo *s=new SymbolInfo();
	s->setDatatype("int");
	string sign = s2->getName();
	string a = s1->getDatatype();
	string b = s3->getDatatype();
	
	int val;
	if(a=="int" && b=="int"){
		int x=s1->getInt();
		int y=s3->getInt();
		if(sign=="&&") val =x&&y;
		else if(sign=="||") val = x||y; 
	}
	else if(a=="int" && b=="float"){
		int x=s1->getInt();
		int y=s3->getFloat();
		if(sign=="&&") val =x&&y;
		else if(sign=="||") val = x||y; 
	}
	else if(a=="float" && b=="int"){
		int x=s1->getFloat();
		int y=s3->getInt();
		if(sign=="&&") val =x&&y;
		else if(sign=="||") val = x||y; 
	}
	else if(a=="float" && b=="float"){
		int x=s1->getFloat();
		int y=s3->getFloat();
		if(sign=="&&") val =x&&y;
		else if(sign=="||") val = x||y; 
	}
	s->setInt(val);
	return s;

}



SymbolInfo* handle_relop_operation(SymbolInfo *s1, SymbolInfo *s2, SymbolInfo *s3){
	SymbolInfo *s=new SymbolInfo();
	s->setDatatype("int");
	string sign = s2->getName();
	string a = s1->getDatatype();
	string b = s3->getDatatype();
	
	int val;
	if(a=="int" && b=="int"){
		int x=s1->getInt();
		int y=s3->getInt();
		if(sign=="<") val =x<y;
		else if(sign==">") val = x>y; 
		else if(sign==">=") val = x>=y;
		else if(sign=="<=") val = x<=y;
		else if(sign=="==") val = x==y;
		else if(sign=="!=") val = x!=y;
	}
	else if(a=="int" && b=="float"){
		int x=s1->getInt();
		int y=s3->getFloat();
		if(sign=="<") val =x<y;
		else if(sign==">") val = x>y; 
		else if(sign==">=") val = x>=y;
		else if(sign=="<=") val = x<=y;
		else if(sign=="==") val = x==y;
		else if(sign=="!=") val = x!=y;
	}
	else if(a=="float" && b=="int"){
		int x=s1->getFloat();
		int y=s3->getInt();
		if(sign=="<") val =x<y;
		else if(sign==">") val = x>y; 
		else if(sign==">=") val = x>=y;
		else if(sign=="<=") val = x<=y;
		else if(sign=="==") val = x==y;
		else if(sign=="!=") val = x!=y;
	}
	else if(a=="float" && b=="float"){
		int x=s1->getFloat();
		int y=s3->getFloat();
		if(sign=="<") val =x<y;
		else if(sign==">") val = x>y; 
		else if(sign==">=") val = x>=y;
		else if(sign=="<=") val = x<=y;
		else if(sign=="==") val = x==y;
		else if(sign=="!=") val = x!=y;
	}
	s->setInt(val);
	return s;
}





SymbolInfo* getIDfromTable(SymbolInfo *s1){
	//SymbolInfo *temp = new SymbolInfo();
	SymbolInfo *temp2 = table->_LookUp(s1->getName());
	if(temp2!=0) {
		//printf("getIDFromTable: %s %s %s\n", temp2->getName().c_str() , temp2->getDatatype().c_str(), temp2->getType().c_str());
		return temp2;
	}
	else{
		yyerror(s1->getName()+ " was not declared in this scope");
		errors++;
		return NULL;
	}	
}

 





void create_array(SymbolInfo *arayname, SymbolInfo* size){
	SymbolInfo *temp = table->_LookUpThisTable(arayname->getName());
	
	//printf("Inserted in createarray%s %s\n", arayname->getName().c_str(), arayname->getType().c_str());
	if(temp!=0){
		yyerror("Multiple Declaration of "+ arayname->getName());
		errors++;
		return ;
	}
	else{
		if(size->getDatatype()!="int"){
			yyerror("Array index must be of 'int' type");
			errors++;
			return;
		}
		else if(size->getInt()<1){
			yyerror("Invalid Array Size");
			errors++;
			return;
		}

		SymbolInfo *s = new SymbolInfo(arayname->getName(), "ID", size->getInt()); 
		s->setDatatype(valuetype);
		s->isArray=true;
		s->CreateArray(); 
		table->_Insert2(s);

		//printf("Inserted %s %s\n", s->getName().c_str(), s->getDatatype().c_str());
		//return s;
	}

}

 




SymbolInfo* newgetIDfromTable(SymbolInfo *s1){
	SymbolInfo *s=new SymbolInfo();
	s->setName(s1->getName());
	s->setDatatype(s1->getDatatype());
	s->setType(s1->getType());
	
	if(s1->getDatatype()=="int"){
			s->setInt(s1->getInt());
			}
	else if(s1->getDatatype()=="float"){
				s->setFloat(s1->getFloat());
			}
	//printf("bla: %s %s %d\n", s->getName().c_str(), s->getDatatype().c_str(), s->getInt());	
	//printf("bla: %s %s %d\n", s1->getName().c_str(), s1->getDatatype().c_str(), s1->getInt());	
	return s;
	
}

SymbolInfo* newgetintIDfromTable(SymbolInfo *s1, SymbolInfo *size){
	SymbolInfo *s=new SymbolInfo(s1->getName(),s1->getType(), s1->getDatatype());
	s->posInArray=size->getInt();
	s->isArray=true;
	s->sizeOfArray=s1->sizeOfArray;
	
	return s;
}




SymbolInfo* getValue(SymbolInfo *s1){
	//printf("In getvalue %s\n", s1->getDatatype().c_str());
	SymbolInfo *s=new SymbolInfo(s1->getName(),s1->getType(),s1->getDatatype());
	if(s1->isArray==true){
			SymbolInfo *temp = table->_LookUp(s1->getName());
		if(s1->getDatatype()=="int") {
						s->setInt(temp->getArrayInt(s1->posInArray));
					}
		else if(s1->getDatatype()=="float"){
						s->setFloat(temp->getArrayFloat(s1->posInArray));
					}
		
	}
	else{
		if(s1->getDatatype()=="int") {
						s->setInt(s1->getInt());
						
					}
		else if(s1->getDatatype()=="float"){
						s->setFloat(s1->getFloat());
					}

	}
	return s;
	
}


void Paramfunction(A *s1, A *s2){
	for(int i=0;i<s2->size;i++){
		s1->Datatypes.push_back(s2->Datatypes[i]);
		s1->Variables.push_back(s2->Variables[i]);
	}

}




SymbolInfo* newTask1(SymbolInfo *s1,SymbolInfo *s2, A *s4){
	//printf("what");
	SymbolInfo *s=new SymbolInfo(s2->getName(), s2->getType());
	s->isFunction = true;
	s->returnType=s1->getName();
	//printf("in new task1 valuetype %s %s\n", s1->getName().c_str(), s2->getName().c_str());
	s2->isFunction = true;
	s2->returnType=s1->getName();
	//printf("This is too\n");
	
		table->_InsertInGlobalScope(s);
		table->EnterScope(10);
		//printf("This is too\n");	
	
		for(int i=0;i<s4->size;i++){
			//printf(s4->Datatypes[i].c_str());
			s->Paramtypes.push_back(s4->Datatypes[i]);
		
		}
		s->noOfParameters = s4->size;
	
		for(int i=0;i<s4->size;i++){
			SymbolInfo *ss = new SymbolInfo();
			string a = s4->Datatypes[i];
			string b = s4->Variables[i];
			//printf("b: %d\n", b.size());
			if(b.size()==0){
				int j=i+1;
				fprintf(errorfile, "Error at line %d: %dth parameter's name not given in function definition %s\n\n", line_count, j, s2->getName().c_str());
				fprintf(logg, "Error at line %d: %dth parameter's name not given in function definition %s\n\n", line_count, j, s2->getName().c_str());
				errors++;			
			}			
			
			ss->setName(b);
			ss->setDatatype(a);
			ss->setType("ID");
			if(a=="int") ss->setInt(-1);
			else if(a=="float") ss->setFloat(-1.0);
			table->_Insert2(ss);
		}
	
	
	return s;

}




SymbolInfo* newTask2(SymbolInfo *s1,SymbolInfo *s2, A *s4){ 
	SymbolInfo *temp=table->_LookUpGlobalTable(s2->getName());
	if(temp==0){
		SymbolInfo *s=new SymbolInfo(s2->getName(), s2->getType());
		s->isFunction = true;
		s->returnType=s1->getName();
		s2->isFunction = true;
		table->_InsertInGlobalScope(s);
		for(int i=0;i<s4->size;i++){
			//printf(s4->Datatypes[i].c_str());
			s->Paramtypes.push_back(s4->Datatypes[i]);
		}
		s->noOfParameters = s4->size;
		s->functionDeclared=true;
		return s;
	}
	else{
		yyerror("Redeclaration of Function "+s2->getName());
		errors++;
		return NULL;
	}
	 
}


void newTask3(SymbolInfo *s1,SymbolInfo *s2, A *s4){
	table->EnterScope(10);
	if(s2->returnType!=s1->getName()){
					yyerror("Ambiguating new declaration of "+valuetype+ " "+s2->getName()+"()");
					errors++;
					return ;
				}
	
	if(s2->Paramtypes.size()!=s4->size) {
					yyerror("Mismatch in no. of arguments");
					errors++;
					return ;
			}

	for(int i=0;i<s4->size;i++){
		if(s2->Paramtypes[i]!=s4->Datatypes[i]){
			//yyerror("Type mismatch in parameter list");
			fprintf(errorfile, "Error at line %d: %dth argument mismatch in function %s\n\n", line_count, i+1,s2->getName().c_str());
			fprintf(logg, "Error at line %d: %dth argument mismatch in function %s\n\n", line_count, i+1,s2->getName().c_str());
			errors++;
			return ;
		}
		
	}
	
	for(int i=0;i<s4->size;i++){
			SymbolInfo *ss = new SymbolInfo();
			string a = s4->Datatypes[i];
			string b = s4->Variables[i];
			ss->setName(b);
			ss->setDatatype(a);
			ss->setType("ID");
			if(a=="int") ss->setInt(-1);
			else if(a=="float") ss->setFloat(-1.0);
			table->_Insert2(ss);
		}

}



void getValueIncop(SymbolInfo *s1){
	//SymbolInfo *s=new SymbolInfo(s1->getName(),s1->getType(),s1->getDatatype());
	if(s1->isArray==true){
		SymbolInfo *temp = table->_LookUp(s1->getName());
		if(s1->getDatatype()=="int") {
						temp->setIntInArray(temp->getArrayInt(s1->posInArray)+1,s1->posInArray);
						 
					}
		else if(s1->getDatatype()=="float"){
						temp->setFloatInArray(temp->getArrayFloat(s1->posInArray)+1.0,s1->posInArray);
						 
					}
		
	}
	else{
		SymbolInfo *temp = table->_LookUp(s1->getName());
		if(s1->getDatatype()=="int") {
						//s->setInt(s1->getInt());	
						temp->setInt(temp->getInt()+1);
						
					}
		else if(s1->getDatatype()=="float"){
						temp->setFloat(temp->getFloat()+1.0);
					}

	}
	 
}


void getValueDecop(SymbolInfo *s1){
	if(s1->isArray==true){
		SymbolInfo *temp = table->_LookUp(s1->getName());
		if(s1->getDatatype()=="int") {
						temp->setIntInArray(temp->getArrayInt(s1->posInArray)-1,s1->posInArray);
						 
					}
		else if(s1->getDatatype()=="float"){
						temp->setFloatInArray(temp->getArrayFloat(s1->posInArray)-1.0,s1->posInArray);
						 
					}
		
	}
	else{
		SymbolInfo *temp = table->_LookUp(s1->getName());
		if(s1->getDatatype()=="int") {
						//s->setInt(s1->getInt());	
						temp->setInt(temp->getInt()-1);
						
					}
		else if(s1->getDatatype()=="float"){
						temp->setFloat(temp->getFloat()-1.0);
					}

	}
}




void newTask4(SymbolInfo *s1, SymbolInfo *s3 ){
	//printf("newtask4 noofparam %d %d\n", s1->noOfParameters, s3->noOfParameters);
	if(s1->noOfParameters!=s3->noOfParameters){
		yyerror("Mismatch in no. of Parameters");
		errors++;
		return ;
	}
	//printf("in newtask4\n");
	for(int i=0;i<s1->Paramtypes.size();i++){
		if(s1->Paramtypes[i]!=s3->Paramtypes[i]){
			//yyerror("Mismatch in types of Parameters");
			fprintf(errorfile, "Error at line %d: %dth argument mismatch in function %s\n\n", line_count, i+1,s1->getName().c_str());
			fprintf(logg, "Error at line %d: %dth argument mismatch in function %s\n\n", line_count, i+1,s1->getName().c_str());
			
			errors++;
			return ;
		}
	}

}







%}

%union{SymbolInfo* sym ; A *a;}

%token <sym> CONST_INT
%token <sym> CONST_FLOAT
%token <sym> CONST_CHAR
%token <sym> ID 
%token <sym> INCOP 
%token <sym> DECOP
%token <sym> ADDOP
%token <sym> MULOP
%token <sym> LOGICOP
%token <sym> RELOP
%token <sym> INT
%token <sym> FLOAT
%token <sym> VOID

%token IF FOR DO SWITCH DEFAULT ELSE WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE LCURL RCURL LPAREN RPAREN LTHIRD RTHIRD 
%token SEMICOLON PRINTLN NOT ASSIGNOP COMMA

 
%type <sym> declaration_list 
%type <sym> statements 
%type <sym> statement 
%type <sym> expression_statement 
%type <sym> variable 
%type <sym> expression 
%type <sym> logic_expression 
%type <sym> rel_expression 
%type <sym> simple_expression
%type <sym> term 
%type <sym> unary_expression 
%type <sym> factor 
%type <sym> func_definition 
%type <sym> func_declaration 
%type <sym> type_specifier 
%type <sym> unit 
%type <sym> program 
%type <sym> start 
%type <sym> var_declaration
%type <sym> argument_list
%type <sym> argument_lists

%type <a> parameter_list
%type <a> parameter_lists

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%left INCOP DECOP NOT
%right RELOP LOGICOP

%error-verbose 


%%

start : program
	{
		//fprintf(logg, "Line %d: start : program\n\n", line_count);	
	}
	;

program : program unit
	{
		fprintf(logg, "Line %d: program : program unit\n\n", line_count);	
	} 
	| 
	unit
	{

		fprintf(logg, "Line %d: program : unit\n\n", line_count);	
	}
	;
	
unit : var_declaration
	{

		fprintf(logg, "Line %d: unit : var_declaration\n\n", line_count);	
	}
     	| 
     	func_declaration
     	{
			fprintf(logg, "Line %d: unit : func_declaration\n\n", line_count);	
     	}
     	| 
     	func_definition
     	{
			fprintf(logg, "Line %d: unit : func_declaration\n\n", line_count);	
     	}
     	;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
			{
				fprintf(logg, "Line %d: func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n%s\n\n", line_count, $2->getName().c_str());	
				//printf("func_declaration %s\n", $1->getName().c_str());
				 $2 = newTask2($1,$2,$4); 		
			}
			|type_specifier ID LPAREN parameter_list RPAREN error {errors++;}
		 	;




		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN LCURL {

	     SymbolInfo* temp=table->_LookUp($2->getName()); if(temp==0){ $2 = newTask1($1, $2, $4);} else{ $2 = table->_LookUp($2->getName()); if($2->functionDefined==false){newTask3($1,$2,$4);} else {yyerror("Redefinition of Function "+$2->getName());errors++;}}}  statements RCURL

			{table->PrintAllScopeTables();
			 
	fprintf(logg, "Line %d: func_definition : type_specifier ID LPAREN parameter_list RPAREN LCURL statements RCURL\n%s\n\n", line_count, $2->getName().c_str());	 if($2->functionDefined==false){
			$2->functionDeclared=false; $2->functionDefined=true; table->PrintInSymtab(); table->ExitScope(); }
			}


			|type_specifier ID LPAREN parameter_list RPAREN LCURL {  SymbolInfo* temp=table->_LookUp($2->getName()); if(temp==0){ $2 = newTask1($1, $2, $4);} else{ $2 = table->_LookUp($2->getName());if($2->functionDefined==false){newTask3($1,$2,$4);}else {yyerror("Redefinition of Function "+$2->getName());errors++;}}} RCURL
			{table->PrintAllScopeTables();
			 
	fprintf(logg, "Line %d: func_definition : type_specifier ID LPAREN parameter_list RPAREN LCURL statements RCURL\n\n", line_count);
			 if($2->functionDefined==false){	
			$2->functionDeclared=false; $2->functionDefined=true; table->PrintInSymtab(); table->ExitScope(); }
			}
 		 	;




parameter_list   : parameter_lists {fprintf(logg,"Line %d: parameter_list : parameter_lists\n\n", line_count);$$=$1;}
		 | {$$ = new A(); $$->size=0; }
		 ;




 		 
parameter_lists  : parameter_lists COMMA type_specifier ID	{ fprintf(logg, "Line %d: parameter_lists  : parameter_lists COMMA type_specifier ID\n%s\n\n", line_count, $4->getName().c_str());$$=new A(); $$->size=$1->size+1; Paramfunction($$,$1); $$->Datatypes.push_back(valuetype);$$->Variables.push_back($4->getName());    }


		| parameter_lists COMMA type_specifier	 {fprintf(logg, "Line %d: parameter_lists : parameter_lists COMMA type_specifier\n\n", line_count);  $$=new A(); $$->size=$1->size+1; Paramfunction($$,$1); $$->Datatypes.push_back(valuetype);$$->Variables.push_back("");      }


 		| type_specifier ID		{fprintf(logg, "Line %d: parameter_lists : type_specifier ID\n%s\n\n", line_count, $2->getName().c_str());$$=new A();$$->size=1;$$->Datatypes.push_back(valuetype);$$->Variables.push_back($2->getName());  }


 		| type_specifier		{fprintf(logg, "Line %d: parameter_lists : type_specifier\n\n", line_count);$$=new A();$$->size=1;$$->Datatypes.push_back(valuetype);$$->Variables.push_back(""); }


 		
 		;
 		





compound_statement : LCURL{table->EnterScope(10);} statements RCURL		{fprintf(logg, "Line %d: compound_statement : LCURL statements RCURL\n\n", line_count);table->PrintAllScopeTables();table->PrintInSymtab(); table->ExitScope();}
 		    | LCURL{table->EnterScope(10);} RCURL			{fprintf(logg, "Line %d: compound_statement : LCURL RCURL\n\n", line_count);table->PrintAllScopeTables();table->PrintInSymtab(); table->ExitScope();}
		    
		  
 		    ;	
 		    





var_declaration : type_specifier declaration_list SEMICOLON		{fprintf(logg, "Line %d: var_declaration : type_specifier declaration_list SEMICOLON\n\n", line_count);}
		| type_specifier declaration_list error {errors++;} 		 
;
 		 





type_specifier	: INT		{fprintf(logg, "Line %d: type_specifier	: INT\n\n", line_count);valuetype = "int";}
 		| FLOAT		{fprintf(logg, "Line %d: type_specifier : FLOAT\n\n", line_count);valuetype = "float";}
 		| VOID		{fprintf(logg, "Line %d: type_specifier : VOID\n\n", line_count);valuetype = "void";}
 		;
 		





declaration_list  : declaration_list COMMA ID		{fprintf(logg, "Line %d: declaration_list  : declaration_list COMMA ID\n%s\n\n", line_count, $3->getName().c_str());if(valuetype=="void"){ yyerror("variable cannot be of void type");errors++; }else $$=insertInTable($3);}

 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD		{fprintf(logg, "Line %d: declaration_list  : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n%s\n%d\n\n", line_count, $3->getName().c_str(), $5->getInt());if(valuetype=="void"){ yyerror("Array cannot be of void type");errors++;} else if($5->getInt()<=0){yyerror("Illegal size of array");errors++;} else create_array($3, $5);}

 		  | ID				{fprintf(logg, "Line %d: declaration_list : ID\n%s\n\n", line_count, $1->getName().c_str());if(valuetype=="void"){ yyerror("Variable cannot be of void type"); errors++;}else $$=insertInTable($1);}

 		  | ID LTHIRD CONST_INT RTHIRD		{fprintf(logg, "Line %d: declaration_list : ID LTHIRD CONST_INT RTHIRD\n%s\n%d\n\n", line_count, $1->getName().c_str(), $3->getInt());if(valuetype=="void"){ yyerror("Array cannot be of void type");errors++;} else if($3->getInt()<=0){yyerror("Illegal size of array");errors++;}  else create_array($1, $3);}
 		  ;
 		  





statements : statement		{fprintf(logg, "Line %d: statements : statement\n\n", line_count);}
	   | statements statement		{fprintf(logg, "Line %d: statements : statements statement\n\n", line_count);}
	   ;
	   





statement : var_declaration		{fprintf(logg, "Line %d: statement : var_declaration\n\n", line_count);}
	  | expression_statement	{fprintf(logg, "Line %d: statement : expression_statement\n\n", line_count);}
	  | compound_statement		{fprintf(logg, "Line %d: statement : compound_statement\n\n", line_count);}

	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement	{fprintf(logg, "Line %d: statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n", line_count);}

	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE		{fprintf(logg, "Line %d: statement : IF LPAREN expression RPAREN statement\n\n", line_count);}

	  | IF LPAREN expression RPAREN statement ELSE statement	{fprintf(logg, "Line %d: statement : IF LPAREN expression RPAREN statement ELSE statement\n\n", line_count);}

	  | WHILE LPAREN expression RPAREN statement		{fprintf(logg, "Line %d: statement : WHILE LPAREN expression RPAREN statement\n\n", line_count);}

	  | PRINTLN LPAREN ID RPAREN SEMICOLON			{fprintf(logg, "Line %d: statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n", 	line_count);	SymbolInfo *temp=table->_LookUp($3->getName());  if(temp==0){yyerror("Undeclared Variable");errors++;}
							else if(temp->getDatatype()=="int"){printf("%d\n", temp->getInt());}
							else if(temp->getDatatype()=="float"){printf("%f\n",temp->getFloat());}
 }

	  | PRINTLN LPAREN ID RPAREN error {errors++;}


	  | RETURN expression SEMICOLON			{fprintf(logg, "Line %d: statement : RETURN expression SEMICOLON\n\n", line_count);
								/*if($2->getDatatype()=="int") $$->setInt($2->getInt()); else $$->setFloat($2->getFloat());*/}


	 | RETURN expression error {errors++;}
	  ;






	  
expression_statement 	: SEMICOLON		{fprintf(logg, "Line %d: expression_statement : SEMICOLON\n\n", line_count);}	
			| expression SEMICOLON 		{fprintf(logg, "Line %d: expression_statement : expression SEMICOLON\n\n", line_count);}
		
			| expression error {errors++;}
	;
	  





variable : ID 		{fprintf(logg, "Line %d: vairable : ID\n%s\n\n", line_count, $1->getName().c_str());/*$$ = getIDfromTable($1);*/SymbolInfo *temp=table->_LookUp($1->getName()); if(temp==0){yyerror("Undeclared variable "+$1->getName());errors++;/*printf("variable:id %s\n", $1->getName().c_str());*/$$=NULL;}else if(temp->isArray==true){yyerror("Type Mismatch: Left operand is of array type");errors++;$$=NULL;} else {$1=temp; $$ = newgetIDfromTable($1);}}

	 | ID LTHIRD expression RTHIRD 		{fprintf(logg, "Line %d: variable : ID LTHIRD expression RTHIRD\n%s\n\n",line_count, $1->getName().c_str(), $3->getInt());       SymbolInfo *temp=table->_LookUp($1->getName());
						 if(temp==0){yyerror("Undeclared array "+$1->getName());errors++;$$=NULL;}
						else if(temp->isArray!=true){yyerror("Indexing on non-array type");errors++;$$=NULL;}					
						else if($3->getDatatype()!="int"){yyerror("Array index of non-integer type");errors++;$$=NULL;}
 						else if($3->getInt()<0){yyerror("Illegal size of array");errors++;$$=NULL;}
						else if($3->getInt()>=temp->sizeOfArray){yyerror("Array index out of bound");errors++;$$=NULL;}
						
					
 						else{$1=temp;$$ = newgetintIDfromTable($1,$3);$$->isArray=true; 	markerForArrayInsert=true;}}
	 ;
	 




expression : logic_expression		{fprintf(logg, "Line %d: expression : logic_expression\n\n", line_count);$$=$1;}	
	   | variable ASSIGNOP logic_expression 	{fprintf(logg, "Line %d: expression : variable ASSIGNOP logic_expression\n\n", line_count);if(($1!=NULL && $1->getDatatype()=="void") || ($3!=NULL && $3->getDatatype()=="void")){$$=NULL;yyerror("Illegal Function return type void");errors++;} else if($1!=NULL && $3!=NULL){$1=handle_assignment($1, $3); $$=$1; table->PrintAllScopeTables();/*printf("what %s\n", $3->getDatatype().c_str());*/} else{$$=NULL;} 
	 }
	   ;





			
logic_expression : rel_expression 	{fprintf(logg, "Line %d: logic_expression : rel_expression\n\n", line_count);$$=$1;}
		 | rel_expression LOGICOP rel_expression 	{fprintf(logg, "Line %d: logic_expression : rel_expression LOGICOP rel_expression\n\n", line_count);	if($1==NULL || $3==NULL){$$=NULL;}
				else if($1!=NULL && $1->getDatatype()=="void"){$$=NULL;yyerror("Illegal Function return type void");errors++;}
				else if($3!=NULL && $3->getDatatype()=="void"){$$=NULL;yyerror("Illegal Function return type void");errors++;}

					 else {$$=handle_logic_operation($1,$2,$3);}}
		 ;
			




rel_expression	: simple_expression 	{fprintf(logg, "Line %d: rel_expression : simple_expression\n\n", line_count);$$=$1;}
		| simple_expression RELOP simple_expression	{fprintf(logg, "Line %d: rel_expression : simple_expression RELOP simple_expression\n\n", line_count);if($1==NULL || $3==NULL){$$=NULL;} 
					else if($1!=NULL && $1->getDatatype()=="void"){$$=NULL;yyerror("Illegal Function return type void");errors++;}
				else if($3!=NULL && $3->getDatatype()=="void"){$$=NULL;yyerror("Illegal Function return type void");errors++;}
					else {$$=handle_relop_operation($1,$2,$3);}}
		;
				





simple_expression : term 	{fprintf(logg, "Line %d: simple_expression : term\n\n", line_count);$$=$1; }
		  | simple_expression ADDOP term 	{fprintf(logg, "Line %d: simple_expression : simple_expression ADDOP term\n\n", 							line_count);if($1==NULL || $3==NULL){$$=NULL;}
							else if($1!=NULL && $1->getDatatype()=="void"){$$=NULL;yyerror("Illegal Function return type void");errors++;}
				else if($3!=NULL && $3->getDatatype()=="void"){$$=NULL;yyerror("Illegal Function return type void");errors++;}
							else {$$ = do_addition($1,$2,$3);/*printf("in simple %d\n", $$->getInt());*/}
							}
		  ;





					
term :	unary_expression		{fprintf(logg, "Line %d: term : unary_expression\n\n", line_count); }
     |  term MULOP unary_expression	{fprintf(logg, "Line %d: term : term MULOP unary_expression\n\n", line_count);
					if($1==NULL || $3==NULL){$$=NULL;} 
				else if($1!=NULL && $1->getDatatype()=="void"){$$=NULL;yyerror("Illegal Function return type void");errors++;}
				else if($3!=NULL && $3->getDatatype()=="void"){$$=NULL;yyerror("Illegal Function return type void");errors++;}

				else{	$$=do_multiplication($1,$2,$3); /*printf("in term: mulop %d\n", $$->getInt());*/} }
     ;






unary_expression : ADDOP unary_expression  {fprintf(logg, "Line %d: unary_expression : ADDOP unary_expression\n\n", line_count);
						if($1->getName()=="-"){
								if($2==NULL){$$=NULL;}
								else if($2->getDatatype()=="void"){$$=NULL;yyerror("Illegal Function return type void");errors++;}
								else{
									if($2->getDatatype()=="int") {$2->setInt(-$2->getInt());}
									else { $2->setFloat(-$2->getFloat());} $$=$2;}
						
								}
						}
		 | NOT unary_expression    {fprintf(logg, "Line %d: unary_expression : NOT unary_expression\n\n", line_count);
						if($2==NULL){$$=NULL;}
						else if($2->getDatatype()=="void"){$$=NULL;yyerror("Illegal Function return type void");errors++; }
						else{
						if($2->getDatatype()=="int") {$2->setInt(!$2->getInt());}
						else if($2->getDatatype()=="float"){ $2->setFloat(!$2->getFloat());} $$=$2;
							}
						}	
		 | factor 		   {fprintf(logg, "Line %d: unary_expression : factor\n\n", line_count);}
		 ;
	





factor	: variable  		{fprintf(logg, "Line %d: factor : variable\n\n", line_count);/*printf("h: %d\n", $1->getInt());*/if($1!=NULL) $$=getValue($1);else $$=NULL;}

	| ID LPAREN argument_list RPAREN	{fprintf(logg, "Line %d: factor : ID LPAREN argument_list RPAREN\n\n", line_count);
	$$->setInt(0);$$->setFloat(0.0);      SymbolInfo *temp=table->_LookUp($1->getName());
		if(temp==0) {yyerror("Undeclared function "+$1->getName());errors++;$$=NULL;}
		else{ 
			if(temp->isFunction==false){ yyerror($1->getName()+" is not a function");errors++;$$=NULL;}	
			else if(temp->noOfParameters!=$3->noOfParameters){yyerror("Mismatch in number of parameters");errors++;}	
			else{$1=temp;$$->setDatatype($1->returnType); newTask4($1,$3);	/*printf("factor: id %s %d\n", $1->returnType.c_str(), $1->noOfParameters);*/	}}
		}

	| LPAREN expression RPAREN	{fprintf(logg, "Line %d: factor : LPAREN expression RPAREN\n\n", line_count);
						//printf("bla: %s %d\n", $2->getDatatype().c_str(), $2->getInt());
					 $$=$2;}

	| CONST_INT 		{fprintf(logg, "Line %d: factor : CONST_INT\n%d\n\n", line_count, $1->getInt());}
	| CONST_FLOAT		{fprintf(logg, "Line %d: factor : CONST_FLOAT\n%f\n\n", line_count, $1->getFloat());}
	| CONST_CHAR		{fprintf(logg, "Line %d: factor : CONST_CHAR\n\n", line_count);}
	| variable INCOP 	{fprintf(logg, "Line %d: factor : variable INCOP\n\n", line_count);if($1!=NULL) getValueIncop($1);else $$=NULL;}


	| variable DECOP	{fprintf(logg, "Line %d: factor : variable DECOP\n\n", line_count);if($1!=NULL) getValueDecop($1);else $$=NULL;}
	;
	


argument_list   : argument_lists {fprintf(logg, "Line %d: argument_list : argument_lists\n\n", 								line_count);$$=$1;}
		| { $$ = new SymbolInfo();$$->noOfParameters=0;  }
		;



argument_lists : argument_lists COMMA logic_expression	{fprintf(logg, "Line %d: argument_lists : argument_lists COMMA logic_expression\n\n", 								line_count);/*printf("logic_expression 2 : %s %s %s\n", $3->getName().c_str(), $3->getType().c_str(), $3->getDatatype().c_str());*/   $$=new SymbolInfo(); $$->noOfParameters=0;
					if($1!=NULL){ $$->noOfParameters=$1->noOfParameters; 
					for(int i=0;i<$1->noOfParameters;i++){ $$->Paramtypes.push_back($1->Paramtypes[i]); }}
					
					if($3!=NULL) {$$->Paramtypes.push_back($3->getDatatype());$$->noOfParameters=$$->noOfParameters+1;}
					

 							}

	      | logic_expression	{fprintf(logg, "Line %d: argument_lists : logic_expression\n\n", line_count);//printf("logic_expression: %s %s %s\n", $1->getName().c_str(), $1->getType().c_str(), $1->getDatatype().c_str());
					$$=new SymbolInfo();
					$$->noOfParameters=0;if($1!=NULL){$$=$1;
					$$->Paramtypes.push_back($1->getDatatype());$$->noOfParameters=1;}
					
					 
					}

	      
	      ;
 

%%
int main(int argc,char *argv[])
{
	FILE *fp;
	extra = new SymbolInfo();
	globalid=2;
	//printf("file name is %s\n", argv[1]);
	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	markerForArrayInsert=false;
	
	

	ScopeTable table1(10);
	table1.setId(1);
	table = new SymbolTable(&table1);
	

	
	logg = fopen("log.txt","w");
	//loggs.open("log.txt");
	errorfile = fopen("error.txt","w");
	symtabfile = fopen("symtab.txt","w");
	
	yyin=fp;
	yyparse();
	
	//table->PrintAllScopeTables();

	fprintf(logg,"Total Lines: %d\n\n", line_count-1);
	fprintf(logg,"Total Errors: %d\n\n", errors);
	
	 
	fclose(logg);
	fclose(errorfile);
	fclose(symtabfile);
	 
	fclose(yyin);
	
	return 0;
}
