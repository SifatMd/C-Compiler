#include<bits/stdc++.h>
#include<iostream>
#include<string>
#include<vector>
#include<fstream>
#include<sstream>
using namespace std;
//string inputlines[90000];
extern int globalid;
extern int p, q, r, i, j;

extern FILE *logg;
extern FILE *token;
extern FILE *symtabfile;
extern int line_count;
extern int errors;


class SymbolInfo{
private:
    string Name, Type;
    string Datatype;
	int intval;
	float floatval; 
    SymbolInfo *next;
	
	
public:
	bool isArray;
	//SymbolInfo *myarray;
	int *myintarray;
	float *myfloatarray;
	int sizeOfArray;
	int posInArray;

	 
	string returnType;
	int noOfParameters;
	bool isFunction;
	bool functionDeclared;
	bool functionDefined;

	vector<string>Paramtypes;
	
	
	SymbolInfo(){
        next=0;
		isArray=false;
		sizeOfArray=-1; 
		isFunction=false;
		noOfParameters=0;
		functionDeclared=false;
		functionDefined=false;
		 
    }
    SymbolInfo(string n, string t)
    {
        Name = n;
        Type = t;
        next = 0;
		isArray=false;
		sizeOfArray=-1;  
		isFunction=false;
		noOfParameters=0;
		functionDeclared=false;
		functionDefined=false;
		 
    }
	SymbolInfo(string n, string t, string d)
    {
        Name = n;
		Datatype = d;
        Type = t;
        next = 0;
		isArray=false;
		sizeOfArray=-1;  
		isFunction=false;
		noOfParameters=0;
		functionDeclared=false;
		functionDefined=false;
	 
    }
	SymbolInfo(string n, string t, int d)
    {
        Name = n;
        Type = t;
        next = 0;
		isArray=true;
		sizeOfArray=d;  
        myintarray = new int[d];
        myfloatarray = new float[d];
		intval=-1;
		floatval=-1; 
		isFunction=false;
		noOfParameters=0;
		functionDeclared=false;
		functionDefined=false;
	 
	}

	void setDatatype(string a){
		Datatype = a;	
	}
	string getDatatype(){
		return Datatype;
	}
	void setInt(int a){
		intval = a;	
	}
	int getInt(){
		return intval;
	}
	void setFloat(float a){
		floatval = a;	
	}
	float getFloat(){
		return floatval;
	}
	 
    void setName(string a)
    {
        Name = a;
    }
    void setType(string a)
    {
        Type = a;
    }
    string getName()
    {
        return Name;
    }
    string getType()
    {
        return Type;
    }
    void setNext(SymbolInfo *a)
    {
        next = a;
    }
    SymbolInfo* getNext()
    {
        return next;
    }
	
	void CreateArray(){
		 
		if(Datatype=="int"){
//			myintarray= new int[a];
			for(int i=0;i<sizeOfArray;i++){ 
				myintarray[i] = -1;
			}
		}
		else if(Datatype=="float"){
			//myfloatarray= new float[a];
			for(int i=0;i<sizeOfArray;i++){
				myfloatarray[i] = -1.0;
			}	
		}
//		sizeOfArray=a;
	}
	
	int getArrayInt(int i){
		//return myarray[i].getInt();
		return myintarray[i];
	}
	float getArrayFloat(int i){
		//return myarray[i].getFloat();
		return myfloatarray[i];
	}
	 
	void setIntInArray(int num, int pos){
		//myarray[pos].setInt(num); 
		myintarray[pos]=num; 
	}
	
	void setFloatInArray(float num, int pos){
		//myarray[pos].setFloat(num);
		myfloatarray[pos]=num;
	}
	
	int getsizeOfArray(){return sizeOfArray;}


};

class ScopeTable
{
private:
    SymbolInfo **aray;
    ScopeTable *parentScope;
    int buckets;
    int id;


public:
    ScopeTable()
    {

    }
    ScopeTable(int n)
    {
        buckets = n;
        aray = new SymbolInfo*[n];
        for(int i=0;i<n;i++)
        {
            aray[i] = new SymbolInfo;
            aray[i] = 0;
        }
        parentScope = 0;
    }

    ~ScopeTable()
    {
        for(int i=0;i<buckets;i++){
            delete aray[i];
        }
        delete[] aray;
        buckets = 0;
    }


    void setParentScope(ScopeTable *a)
    {
        parentScope = a;
    }
    ScopeTable* getParentScope()
    {
        return parentScope;
    }

    int hashfunction(string s)
    {
        int sum=0;
        for(int i=0;i<s.length();i++){
            sum+=(s[i]+13+i);
        }
        return sum%buckets;
    }

