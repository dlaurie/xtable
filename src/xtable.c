/* xtable.c      (c) 2012-2015 Dirk Laurie and John Hind 
      Enhanced version of the Lua table library
   Same license as Lua (c) 1994-2015 Lua.org, PUC-Rio
      from which much of the code has been borrowed anyway.

Install using LuaRocks, see INSTALL.
*/

/* Program design notes

Only a few building blocks are written in C and exported in the subtables 
`block` and `tuple`. The rest of the functionality is written in Lua. The 
existing table library is imported into the module table from C; the rest 
is defined in `xtable.lua`.
*/


#include <stdlib.h>
#include <time.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

/* For debugging. I've put these back too often to omit them altogether.
static void stackprint(lua_State *L, int from) {
   int top=lua_gettop(L);
   printf("Stack:");
   while (from<=top) {
     printf(" %s",luaL_tolstring(L,from++,NULL));
     lua_pop(L,1); }
   printf("\n");
}
static void arrayprint(lua_State *L, int from, int to) {
   printf("Array:");
   while (from<=to) { lua_rawgeti(L,1,from++); 
     printf(" %s",luaL_tolstring(L,-1,NULL)); 
     lua_pop(L,2); }
   printf("\n");
}
 */

#if LUA_VERSION_NUM < 502
#define lua_absindex(L,idx) (idx < 0 ? lua_gettop(L)+idx+1 : idx)
#define lua_compare(L,idx1,idx2,op) 0
#define LUAMOD_API LUALIB_API
#endif

#define store(tbl,item,idx) lua_pushvalue(L,item); lua_rawseti(L,1,idx)
#define move(a,from,to) lua_rawgeti(L,a,from); lua_rawseti(L,a,to)
#define swap(a,x,y) lua_rawgeti(L,a,x); lua_rawgeti(L,a,y); \
  lua_rawseti(L,a,x); lua_rawseti(L,a,y); 

/* block.get(tbl,a,b) */
static int block_get(lua_State *L) {
  int a=luaL_checkinteger(L,2), b=luaL_checkinteger(L,3), inc, count;
  luaL_checktype(L,1,LUA_TTABLE);
  inc = a<=b ? 1 : -1; 
  count = (b-a)*inc+1;
  lua_settop(L,1);
  if (!lua_checkstack(L,count)) luaL_error(
     L, "stack overflow: 'get' needs %d values",count);
  for(;;a+=inc) { lua_rawgeti(L,1,a); if(a==b) break; } 
  return count;
}

/* _block.set(tbl,a,b,...) */
static int block_set(lua_State *L) {
  int a=luaL_checkinteger(L,2), b, top=lua_gettop(L), count=top-3, 
      inc, item=4;
  luaL_checktype(L,1,LUA_TTABLE);
  b = (lua_isnoneornil(L,3)) ? a+count-1 : luaL_checkinteger(L,3);
  if (count<1) return 0;  
  inc = a<=b ? 1 : -1; 
  if (top==4) for(;;a+=inc) { store(tbl,top,a); if(a==b) break; }
  else for(;;a+=inc) { 
    if (item>top) item=4; 
    store(tbl,item++,a); 
    if(a==b) break; 
  }
  return 0;
}   

/* block.copy(tbl,a1,b1,a2[,b2]) */
static int block_copy(lua_State *L) {
  int a1=luaL_checkinteger(L,2), b1=luaL_checkinteger(L,3), 
      a2=luaL_checkinteger(L,4), b2, inc1, inc2;
  luaL_checktype(L,1,LUA_TTABLE);
  inc1 = a1<=b1 ? 1 : -1; 
  if (lua_isnoneornil(L,5)) { inc2=inc1; b2=a2+b1-a1; }
  else {
    b2=luaL_checkinteger(L,5);
    inc2 = a2<=b2 ? 1 : -1; 
    luaL_argcheck(L,(b1-a1)*inc1==(b2-a2)*inc2,5,
       "source and destination must have the same length");
  }
  lua_settop(L,1);
  if (inc1!=inc2) { /* reverse direction */
    for(;(a1-b2)*inc1<0;a1+=inc1,a2+=inc2) { move(1,a1,a2); }
    for(;(b1-a2)*inc1>0;b1-=inc1,b2-=inc2) { move(1,b1,b2); }
    for(;(a2-a1)*inc1>0;a1+=inc1,a2+=inc2) { swap(1,a1,a2); }  
  }
  else if ((a2-a1)*inc1<0) 
    for (;;a1+=inc1,a2+=inc2) { move(1,a1,a2); if (a1==b1) break; }
  else for (;;b1-=inc1,b2-=inc2) { move(1,b1,b2); if (a1==b1) break; }
  return 0;   
}
  
