YY=yacc
CC=gcc
YSRCS=$(wildcard *.y)
CSRCS=y.tab.c
OBJS=$(CSRCS:.c=.o)
CFLAGS=-Wall -std=c11

hoc1:
	$(CC) -o $@ $(CSRCS) $(CFLAGS)

hoc1: $(OBJS)
$(CSRCS): $(YSRCS)
	$(YY) $(YSRCS)

clean:
	rm -rf hoc1 *.o *~ tmp* a.out \#* y.tab.c