    void setId(int i)
    {
        id = i;
    }
    int getId()
    {
        return id;
    }

    SymbolInfo* Insert(string name, string type)
    {
        SymbolInfo *newobj = new SymbolInfo(name, type);
        int index = hashfunction(name);
        int cnt=0;

        SymbolInfo *temp = aray[index];
        if(temp==0){
            aray[index] = newobj;
        }
        else{
            cnt++;
            while(temp->getNext()!=0){
                temp = temp->getNext();
                cnt++;
            }
            temp->setNext(newobj);

        }
        //cout<<"  Inserted in ScopeTable #" << getId() << " at position " << index << " , " << cnt  <<endl <<endl;
        return newobj;
    }


	SymbolInfo* Insert2(SymbolInfo *ss)
    {
		//printf("In insert2: %s %s\n",ss->getName().c_str(), ss->getDatatype().c_str());
        SymbolInfo *newobj = ss;
        int index = hashfunction(ss->getName());
        int cnt=0;

        SymbolInfo *temp = aray[index];
        if(temp==0){
            aray[index] = ss;
        }
        else{
            cnt++;
            while(temp->getNext()!=0){
                temp = temp->getNext();
                cnt++;
            }
            temp->setNext(ss);

        }
        //cout<<"  Inserted in ScopeTable #" << getId() << " at position " << index << " , " << cnt  <<endl <<endl;
        return ss;
    }

    void Print()
    {
    //cout<<" ScopeTable # " << getId() <<endl;
	p = getId();
	fprintf(logg, " ScopeTable # %d \n", p);
        for(int i=0;i<buckets;i++)
        {
            SymbolInfo *temp = aray[i];
            //cout<< " " << i << "-->";
            if(temp==0){
                //cout<< endl;
                continue;
}
            else{
			fprintf(logg, " %d-->", i);
            while(temp!=0){
			if(temp->isFunction==true){fprintf(logg, " < %s : %s >", temp->getName().c_str(), temp->getType().c_str());
						
										}
            else if(temp->getDatatype()=="int" && temp->isArray==true) {fprintf(logg, " < %s : %s :", temp->getName().c_str(), temp->getType().c_str());   		
					fprintf(logg,"{%d ", temp->myintarray[0]);
					
					for(int ii=1;ii<temp->sizeOfArray;ii++){
							fprintf(logg,":%d ",temp->myintarray[ii]);						
					}
					fprintf(logg,"}>");
					

}

			else if(temp->getDatatype()=="float" && temp->isArray==true) {fprintf(logg, " < %s : %s :", temp->getName().c_str(), temp->getType().c_str());  		
					fprintf(logg,"{%f ", temp->myfloatarray[0]);
					for(int ii=1;ii<temp->sizeOfArray;ii++){
							fprintf(logg,":%f ",temp->myfloatarray[ii]);						
					}
					fprintf(logg,"}");

}



			else if(temp->getDatatype()=="int"){fprintf(logg, " < %s : %s : %d>", temp->getName().c_str(), temp->getType().c_str(), temp->getInt());
												}



			else if(temp->getDatatype()=="float"){fprintf(logg, " < %s : %s : %f>", temp->getName().c_str(), temp->getType().c_str(), temp->getFloat());}
			
		 
				temp = temp->getNext();
            }
			fprintf(logg, "\n");
			} 
        } 
		fprintf(logg, "\n\n");
    }


	void PrintSymtab(){
		//cout<<" ScopeTable # " << getId() <<endl;
		p = getId();
		
		fprintf(symtabfile, " ScopeTable # %d \n", p);
		    for(int i=0;i<buckets;i++)
		    {
		        SymbolInfo *temp = aray[i];
		        //cout<< " " << i << "-->";
		        if(temp==0){
		            //cout<< endl;
		            continue;
	}
		        else{
				
				fprintf(symtabfile, " %d-->", i);
		        while(temp!=0){
				if(temp->isFunction==true){
							fprintf(symtabfile, " < %s : %s >", temp->getName().c_str(), temp->getType().c_str());}
		        else if(temp->getDatatype()=="int" && temp->isArray==true) {fprintf(symtabfile, " < %s : %s :", temp->getName().c_str(), temp->getType().c_str()); 		
						fprintf(symtabfile,"{%d ", temp->myintarray[0]);
						for(int ii=1;ii<temp->sizeOfArray;ii++){
									fprintf(symtabfile,":%d ",temp->myintarray[ii]);		
						}
						fprintf(symtabfile,"}>");

	}

				else if(temp->getDatatype()=="float" && temp->isArray==true) {fprintf(symtabfile, " < %s : %s :", temp->getName().c_str(), temp->getType().c_str());   		
						fprintf(symtabfile,"{%f ", temp->myfloatarray[0]);
						for(int ii=1;ii<temp->sizeOfArray;ii++){
								fprintf(symtabfile,":%f ",temp->myfloatarray[ii]);		
						}
						fprintf(symtabfile,"}");

	}



				else if(temp->getDatatype()=="int"){fprintf(symtabfile, " < %s : %s : %d>", temp->getName().c_str(), temp->getType().c_str(), temp->getInt());}



				else if(temp->getDatatype()=="float"){fprintf(symtabfile, " < %s : %s : %f>", temp->getName().c_str(), temp->getType().c_str(), temp->getFloat());}
			
			 
					temp = temp->getNext();
		        }
				fprintf(symtabfile,"\n");
				} 
		    } 
			fprintf(symtabfile, "\n\n");




	}













