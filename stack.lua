Stack={}

function Stack:new()
	local o = {}
	setmetatable(o,self)
	self.__index=self
	o.stack={}
	return o
end

function Stack:push(item)
	table.insert(self.stack,item)
end

function Stack:pop(n)
	local n=n or 1;
	local res={}
	
	for i=1,n,1 do
		res[#res+1]=table.remove(self.stack,#self.stack)
	end
	
	return unpack(res)
end 

return Stack