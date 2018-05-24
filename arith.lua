

OP_EQ=function(a,b) return a==b end
OP_NE=function(a,b) return not (a==b) end
OP_LE=function(a,b) return a<=b end
OP_GE=function(a,b) return a>=b end
OP_LT=function(a,b) return a<b end
OP_GT=function(a,b) return a>b end


OP_ADD=function(a,b) return a+b end
OP_MINUS=function(a,b) return b-a end
OP_MUL=function(a,b) return a*b end


function OP_DIV(a,b)
	c=newn()
	d=newn()
	div(a,b,c,d)
	return c
end

--OP_MOD=function(a,b) return a%b end

function OP_MOD(a,b)
	c=newn()
	d=newn()
	div(a,b,c,d)
	return d
end

--lshift=bit.lshift
-- rshift=bit.rshift
-- band=bit.band
--bor=bit.bor

function rshift(n,i)
	m=bexp(2,i)
	d=newn()
	r=newn()
	div(n,m,d,r)
	return d
end

function band(a,b)
	c=newn()
	d=newn()
	div(a,b+newn(1),c,d)
	return d
end
