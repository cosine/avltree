#!/bin/sh
#
# xAVLTree.c.sh: Source code generator for AVLTree library.
# Copyright (C) 1998,2001  Michael H. Buselli
# This is version 0.1.3 (alpha).
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
# The author of this library can be reached by email at <cosine@cosine.org>.
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
 * ${x}AVLTree.c: Source code for ${x}AVLTrees.
 * Copyright (C) 1998,2001  Michael H. Buselli
 * This is version 0.1.3 (alpha).
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
 * The author of this library can be reached by email at <cosine@cosine.org>.
 * The official web page for this product is:
 * http://www.cosine.org/project/AVLTree/
 */

#include <stdlib.h>
#include "${x}AVLTree.h"

static ${x}AVLNode *${x}AVLCloseSearchNode\
 (${x}AVLTree const *avltree, ${x}AVLKey key);
static void ${x}AVLRebalanceNode\
 (${x}AVLTree *avltree, ${x}AVLNode *avlnode);
static void ${x}AVLFreeBranch\
 (${x}AVLNode *avlnode, void (freeitem)(void *item));
static void ${x}AVLFillVacancy (${x}AVLTree *avltree,
        ${x}AVLNode *origparent, ${x}AVLNode **superparent,
        ${x}AVLNode *left, ${x}AVLNode *right);

#define MAX(x, y)      ((x) > (y) ? (x) : (y))
#define MIN(x, y)      ((x) < (y) ? (x) : (y))
#define L_DEPTH(n)     ((n)->left ? (n)->left->depth : 0)
#define R_DEPTH(n)     ((n)->right ? (n)->right->depth : 0)
#define CALC_DEPTH(n)  (MAX(L_DEPTH(n), R_DEPTH(n)) + 1)


/*
 * AVLAllocTree:
 * Allocate memory for a new AVL tree and set the getkey function for
 * that tree.  The getkey function should take an item and return an
 * AVLKey that is to be used for indexing this object in the AVL tree.
 * On success, a pointer to the malloced AVLTree is returned.  If there
 * was a malloc failure, then NULL is returned.
 */
---- gAVLbegin ----
${x}AVLTree *${x}AVLAllocTree (${x}AVLKey (*getkey)(void const *item))
---- gAVLend ----
++++ gAVLbegin ++++
${x}AVLTree *${x}AVLAllocTree (${x}AVLKey (*getkey)(void const *item),
        ${x}AVLCompare cmp)
++++ gAVLend ++++
{
  ${x}AVLTree *rc;

  rc = malloc(sizeof(${x}AVLTree));
  if (rc == NULL)
    return NULL;

  rc->top = NULL;
  rc->count = 0;
  rc->getkey = getkey;
++++ gAVLbegin ++++
  rc->cmp = cmp;
++++ gAVLend ++++
  return rc;
}


/*
 * AVLFreeTree:
 * Free all memory used by this AVL tree.  If freeitem is not NULL, then
 * it is assumed to be a destructor for the items reference in the AVL
 * tree, and they are deleted as well.
 */
void ${x}AVLFreeTree (${x}AVLTree *avltree, void (freeitem)(void *item))
{
  if (avltree->top)
    ${x}AVLFreeBranch(avltree->top, freeitem);
  free(avltree);
}


/*
 * AVLInsert:
 * Create a new node and insert an item there.
 *
 * Returns  0 on success,
 *         -1 on malloc failure,
 *          3 if duplicate key.
 */
int ${x}AVLInsert (${x}AVLTree *avltree, void *item)
{
  ${x}AVLNode *newnode;
  ${x}AVLNode *node;
  ${x}AVLNode *balnode;
  ${x}AVLNode *nextbalnode;

  newnode = malloc(sizeof(${x}AVLNode));
  if (newnode == NULL)
    return -1;

  newnode->key = avltree->getkey(item);
  newnode->item = item;
  newnode->depth = 1;
  newnode->left = NULL;
  newnode->right = NULL;
  newnode->parent = NULL;

  if (avltree->top != NULL) {
    node = ${x}AVLCloseSearchNode(avltree, newnode->key);

    if (!${x}AVLKey_cmp(avltree, node->key, newnode->key)) {
      free(newnode);
      return 3;
    }

    newnode->parent = node;

    if (${x}AVLKey_cmp(avltree, newnode->key, node->key) < 0) {
      node->left = newnode;
      node->depth = CALC_DEPTH(node);
    }

    else {
      node->right = newnode;
      node->depth = CALC_DEPTH(node);
    }

    for (balnode = node->parent; balnode; balnode = nextbalnode) {
      nextbalnode = balnode->parent;
      ${x}AVLRebalanceNode(avltree, balnode);
    }
  }

  else {
    avltree->top = newnode;
  }

  avltree->count++;
  return 0;
}


