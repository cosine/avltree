#include <stdlib.h>
#include "zAVLTree.h"

static AVLNode *AVLCloseSearchNode (AVLTree const *avltree, const char *key);
static void AVLRebalanceNode (AVLTree *avltree, AVLNode *avlnode);
static void AVLFreeBranch (AVLNode *avlnode, void (freeitem)(void *item));
static void AVLFillVacancy (AVLNode *origparent, AVLNode **superparent,
                            AVLNode *left, AVLNode *right);

#define MAX(x, y)      ((x) > (y) ? (x) : (y))
#define MIN(x, y)      ((x) < (y) ? (x) : (y))
#define L_DEPTH(n)     ((n)->left ? (n)->left->depth : 0)
#define R_DEPTH(n)     ((n)->right ? (n)->right->depth : 0)
#define CALC_DEPTH(n)  (MAX(L_DEPTH(n), R_DEPTH(n)) + 1)


/*
 * AVLAllocTree:
 * Allocate memory for a new AVL tree and set the getkey function for
 * that tree.  The getkey function should take an item and return a
 * const char * that is to be used for indexing this object in the AVL
 * tree.  On success, a pointer to the malloced AVLTree is returned.  If
 * there was a malloc failure, then NULL is returned.
 */
AVLTree *AVLAllocTree (const char *(*getkey)(void const *item))
{
  AVLTree *rc;

  rc = malloc(sizeof(AVLTree));
  if (rc == NULL)
    return NULL;

  rc->top = NULL;
  rc->count = 0;
  rc->getkey = getkey;
  return rc;
}


/*
 * AVLFreeTree:
 * Free all memory used by this AVL tree.  If freeitem is not NULL, then
 * it is assumed to be a destructor for the items reference in the AVL
 * tree, and they are deleted as well.
 */
void AVLFreeTree (AVLTree *avltree, void (freeitem)(void *item))
{
  if (avltree->top)
    AVLFreeBranch(avltree->top, freeitem);
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
int AVLInsert (AVLTree *avltree, void *item)
{
  AVLNode *newnode;
  AVLNode *node;
  AVLNode *balnode;
  AVLNode *nextbalnode;

  newnode = malloc(sizeof(AVLNode));
  if (newnode == NULL)
    return -1;

  newnode->key = avltree->getkey(item);
  newnode->item = item;
  newnode->depth = 1;
  newnode->left = NULL;
  newnode->right = NULL;
  newnode->parent = NULL;

  if (avltree->top != NULL) {
    node = AVLCloseSearchNode(avltree, newnode->key);

    if (!strcmp(node->key, newnode->key)) {
      free(newnode);
      return 3;
    }

    newnode->parent = node;

    if (strcmp(newnode->key, node->key) < 0) {
      node->left = newnode;
      node->depth = CALC_DEPTH(node);
    }

    else {
      node->right = newnode;
      node->depth = CALC_DEPTH(node);
    }

    for (balnode = node->parent; balnode; balnode = nextbalnode) {
      nextbalnode = balnode->parent;
      AVLRebalanceNode(avltree, balnode);
    }
  }

  else {
    avltree->top = newnode;
  }

  avltree->count++;
  return 0;
}


/*
 * AVLSearch:
 * Return a pointer to the item with the given key in the AVL tree.  If
 * no such item is in the tree, then NULL is returned.
 */
void *AVLSearch (AVLTree const *avltree, const char *key)
{
  AVLNode *node;

  node = AVLCloseSearchNode(avltree, key);

  if (node && !strcmp(node->key, key))
    return node->item;

  return NULL;
}


/*
 * AVLDelete:
 * Deletes the node with the given key.  Does not delete the item at
 * that key.  Returns 0 on success and -1 if a node with the given key
 * does not exist.
 */
int AVLDelete (AVLTree *avltree, const char *key)
{
  AVLNode *avlnode;
  AVLNode *origparent;
  AVLNode **superparent;

  avlnode = AVLCloseSearchNode(avltree, key);
  if (avlnode == NULL || strcmp(avlnode->key, key))
    return -1;

  origparent = avlnode->parent;

  if (origparent) {
    if (strcmp(avlnode->key, avlnode->parent->key) < 0)
      superparent = &(avlnode->parent->left);
    else
      superparent = &(avlnode->parent->right);
  }
  else
    superparent = &(avltree->top);

  AVLFillVacancy(origparent, superparent, avlnode->left, avlnode->right);
  free(avlnode);
  avltree->count--;
  return 0;
}


/*
 * AVLFirst:
 * Initializes an AVLCursor object and returns the item with the lowest
 * key in the AVLTree.
 */
void *AVLFirst (AVLCursor *avlcursor, AVLTree const *avltree)
{
  const AVLNode *avlnode;

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
 * AVLNext:
 * Called after an AVLFirst() call, this returns the item with the least
 * key that is greater than the last item returned either by AVLFirst()
 * or a previous invokation of this function.
 */
void *AVLNext (AVLCursor *avlcursor)
{
  const AVLNode *avlnode;

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
 * AVLCloseSearchNode:
 * Return a pointer to the node closest to the given key.
 * Returns NULL if the AVL tree is empty.
 */
AVLNode *AVLCloseSearchNode (AVLTree const *avltree, const char *key)
{
  AVLNode *node;

  node = avltree->top;

  if (!node)
    return NULL;

  for (;;) {
    if (!strcmp(node->key, key))
      return node;

    if (strcmp(node->key, key) < 0) {
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
 * AVLRebalanceNode:
 * Rebalances the AVL tree if one side becomes too heavy.  This function
 * assumes that both subtrees are AVL trees with consistant data.  This
 * function has the additional side effect of recalculating the depth of
 * the tree at this node.  It should be noted that at the return of this
 * function, if a rebalance takes place, the top of this subtree is no
 * longer going to be the same node.
 */
void AVLRebalanceNode (AVLTree *avltree, AVLNode *avlnode)
{
  long depthdiff;
  AVLNode *child;
  AVLNode *gchild;
  AVLNode *origparent;
  AVLNode **superparent;

  origparent = avlnode->parent;

  if (origparent) {
    if (strcmp(avlnode->key, avlnode->parent->key) < 0)
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
 * AVLFreeBranch:
 * Free memory used by this node and its item.  If the freeitem argument
 * is not NULL, then that function is called on the items to free their
 * memory as well.  In other words, the freeitem function is a
 * destructor for the items in the tree.
 */
void AVLFreeBranch (AVLNode *avlnode, void (freeitem)(void *item))
{
  if (avlnode->left)
    AVLFreeBranch(avlnode->left, freeitem);
  if (avlnode->right)
    AVLFreeBranch(avlnode->right, freeitem);
  if (freeitem)
    freeitem(avlnode->item);
  free(avlnode);
}


/*
 * AVLFillVacancy:
 * Given a vacancy in the AVL tree by it's parent, children, and parent
 * component pointer, fill that vacancy.
 */
void AVLFillVacancy (AVLNode *origparent, AVLNode **superparent,
                     AVLNode *left, AVLNode *right)
{
  if (left == NULL) {
    if (right == NULL)
      return;

    *superparent = right;
    right->parent = origparent;
  }

  else if (right == NULL) {
    *superparent = left;
    left->parent = origparent;
  }

  else if (left->depth >= right->depth) {
    *superparent = left;
    left->parent = origparent;
    AVLFillVacancy(left, &(left->right), left->right, right);
    left->depth = CALC_DEPTH(left);
  }

  else {
    *superparent = right;
    right->parent = origparent;
    AVLFillVacancy(right, &(right->left), right->left, left);
    right->depth = CALC_DEPTH(right);
  }
}
