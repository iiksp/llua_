from sympy import *

fm3=lambda x:8*x**3+13*x**2+26*x+87
#fm3=lambda x:14*x**3+5*x**2+15*x+125#student

Mr=[0,16,186,236,249,191,177,166,248]
#Mr=[0,149, 213, 142, 66, 121, 143, 78, 242]#student 99844602


class bstream:
    def __init__(self,data):
        self.d=data
        self.i=0
        
    def readByte(self,n=None):
        if not n:
            assert(self.i < len(self.d))
            res=self.d[self.i]
            self.i+=1
            return res
        else:
            assert(self.i + n <= len(self.d))
            res=self.d[self.i:self.i+n]
            self.i+=n
            return res
        
    def readInt(self,):
        if self.i + 4 >= len(self.d):
            return -1
            
        res=0
        for i in range(4):
            b=self.readByte()
            res=res+(b<<(i*8))
        return res

        
def cal3eq(n):
    x=symbols('x')
    #eq=Eq(8*x**3+13*x**2+26*x+87,n)
    eq=Eq(fm3(x),n)
    return solve(eq,x)[0]

    
def gcd(a, b):  
    k = a // b  
    remainder = a % b  
    while remainder != 0:  
        a = b   
        b = remainder  
        k = a // b  
        remainder = a % b  
    return b  

def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)

def inv(a, m):
    g, x, y = egcd(a, m)
    if g != 1:
        raise Exception('modular inverse does not exist')
    else:
        return x % m
    
def exCRT(C):
    M=list(Mr)
    K=len(M)-1
    C=[0]+C
    flag=True
    
    i=2
    while i<=K:
        M1 = M[i - 1]
        M2 = M[i]
        C2 = C[i]
        C1 = C[i - 1]
        T = gcd(M1, M2)

        if (C2-C1)%T!=0:
            flag=False
            return 0,0
        else:
            M[i] = (M1*M2) / T
            C[i] = (inv(M1 / T, M2 / T) * (C2 - C1) / T) % (M2 / T) * M1 + C1
            C[i] = (C[i] % M[i] + M[i]) % M[i]
        i+=1

    return int(C[K]),int(M[K])

def caldw(c):
    n,m=exCRT(c)
    print(n,m)
    res=[]
    for i in range(3):
        res.append((n>>(i*8))&0xff)
    return res

def tolist(bs):
    res=[]
    while True:
        one=bs.readInt()
        #print('%x'%one)
        if one == -1:
            break
        else:
            res.append(cal3eq(one))
            two=bs.readByte(8)
            two=list(two)
            res=res+caldw(two)
    return res

def b64decode(bs):
    const='ld4LiOz3F0bpyCNgWQBkr6HahGM1f85ocJ9/VUeTEmwqDPIsuvnZYRKjX7+ASt2x'
    tb={}
    for i in range(len(const)):
        tb[const[i]]=i

    i=0
    res=b''
    while True:
        cur=bs[i:i+4]
        i+=4
        if i > len(bs):
            break

        rawb=[]
        for c in cur:
            rawb.append(tb[chr(c)])

        rawdw=0
        for n in range(4):
            rawdw=((rawb[n])<<(6*n))+rawdw

        resdw=0
        for n in range(3):
            x=(rawdw>>(n*8))&0xff
            xb=x.to_bytes(length=1,byteorder='big',signed=False)
            res+=xb

    return res
        

def testSociety():
    global fm3
    global Mr
    
    fm3=lambda x:8*x**3+13*x**2+26*x+87

    #Mr=[0,16,186,236,249,191,177,166,248]
    Mr=[0,38371,11829,16627,4017]

    return open('encrypted.ph','rb').read()

def testStu():
    global fm3
    global Mr
    fm3=lambda x:14*x**3+5*x**2+15*x+125#student
    Mr=[0,149, 213, 142, 66, 121, 143, 78, 242]#student 99844602

    return open('encrypted_stu.ph','rb').read()
    
if __name__ == '__main__':
    #bs=open('encrypted_stu.ph','rb').read()
    #bs=open('encrypted.ph','rb').read()
    
    bs=testSociety()
    #bs=testStu()
    bs=b64decode(bs)
    hs=bs.hex()
    i=0
    while i < len(hs):
        print(hs[i:i+8],hs[i+8:i+16],hs[i+16:i+24])
        i+=24
    
    bs=bstream(bs)

    res=tolist(bs)
    sres=''
    for i in res:
        sres+=chr(i)
    print(sres)
