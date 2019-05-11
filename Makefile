YY=yacc
CC=gcc
YSRCS=$(wildcard *.y)
CSRCS=y.tab.c
OBJS=$(CSRCS:.c=.o)
CFLAGS=-Wall -std=c11 -lm

hoc2:
	$(CC) -o $@ $(CSRCS) $(CFLAGS)

hoc2: $(OBJS)
$(CSRCS): $(YSRCS)
	$(YY) $(YSRCS)

clean:
	rm -rf hoc2 *.o *~ tmp* a.out \#* y.tab.c
