#include "main.h"
#include "bc.h"
#include "string.h"
#include "bstream.h"
#include "misc.h"
#include "yacc.tab.h"


#define EKEY 0x63
FILE* out;



extern "C" int compile(nodeType* p);

namespace VM
{
	using namespace Misc;
	bstream bcres;
	stack<Tag> tagStack;
	int vm(nodeType* p);
	void pushn(int n);


	int argsn = 0;
	void pushArgs(nodeType* p)
	{
		argsn += 1;
		nodeType* next = p->opr.op[0];
		nodeType* cur = p->opr.op[1];

		vm(cur);//push current arg.
		vm(next);//recursive.
	}

	void callFunc(nodeType* p)
	{
		string name = (char*)(p->opr.op[0]);
		nodeType* args = p->opr.op[1];
		argsn = 0;
		if (args != NULL)
		{
			vm(args);//push arg.
			argsn += 1;
		}
		
		pushn(argsn);

		LOG("call %s", name.c_str());
		bcres.concat(BYTE_CODE::CALL);
		bcres.concat(name);
	}

	void pushn(int n)
	{
		LOG("pushn %d", n);
		bcres.concat(BYTE_CODE::PUSHN);
		bcres.concat(n);
	}

	int vm(nodeType* p)
	{
		//LOG("%d", p->type);
		if (!p) return 0;
		switch (p->type)
		{
			//here should make con to a nodeType too
		case typeCon:
			pushn(p->con.value);
			return 0;
		case typeStr:
		{
			LOG("pushs %s (strlen:%d)", p->id.name.c_str(),p->id.name.length());
			
			bcres.concat(BYTE_CODE::PUSHS);
			bcres.concat(p->id.name);
			return 0;
		}
		case typeId:
			LOG("pushv %s (strlen:%d)", p->id.name.c_str(),p->id.name.length());
			bcres.concat(BYTE_CODE::PUSHV);
			bcres.concat(p->id.name);
			return 0;

		case typeOpr:
			//LOG("opr %d %c", p->opr.oper, p->opr.oper);
			switch (p->opr.oper)
			{
				case '=':
				{
					nodeType* dst = p->opr.op[0];
					nodeType* src = p->opr.op[1];
					vm(src);
					LOG("set %s", dst->id.name.c_str());
					bcres.concat(BYTE_CODE::SET);
					bcres.concat(dst->id.name);
					return 0;
				}
				case '+':
				{
					vm(p->opr.op[0]);
					vm(p->opr.op[1]);
					LOG("add");
					bcres.concat(BYTE_CODE::ADD);
					return 0;
				}
				case '-':
				{
					vm(p->opr.op[0]);
					vm(p->opr.op[1]);
					LOG("minus");
					bcres.concat(BYTE_CODE::MINUS);
					return 0;
				}
				case '*':
				{
					vm(p->opr.op[0]);
					vm(p->opr.op[1]);
					LOG("mul");
					bcres.concat(BYTE_CODE::MUL);
					return 0;
				}
				case '/':
				{
					vm(p->opr.op[0]);
					vm(p->opr.op[1]);
					LOG("div");
					bcres.concat(BYTE_CODE::DIV);
					return 0;
				}
				case '%':
				{
					vm(p->opr.op[0]);
					vm(p->opr.op[1]);
					LOG("MOD");
					bcres.concat(BYTE_CODE::MOD);
					return 0;
				}
				case ';':
				{
					vm(p->opr.op[0]);
					vm(p->opr.op[1]);
					return 0;
				}
				case IF:
				{
					vm(p->opr.op[0]);
					bcres.concat(BYTE_CODE::BNE);

					//tagStack.push(Tag(IF, bcres.res.size())); 
					bcres.concat(0);//nop here
					int fixPos = bcres.length() - sizeof(int);//save offset here to modify later.
					LOG("%d:BNE none",fixPos);

					vm(p->opr.op[1]);//if true.
					int cur = bcres.length();
					bcres.modify(fixPos, cur - (fixPos + 4));
					LOG("cur %d,fix %d:BNE %d", cur, fixPos, cur - fixPos);
					
					return 0;
				}
				case WHILE:
				{
					int begin = bcres.length();
					LOG("%d:WHILE", begin);
					vm(p->opr.op[0]);//the condition statments.

					bcres.concat(BYTE_CODE::BNE);
					int fixMid = bcres.length();
					bcres.concat(0);//nop here.
					LOG("%d:BNE none", fixMid);

					vm(p->opr.op[1]);//into loop.

					bcres.concat(BYTE_CODE::PUSHN);//push false to jump.
					bcres.concat(0);
					bcres.concat(BYTE_CODE::BNE);
					int end = bcres.length() + sizeof(int);
					bcres.concat(begin - end);//jump back to the beginning
					LOG("%d:JUMP_BACK %d", end, begin - end);

					bcres.modify(fixMid, end - (fixMid + 4));//modify mid nop.
					LOG("cur %d,fix %d:BNE %d", end, fixMid, end - fixMid);

					return 0;
				}
				case UMINUS:
				{
					vm(p->opr.op[0]);
					bcres.concat(BYTE_CODE::UMINUS);
					LOG("UMINUS");
					return 0;
				}
				case '<':
				{
					vm(p->opr.op[0]);
					vm(p->opr.op[1]);
					LOG("LT");
					bcres.concat(BYTE_CODE::LT);
					return 0;
				}
				case '>':
				{
					vm(p->opr.op[0]);
					vm(p->opr.op[1]);
					LOG("GT");
					bcres.concat(BYTE_CODE::GT);
					return 0;
				}       
				case GE:
				{
					vm(p->opr.op[0]);
					vm(p->opr.op[1]);
					LOG("GE");
					bcres.concat(BYTE_CODE::GE);
					return 0;
				}        
				case LE:
				{
					vm(p->opr.op[0]);
					vm(p->opr.op[1]);
					LOG("LE");
					bcres.concat(BYTE_CODE::LE);
					return 0;
				} 
				case NE:
				{
					vm(p->opr.op[0]);
					vm(p->opr.op[1]);
					LOG("NE");
					bcres.concat(BYTE_CODE::NE);
					return 0;
				}       
				case EQ:
				{
					vm(p->opr.op[0]);
					vm(p->opr.op[1]);
					LOG("EQ");
					bcres.concat(BYTE_CODE::EQ);
					return 0;
				}
				case ',':
				{
					pushArgs(p);
					return 0;
				}
				case typeCall:
				{
					callFunc(p);
					return 0;
				}
			}
		}
		return 0;
	}
}

using namespace VM;
int compile(nodeType* p)
{
	LOG("alloc");
	out = fopen("out.lluac", "wb");
	//getchar();
	vm(p);
	bcres.print();
	fwrite(bcres.toBuffer(), 1, bcres.length(), out);
	fclose(out);
	return 0;
}