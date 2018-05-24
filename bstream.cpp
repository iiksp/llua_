#include "bstream.h"
#include "fstream"
#include "iostream"



bstream::bstream(char * fn)
{
	ifstream ifs(fn);
	int size = ifs.tellg();
	ifs.seekg(0, ios::beg);

	BYTE* temp = new BYTE[size];
	ifs.read(temp, size);

	concat(temp, size);
	delete[] temp;
}

bstream::bstream(BYTE * bs, int count)
{
	concat(bs, count);
}

bstream::bstream() 
{

}

void bstream::concat(BYTE_CODE b)
{
	concat((BYTE)((int)b & 0xff));
}
void bstream::concat(BYTE b)
{
	res.push_back(b);
}
void bstream::concat(BYTE* bs, int count)
{
	//for (int i = 0; i < count; i++)
	//{
	//	res.push_back(bs[i]);
	//}

	res.insert(res.end(), bs, bs + count);
}
void bstream::concat(string s)
{
	concat((int)s.length());
	concat((BYTE*)s.c_str(), s.length());
}
void bstream::concat(int i)
{
	//LOG("%d:%d", length(), i);
	BYTE* ib = (BYTE*)&i;
	concat(ib, sizeof(int));
}
void bstream::print()
{
	for (BYTE b : res)
	{
		printf("%02X", b);
	}
	printf("\n total:%d \n",res.size());

	BYTE* b = toBuffer();
	int size = res.size();
	//for (int i = 0; i < size; i++, b++) printf("%02X", *b);
}

BYTE bstream::readB()
{
	return 0;
}

BYTE * bstream::toBuffer()
{
	return reinterpret_cast<BYTE*>(res.data());
}

int bstream::length()
{
	return res.size();
}

void bstream::modify(int pos, BYTE b)
{
	res[pos] = b;
}

void bstream::modify(int pos, int i)
{
	BYTE* ib = (BYTE*)&i;
	for (int ii = 0; ii < sizeof(int); ii++)
	{
		res[pos + ii] = *(ib + ii);
	}
}

