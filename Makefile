#
# Copyright (C) 2001  Michael H. Buselli
# This is version 0.1.2 (alpha).
# $Id: Makefile,v 1.6 2001-03-04 22:17:49 cosine Exp $
#
# This file is released under the terms given in the LICENSE file
# included in this package.
#

CC = gcc
SED = sed
GREP = grep
CFLAGS = -ggdb
LDFLAGS =

IAVLFILES = iAVLTree.h iAVLTree.o
ZAVLFILES = zAVLTree.h zAVLTree.o
GAVLFILES = gAVLTree.h gAVLTree.o
TRANSFILES = iAVLTree.c zAVLTree.c gAVLTree.c avltest.o
TESTFILES = avltest

FILES = $(IAVLFILES) $(ZAVLFILES) $(GAVLFILES) $(TESTFILES)

all: $(FILES)

clean:
	rm -f $(FILES) $(TRANSFILES)

# The following rules generate the header files.
iAVLTree.h: xAVLTree.h.sh
	./xAVLTree.h.sh i > iAVLTree.h

zAVLTree.h: xAVLTree.h.sh
	./xAVLTree.h.sh z > zAVLTree.h

gAVLTree.h: xAVLTree.h.sh
	./xAVLTree.h.sh g > gAVLTree.h


# These generate the source code files.
iAVLTree.c: xAVLTree.c.sh
	./xAVLTree.c.sh i > iAVLTree.c

zAVLTree.c: xAVLTree.c.sh
	./xAVLTree.c.sh z > zAVLTree.c

gAVLTree.c: xAVLTree.c.sh
	./xAVLTree.c.sh g > gAVLTree.c


# Object files and executables.
iAVLTree.o: iAVLTree.c iAVLTree.h
	$(CC) $(CFLAGS) -o iAVLTree.o -c iAVLTree.c

zAVLTree.o: zAVLTree.c zAVLTree.h
	$(CC) $(CFLAGS) -o zAVLTree.o -c zAVLTree.c

avltest.o: avltest.c gAVLTree.h
	$(CC) $(CFLAGS) -o avltest.o -c avltest.c

avltest: avltest.o gAVLTree.o
	$(CC) $(LDFLAGS) -o avltest gAVLTree.o avltest.o

