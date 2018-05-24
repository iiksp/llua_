from hashlib import *

fnl=[r'vm\vm.lua',r'vm\arith.lua']
fnl=[r'vm\total.lua']
castFile='obfCast.txt'

todol=['PUSHN', 'PUSHV', 'SET', 'ADD', 'MINUS', 'MUL', 'DIV', 'MOD', 'UMINUS', 'BNE', 'GT', 'LT', 'GE', 'LE', 'NE', 'EQ', 'CALL', 'PUSHS']
todol=todol+['pushn', 'pushv', 'pushs', 'add', 'minus', 'mul', 'div', 'uminus', 'bne', 'call']
md5hash=md5()
resl={}

def obfVar(s):
    md5hash.update(s.encode('utf-8'))
    mres=md5hash.hexdigest()
    for i in range(len(mres)):
        if not mres[i].isdigit():
            tres=mres[i:i+8]
            if not tres in resl:
                resl[s]=tres
                return tres


def obfFile(fn):
    out=fn+'obf'
    d=open(fn,'rb').read()
    for i in todol:
        newv=resl[i]
        newv=newv.encode('ascii')
        ib=i.encode('ascii')
        d=d.replace(bytes(ib),bytes(newv))

    open(out,'wb').write(d)


if __name__ == '__main__':
    #init map
    for i in todol:
        resl[i]=obfVar(i)

    #do file list
    for fn in fnl:
        obfFile(fn)

    #save map 
    wf=open(castFile,'w')
    for k,v in resl.items():
        wf.write('%-10s => %s \n'%(k,v))
    wf.close()

    
    