    SymbolInfo* LookUp(string name)
    {
        int row=0, col=0;
        for(int i=0;i<buckets;i++,row++)
        {
            SymbolInfo *temp = aray[i];
            col=0;
            while(temp!=0)
            {
                if(temp->getName()==name){
                    //cout<<"  Found in ScopeTable #" << getId() << " at position " << row <<", " <<col <<endl <<endl;
                    return temp;
                }
                temp = temp->getNext();
                col++;
            }

        }
        return 0;
    }




    SymbolInfo* LookUp2(string name, string types)
    {
        int row=0, col=0;
        for(int i=0;i<buckets;i++,row++)
        {
            SymbolInfo *temp = aray[i];
            col=0;
            while(temp!=0)
            {
                //temp = temp->getNext();
                if(temp->getName()==name && temp->getType()==types){
                    //cout<<" < " << name << " , " << types << " > " << "already exists in current ScopeTable" <<endl<<endl;
                    return temp;
                }
                temp = temp->getNext();
                col++;
            }

        }
        return 0;
    }



	


    bool Delete(string names)
    {
        //cout<< "name is " <<names <<endl;
        int row=0, col=0;
        int i, indexx=-1;
        SymbolInfo *temp, *prev;
        for(i=0;i<buckets;i++,row++)
        {
            temp = aray[i];
            prev = 0;
            indexx = -1;
            col=0;
            while(temp!=0){
                //cout<<"temp is " <<temp->getName() <<endl;
                if(temp->getName() == names){
                    indexx = i;
                    break;
                }
                prev = temp;
                temp = temp->getNext();
                col++;
            }
            if(indexx!=-1) break;
        }

        if(i==buckets) return false;
        else{
            if(prev==0){
                aray[indexx] = temp->getNext();
            }
            else{
                prev->setNext(temp->getNext());
            }
            //cout<<"  Found in ScopeTable #" << getId() << " at position " << row <<", " <<col <<endl <<endl;
            //cout<<"Deleted entry at " <<row <<", " <<col << " from current ScopeTable" <<endl <<endl;
            delete temp;
            return true;
        }

    }

};

class SymbolTable
{
private:
    ScopeTable *currTable;
	ScopeTable *globalScope;

public:
	SymbolTable(){}	
    SymbolTable(ScopeTable *tab)
    {
        currTable = new ScopeTable;
        currTable = tab;
		globalScope=currTable;
    }

	void CreateScope(ScopeTable *tab){
		currTable = new ScopeTable;
        currTable = tab;
		
	}

    void EnterScope(int n)
    {
        ScopeTable *temp = new ScopeTable(n);
        temp->setId(globalid);
        globalid++;
        temp->setParentScope(currTable);
        currTable = temp;
        //cout<<"  New ScopeTable with id " << currTable->getId() << " created" <<endl <<endl;
    }

    void ExitScope()
    {
        if(currTable==0) return ;
        ScopeTable *temp = currTable;
        //cout<<"  ScopeTable with id " <<currTable->getId() << " removed" <<endl <<endl;
        currTable = currTable->getParentScope();
        delete temp;
        //globalid--;
    }

    SymbolInfo* _Insert(string n, string t)
    {
        return currTable->Insert(n, t);
    }

	SymbolInfo* _Insert2(SymbolInfo *ss)
    {
		//printf("insert2: %s %s\n",ss->getName(), ss->getDatatype());
        return currTable->Insert2(ss);
    }

	SymbolInfo* _InsertInGlobalScope(SymbolInfo *ss){
		return globalScope->Insert2(ss);
	}	

    bool _Delete(string n)
    {
        return currTable->Delete(n);
    }


