#ifndef _ZAVLTREE_H_
#define _ZAVLTREE_H_


typedef struct _zAVLNode {
  const char *key;
  long depth;
  void *item;
  struct _zAVLNode *parent;
  struct _zAVLNode *left;
  struct _zAVLNode *right;
} zAVLNode;


typedef struct {
  zAVLNode *top;
  long count;
  const char *(*getkey)(const void *item);
} zAVLTree;


typedef struct {
  zAVLTree *avltree;
  zAVLNode *curnode;
} zAVLCursor;


extern zAVLTree *zAVLAllocTree (const char *(*getkey)(const void *item));
extern void zAVLFreeTree (zAVLTree *avltree, void (freeitem)(void *item));
extern int zAVLInsert (zAVLTree *avltree, void *item);
extern void *zAVLSearch (const zAVLTree *avltree, const char *key);
extern int zAVLDelete (zAVLTree *avltree, const char *key);
extern void *zAVLFirst (zAVLCursor *avlcursor, zAVLTree *avltree);
extern void *zAVLNext (zAVLCursor *avlcursor);


#endif
