#ifndef _IAVLTREE_H_
#define _IAVLTREE_H_


typedef struct _iAVLNode {
  long key;
  long depth;
  void *item;
  struct _iAVLNode *parent;
  struct _iAVLNode *left;
  struct _iAVLNode *right;
} iAVLNode;


typedef struct {
  iAVLNode *top;
  long count;
  long (*getkey)(const void *item);
} iAVLTree;


typedef struct {
  const iAVLTree *avltree;
  const iAVLNode *curnode;
} iAVLCursor;


extern iAVLTree *iAVLAllocTree (long (*getkey)(void const *item));
extern void iAVLFreeTree (iAVLTree *avltree, void (freeitem)(void *item));
extern int iAVLInsert (iAVLTree *avltree, void *item);
extern void *iAVLSearch (iAVLTree const *avltree, long key);
extern int iAVLDelete (iAVLTree *avltree, long key);
extern void *iAVLFirst (iAVLCursor *avlcursor, iAVLTree const *avltree);
extern void *iAVLNext (iAVLCursor *avlcursor);


#endif
