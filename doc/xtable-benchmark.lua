-- run as 'lua xtable-benchmark.lua 100000' etc.

X=require"xtable"
B=X.block
T=X.tuple

function sorted(a,cmp,l,r)
   l, r = l or 1, r or #a
   if cmp then for k=l,r-1 do if cmp(a[k+1],a[k]) then return false end end
   else for k=l,r-1 do if a[k+1]<a[k] then return false end end end
   return true
end

function cmp1(a,b) return a[1]<b[1] end
function cmp2(a,b) return a[2]<b[2] end

function sorttest(a,cmp1,cmp2)
--- sorts a by cmp1 using three methods.
-- if cmp2 is given, tests whether a is sorted by cmp2 and whether
-- this ordering is preserved for equals under cmp1   
   local sorted2 = cmp2 and sorted(a,cmp2)
   local cmp = function(x,y)
      return cmp1(x,y) or not cmp1(y,x) and cmp2(x,y)
   end
   local b=setmetatable({},{__index=B,__tostring=B.concat})
   local function test(method,name)
      for k=1,#a do b[k]=a[k] end
      tic=os.clock(); method(b,cmp1); tic=os.clock()-tic
      if sorted(b,cmp1) then 
         io.write((name..": %.2f seconds"):format(tic,#a))
         if sorted2 then if sorted(b,cmp)
            then print   (" and seems stable :-))")
            else print (" but is unstable :-(")  
         end 
         else print''
      end
      else print(name.." did not sort correctly :(((")
      end
   end
   ------
   test(table.sort,'table.sort')   
   test(B.sort,"block.sort")
   test(X.sort,'xtable.sort')
end

local ceil, random, sqrt = math.ceil, math.random, math.sqrt

nmax = arg[1] or 10
nmax = 20 * math.ceil(nmax/20)
swaps = math.ceil(math.sqrt(nmax))

M={__tostring = function(t) return '('..table.concat(t,':')..')' end}
a=setmetatable({},{__index=B,__tostring=B.concat})

print (("== test on %d duples with 20 distinct values"):format(nmax))
for k=1,nmax do a[k]=setmetatable({k,(59*k)%20},M) end
sorttest(a,cmp2,cmp1)

print (("== test on %d duples with approximately 20 equals of every value"):
   format(nmax))
for k=1,nmax do a[k]=setmetatable({k,(59*k)%(nmax%20)},M) end
sorttest(a,cmp2,cmp1)

print (("== test on %d random elements"):format(nmax))
for k=1,nmax do a[k]=random(k) end
sorttest(a)

print (("== test on %d sorted elements with %d random swaps"):
  format(nmax,swaps))
for k=1,nmax do a[k]=k end
for k=1,swaps do 
   local i,j = random(nmax), random(nmax)
   a[i],a[j] = a[j],a[i]
end
sorttest(a)

