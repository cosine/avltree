#ifndef _AVLTREE_H_
#define _AVLTREE_H_


typedef struct _AVLNode {
  const char *key;
  long depth;
  void *item;
  struct _AVLNode *parent;
  struct _AVLNode *left;
  struct _AVLNode *right;
} AVLNode;


typedef struct {
  AVLNode *top;
  long count;
  (const char *)(*getkey)(const void *item);
} AVLTree;


typedef struct {
  AVLTree *avltree;
  AVLNode *curnode;
} AVLCursor;


extern AVLTree *AVLAllocTree ((const char *)(*getkey)(const void *item));
extern void AVLFreeTree (AVLTree *avltree, void (freeitem)(void *item));
extern int AVLInsert (AVLTree *avltree, void *item);
extern void *AVLSearch (const AVLTree *avltree, const char *key);
extern int AVLDelete (AVLTree *avltree, const char *key);
extern void *AVLFirst (AVLCursor *avlcursor, AVLTree *avltree);
extern void *AVLNext (AVLCursor *avlcursor);


#endif
