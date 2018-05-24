import random

def primes(n):
    primfac = []
    d = 2
    while d*d <= n:
        while (n % d) == 0:
            primfac.append(d)  # supposing you want multiple factors repeated
            n //= d
        d += 1
    if n > 1:
       primfac.append(n)
    return primfac

def findMod(item=256*256):
    ok=False
    while True:
        n=random.randint(1<<48,1<<52)
        pl=primes(n)

        isok=len([i for i in pl if i>item]) == 0

        #no p^k > item
        last=0
        remain=1
        for i in pl:
            if last != i:
                last=i
                remain=i
            else:
                remain=remain*i
                if remain>item:
                    isok=False
                    break

        if isok:
            for i in pl:
                print(i)
            return n


if __name__ == '__main__':
    print(findMod())
    #construct the mod list.
    #make a new m == m1*m2%(m1,m2)
    #as you can see every m is a factor of n
    #and m can represent by some primes.
    #but you have to ensure their is a m consists of most prime.

    