    void PrintCurrentScopeTable()
    {
        currTable->Print();
    }

    void PrintAllScopeTables()
    {
        ScopeTable *temp = currTable;
        while(temp!=0)
        {
            temp->Print();
            temp = temp->getParentScope();
        }
    }


	void PrintInSymtab(){
		ScopeTable *temp = currTable;
		fprintf(symtabfile,"Line no: %d\n\n", line_count);
        while(temp!=0)
        {
            temp->PrintSymtab();
            temp = temp->getParentScope();
        }
	}


    SymbolInfo* _LookUp(string n)
    {
        ScopeTable *temp = currTable;
        SymbolInfo *p=0;
        while(temp!=0)
        {
            p = temp->LookUp(n);
            if(p!=0){
				//printf("In lookUp %s %s\n", p->getName().c_str(), p->getDatatype().c_str());
                return p;
            }
            temp = temp->getParentScope();
        }
        return 0;
    }

    SymbolInfo* _LookUp2(string n, string t)
    {
        ScopeTable *temp = currTable;
        SymbolInfo *p = temp->LookUp2(n, t);
        if(p!=0) return p;
        return 0;

    }






	SymbolInfo* _LookUpThisTable(string n)
    {
        ScopeTable *temp = currTable;
        SymbolInfo *p=0;
        p = temp->LookUp(n);
            if(p!=0){
				//printf("In lookUp %s %s\n", p->getName().c_str(), p->getDatatype().c_str());
                return p;
            }
			return 0; 
         
    }

	SymbolInfo* _LookUpGlobalTable(string n)
    {
        ScopeTable *temp = globalScope;
        SymbolInfo *p=0;
        p = temp->LookUp(n);
            if(p!=0){
				//printf("In lookUp %s %s\n", p->getName().c_str(), p->getDatatype().c_str());
                return p;
            }
			return 0; 
         
    }

     





    void _FinalDelete()
    {
        ScopeTable *temp = currTable;
        ScopeTable *temp2=0;
        while(temp!=0){
            temp2 = temp;
            temp = temp->getParentScope();
            delete temp2;
        }
    }

};


class A{
public:
	vector<string>Datatypes;
	vector<string>Variables;
	int size;


	A(){
		
	}
	
};



/*int main()
{
    string a, b, c, line;
    int i, j, k, inputsize=0;


    ifstream inp("InputHello.txt");//reading line by line from input file
    for(i=0;getline(inp, a);i++){
        inputlines[i]=a;
    }
    inputsize = i;
    vector<string> v;
    stringstream ss(inputlines[0]);
    while(ss >> c){
        v.push_back(c);
    }
    istringstream mystring(v[0]);
    int num;
    mystring>>num;

    ScopeTable table1(num);
    table1.setId(1);
    SymbolTable MainTable(&table1);
    for(int ii=1;ii<inputsize;ii++)
    {
        line = inputlines[ii];
        cout <<line <<endl <<endl;
        if(line[0]=='I'){
            v.clear();
            stringstream ss(line);
            while(ss >> c){
                v.push_back(c);
            }
            SymbolInfo *f = MainTable._LookUp2(v[1], v[2]);
            if(f==0){
                MainTable._Insert(v[1], v[2]);
            }
         }
        else if(line[0]=='L'){
            v.clear();
            stringstream ss(line);
            while(ss >> c){
                v.push_back(c);
            }
            SymbolInfo *f = MainTable._LookUp(v[1]);
            if(f==0){
                cout<<"Not Found"<<endl <<endl;
            }

        }
        else if(line[0]=='P'){
            v.clear();
            stringstream ss(line);
            while(ss >> c){
                v.push_back(c);
            }
            if(v[1]=="A") MainTable.PrintAllScopeTables();
            else if(v[1]=="C") MainTable.PrintCurrentScopeTable();
        }
        else if(line[0]=='D'){
            v.clear();
            stringstream ss(line);
            while(ss >> c){
                v.push_back(c);
            }

            bool ff = MainTable._Delete(v[1]);
            if(ff==false){
                cout<<"  Not found" <<endl <<endl;
                cout<< v[1] << " not found "<<endl <<endl;
            }
        }
        else if(line[0]=='S'){
            v.clear();
            stringstream ss(line);
            while(ss >> c){
                v.push_back(c);
            }
            MainTable.EnterScope(num);
        }
        else if(line[0]=='E'){
            v.clear();
            stringstream ss(line);
            while(ss >> c){
                v.push_back(c);
            }
            MainTable.ExitScope();
        }
    }


    MainTable._FinalDelete();
    inp.close();

    return 0;
}*/

