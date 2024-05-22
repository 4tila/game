from random import randint
N=320
with open('map', 'r') as f: inst = f.read().split('\n')
inst.pop(-1)
mapname = inst.pop(0)
width = int(inst.pop(0))
M = [['30' if ((i+j)%2)==0 else '100' for j in range(N)] for i in range(width)]
for e in inst:
    a, b, c, d = tuple(map(int, e.split()))
    if a==c:
        b, d = (b, d) if b<d else (d, b)
        for i in range(b, d): M[min(i, width-1)][min(a, N-1)]='1'
    if b==d:
        a, c = (a, c) if a<c else (c, a)
        for i in range(a, c): M[min(b, width-1)][min(i, N-1)]='1'
s=mapname+":           .byte "
for i in range(width): s+=','.join(M[i])+',\n'
print(s[0:-2])
