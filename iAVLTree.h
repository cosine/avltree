#ifndef _AVLTREE_H_
#define _AVLTREE_H_


typedef struct _AVLNode {
  long key;
  long depth;
  void *item;
  struct _AVLNode *parent;
  struct _AVLNode *left;
  struct _AVLNode *right;
} AVLNode;


typedef struct {
  AVLNode *top;
  long count;
  long (*getkey)(const void *item);
} AVLTree;


typedef struct {
  AVLTree *avltree;
  AVLNode *curnode;
} AVLCursor;


extern AVLTree *AVLAllocTree (long (*getkey)(const void *item));
extern void AVLFreeTree (AVLTree *avltree, void (freeitem)(void *item));
extern int AVLInsert (AVLTree *avltree, void *item);
extern void *AVLSearch (const AVLTree *avltree, long key);
extern int AVLDelete (AVLTree *avltree, long key);
extern void *AVLFirst (AVLCursor *avlcursor, AVLTree *avltree);
extern void *AVLNext (AVLCursor *avlcursor);


#endif
