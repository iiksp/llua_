local bs = require('bcstream')
local Stack = require('stack')
local bit = require('bit')
dofile('arith.lua')


function file2array(fn)
	local fileName = fn
	local file = assert(io.open(fileName, 'rb'))
	local t = {}
	repeat
	   local str = file:read(4*1024)
	   for c in (str or ''):gmatch'.' do
		  t[#t+1] = c
	   end
	until not str
	file:close()
	return t
end

function str2array(s)
	local t={}

	for c in (s or ''):gmatch'.' do
		t[#t+1]=c
	end

	return t
end

function dump_table(root, n)
    if n > 5 then
        return ""
    end
    n = n + 1
    if type(root) == "table" then
        local s = "{ "
		local entrys=0
        for k,v in pairs(root) do
			entrys = entrys + 1
            if type(k) ~= "number" then
                k = "\"" .. k .. "\""
            end
			
			if root == v then
				s = s .. "[" .. k .. "] = __self,"
			elseif entrys<30 then
				s = s .. "[" .. k .. "] = " .. dump_table(v, n) .. ","
			else
				s = s .. "[" .. k .. "] = ...,"
			end
        end
        return s .. "} "
    elseif type(root) == "string" then
        return "\"" .. root .. "\""
    else
        return tostring(root)
    end
end

function dumpTable(root)
	return dump_table(root,1)
end

function genBinOp(op,name)
	f=
	function(self)
		local a,b=self.stack:pop(2)
		self.stack:push(op(b,a))
		--LOG('%s %d %d',name,b,a)
	end
	return f
end

function LOG(fmt,...)
	LOGPH(fmt,...)
end

function LOGPH(fmt,...)
    if type(fmt)~='string' then
        print(fmt,...)
	elseif select("#",...) == 0 then
		print(fmt)
    else
        print(fmt:format(...))
    end
end

plainBs=nil
encryptBs=nil
function getByte()
	local b,isok=plainBs:readByte()
	if not isok then
		return 0
	else
		return b
	end
end

stringsub=string.sub
lshift=bit.lshift
rshift=bit.rshift
band=bit.band
bor=bit.bor

function dw2Byte(dw,out)
	local res=out or {}
	res[#res+1]=bit.band(bit.rshift(dw,8*0),0xff)
	res[#res+1]=bit.band(bit.rshift(dw,8*1),0xff)
	res[#res+1]=bit.band(bit.rshift(dw,8*2),0xff)
	res[#res+1]=bit.band(bit.rshift(dw,8*3),0xff)
	return res
end

function putDword(dw)
	encryptBs = encryptBs or {}
	dw2Byte(dw,encryptBs)
	----LOG("%s",dumpTable(encryptBs))
end

function putByte(b)
	encryptBs = encryptBs or {}
	encryptBs[#encryptBs+1]=b
	----LOG("%s",dumpTable(encryptBs))
end

function saveEncrypt(fn)
	local f=io.open(fn,'wb')
	for k,v in pairs(encryptBs) do
		if type(v) == type(1) then
			f:write(string.char(v))
		else
			f:write(v)
		end
	end
end

PUSHN=0
PUSHV=1
SET=2
ADD=3
MINUS=4
MUL=5
DIV=6
MOD=7
UMINUS=8
BNE=9
GT=10
LT=11
GE=12
LE=13
NE=14
EQ=15
CALL=16
PUSHS=17

vm={}
op_func={}
vm.opf=op_func

function vm:new(bs,env)
	o={}
	setmetatable(o,self)
	self.__index=self
	o.bs=bs
	o.stack=Stack:new()
	o.env=env or {}
    setmetatable(o.env,_G)
    _G.__index=_G
	return o
end

function vm:exe()
	while true do
		local op,isok = self.bs:readByte()
        if not isok then break end
        
		--LOG(dumpTable(self.stack))
		--LOG("pos:%d op:%d",self.bs:bPos(),op)
		self.opf[op](self)
	end
    --LOG("finish running.")
end

function vm:pushn()
	local n=self.bs:readInt()
	--LOG('pushn ' .. n)
	self.stack:push(n)
end


function vm:pushv()
	local s=self.bs:readStr()
	--LOG('pushv '.. s)
	self.stack:push(self.env[s])
end


function vm:pushs()
	local s=self.bs:readStr()
	--LOG('pushs '.. s)
	self.stack:push(s)
end


function vm:set()
	local s=self.bs:readStr()
	local n=self.stack:pop()
	--LOG('set %s = %s',s,n)
	self.env[s]=n
end


function vm:add()
	local a,b=self.stack:pop(2)
	self.stack:push(a+b)
	--LOG("add %d %d",a,b)
end


function vm:minus()
	local a,b=self.stack:pop(2)
	self.stack:push(b-a)
	--LOG("minus %d - %d",b,a)
end


function vm:mul()
	local a,b=self.stack:pop(2)
	self.stack:push(a*b)
	--LOG("mul %d %d",a,b)
end


function vm:div()
	local a,b=self.stack:pop(2)
	self.stack:push(b/a)
	--LOG("div %d %d",b,a)
end


function vm:uminus()
    local a=self.stack:pop()
    self.stack:push(-a)
    --LOG('uminus %d',a)
end

function vm:bne()
	local cond=self.stack:pop()
	local offset=self.bs:readInt()
	if not cond or cond == 0 then
		self.bs:move(offset)
	end
	----LOG("BNE %s %d",cond,offset)
end

function vm:call()
    local fn=self.bs:readStr()
    local func=self.env[fn]
    if type(func) == 'function' then
        argsn=self.stack:pop()
        args={}
        for i=1,argsn,1 do
            args[#args+1]=self.stack:pop()
        end
		----LOG("call %s %s",fn,dumpTable(args))
        res=func(unpack(args))
		self.stack:push(res)
    end
end

op_func[CALL]=vm.call
op_func[BNE]=vm.bne
op_func[PUSHN]=vm.pushn
op_func[PUSHV]=vm.pushv
op_func[PUSHS]=vm.pushs
op_func[SET]=vm.set
op_func[ADD]=vm.add
op_func[MINUS]=vm.minus
op_func[MUL]=vm.mul
op_func[DIV]=vm.div
op_func[UMINUS]=vm.uminus

op_func[MOD]=genBinOp(OP_MOD,'MOD')
op_func[EQ]=genBinOp(OP_EQ,'EQ')
op_func[NE]=genBinOp(OP_NE,'NE')
op_func[LE]=genBinOp(OP_LE,'LE')
op_func[GE]=genBinOp(OP_GE,'GE')
op_func[LT]=genBinOp(OP_LT,'LT')
op_func[GT]=genBinOp(OP_GT,'GT')


function check(pt)
	--s=file2array('hashtest.txt')
	
	
	s=str2array(pt)
	plainBs=bs:new(s)

	--s=file2array('out.l')
	s=require('bcpunkHash')
	----LOG("%s",dumpTable(s))
	bss=bs:new(s)
	lvm=vm:new(bss)
	lvm:exe()
	
	--saveEncrypt('encrypted.ph')
	dstRes='goodlucku+YcR7i/a5LdllcHiLzoNdzenDtUlllcrC9pgM3cnpOslcccF71/CcdujFOLlXceIwmlZmm3TbtilyWJ1pO/cH+u3SPblccdVAYlZXiu3SPblhlONJGP09mZnqpilFci25EUFQ/i3SPblfuMq+mQRDY7eGYOlFc9b8BPgET9nqpilWl4F4OCCdOJ3SPblWlQiQiQiQiQ'
	for k,v in pairs(encryptBs) do
		if v ~= string.sub(dstRes,k,k) then
			LOGPH("fail!")
			return false
		end
		if k == string.len(dstRes) then
			LOGPH("success")
			return true
		end
	end
end

-- plainText='$llo punk hash....BE6CA4F8B4FFC032D5F7829BB33D21FD'
-- check(plainText)