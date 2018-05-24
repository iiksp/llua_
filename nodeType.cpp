#include "nodeType.h"

string nodeType::tostring()
{
    string res;
    for(auto i=this.m.begin();i!=this.m.end();i++)
    {
        res=res+i->first+":"+typeid(i->second).name()+","
    }
    return res;
}