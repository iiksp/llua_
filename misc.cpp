#include "misc.h"

namespace Misc
{
	char* encryptName(char* n)
	{
		char* out = (char*)malloc(strlen(n));
		for (int i = 0; i < strlen(n); i++, n++)
		{
			*(out + i) = *(n + i) ^ EKEY;
		}
		return out;
	}
	Tag::Tag(TyTag bc, int p):t(bc),pos(p)
	{
	}
}