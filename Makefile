LEX=flex
YACC=bison
LDFLAGS =-static-libgcc -static-libstdc++ -fpermissive
CXXFLAGS = -fpermissive -c -std=c++0x -g -ggdb -Ddebug -U__STRICT_ANSI__ 
CC=g++ $(CXXFLAGS)
LD=g++ $(LDFLAGS)

CPPSRC=interpreter.cpp compiler.cpp bstream.cpp
CPPOBJ=$(CPPSRC:.c=.o)
OBJECT=main			#生成的目标文件

$(OBJECT): lex.yy.o  yacc.tab.o $(CPPOBJ)
	$(LD) $^ -o $(OBJECT)
	@./$(OBJECT) punkHash.llua	#编译后立刻运行
	#lj vm.lua

lex.yy.o: lex.yy.c  yacc.tab.h  main.h
	$(CC) -c lex.yy.c

yacc.tab.o: yacc.tab.c main.h
	$(CC) -c $^
    
%.o: %.cpp
	$(CC) $^

yacc.tab.c  yacc.tab.h: yacc.y
#	bison使用-d参数编译.y文件
	$(YACC) -d yacc.y

lex.yy.c: lex.l
	$(LEX) lex.l

clean:
	@rm -f $(OBJECT)  *.o