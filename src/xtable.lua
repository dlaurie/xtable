-- Lua part of module `xtable`

local X=require"xtable_core"
if type(X)~='table' then error(X) end

local B=X.block
local T=X.tuple
local select,           wrap,           yield =
      select, coroutine.wrap, coroutine.yield
local random,      abs,      max,      min =
 math.random, math.abs, math.max, math.min

-- Compatibility

B.move =  B.copy

-- Lua implementations of documented functions

local xsort
xsort = function (tbl,cmp,first,last)
  first, last = first or 1, last or #tbl
  if last<=first then return end
  local i,j = B.trisect(tbl,first,last,tbl[random(first,last)],cmp)
  xsort(tbl,cmp,first,i)
  xsort(tbl,cmp,j,last)
end  
X.sort = xsort

T.iter = function(...)
   local iter = wrap(
   function(...)
      local n=0
      repeat n=n+1 until not yield(select(n,...))
   end)
   iter(...)
   return iter
end

T.cache = function(...)
   local cache = wrap(function(...) repeat yield(...) until false end)
   cache(...)
   return cache
end

-- generate short help information

local topics = function (tbl,prefix)
   local t={}
   for k in pairs(tbl) do t[#t+1]=(prefix or '')..k end   
   table.sort(t)
   return table.concat(t,' ')
end

local shorthelp = table.concat({
'The following functions are officially documented : ',
'  '..topics(B,'block.'),'  '..topics(T,'tuple.'),
'Try "help(help)".',
},'\n')

--- The formally documented functions are not described again below,
-- although brief help is available via the interactive help system
-- available from  <https://github.com/dlaurie/lua-ihelp>.
-- If the module has been installed on your system, `xtable.help()`
-- gets you started, otherwise `xtable.help` contains the error message 
-- from `require`. 
--     
-- The informally documented functions (`B=xtable.block`) below are sample 
-- routines for the user to adapt. The comments are recognized by the 
-- interactive help system as well as by the
-- LDoc system <http://stevedonovan.github.com/ldoc> for automatically 
-- generating standalone documentation.
--
-- Nonstandard `table`-like functions go into the block submodule;
-- replacements of standard ones go into the main module.
--
-- Recommendation: `setmetatable(tbl,{__index=xtable.block})`

local get,   set,   move,   trisect
  = B.get, B.set, B.move, B.trisect
local cache,   map,   collect
  = T.cache, T.map, T.collect

---   concat(tbl,sep,first,last)  
-- standard: second argument is used as a separator if a number or a string  
-- extra: second argument is used as a filter if a function  
-- nonstandard: `sep`=`nil` defaults to `tostring`, not to the empty string   
-- extra: concatenation respects metamethods  
-- missing: elegant workaround for stack overflow  
B.concat = function(tbl,sep,first,last)
   first = first or 1
   last = last or #tbl
   if sep==nil or first>=last then 
      return collect(map(tostring,get(tbl,first,last))) 
   elseif type(sep)=='function' then 
      return collect(map(sep,get(tbl,first,last))) 
   end
   local t={tbl[1]}
   local len=#tbl
   for k=2,len do set(t,2*k-2,nil,sep,tbl[k]) end
   return collect(get(t,1,2*len-1))
end
   
---     insert(tbl,index,...)  
-- extra: multiple insert  
-- missing: parameter checks  
B.insert = function(tbl,index,...)
   local len=#tbl
   local count=select('#',...)
   if (count<1) then set(B,len+1,nil,index) return end
   move(tbl,index,len,index+count)
   set(tbl,index,nil,...)
end

---     remove(tbl,first,last)  
-- extra: multiple remove  
-- missing: parameter checks  
B.remove = function(tbl,first,last)
  local c=cache(get(tbl,first,last))
  first, last = min(first,last),max(first,last)+1 
  local len=#tbl
  move(tbl,last,len,first)
  set(tbl,len+first-last,len,nil)
  return c()
end

local sort
sort = function (tbl,cmp,first,last,p)
  if last<=first then return end
  local i,j = trisect(tbl,first,last,tbl[random(first,last)],cmp,p)
  sort(tbl,cmp,first,i,p)
  sort(p,nil,i+1,j-1,tbl)
  sort(tbl,cmp,j,last,p)
end  

---     sort(tbl,cmp,first,last)  
-- extra: stable sort  
-- extra: returns permutation  
-- extra: reverse the sort when `last<first`  
B.sort = function(tbl,cmp,first,last)
  first=first or 1; last=last or #tbl
  local invert=last<first
  if invert then 
    move(tbl,first,last,last,first); first,last=last,first;
  end
  local p={}; for k=first,last do p[k]=k end
  if last==first then return p end
  if invert then move(p,first,last,last,first) end
  sort(tbl,cmp,first,last,p)
  if invert then 
    move(tbl,first,last,last,first); move(p,first,last,last,first) 
    first,last=last,first;
  end
  return p
end

--- The interactive help system. 

local ok, help=pcall(require,"ihelp")
if ok then
help('bugs',nil)
help('customize',nil)
help('method',nil)
help('docstring',nil)

help(nil,shorthelp)
help('get',"get(tbl,a,b): return tbl[a:b]")
help('set',"set(tbl,a,b,...): tbl[a:b]=..., cyclically extended")
help('move',"move(tbl,a1,b1,a2,b2): tbl[a2:b2]=tbl[a1:b1]}") 
help('trisect',"i,j = trisect(tbl,a,b,v[,cmp[,tag]]]): <=a[i+1]=',=a[j-1]<=")
help('cache',"f=cache(...): f() returns original ...")
help('collect',"collect(...): concatenates ..., respecting metamethods")
help('iter',"in iter(...): iterates over ...")
help('keep',"keep(k,...): returns first k of ...")
help('map',"map(tf,...): applies table of function to ...")
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

X.help = help
return X