/* tuple.map(tbl,table_or_monadic_function,...) */
static void tuple_call(lua_State *L) {
  int i, top=lua_gettop(L);
  for (i=2; i<=top; i++) {
    lua_pushvalue(L,1); lua_pushvalue(L,i); lua_call(L,1,1); 
    lua_replace(L,i);
  }
}
static void tuple_index(lua_State *L) {
  int i, top=lua_gettop(L);
  for (i=2; i<=top; i++) {
    lua_pushvalue(L,i); lua_gettable(L,1); 
    lua_replace(L,i); 
  }
}
static int tuple_map(lua_State *L) {
  if (lua_type(L,1)==LUA_TFUNCTION) tuple_call(L);
  else if  (lua_type(L,1)==LUA_TTABLE) tuple_index(L);
  else return 0; 
  return lua_gettop(L)-1; 
}

/* tuple.concat(...) */
static int tuple_collect(lua_State *L) {
  lua_concat(L,lua_gettop(L));
  return 1;
}

/* tuple.keep(count,...) */
static int tuple_keep(lua_State *L) {
  int count=lua_absindex(L,luaL_checkinteger(L,1));
  lua_settop(L,count+1);
  return count;
}

/* block.trisect(tbl,l,r,v,cmp,tag) */
#define tbl 1
#define v 4
#define cmp 5
#define tag 6
#define ai 7
#if LUA_VERSION_NUM > 501 
#define lua_lessthan(L,i,j) lua_compare(L,i,j,LUA_OPLT)
#define lua_equal(L,i,j) lua_compare(L,i,j,LUA_OPEQ)
#else
#endif
#define precedes(i,j) (lua_isnoneornil(L,cmp)? lua_lessthan(L,i,j) : \
    (lua_pushvalue(L,cmp), lua_pushvalue(L,i), lua_pushvalue(L,j), \
    lua_call(L,2,1), test=lua_toboolean(L,-1), lua_pop(L,1), test))
static int block_trisect(lua_State *L) {
  int lo=luaL_checkinteger(L,2), hi=luaL_checkinteger(L,3),
    lt=lo, gt=hi, i=lo, test, hastag=!lua_isnoneornil(L,tag);  
  if (hi<=lo) return 0;
  luaL_checktype(L,tbl,LUA_TTABLE); 
  lua_settop(L,tag);
  luaL_argcheck(L,!lua_isnoneornil(L,v),v,"central value must be supplied");
  if (!lua_isnoneornil(L,cmp)) {
    luaL_checktype(L,cmp,LUA_TFUNCTION);
    luaL_argcheck(L,!precedes(v,v),cmp,
         "equal elements may not test out-of-order");
  }
  if (hastag) { 
    luaL_checktype(L,tag,LUA_TTABLE);
    luaL_argcheck(L,!lua_equal(L,tbl,tag),tag,
      "the tag table may not be the same as the main table"); }
/* The following code is based on `sort` from Quick3way.java, described 
   in the 4th edition of "Algorithms" by Robert Sedgewick. The Java code 
   is downloadable from <http://algs4.cs.princeton.edu/23quicksort>.
 */
  while (i<=gt) {
    lua_rawgeti(L,tbl,i);
    if (precedes(ai,v)) { 
      if (i>lt) { move(tbl,lt,i); 
        lua_rawseti(L,tbl,lt); 
        if (hastag) { swap(tag,i,lt); } }
      else lua_pop(L,1);
      lt++; i++; 
    }
    else if (precedes(v,ai)) { 
      if (i<gt) { move(tbl,gt,i); 
        lua_rawseti(L,tbl,gt); 
        if (hastag) { swap(tag,i,gt); } }
      else lua_pop(L,1);
      gt--;
    }
    else { lua_pop(L,1); i++; }
  }
  lua_pushinteger(L,lt-1); 
  lua_pushinteger(L,gt+1);
  return 2;
}

/* block library */
static const luaL_Reg block_funcs[] = {
  {"get", block_get},
  {"set", block_set},
  {"copy", block_copy},
  {"trisect",block_trisect},
  {NULL, NULL}
};

/* tuple library */
static const luaL_Reg tuple_funcs[] = {
  {"collect", tuple_collect},
  {"map", tuple_map},
  {"keep", tuple_keep},
  {NULL, NULL}
};

/* startup Lua code 
*/
char *xtable_init = 
"for k,v in pairs(table) do xtable_core[k]=v end "
"xtable_core=nil"
;

LUAMOD_API int luaopen_xtable_core (lua_State *L) {
  lua_createtable(L,8,0);
#if LUA_VERSION_NUM > 501
  luaL_newlib(L, block_funcs);
#else
  luaL_register(L, "xtable.block", block_funcs);
#endif
  lua_setfield(L,-2,"block");
#if LUA_VERSION_NUM > 501
  luaL_newlib(L, tuple_funcs);
#else
  luaL_register(L, "xtable.block", tuple_funcs);
#endif
  lua_setfield(L,-2,"tuple");
  lua_pushvalue(L,-1); lua_setglobal(L,"xtable_core"); 
  (void)luaL_dostring(L,xtable_init); 
  return 1;
}

