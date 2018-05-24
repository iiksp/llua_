#pragma once

#include "stack"
#include "yacc.tab.h"

namespace Misc
{
	char* encryptName(char* n);

	typedef yytokentype TyTag;
	class Tag
	{
	public:
		TyTag t;
		int pos;
		Tag(TyTag bc, int p);
	};

}
