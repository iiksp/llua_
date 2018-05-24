// testdll.cpp : main project file.

#include "stdafx.h"
#include "windows.h"
#include "stdio.h"

using namespace System;

int main(array<System::String ^> ^args)
{

	HINSTANCE hdll = LoadLibraryA("D:\\proj\\luajit\\LuaJIT-2.0.5\\src\\lua51.dll");

	typedef int(*tpunkHash_check)(char* s);
	tpunkHash_check pf = (tpunkHash_check)GetProcAddress(hdll, "punkHash_check");


    printf("%d",pf("sdfd"));
	getchar();
    return 0;
}
