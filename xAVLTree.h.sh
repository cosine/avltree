#!/bin/sh
#
# xAVLTree.h.sh: Header file generator for AVLTree library.
# Copyright (C) 1998,2001  Michael H. Buselli
# This is version 0.1.2 (alpha).
# $Id: xAVLTree.h.sh,v 1.1 2001-03-04 19:43:06 cosine Exp $
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public
# License along with this library; if not, write to the Free
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# The author of this library can be reached at the following address:
# Michael H. Buselli
# 30051 N. Waukegan Rd. Apt. 103
# Lake Bluff, IL  60044-5412
#
# Or you can send email to <cosine@cosine.org>.
# The official web page for this product is:
# http://www.cosine.org/project/AVLTree/
#

# Replacement variables
x=`echo "$1" | tr '[A-Z]' '[a-z]'`
X=`echo "$1" | tr '[a-z]' '[A-Z]'`

cat <<__EOF__ | \
  sed -e "/^----.* ${x}AVLbegin .*----\$/,/^----.* ${x}AVLend .*----\$/d" \
    -e "/^++++ [^${x}]AVLbegin ++++\$/,/^++++ [^${x}]AVLend ++++\$/d" | \
  grep -v '^---- .* ----$' | \
  grep -v '^++++ .* ++++$'
/*
 * ${x}AVLTree.h: Header file for ${x}AVLTrees.
 * Copyright (C) 1998,2001  Michael H. Buselli
 * This is version 0.1.2 (alpha).
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the Free
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * The author of this library can be reached at the following address:
 * Michael H. Buselli
 * 30051 N. Waukegan Rd. Apt. 103
 * Lake Bluff, IL  60044-5412
 *
 * Or you can send email to <cosine@cosine.org>.
 * The official web page for this product is:
 * http://www.cosine.org/project/AVLTree/
 */

#ifndef _${X}AVLTREE_H_
#define _${X}AVLTREE_H_

/* typedef the keytype */
++++ iAVLbegin ++++
typedef long iAVLKey;
++++ iAVLend ++++
++++ zAVLbegin ++++
typedef const char *zAVLKey;
++++ zAVLend ++++
++++ gAVLbegin ++++
typedef const void *gAVLKey;

/*
 * Comparison function for gAVLTrees.  It is important that for any A,
 * B, C, and D objects that if AVLCompare(a, b) < 0, AVLCompare(b, c) <
 * 0, and AVLCompare(a, d) == 0, then the following are also true:
 * AVLCompare(a, c) < 0, AVLCompare(b, a) > 0, AVLCompare(d, a) == 0.
 * This code cannot verify that the function supplied by the user has
 * this property--this is the coder's responsibility--but the code will
 * by default perform some sanity checks and the cost of performance.
 * Turn the sanity checks off in avlconfig.h by defining AVL_NO_SANITY.
 */
typedef int (*AVLCompare)(gAVLKey a, gAVLKey b);
++++ gAVLend ++++


typedef struct _${x}AVLNode {
  ${x}AVLKey key;
  long depth;
  void *item;
  struct _${x}AVLNode *parent;
  struct _${x}AVLNode *left;
  struct _${x}AVLNode *right;
} ${x}AVLNode;


typedef struct {
  ${x}AVLNode *top;
  long count;
  ${x}AVLKey (*getkey)(const void *item);
++++ gAVLbegin ++++
  AVLCompare cmp;
++++ gAVLend ++++
} ${x}AVLTree;


typedef struct {
  const ${x}AVLTree *avltree;
  const ${x}AVLNode *curnode;
} ${x}AVLCursor;


---- gAVLbegin ----
extern ${x}AVLTree *${x}AVLAllocTree (${x}AVLKey (*getkey)(void const *item));
---- gAVLend ----
++++ gAVLbegin ++++
extern ${x}AVLTree *${x}AVLAllocTree\
 (${x}AVLKey (*getkey)(void const *item), AVLCompare cmp);
++++ gAVLend ++++
extern void ${x}AVLFreeTree\
 (${x}AVLTree *avltree, void (freeitem)(void *item));
extern int ${x}AVLInsert (${x}AVLTree *avltree, void *item);
extern void *${x}AVLSearch (${x}AVLTree const *avltree, ${x}AVLKey key);
extern int ${x}AVLDelete (${x}AVLTree *avltree, ${x}AVLKey key);
extern void *${x}AVLFirst\
 (${x}AVLCursor *avlcursor, ${x}AVLTree const *avltree);
extern void *${x}AVLNext (${x}AVLCursor *avlcursor);

#endif
__EOF__
