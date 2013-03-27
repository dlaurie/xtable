xtable
======

Generic functions for table manipulation, at a lower level than the 
standard table library.

The project started as a drop-in replacement for the standard table 
library, incorporating a selection of extra features that have on 
occasion been requested on this list (e.g. multiple insert/remove; 
negative indices; list integrity maintenance). The authors gradually 
realized that no two Lua users can be made to agree on just which 
extra features are desirable, and moved to a model of C core functions 
with a Lua top layer.

The main reasons why the standard table library is fast, are:

  - table accessess are done by `lua_rawgeti` and `lua_rawseti`, 
    which directly call a C function with the indices already 
    available as C integers;
  - temporary values are kept on the stack;
  - loops are coded directly in C.

Accordingly, the `xtable` core C routines perform only tasks that exploit
these techniques. They do only minimal parameter checking and do not 
supply default table limits (neither 1 nor `#tbl`). The intention is
that users can easily implement their own add-ons directly in Lua.

The library contains two sublibraries: `xtable.block` and `xtable.tuple`. 

`xtable.block` is designed to be a suitable metatable for a table
that will be used mainly as an array. Every function has the same
first three arguments `tbl,a,b` and operates on the elements from
`tbl[a]` to `tbl[b]`, where decreasing keys are taken when `a>b`.
The functions `get`, `set`, `move` and `trisect` are provided in
the C core; `concat`, `insert`, `remove` and `sort`, which in various 
ways offer more than their namesakes from the standard library, are 
provided in the Lua top layer.

`xtable.tuple` is a suite of routines that take `...` arguments. The
functions `keep`, `map` and `collect` are provided in the C core;
`cache` and `iter` are provided in the Lua top layer. The aim is to
provide not full tuple support, but merely some essential services for
routines that are based on the block routines.

The library is released under the same license as Lua.
