#
# Copyright (C) 2001  Michael H. Buselli
# This is version 0.1.1 (alpha).
# $Id: Makefile,v 1.1 2001-03-04 05:52:18 cosine Exp $
#
# This file is released under the terms given in the LICENSE file
# included in this package.
#

CC = gcc
CFLAGS = -ggdb
LDFLAGS =

all: iAVLTree.o zAVLTree.o avltest

iAVLTree.o: iAVLTree.c iAVLTree.h
	$(CC) $(CFLAGS) -o iAVLTree.o -c iAVLTree.c

zAVLTree.o: zAVLTree.c zAVLTree.h
	$(CC) $(CFLAGS) -o zAVLTree.o -c zAVLTree.c

avltest.o: avltest.c zAVLTree.h
	$(CC) $(CFLAGS) -o avltest.o -c avltest.c

avltest: avltest.o zAVLTree.o
	$(CC) $(LDFLAGS) -o avltest zAVLTree.o avltest.o

