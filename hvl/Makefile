CFLAGS?=-g -O2 -Wall -DNO_DPI
CXXFLAGS?=$(CFLAGS)
CC:=$(CXX)
LD:=$(CXX)

all: opcode_gen

opcode_gen: main.o opgen.o

clean:
	-rm -f opgen *.o

.PHONY: clean all
