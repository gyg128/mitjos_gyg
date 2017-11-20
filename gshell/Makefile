CC=gcc
EXE=gshell

all:${EXE}

gshell:gshell.o
	${CC} -o $@ $<

gshell.o:gshell.c
	${CC} -c $<

run:${EXE}
	./gshell

clean:
	rm -fr ${EXE} *.o