/*
 * ${x}AVLSearch:
 * Return a pointer to the item with the given key in the AVL tree.  If
 * no such item is in the tree, then NULL is returned.
 */
void *${x}AVLSearch (${x}AVLTree const *avltree, ${x}AVLKey key)
{
  ${x}AVLNode *node;

  node = ${x}AVLCloseSearchNode(avltree, key);

  if (node && !${x}AVLKey_cmp(avltree, node->key, key))
    return node->item;

  return NULL;
}


/*
 * ${x}AVLDelete:
 * Deletes the node with the given key.  Does not delete the item at
 * that key.  Returns 0 on success and -1 if a node with the given key
 * does not exist.
 */
int ${x}AVLDelete (${x}AVLTree *avltree, ${x}AVLKey key)
{
  ${x}AVLNode *avlnode;
  ${x}AVLNode *origparent;
  ${x}AVLNode **superparent;

  avlnode = ${x}AVLCloseSearchNode(avltree, key);
  if (avlnode == NULL || ${x}AVLKey_cmp(avltree, avlnode->key, key))
    return -1;

  origparent = avlnode->parent;

  if (origparent) {
    if (${x}AVLKey_cmp(avltree, avlnode->key, avlnode->parent->key) < 0)
      superparent = &(avlnode->parent->left);
    else
      superparent = &(avlnode->parent->right);
  }
  else
    superparent = &(avltree->top);

  ${x}AVLFillVacancy(avltree, origparent, superparent,
                  avlnode->left, avlnode->right);
  free(avlnode);
  avltree->count--;
  return 0;
}


/*
 * ${x}AVLFirst:
 * Initializes an ${x}AVLCursor object and returns the item with the lowest
 * key in the ${x}AVLTree.
 */
void *${x}AVLFirst (${x}AVLCursor *avlcursor, ${x}AVLTree const *avltree)
{
  const ${x}AVLNode *avlnode;

  avlcursor->avltree = avltree;

  if (avltree->top == NULL) {
    avlcursor->curnode = NULL;
    return NULL;
  }

  for (avlnode = avltree->top;
       avlnode->left != NULL;
       avlnode = avlnode->left);
  avlcursor->curnode = avlnode;
  return avlnode->item;
}


/*
 * ${x}AVLNext:
 * Called after an ${x}AVLFirst() call, this returns the item with the least
 * key that is greater than the last item returned either by ${x}AVLFirst()
 * or a previous invokation of this function.
 */
void *${x}AVLNext (${x}AVLCursor *avlcursor)
{
  const ${x}AVLNode *avlnode;

  avlnode = avlcursor->curnode;

  if (avlnode->right != NULL) {
    for (avlnode = avlnode->right;
         avlnode->left != NULL;
         avlnode = avlnode->left);
    avlcursor->curnode = avlnode;
    return avlnode->item;
  }

  while (avlnode->parent && avlnode->parent->left != avlnode) {
    avlnode = avlnode->parent;
  }

  if (avlnode->parent == NULL) {
    avlcursor->curnode = NULL;
    return NULL;
  }

  avlcursor->curnode = avlnode->parent;
  return avlnode->parent->item;
}


/*
 * ${x}AVLCloseSearchNode:
 * Return a pointer to the node closest to the given key.
 * Returns NULL if the AVL tree is empty.
 */
${x}AVLNode *${x}AVLCloseSearchNode (${x}AVLTree const *avltree, ${x}AVLKey key)
{
  ${x}AVLNode *node;

  node = avltree->top;

  if (!node)
    return NULL;

  for (;;) {
    if (!${x}AVLKey_cmp(avltree, node->key, key))
      return node;

    if (${x}AVLKey_cmp(avltree, node->key, key) < 0) {
      if (node->right)
        node = node->right;
      else
        return node;
    }

    else {
      if (node->left)
        node = node->left;
      else
        return node;
    }
  }
}


/*
 * ${x}AVLRebalanceNode:
 * Rebalances the AVL tree if one side becomes too heavy.  This function
 * assumes that both subtrees are AVL trees with consistant data.  This
 * function has the additional side effect of recalculating the depth of
 * the tree at this node.  It should be noted that at the return of this
 * function, if a rebalance takes place, the top of this subtree is no
 * longer going to be the same node.
 */
