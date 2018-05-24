LEX=flex
YACC=bison
LDFLAGS =-static-libgcc -static-libstdc++ -fpermissive
CXXFLAGS = -fpermissive -c -std=c++0x -g -ggdb -Ddebug -U__STRICT_ANSI__ 
CC=g++ $(CXXFLAGS)
LD=g++ $(LDFLAGS)

CPPSRC=interpreter.cpp compiler.cpp bstream.cpp
CPPOBJ=$(CPPSRC:.c=.o)
OBJECT=main			#���ɵ�Ŀ���ļ�

$(OBJECT): lex.yy.o  yacc.tab.o $(CPPOBJ)
	$(LD) $^ -o $(OBJECT)
	@./$(OBJECT) punkHash.llua	#�������������
	#lj vm.lua

lex.yy.o: lex.yy.c  yacc.tab.h  main.h
	$(CC) -c lex.yy.c

yacc.tab.o: yacc.tab.c main.h
	$(CC) -c $^
    
%.o: %.cpp
	$(CC) $^

yacc.tab.c  yacc.tab.h: yacc.y
#	bisonʹ��-d��������.y�ļ�
	$(YACC) -d yacc.y

lex.yy.c: lex.l
	$(LEX) lex.l

clean:
	@rm -f $(OBJECT)  *.o