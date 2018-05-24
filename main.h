#pragma once
#include "iostream"
#include "map"
#include "vector"
#include "math.h"
//#include "cassert"
using namespace std;

#define DEBUG

#ifdef DEBUG

#define LOG(fmt,...) printf("[%s    %s:%d]" fmt "\n",__FILE__,__FUNCTION__,__LINE__,##__VA_ARGS__)

#else

#define LOG(fmt,...)

#endif

#define IN
#define OUT
#define BYTE unsigned char

typedef map<string, void*> smap;

template<typename T>
bool map_has_key(map<string,T>& m,string& n)
{
    typename map<string,T>::iterator it=m.find(n);
    if(it != m.end()) return true;
    else return false;
}


typedef enum { typeCon, typeStr, typeId, typeOpr, typeArgDef, typeFuncDef, typeFuncProto, typeCall } nodeEnum;

/* constants */
typedef struct {
    int value;                  /* value of constant */
} conNodeType;

/* identifiers */
class idNodeType {
    //int i;                      /* subscript to sym array */
    public:
    string name;
    
    idNodeType()
    {
        //cout<<"ctor idNodeType"<<endl;
        name="";
    }
};

/* operators */
typedef struct {
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    struct nodeTypeTag *op[1];  /* operands, extended at runtime */
} oprNodeType;

typedef struct nodeTypeTag {
    nodeEnum type;              /* type of node */

    idNodeType id;          /* identifiers */
    union {
        conNodeType con;        /* constants */
        oprNodeType opr;        /* operators */
    };
    
} nodeType;



struct yystype {
    int iValue;                 /* integer value */
    string sIndex;                /* symbol table index */
    nodeType *nPtr;             /* node pointer */
};

#define YYSTYPE yystype

//extern int sym[26];
extern map<string,void*> gEnv;
extern "C" int ex(nodeType *p, map<string,void*>& env);
extern "C" int compile(nodeType* p);
