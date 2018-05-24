#include <stdio.h>
#include "main.h"
#include "yacc.tab.h"
#include "queue"
using namespace std;



nodeType* exArgDef(nodeType* p, smap& env);

smap gEnv;

extern "C"
{
    nodeType *opr(int oper, int nops, ...);
    nodeType *con(int value);
}

nodeType* exFuncDef(nodeType* p, smap& env )
{
    if(p->opr.nops==3)
    {
        string name=(char*)(p->opr.op[0]);
        LOG("function name:%s",name.c_str());
        
        smap* pnewEnv=new smap;
        env[name]=pnewEnv;
        smap& newEnv=*pnewEnv;
        
        newEnv["__stmt__"]=p->opr.op[2];
        
        nodeType* args=p->opr.op[1];
        queue<string>* q=new queue<string>;
        newEnv["__arglist__"]=q;
        exArgDef(args,newEnv);
		
    }
    else
    {
        
    }
    return 0;
}

nodeType* exArgDef(nodeType* p, smap& env)
{
    nodeType* next=p->opr.op[0];
    queue<string>* q=(queue<string>*)env["__arglist__"];
    
    string name=(char*)(p->opr.op[1]);
    LOG("%d %s",p->opr.oper,name.c_str());
    q->push(name);
    
    if(next->type==typeId)
    {
        LOG("last:%s",next->id.name.c_str());
        q->push(next->id.name);
        return 0;
    }
    else
    {
        return exArgDef(next,env);
    }
}

nodeType* exArgUse(nodeType* p,smap& env)
{
    nodeType* next=p->opr.op[0];
    nodeType* cur=p->opr.op[1];
    
    int val=ex(cur,env);
    queue<string>* q=(queue<string>*)env["__arglist__"];
    string argName=q->front();
    q->pop();
    env[argName]=(void*)val;
    
    LOG("%s %d",argName.c_str(),val);
    
    if(next->opr.oper!=',')
    {
        int lastVal=ex(next,env);
        string lastName=q->front();
        q->pop();
        env[lastName]=(void*)lastVal;
        
        LOG("last %s %d",lastName.c_str(),lastVal);
        
        return 0;
    }
    else
    {
        return exArgUse(next,env);
    }
}

void copyQueue(queue<string>* q,queue<string>* newq)
{
	vector<string> v;
	while (!q->empty())
	{
		v.push_back(q->front());
		q->pop();
	}
	for (vector<string>::iterator s=v.begin();s!=v.end();s++)
	{
		q->push(*s);
		newq->push(*s);
	}
}

nodeType* exCallFunction(nodeType* p, smap& env)
{
    string name=(char*)(p->opr.op[0]);
    LOG("%s",name.c_str());
    smap& func=*(smap*)(env[name]);
	map<string, void*>& curEnv = *(new map<string, void*>);

	curEnv["__arglist__"] = new queue<string>;

	copyQueue((queue<string>*)func["__arglist__"], (queue<string>*)curEnv["__arglist__"]);
    
    nodeType* args=p->opr.op[1];
    if(args!=NULL) ex(args,curEnv);
    
    nodeType* stmt=(nodeType*)func["__stmt__"];
    ex(stmt,curEnv);
    
    return 0;
}

nodeType* constructNode(nodeType *p, smap& env)
{
    switch (p->type)
    {
        case typeFuncDef:
        {
            exFuncDef(p,env);
        }
    }
    return 0;
}

extern "C" int ex(nodeType *p, smap& env) {
    LOG("%d",p->type);
    if (!p) return 0;
    switch(p->type) {
        //here should make con to a nodeType too
    case typeCon:       return p->con.value;
    case typeId:        return (int)env[p->id.name];

    case typeOpr:
        LOG("opr %d %c",p->opr.oper,p->opr.oper);
        switch(p->opr.oper) {
        case typeFuncDef:   return (int)exFuncDef(p,env);
        case typeArgDef:
        {
            queue<string>* v=new queue<string>;
            env["arglist"]=v;
            return (int)exArgDef(p,env);
        }
        case typeCall:
        {
            return (int)exCallFunction(p,env);
        }
        case ',':
        {
            return (int)exArgUse(p,env);
        }
        case WHILE:     while(ex(p->opr.op[0],env)) ex(p->opr.op[1],env); return 0;
        //each ifstmt has its return val,return 1 means this ifstmt executed.
        case IF:
		{
			if (ex(p->opr.op[0], env))
			{
				ex(p->opr.op[1], env);
				return 1;
			}
			else return 0;
		}
		//each ifstmt has its return val,return 1 means this ifstmt executed.
		case ELSEIF:
		{
			//elseif

			if (ex(p->opr.op[0], env)) return 1;
			else
			{
				if (ex(p->opr.op[1], env))
				{
					ex(p->opr.op[2], env);
					return 1;
				}
				else
				{
					return 0;
				}
			}
		}
        case ELSE:      if(ex(p->opr.op[0],env)==0) ex(p->opr.op[1],env);
                        return 0;
        case PRINT:     printf("%d\n", ex(p->opr.op[0],env)); return 0;
        case ';':       ex(p->opr.op[0],env); return ex(p->opr.op[1],env);
		case '=':       env[(p->opr.op[0])->id.name] = (void*)ex(p->opr.op[1], env); return 0;
        case UMINUS:    return -ex(p->opr.op[0],env);
        
        case '+':       return ex(p->opr.op[0],env) + ex(p->opr.op[1],env);
        case '-':       return ex(p->opr.op[0],env) - ex(p->opr.op[1],env);
        case '*':       return ex(p->opr.op[0],env) * ex(p->opr.op[1],env);
        case '/':       return ex(p->opr.op[0],env) / ex(p->opr.op[1],env);
        case '<':       return ex(p->opr.op[0],env) < ex(p->opr.op[1],env);
        case '>':       return ex(p->opr.op[0],env) > ex(p->opr.op[1],env);
        case GE:        return ex(p->opr.op[0],env) >= ex(p->opr.op[1],env);
        case LE:        return ex(p->opr.op[0],env) <= ex(p->opr.op[1],env);
        case NE:        return ex(p->opr.op[0],env) != ex(p->opr.op[1],env);
        case EQ:        return ex(p->opr.op[0],env) == ex(p->opr.op[1],env);
        
        }
    
    
    }
    return 0;
}
