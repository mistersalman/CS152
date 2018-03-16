#ifndef __semanticValues_h__
#define __semanticValues_h__

 #include <vector>
 #include <string>
 #include <iostream>
 using namespace std; //don't wanna add std:: to everything

 struct varParams {
	string* type;
	string* index;
	int* place;
	};
 struct exprParams {
	int* place;
	};


struct semanticValues {
  	int* place;
  	string* type;
	  string* val;
	  string* index;
	  vector<string>* valSet;
	  vector<varParams>* varSet;
	  vector<exprParams>* exprSet;
};
#endif
