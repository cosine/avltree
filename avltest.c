/*
 * avltest.c: Program to test the AVL Tree library.
 * Copyright (C) 2001, 2008  Michael H. Buselli
 * This is version 0.1.4 (alpha).
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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "gAVLTree.h"

#define BUFSIZE (256)


/* Function to return the argument */
const void *identity (void const *arg)
{
  return (const void *) arg;
}


/* Function to test iteration.  If check is non-zero, then we also call
 * AVLSearch and verify that we can find the item.
 */
void iterate_test (gAVLTree *avltree, const int check)
{
  int counter;
  char *item;
  char *checkout;
  gAVLCursor avlcursor;

  counter = 1;
  for (item = (char *) gAVLFirst(&avlcursor, avltree); item;
       item = (char *) gAVLNext(&avlcursor))
  {
    checkout = "";
    if (check && gAVLSearch(avltree, item))
      checkout = " Found";
    printf("%03d:%s [%s]\n", counter++, checkout, item);
  }
}


/* Function to test insert */
void insert_test (gAVLTree *avltree, char const *input)
{
  char *item;
  int rc;

  /* Allocate the memory for the string */
  item = strdup(input);
  assert(item);

  /* Do the insertion */
  rc = gAVLInsert(avltree, item);
  switch (rc) {
    case 0: puts("Inserted"); break;
    case -1: puts("Insert Failed"); break;
    case 3: puts("Duplicate Not Inserted"); break;
    default: printf("Unknown Error %d\n", rc);
  }
}


/* Function to delete an entry; also demonstrates search */
void delete_test (gAVLTree *avltree, char const *input)
{
  char *item;
  int rc;

  /* First locate the string so we can free() it later.  This wouldn't
   * be necessary if we don't need to free() the item.
   */
  item = (char *) gAVLSearch(avltree, input);
  if (!item) {
    puts("Not Found--Not Deleted");
    return;
  }

  /* Do the deletion.  Note that we pass the KEY not the ITEM to this
   * function.
   */
  rc = gAVLDelete(avltree, input);
  switch (rc) {
    case 0: puts("Deleted"); break;
    case -1: puts("Delete Failed"); break;
    default: printf("Unknown Error %d\n", rc);
  }
}


/* Main Program */
main ()
{
  char input[BUFSIZE];
  int rc;
  gAVLTree *avltree;

  avltree = gAVLAllocTree(identity, (gAVLCompare) strcmp);

  for (;;) {
    /* Print out a prompt. */
    fputs("> ", stdout);
    fflush(stdout);

    /* Get the users input */
    fgets(input, BUFSIZE - 1, stdin);
    input[BUFSIZE - 1] = '\0';

    /* Clip off the newline */
    rc = strlen(input);
    if (rc > 0 && input[rc - 1] == '\n')
      input[rc - 1] = '\0';

    /* Quit if necessary */
    if (!strcmp(input, "quit")) {
      gAVLFreeTree(avltree, free);
      exit(0);
    }

    /* Check for the iterate test */
    if (!strcmp(input, "list")) {
      iterate_test(avltree, 0);
    }

    /* Does a list but also runs AVLSearch on each node */
    else if (!strcmp(input, "test")) {
      iterate_test(avltree, 1);
    }

    /* Check for the deletion test */
    else if (!strncmp(input, "delete ", 7)) {
      delete_test(avltree, input + 7);
    }

    /* If we get down to here, we insert the string into the tree */
    else {
      insert_test(avltree, input);
    }
  }
}
