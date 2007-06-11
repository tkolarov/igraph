/* -*- mode: C -*-  */
/* 
   IGraph library.
   Copyright (C) 2003, 2004, 2005  Gabor Csardi <csardi@rmki.kfki.hu>
   MTA RMKI, Konkoly-Thege Miklos st. 29-33, Budapest 1121, Hungary
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 
   02110-1301 USA

*/

#include "types.h"
#include "memory.h"
#include "random.h"
#include "error.h"

#include <assert.h>
#include <string.h> 		/* memcpy & co. */
#include <stdlib.h>

/**
 * \ingroup stack
 * \brief Initializes a stack (constructor).
 *
 * @return Error code:
 *         - <b>IGRAPH_ENOMEM</b>: out of memory
 */

int FUNCTION(igraph_stack,init)       (TYPE(igraph_stack)* s, long int size) {
        long int alloc_size= size > 0 ? size : 1;
	assert (s != NULL);
	if (size < 0) { size=0; }
	s->stor_begin=Calloc(alloc_size, BASE);
	if (s->stor_begin==0) {
	  IGRAPH_ERROR("stack init failed", IGRAPH_ENOMEM);
	}
	s->stor_end=s->stor_begin + alloc_size;
	s->end=s->stor_begin;
	
	return 0;
}

/**
 * \ingroup stack
 * \brief Destroys a stack object.
 */

void FUNCTION(igraph_stack,destroy)    (TYPE(igraph_stack)* s) {
  assert( s != NULL);
  if (s->stor_begin != 0) {
    Free(s->stor_begin);
    s->stor_begin=NULL;
  }
}

/**
 * \ingroup stack
 * \brief Reserves memory for a stack object.
 *
 * @return Error code:
 *         - <b>IGRAPH_ENOMEM</b>: out of memory
 */

int FUNCTION(igraph_stack,reserve)    (TYPE(igraph_stack)* s, long int size) {
  long int actual_size=FUNCTION(igraph_stack,size)(s);
  BASE *tmp;
  assert(s != NULL);
  assert(s->stor_begin != NULL);
  
  if (size <= actual_size) { return 0; }
  
  tmp=Realloc(s->stor_begin, size, BASE);
  if (tmp==0) {
    IGRAPH_ERROR("stack reserve failed", IGRAPH_ENOMEM);
  }
  s->stor_begin=tmp; 
  s->stor_end=s->stor_begin + size;
  s->end=s->stor_begin+actual_size;
  
  return 0;
}

/**
 * \ingroup stack
 * \brief Decides whether a stack object is empty.
 */

igraph_bool_t FUNCTION(igraph_stack,empty)      (TYPE(igraph_stack)* s) {
	assert (s != NULL);
	assert (s->stor_begin != NULL);
	assert (s->end != NULL);
	return s->stor_begin == s->end;
}

/**
 * \ingroup stack
 * \brief Returns the number of elements in a stack.
 */

long int FUNCTION(igraph_stack,size)       (TYPE(igraph_stack)* s) {
	assert (s != NULL);
	assert (s->stor_begin != NULL);
	return s->end - s->stor_begin;
}

/**
 * \ingroup stack
 * \brief Removes all elements from a stack.
 */

void FUNCTION(igraph_stack,clear)      (TYPE(igraph_stack)* s) {
	assert (s != NULL);
	assert (s->stor_begin != NULL);
	s->end = s->stor_begin;
}

/**
 * \ingroup stack
 * \brief Places an element on the top of a stack.
 *
 * @return Error code:
 *         - <b>IGRAPH_ENOMEM</b>: out of memory
 */

int FUNCTION(igraph_stack,push)(TYPE(igraph_stack)* s, BASE elem) {
	assert (s != NULL);
	assert (s->stor_begin != NULL);
	if (s->end == s->stor_end) {
		/* full, allocate more storage */
		
	        BASE *bigger=NULL, *old=s->stor_begin;
		
		bigger = Calloc(2*FUNCTION(igraph_stack,size)(s)+1, BASE);
		if (bigger==0) {
		  IGRAPH_ERROR("stack push failed", IGRAPH_ENOMEM);
		}
		memcpy(bigger, s->stor_begin, 
		       FUNCTION(igraph_stack,size)(s)*sizeof(BASE));

		s->end        = bigger + (s->stor_end - s->stor_begin);
		s->stor_end   = bigger + 2*(s->stor_end - s->stor_begin)+1;
		s->stor_begin = bigger;
		
		*(s->end) = elem;
		(s->end) += 1;

		Free(old);
	} else {
		*(s->end) = elem;
		(s->end) += 1;
	}
	return 0;
}

/**
 * \ingroup stack
 * \brief Removes and returns an element from the top of a stack.
 */

BASE FUNCTION(igraph_stack,pop)        (TYPE(igraph_stack)* s) {

	assert (s != NULL);
	assert (s->stor_begin != NULL);
	assert (s->end != NULL);
	assert (s->end != s->stor_begin);
		
	(s->end)--;
	
	return *(s->end);
}

/**
 * \ingroup stack
 * \brief Returns an element from the top of a stack.
 */

BASE FUNCTION(igraph_stack,top)        (const TYPE(igraph_stack)* s) {

	assert (s != NULL);
	assert (s->stor_begin != NULL);
	assert (s->end != NULL);
	assert (s->end != s->stor_begin);

	return *(s->end-1);
}
