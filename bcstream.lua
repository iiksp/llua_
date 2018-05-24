bs={}
local bit=require('bit')
local lshift=bit.lshift

function bs:new(data)
	o={}
	o.data=data or {}
	
	if type(data[1]) == 'number' then
		t={}
		for k,v in pairs(data) do
			t[#t+1]=string.char(v)
		end
		o.data=t
	end
	
	o.i=1
	o.length=#data
	setmetatable(o,self)
	self.__index=self
	return o
end

function bs:move(step)
	if self.i + step > self.length + 1 then
		return false
	elseif self.i + step < 1 then
		return false
	else
		self.i = self.i + step
		return true
	end
end

function bs:pop(n)
	local t,isok=self:pop_raw(n)
	local res={}
	for k,v in pairs(t) do
		res[#res+1]=string.byte(v,1)
	end
	return res,isok
end

function bs:pop_raw(n)
	local t={unpack(self.data,self.i,self.i+n-1)}
	local isok=self:move(n)
	return t,isok
end

function bs:readByte()
	local t,isok = self:pop(1)
	return t[1],isok
end

function bs:readInt()
	local res=0
	local t=self:pop(4)
	for k,v in pairs(t) do res=res+lshift(v,8*(k-1)) end
    
    if res > 2^31 then
        res=res+2^31
        res=res%2^32
        res=res-2^31
    end
    
	return res
end

function bs:readStr()
	local res=''
	local size=self:readInt()
	--print("bs readStr size: " .. size)
	local t=self:pop_raw(size)
	
	for k,v in pairs(t) do res=res .. v end
	
	return res
end

function bs:bPos()
    return self.i-1
end

return bs
		
	