void ${x}AVLRebalanceNode (${x}AVLTree *avltree, ${x}AVLNode *avlnode)
{
  long depthdiff;
  ${x}AVLNode *child;
  ${x}AVLNode *gchild;
  ${x}AVLNode *origparent;
  ${x}AVLNode **superparent;

  origparent = avlnode->parent;

  if (origparent) {
    if (${x}AVLKey_cmp(avltree, avlnode->key, avlnode->parent->key) < 0)
      superparent = &(avlnode->parent->left);
    else
      superparent = &(avlnode->parent->right);
  }
  else
    superparent = &(avltree->top);

  depthdiff = R_DEPTH(avlnode) - L_DEPTH(avlnode);

  if (depthdiff <= -2) {
    child = avlnode->left;

    if (L_DEPTH(child) >= R_DEPTH(child)) {
      avlnode->left = child->right;
      if (avlnode->left != NULL)
        avlnode->left->parent = avlnode;
      avlnode->depth = CALC_DEPTH(avlnode);
      child->right = avlnode;
      if (child->right != NULL)
        child->right->parent = child;
      child->depth = CALC_DEPTH(child);
      *superparent = child;
      child->parent = origparent;
    }

    else {
      gchild = child->right;
      avlnode->left = gchild->right;
      if (avlnode->left != NULL)
        avlnode->left->parent = avlnode;
      avlnode->depth = CALC_DEPTH(avlnode);
      child->right = gchild->left;
      if (child->right != NULL)
        child->right->parent = child;
      child->depth = CALC_DEPTH(child);
      gchild->right = avlnode;
      if (gchild->right != NULL)
        gchild->right->parent = gchild;
      gchild->left = child;
      if (gchild->left != NULL)
        gchild->left->parent = gchild;
      gchild->depth = CALC_DEPTH(gchild);
      *superparent = gchild;
      gchild->parent = origparent;
    }
  }

  else if (depthdiff >= 2) {
    child = avlnode->right;

    if (R_DEPTH(child) >= L_DEPTH(child)) {
      avlnode->right = child->left;
      if (avlnode->right != NULL)
        avlnode->right->parent = avlnode;
      avlnode->depth = CALC_DEPTH(avlnode);
      child->left = avlnode;
      if (child->left != NULL)
        child->left->parent = child;
      child->depth = CALC_DEPTH(child);
      *superparent = child;
      child->parent = origparent;
    }

    else {
      gchild = child->left;
      avlnode->right = gchild->left;
      if (avlnode->right != NULL)
        avlnode->right->parent = avlnode;
      avlnode->depth = CALC_DEPTH(avlnode);
      child->left = gchild->right;
      if (child->left != NULL)
        child->left->parent = child;
      child->depth = CALC_DEPTH(child);
      gchild->left = avlnode;
      if (gchild->left != NULL)
        gchild->left->parent = gchild;
      gchild->right = child;
      if (gchild->right != NULL)
        gchild->right->parent = gchild;
      gchild->depth = CALC_DEPTH(gchild);
      *superparent = gchild;
      gchild->parent = origparent;
    }
  }

  else {
    avlnode->depth = CALC_DEPTH(avlnode);
  }
}


/*
 * ${x}AVLFreeBranch:
 * Free memory used by this node and its item.  If the freeitem argument
 * is not NULL, then that function is called on the items to free their
 * memory as well.  In other words, the freeitem function is a
 * destructor for the items in the tree.
 */
void ${x}AVLFreeBranch (${x}AVLNode *avlnode, void (freeitem)(void *item))
{
  if (avlnode->left)
    ${x}AVLFreeBranch(avlnode->left, freeitem);
  if (avlnode->right)
    ${x}AVLFreeBranch(avlnode->right, freeitem);
  if (freeitem)
    freeitem(avlnode->item);
  free(avlnode);
}


/*
 * ${x}AVLFillVacancy:
 * Given a vacancy in the AVL tree by it's parent, children, and parent
 * component pointer, fill that vacancy.
 */
void ${x}AVLFillVacancy (${x}AVLTree *avltree,
                      ${x}AVLNode *origparent, ${x}AVLNode **superparent,
                      ${x}AVLNode *left, ${x}AVLNode *right)
{
  ${x}AVLNode *avlnode;
  ${x}AVLNode *balnode;
  ${x}AVLNode *nextbalnode;

  if (left == NULL) {
    if (right)
      right->parent = origparent;

    *superparent = right;
    balnode = origparent;
  }

  else {
    for (avlnode = left; avlnode->right != NULL; avlnode = avlnode->right);

    if (avlnode == left) {
      balnode = avlnode;
    }
    else {
      balnode = avlnode->parent;
      balnode->right = avlnode->left;
      if (balnode->right != NULL)
        balnode->right->parent = balnode;
      avlnode->left = left;
      left->parent = avlnode;
    }

    avlnode->right = right;
    if (right != NULL)
      right->parent = avlnode;
    *superparent = avlnode;
    avlnode->parent = origparent;
  }

  for (; balnode; balnode = nextbalnode) {
    nextbalnode = balnode->parent;
    ${x}AVLRebalanceNode(avltree, balnode);
  }
}
__EOF__
