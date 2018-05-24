#pragma once
#include "main.h"
#include "bc.h"

class bstream
{
public:
	vector<BYTE> res;

	bstream();
	bstream(char* fn);
	bstream(BYTE* bs, int count);

	void concat(BYTE_CODE b);	
	void concat(BYTE b);
	void concat(BYTE* bs, int count);
	void concat(string s);
	void concat(int i);

	void print();

	BYTE readB();
	void readS(OUT BYTE* out);

	BYTE* toBuffer();
	int length();
	void modify(int pos, BYTE b);
	void modify(int pos, int i);
};
