raw='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
raw=list(raw)

import random
res=[]
while len(res)<len(raw):
    i=random.randint(0,len(raw)-1)
    if raw[i] == '$$':
            continue
    else:
            res.append(raw[i])
            raw[i]='$$'

gs='goodluck'
gl=[15, 31, 31, 1, 0, 48, 32, 19]
for n,s in zip(gl,gs):
    n2=[i for i in range(len(res)) if res[i] == s][0]
    save=res[n]
    if n == n2:
            continue
    res[n]=s
    res[n2]=save

sres=''
for i in res:
    sres+=i

print(sres)
