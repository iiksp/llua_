#include "iostream"
#include "map"
#pragma once
using namespace std;

class nodeType
{
    map<string,void*> m;
    string tostring();
}

/* identifiers */
class varNode:nodeType {
    public:
    string name;
    idNodeType()
    {
        name="";
    }
};

/* constants */
typedef struct {
    int value;                  /* value of constant */
} conNodeType;