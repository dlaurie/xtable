package.path = "./?.lua"
package.cpath = "./?.so"
X = require "xtable"
B = X.block
T = X.tuple

block = function(tbl) 
  return setmetatable(tbl,
{ __index=B,
  __tostring = function(tbl) return '{'..B.concat(tbl,',')..'}' end 
}) 
end

print("Module 'xtable' for ".._VERSION)
print"  reverse sort demo"
a=block{1,2,4,3,5,4,6,7,4,8,9,4}
print("tbl:",a)
p=block(a:sort(nil,12,1))
print("sorted:",a)
print("index:",p)

function sieve(nmax)
   local x={}
   for k=2,nmax do x[k]=k end
   for k=2,math.sqrt(nmax) do
      for j=2*k,nmax,k do x[j]=nil
   end end
   local p={}
   for k=2,nmax do p[#p+1]=x[k] end
   return p
end

testcase = function(nmax)
   local primes=sieve(nmax)
   a=block{}; for k,p in pairs(primes) do a[k]=block{p%17,p} end
   getmetatable(a).__tostring = B.concat
   return a
end

local a

cmp=function(x,y) return x[1]<y[1] end

print"  stable sort demo (watch second element of pair)"

a=testcase(100)
X.sort(a,cmp)
print("table.sort:",a)

a=testcase(100)
a:sort(cmp)
print("block.sort:",a)


